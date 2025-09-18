import ActivityKit
import NitroModules
import AlarmKit

@available(iOS 26.0, *)
func convertAuthStatus(_ status: AlarmManager.AuthorizationState) -> AuthStatus {
    switch status {
    case .authorized:
        return .authorized
    case .denied:
        return .denied
    case .notDetermined:
        return .notdetermined
    @unknown default:
        return .notdetermined
    }
}

@available(iOS 26.0, *)
func convertAlarmState(_ status: Alarm.State) -> AlarmState {
    switch status {
    case .alerting:
        return .alerting
    case .countdown:
        return .countdown
    case .paused:
        return .paused
    case .scheduled:
        return .scheduled
    @unknown default:
        fatalError("unknown alarm state")
    }
}

func getAnyMapValue(_ anyMap: AnyMap, key: String) -> Any? {
    if anyMap.isBool(key: key) {
        return anyMap.getBoolean(key: key)
    }
    if anyMap.isArray(key: key) {
        return anyMap.getArray(key: key)
    }
    if anyMap.isDouble(key: key) {
        return anyMap.getDouble(key: key)
    }
    if anyMap.isObject(key: key) {
        return anyMap.getObject(key: key)
    }
    if anyMap.isString(key: key) {
        return anyMap.getString(key: key)
    }
    if anyMap.isBigInt(key: key) {
        return anyMap.getBigInt(key: key)
    }
    if anyMap.isNull(key: key) {
        return nil
    }
    return nil
}

func anyMapToDictionary(_ anyMap: AnyMap) -> [String: Any] {
    var dict = [String: Any]()
    anyMap.getAllKeys().forEach { key in
        dict[key] = getAnyMapValue(anyMap, key: key)
    }
    return dict
}

func serializeAnyMap(_ metadata: [String: Any]?) -> AnyMap {
    let serialized = AnyMap()
    if let m = metadata {
        for item in m {
            if let bool = item.value as? Bool {
                serialized.setBoolean(key: item.key, value: bool)
            }

            if let str = item.value as? String {
                serialized.setString(key: item.key, value: str)
            }

            if let double = item.value as? Double {
                serialized.setDouble(key: item.key, value: double)
            }

            if let integer = item.value as? Int64 {
                serialized.setBigInt(key: item.key, value: integer)
            }

            if let dict = item.value as? [String: AnyValue] {
                serialized.setObject(key: item.key, value: dict)
            }
        }
    }
    return serialized
}

@available(iOS 16.1, *)
func serializeContentState(contentState: GenericDictionaryStruct) throws -> AnyMap {
    let encoder = JSONEncoder()

    let encodedData = try encoder.encode(contentState)
    if let jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] {
        return serializeAnyMap(jsonObject)
    }

    return AnyMap()
}

@available(iOS 16.1, *)
func convertActivityState(_ activityState: ActivityKit.ActivityState) -> ActivityState {
    switch activityState {
    case .active:
        return .active
    case .dismissed:
        return .dismissed
    case .ended:
        return .ended
    case .stale:
        return .stale
    default:
        return .none
    }
}

func parsePushToken(_ token: Data?) -> String? {
    if let token = token {
        return token.map { String(format: "%02x", $0) }.joined()
    }
    return nil
}
