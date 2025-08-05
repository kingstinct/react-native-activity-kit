import ActivityKit
import NitroModules

struct AnyHashableValue: Hashable {
    private let value: AnyHashable

    init?<T>(_ value: T) {
        guard let hashable = value as? AnyHashable else {
            return nil
        }
        self.value = hashable
    }

    static func ==(lhs: AnyHashableValue, rhs: AnyHashableValue) -> Bool {
        return lhs.value == rhs.value
    }

    func hash(into hasher: inout Hasher) {
        value.hash(into: &hasher)
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

struct HashableDict: Hashable {
    let dict: [String: AnyHashableValue]

    init?(_ original: [String: Any]) {
        var newDict: [String: AnyHashableValue] = [:]
        for (key, value) in original {
            guard let hashableValue = AnyHashableValue(value) else {
                return nil // fail if any value is not Hashable
            }
            newDict[key] = hashableValue
        }
        self.dict = newDict
    }

    func hash(into hasher: inout Hasher) {
        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            hasher.combine(key)
            hasher.combine(value)
        }
    }

    static func == (lhs: HashableDict, rhs: HashableDict) -> Bool {
        lhs.dict == rhs.dict
    }
}

enum CodableValue: Codable, Hashable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case null
    case array([CodableValue])
    case dictionary([String: CodableValue])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self = .null
        } else if let val = try? container.decode(Bool.self) {
            self = .bool(val)
        } else if let val = try? container.decode(Int.self) {
            self = .int(val)
        } else if let val = try? container.decode(Double.self) {
            self = .double(val)
        } else if let val = try? container.decode(String.self) {
            self = .string(val)
        } else if let val = try? container.decode([CodableValue].self) {
            self = .array(val)
        } else if let val = try? container.decode([String: CodableValue].self) {
            self = .dictionary(val)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported value in CodableValue"
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let val): try container.encode(val)
        case .int(let val): try container.encode(val)
        case .double(let val): try container.encode(val)
        case .bool(let val): try container.encode(val)
        case .null: try container.encodeNil()
        case .array(let val): try container.encode(val)
        case .dictionary(let val): try container.encode(val)
        }
    }
}

func convertToCodableValue(_ value: Any) -> CodableValue? {
    switch value {
    case let v as String: return .string(v)
    case let v as Int: return .int(v)
    case let v as Double: return .double(v)
    case let v as Bool: return .bool(v)
    case _ as NSNull: return .null
    case let v as [Any]:
        let array = v.compactMap { convertToCodableValue($0) }
        return .array(array)
    case let v as [String: Any]:
        var dict: [String: CodableValue] = [:]
        for (key, value) in v {
            if let val = convertToCodableValue(value) {
                dict[key] = val
            }
        }
        return .dictionary(dict)
    default:
        return nil
    }
}

class GenericDictionary : Codable, Hashable {
    var codable: CodableValue?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(codable?.hashValue)
    }
    
    static func == (lhs: GenericDictionary, rhs: GenericDictionary) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.codable = try container.decode(CodableValue.self)
        
    }
    
    public init(state: AnyMap) throws {
        self.codable = convertToCodableValue(anyMapToDictionary(state))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codable)
    }
}

struct GenericDictionaryStruct : Codable, Hashable {
    var codable: CodableValue?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(codable?.hashValue)
    }
    
    static func == (lhs: GenericDictionaryStruct, rhs: GenericDictionaryStruct) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.codable = try container.decode(CodableValue.self)
        
    }
    
    public init(data: AnyMap) throws {
        self.codable = convertToCodableValue(anyMapToDictionary(data))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codable)
    }
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
func serializeAttributes(data: GenericDictionary) throws -> AnyMap {
    let encoder = JSONEncoder()
    
    let encodedData = try encoder.encode(data)
    if let jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] {
        return serializeAnyMap(jsonObject)
    }
    
    return AnyMap()
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

@available(iOS 16.1, *)
class ActivityProxy : HybridActivityProxySpec {
    func subscribeToActivityStateUpdates(callback: @escaping (ActivityState) -> Void) throws {
        Task {
            for await activityState in activity.activityStateUpdates {
                callback(convertActivityState(activityState))
            }
        }
    }
    
    func subscribeToPushTokenUpdates(callback: @escaping (String) -> Void) throws {
        Task {
            for await pushToken in activity.pushTokenUpdates {
                if let tokenString = parsePushToken(pushToken) {
                    callback(tokenString)
                }
            }
        }
    }
    
    func subscribeToStateUpdates(callback: @escaping (ActivityStateUpdate) -> Void) throws {
        Task {
            if #available(iOS 16.2, *) {
                for await content in activity.contentUpdates {
                    callback(
                        ActivityStateUpdate(
                            state: try serializeContentState(contentState: content.state),
                            staleDate: content.staleDate,
                            relevanceScore: content.relevanceScore
                        ))
                }
            } else {
                for await contentState in activity.contentStateUpdates {
                    callback(ActivityStateUpdate(
                        state: try serializeContentState(contentState: contentState),
                        staleDate: nil,
                        relevanceScore: nil
                    ))
                }
            }
        }
    }
    
    // Swift
    var attributes: AnyMap {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(activity.attributes)
            if let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                return serializeAnyMap(jsonObject)
            }
        } catch {
            // Handle error if needed
        }
        return AnyMap()
    }
    
    var state: AnyMap {
        do {
            let encoder = JSONEncoder()
            var data: GenericDictionaryStruct
            if #available(iOS 16.2, *) {
                data = activity.content.state
            } else {
                data = activity.contentState
            }
            
            let encodedData = try encoder.encode(data)
            if let jsonObject = try JSONSerialization.jsonObject(with: encodedData) as? [String: Any] {
                return serializeAnyMap(jsonObject)
            }
        } catch {
            // Handle error if needed
        }
        return AnyMap()
    }
    
    var relevanceScore: Double? {
        if #available(iOS 16.2, *) {
            return activity.content.relevanceScore
        } else {
            return nil
        }
    }
    
    var staleDate: Date? {
        if #available(iOS 16.2, *) {
            return activity.content.staleDate
        } else {
            return nil
        }
    }
    
    var activityState: ActivityState {
        switch activity.activityState {
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
    
    func update(state: AnyMap, options: UpdateOptions?) throws -> Void {
        Task {
            let contentState = try ActivityKitModuleAttributes.ContentState(data: state)
            
            var alertConfiguration: ActivityKit.AlertConfiguration? = nil
            if let config = options?.alertConfiguration {
                alertConfiguration = ActivityKit.AlertConfiguration(
                    title: LocalizedStringResource(stringLiteral: config.title),
                    body: LocalizedStringResource(stringLiteral: config.body),
                    sound: config.sound != nil
                        ? ActivityKit.AlertConfiguration.AlertSound.named(config.sound!)
                        : .default
                )
            }
            
            if #available(iOS 16.2, *) {
                let updatedState = ActivityContent.init(
                    state: contentState,
                    staleDate: options?.staleDate,
                    relevanceScore: options?.relevanceScore ?? 0
                )
                
                if #available(iOS 17.2, *) {
                    await activity.update(
                        updatedState,
                        alertConfiguration: alertConfiguration,
                        timestamp: options?.timestamp ?? Date.now
                    )
                } else {
                    await activity.update(
                        updatedState,
                        alertConfiguration: alertConfiguration
                    )
                }
            } else {
                await activity.update(
                    using: contentState,
                    alertConfiguration: alertConfiguration
                )
            }
        }
    }
    
    func end(state: AnyMap, options: EndOptions?) throws -> Void {
        Task {
            let newState = try ActivityKitModuleAttributes.ContentState(data: state)
            
            var dismissalPolicy: ActivityUIDismissalPolicy = .default
            if let policy = options?.dismissalPolicy {
                if(policy.timeIntervalSinceNow < 0) {
                    dismissalPolicy = .after(policy)
                } else {
                    dismissalPolicy = .immediate
                }
            }
            
            let timestamp = options?.timestamp ?? Date()
            
            if #available(iOS 16.2, *) {
                let endingState = ActivityContent.init(
                    state: newState,
                    staleDate: options?.staleDate,
                    relevanceScore: options?.relevanceScore ?? 0
                )
                
                if #available(iOS 17.2, *) {
                    await activity.end(
                        endingState,
                        dismissalPolicy: dismissalPolicy,
                        timestamp: timestamp
                    )
                } else {
                    await activity.end(
                        endingState,
                        dismissalPolicy: dismissalPolicy
                    )
                }
            } else {
                await activity.end(using: newState, dismissalPolicy: dismissalPolicy)
            }
        }
        
    }
    
    var id: String {
        return activity.id
    }
    
    var pushToken: String? {
        if let pushToken = activity.pushToken {
            return parsePushToken(pushToken)
        }
        return nil
    }
    
    var activity: Activity<ActivityKitModuleAttributes>
    
    init(activity: Activity<ActivityKitModuleAttributes>) {
        self.activity = activity
    }
}

class ActivityKitModuleAttributes: GenericDictionary, ActivityAttributes {
    typealias ContentState = GenericDictionaryStruct
    
    init(data: AnyMap) throws {
        try super.init(state: data)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

@available(iOS 16.1, *)
let activityAuthorizationInfo = ActivityKit.ActivityAuthorizationInfo()

class ActivityKitModule : HybridActivityKitModuleSpec {
    var pushToStartToken: String? {
        if #available(iOS 17.2, *) {
            if let token = Activity<ActivityKitModuleAttributes>.pushToStartToken {
                if let tokenString = parsePushToken(token) {
                    return tokenString
                }
            }
        } else {
            print("[react-native-activity-kit] pushToStartToken requires iOS 17.2 or later")
        }
        return nil
    }
    
    var isAvailable: Bool {
        if #available(iOS 16.1, *) {
            return true
        } else {
            return false
        }
    }
    
    func subscribeToActivityUpdates(callback: @escaping (any HybridActivityProxySpec) -> Void) throws {
        if #available(iOS 16.1, *) {
            Task {
                for await activity in Activity<ActivityKitModuleAttributes>.activityUpdates {
                    callback(ActivityProxy(activity: activity))
                }
            }
        }
    }
    
    var areActivitiesEnabled: Bool {
        if #available(iOS 16.1, *) {
            return activityAuthorizationInfo.areActivitiesEnabled
        } else {
            return false
        }
    }
    
    var frequentPushesEnabled: Bool {
        if #available(iOS 16.2, *) {
            return activityAuthorizationInfo.frequentPushesEnabled
        } else {
            
           print("[react-native-activity-kit] frequentPushesEnabled requires iOS 16.2 or later")
            return false
        }
    }
    
    func subscribeToFrequentPushesUpdates(callback: @escaping (Bool) -> Void) throws {
        Task {
            if #available(iOS 16.2, *) {
                for await isEnabled in activityAuthorizationInfo.frequentPushEnablementUpdates {
                    callback(isEnabled)
                }
            } else {
                print("[react-native-activity-kit] subscribeToActivityEnablementUpdates requires iOS 16.2 or later")
            }
        }
    }
    
    func subscribeToActivityEnablementUpdates(callback: @escaping (Bool) -> Void) throws {
        Task {
            if #available(iOS 16.1, *) {
                for await isEnabled in activityAuthorizationInfo.activityEnablementUpdates {
                    callback(isEnabled)
                }
            } else {
                print("[react-native-activity-kit] subscribeToActivityEnablementUpdates requires iOS 16.1 or later")
            }
        }
    }
    
    func subscribeToPushToStartTokenUpdates(callback: @escaping (String) -> Void) throws {
        Task {
            if #available(iOS 17.2, *) {
                for await token in Activity<ActivityKitModuleAttributes>.pushToStartTokenUpdates {
                    if let tokenString = String(data: token, encoding: .utf8) {
                        callback(tokenString)
                    }
                }
            } else {
                print("[react-native-activity-kit] subscribeToPushToStartTokenUpdates requires iOS 17.2 or later")
            }
        }
    }
    
    
    func startActivity(attributes: AnyMap, state: AnyMap, options: StartActivityOptions?) throws -> HybridActivityProxySpec {
        
        if #available(iOS 16.1, *) {
            var pushType: PushType?
            
            switch options?.pushType {
            case .first(let useTokenConfig):
                if(useTokenConfig.token){
                    pushType = .token
                }
            case .second(let pushChannelConfig):
                if #available(iOS 18.0, *) {
                    pushType = .channel(pushChannelConfig.channelName)
                } else {
                    // Fallback on earlier versions
                }
            default:
                pushType = nil
            }
            
            let state = try ActivityKitModuleAttributes.ContentState(data: state)
            
            let attributes = try ActivityKitModuleAttributes(data: attributes)
            
            var activity: Activity<ActivityKitModuleAttributes>
            
            if #available(iOS 16.2, *) {
                let content = ActivityContent<ActivityKitModuleAttributes.ContentState>.init(
                    state: state,
                    staleDate: options?.staleDate,
                    relevanceScore: options?.relevanceScore ?? 0,
                )
                
                if #available(iOS 18.0, *) {
                    activity = try Activity.request(
                        attributes: attributes,
                        content: content,
                        pushType: pushType,
                        style: options?.style == .transient ? .transient : .standard
                    )
                } else {
                    activity = try Activity.request(
                        attributes: attributes,
                        content: content,
                        pushType: pushType
                    )
                }
            } else {
                activity = try Activity.request(attributes: attributes, contentState: state)
            }
            return ActivityProxy(activity: activity)
        } else {
            throw RuntimeError.error(withMessage: "ActivityKit is not available on this version of iOS. Please use iOS 16.1 or later.")
        }
    }
        
        func getActivityById(activityId: String) throws -> HybridActivityProxySpec? {
            if #available(iOS 16.1, *) {
                let activity = Activity<ActivityKitModuleAttributes>.activities.first(where: { $0.id == activityId })
                if let activity = activity {
                    return ActivityProxy(activity: activity)
                }
            } else {
                // Fallback on earlier versions
            }
            
            return nil
        }
        
        func getAllActivities() throws -> [HybridActivityProxySpec] {
            if #available(iOS 16.1, *) {
                let activityProxies = Activity.activities
                    .map {
                        ActivityProxy(activity: $0)
                    }
                return activityProxies
            } else {
                // Fallback on earlier versions
            }
            return []
        }
        
    
}
