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
    case let stringValue as String: return .string(stringValue)
    case let intValue as Int: return .int(intValue)
    case let doubleValue as Double: return .double(doubleValue)
    case let boolValue as Bool: return .bool(boolValue)
    case _ as NSNull: return .null
    case let arrayValue as [Any]:
        let array = arrayValue.compactMap { convertToCodableValue($0) }
        return .array(array)
    case let dictValue as [String: Any]:
        var dict: [String: CodableValue] = [:]
        for (key, value) in dictValue {
            if let val = convertToCodableValue(value) {
                dict[key] = val
            }
        }
        return .dictionary(dict)
    default:
        return nil
    }
}

func extractValue(from codableValue: CodableValue?) -> Any? {
    guard let codableValue = codableValue else { return nil }
    
    switch codableValue {
    case .string(let stringValue):
        return stringValue
    case .int(let intValue):
        return intValue
    case .double(let doubleValue):
        return doubleValue
    case .bool(let boolValue):
        return boolValue
    case .null:
        return nil
    case .array(let arrayValue):
        return arrayValue.compactMap { extractValue(from: $0) }
    case .dictionary(let dictValue):
        var result: [String: Any] = [:]
        for (key, value) in dictValue {
            result[key] = extractValue(from: value)
        }
        return result
    }
}

open class GenericDictionary: Codable, Hashable {
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
    
    public init(state: [String: Any]) throws {
        self.codable = convertToCodableValue(state)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codable)
    }
    
    // Dictionary-like access
    public subscript(key: String) -> Any? {
        get {
            guard case let .dictionary(dict) = codable else { return nil }
            return extractValue(from: dict[key])
        }
        set {
            guard case var .dictionary(dict) = codable else { return }
            if let newValue = newValue {
                dict[key] = convertToCodableValue(newValue) ?? .null
            } else {
                dict[key] = .null
            }
            codable = .dictionary(dict)
        }
    }
    
    // Get all keys
    public var keys: [String] {
        guard case let .dictionary(dict) = codable else { return [] }
        return Array(dict.keys)
    }
    
    // Convert to regular dictionary
    public func toDictionary() -> [String: Any] {
        guard case let .dictionary(dict) = codable else { return [:] }
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = extractValue(from: value)
        }
        return result
    }
}

public struct GenericDictionaryStruct: Codable, Hashable {
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
    
    public init(data: [String: Any]) throws {
        self.codable = convertToCodableValue(data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(codable)
    }
    
    // Dictionary-like access
    public subscript(key: String) -> Any? {
        get {
            guard case let .dictionary(dict) = codable else { return nil }
            return extractValue(from: dict[key])
        }
        set {
            guard case var .dictionary(dict) = codable else { return }
            if let newValue = newValue {
                dict[key] = convertToCodableValue(newValue) ?? .null
            } else {
                dict[key] = .null
            }
            codable = .dictionary(dict)
        }
    }
    
    // Get all keys
    public var keys: [String] {
        guard case let .dictionary(dict) = codable else { return [] }
        return Array(dict.keys)
    }
    
    // Convert to regular dictionary
    public func toDictionary() -> [String: Any] {
        guard case let .dictionary(dict) = codable else { return [:] }
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = extractValue(from: value)
        }
        return result
    }
    
    // Convenience method to get string values safely
    public func getString(_ key: String) -> String {
        return self[key] as? String ?? ""
    }
    
    // Convenience method to convert any value to string
    public func getAsString(_ key: String) -> String {
        guard let value = self[key] else { return "" }
        
        switch value {
        case let stringValue as String:
            return stringValue
        case let intValue as Int:
            return String(intValue)
        case let doubleValue as Double:
            return String(doubleValue)
        case let boolValue as Bool:
            return boolValue ? "true" : "false"
        case let arrayValue as [Any]:
            return arrayValue.map { String(describing: $0) }.joined(separator: ", ")
        case let dictValue as [String: Any]:
            return dictValue.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
        default:
            return String(describing: value)
        }
    }
    
    // Convenience method to get boolean values safely
    public func getBool(_ key: String) -> Bool {
        return self[key] as? Bool ?? false
    }
    
    // Convenience method to get date values safely
    public func getDate(_ key: String) -> Date? {
        guard let value = self[key] else { return nil }
        
        if let date = value as? Date {
            return date
        }
        
        if let timestamp = value as? Double {
            return Date(timeIntervalSince1970: timestamp / 1000) // Assuming milliseconds
        }
        
        if let timestamp = value as? Int {
            return Date(timeIntervalSince1970: Double(timestamp) / 1000) // Assuming milliseconds
        }
        
        if let dateString = value as? String {
            let formatter = ISO8601DateFormatter()
            return formatter.date(from: dateString)
        }
        
        return nil
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
