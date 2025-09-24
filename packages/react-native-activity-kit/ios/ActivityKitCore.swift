import ActivityKit
import SwiftUI
import AlarmKit

// App Extension-safe implementation of ActivityKit types
// This file can be used in App Extensions without React Native dependencies

// Protocol for dictionary-like access with convenience methods
public protocol DictionaryAccessible {
    subscript(key: String) -> Any? { get }
}

public extension DictionaryAccessible {
    // Convenience method to get string values safely
    func getString(_ key: String) -> String {
        return self[key] as? String ?? ""
    }

    // Convenience method to convert any value to string
    func getAsString(_ key: String) -> String {
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
    func getBool(_ key: String) -> Bool {
        return self[key] as? Bool ?? false
    }

    // Convenience method to get date values safely
    func getDate(_ key: String) -> Date? {
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

    // Convenience method to get color values safely
    func getAsColor(_ key: String) -> Color? {
        guard let value = self[key] else { return nil }

        if let colorString = value as? String {
            // Handle hex colors (#RRGGBB or #RRGGBBAA)
            if colorString.hasPrefix("#") {
                let hex = String(colorString.dropFirst())
                var hexInt: UInt64 = 0

                if Scanner(string: hex).scanHexInt64(&hexInt) {
                    let red, green, blue, alpha: Double

                    switch hex.count {
                    case 6: // RGB
                        red = Double((hexInt & 0xFF0000) >> 16) / 255.0
                        green = Double((hexInt & 0x00FF00) >> 8) / 255.0
                        blue = Double(hexInt & 0x0000FF) / 255.0
                        alpha = 1.0
                    case 8: // RGBA
                        red = Double((hexInt & 0xFF000000) >> 24) / 255.0
                        green = Double((hexInt & 0x00FF0000) >> 16) / 255.0
                        blue = Double((hexInt & 0x0000FF00) >> 8) / 255.0
                        alpha = Double(hexInt & 0x000000FF) / 255.0
                    default:
                        return nil
                    }

                    return Color(red: red, green: green, blue: blue, opacity: alpha)
                }
            }

            // Handle named colors
            return Color(colorString)
        }

        // Handle RGB array [r, g, b] or [r, g, b, a]
        if let rgbArray = value as? [Double] {
            switch rgbArray.count {
            case 3:
                return Color(red: rgbArray[0], green: rgbArray[1], blue: rgbArray[2])
            case 4:
                return Color(red: rgbArray[0], green: rgbArray[1], blue: rgbArray[2], opacity: rgbArray[3])
            default:
                return nil
            }
        }

        if let rgbColor = value as? RGBColor {
            if let alpha = rgbColor.alpha {
                return Color(
                    red: rgbColor.red * 255,
                    green: rgbColor.green * 255,
                    blue: rgbColor.blue * 255,
                    opacity: alpha
                )
            }
            return Color(
                red: rgbColor.red * 255,
                green: rgbColor.green * 255,
                blue: rgbColor.blue * 255
            )
        }

        return nil
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

open class GenericDictionary: Codable, Hashable, DictionaryAccessible {
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

public struct GenericDictionaryStruct: Codable, Hashable, DictionaryAccessible {
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

    // Create new instance by merging with another, incoming values win
    public static func merge(previous: GenericDictionaryStruct, with incoming: [String: Any]) throws -> GenericDictionaryStruct {
        var mergedData = previous.toDictionary()

        // Merge dictionaries, incoming values win
        for (key, value) in incoming {
            mergedData[key] = value
        }

        return try GenericDictionaryStruct(data: mergedData)
    }
}

open class ActivityKitModuleAttributes: GenericDictionary, ActivityAttributes {
    public typealias ContentState = GenericDictionaryStruct

    public init(data: [String: Any]) throws {
        try super.init(state: data)
    }

    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

public struct GenericDictionaryAlarmStruct: AlarmMetadata, DictionaryAccessible {
    private var _codable: CodableValue?

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_codable?.hashValue)
    }

    public static func == (lhs: GenericDictionaryAlarmStruct, rhs: GenericDictionaryAlarmStruct) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self._codable = try container.decode(CodableValue.self)
    }

    public init(state: [String: Any]) throws {
        self._codable = convertToCodableValue(state)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(_codable)
    }

    // Dictionary-like access
    public subscript(key: String) -> Any? {
        get {
            guard case let .dictionary(dict) = _codable else { return nil }
            return extractValue(from: dict[key])
        }
        set {
            guard case var .dictionary(dict) = _codable else { return }
            if let newValue = newValue {
                dict[key] = convertToCodableValue(newValue) ?? .null
            } else {
                dict[key] = .null
            }
            _codable = .dictionary(dict)
        }
    }

    // Get all keys
    public var keys: [String] {
        guard case let .dictionary(dict) = _codable else { return [] }
        return Array(dict.keys)
    }

    // Convert to regular dictionary
    public func toDictionary() -> [String: Any] {
        guard case let .dictionary(dict) = _codable else { return [:] }
        var result: [String: Any] = [:]
        for (key, value) in dict {
            result[key] = extractValue(from: value)
        }
        return result
    }
}

/*
@available(iOS 26.0, *)
struct AlarmKitModuleAttributes: AlarmAttributes<GenericDictionaryAlarmStruct> {
    public typealias ContentState = GenericDictionaryStruct

    public init(data: [String: Any]) throws {
        try super.init(state: data)
    }

    required public init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}

*/
