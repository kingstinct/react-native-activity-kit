import ActivityKit

// App Extension-safe implementation of ActivityKit types
// This file can be used in App Extensions without React Native dependencies

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

open class GenericDictionary : Codable, Hashable {
    var codable: CodableValue?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(codable?.hashValue)
    }
    
    public static func == (lhs: GenericDictionary, rhs: GenericDictionary) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.codable = try container.decode(CodableValue.self)
        
    }
    
    public init(state: Dictionary<String, Any>) throws {
        self.codable = convertToCodableValue(state)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codable)
    }
}

public struct GenericDictionaryStruct : Codable, Hashable {
    var codable: CodableValue?
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(codable?.hashValue)
    }
    
    public static func == (lhs: GenericDictionaryStruct, rhs: GenericDictionaryStruct) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.codable = try container.decode(CodableValue.self)
        
    }
    
    public init(data: Dictionary<String, Any>) throws {
        self.codable = convertToCodableValue(data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codable)
    }
}

open class ActivityKitModuleAttributes: GenericDictionary, ActivityAttributes {
    public typealias ContentState = GenericDictionaryStruct
    
    public init(data: Dictionary<String, Any>) throws {
        try super.init(state: data)
    }
    
    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
