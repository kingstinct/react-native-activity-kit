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

class ActivityKitModuleAttributes: GenericDictionary, ActivityAttributes {
    typealias ContentState = GenericDictionaryStruct
    
    init(data: AnyMap) throws {
        try super.init(state: data)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
