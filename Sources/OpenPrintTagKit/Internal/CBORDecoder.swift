import Foundation

/// Represents a decoded CBOR value.
enum CBORValue {
    case uint(UInt64)
    case nint(Int64)
    case bytes(Data)
    case text(String)
    case array([CBORValue])
    case map([(CBORValue, CBORValue)])
    case float(Double)
    case bool(Bool)
    case null
}

enum CBORDecodingError: Error, Equatable {
    case unexpectedEndOfData
    case unsupportedType(UInt8)
    case invalidUTF8
    case integerOverflow
}

/// Decodes a CBOR-encoded byte sequence into a CBORValue tree.
enum CBORDecoder {
    /// Decodes the first CBOR value from data and returns it together with
    /// the number of bytes consumed.
    static func decode(from data: Data, at offset: Int = 0) throws -> (value: CBORValue, bytesRead: Int) {
        guard offset < data.count else {
            throw CBORDecodingError.unexpectedEndOfData
        }
        let initialByte = data[data.startIndex + offset]
        let majorType = initialByte >> 5
        let additionalInfo = initialByte & 0x1F

        switch majorType {
        case 0:
            let (value, length) = try readUInt(data: data, at: offset, additionalInfo: additionalInfo)
            return (.uint(value), length)
        case 1:
            let (value, length) = try readUInt(data: data, at: offset, additionalInfo: additionalInfo)
            guard value <= UInt64(Int64.max) + 1 else {
                throw CBORDecodingError.integerOverflow
            }
            return (.nint(-1 - Int64(bitPattern: value)), length)
        case 2:
            let (byteCount, headerLength) = try readUInt(data: data, at: offset, additionalInfo: additionalInfo)
            let start = offset + headerLength
            let end = start + Int(byteCount)
            guard end <= data.count else {
                throw CBORDecodingError.unexpectedEndOfData
            }
            let bytes = data[data.startIndex + start ..< data.startIndex + end]
            return (.bytes(Data(bytes)), headerLength + Int(byteCount))
        case 3:
            let (byteCount, headerLength) = try readUInt(data: data, at: offset, additionalInfo: additionalInfo)
            let start = offset + headerLength
            let end = start + Int(byteCount)
            guard end <= data.count else {
                throw CBORDecodingError.unexpectedEndOfData
            }
            let bytes = data[data.startIndex + start ..< data.startIndex + end]
            guard let text = String(bytes: bytes, encoding: .utf8) else {
                throw CBORDecodingError.invalidUTF8
            }
            return (.text(text), headerLength + Int(byteCount))
        case 4:
            return try readArray(data: data, at: offset, additionalInfo: additionalInfo)
        case 5:
            return try readMap(data: data, at: offset, additionalInfo: additionalInfo)
        case 6:
            // CBOR tag — skip the tag number and return the wrapped value transparently.
            let (_, tagHeaderLength) = try readUInt(data: data, at: offset, additionalInfo: additionalInfo)
            let (wrappedValue, wrappedLength) = try decode(from: data, at: offset + tagHeaderLength)
            return (wrappedValue, tagHeaderLength + wrappedLength)
        case 7:
            return try readSpecial(data: data, at: offset, additionalInfo: additionalInfo)
        default:
            throw CBORDecodingError.unsupportedType(initialByte)
        }
    }

    // MARK: - Private helpers

    private static func readUInt(data: Data, at offset: Int, additionalInfo: UInt8) throws -> (UInt64, Int) {
        if additionalInfo <= 23 {
            return (UInt64(additionalInfo), 1)
        }
        switch additionalInfo {
        case 24:
            guard offset + 1 < data.count else { throw CBORDecodingError.unexpectedEndOfData }
            return (UInt64(data[data.startIndex + offset + 1]), 2)
        case 25:
            guard offset + 2 < data.count else { throw CBORDecodingError.unexpectedEndOfData }
            let value = UInt16(data[data.startIndex + offset + 1]) << 8
                | UInt16(data[data.startIndex + offset + 2])
            return (UInt64(value), 3)
        case 26:
            guard offset + 4 < data.count else { throw CBORDecodingError.unexpectedEndOfData }
            var value: UInt32 = 0
            for i in 0 ..< 4 {
                value = (value << 8) | UInt32(data[data.startIndex + offset + 1 + i])
            }
            return (UInt64(value), 5)
        case 27:
            guard offset + 8 < data.count else { throw CBORDecodingError.unexpectedEndOfData }
            var value: UInt64 = 0
            for i in 0 ..< 8 {
                value = (value << 8) | UInt64(data[data.startIndex + offset + 1 + i])
            }
            return (value, 9)
        default:
            throw CBORDecodingError.unsupportedType(additionalInfo)
        }
    }

    private static func readArray(data: Data, at offset: Int, additionalInfo: UInt8) throws -> (CBORValue, Int) {
        if additionalInfo == 31 {
            var items: [CBORValue] = []
            var cursor = offset + 1
            while cursor < data.count && data[data.startIndex + cursor] != 0xFF {
                let (item, itemLength) = try decode(from: data, at: cursor)
                items.append(item)
                cursor += itemLength
            }
            return (.array(items), cursor - offset + 1)
        }
        let (count, headerLength) = try readUInt(data: data, at: offset, additionalInfo: additionalInfo)
        var items: [CBORValue] = []
        var cursor = offset + headerLength
        for _ in 0 ..< count {
            let (item, itemLength) = try decode(from: data, at: cursor)
            items.append(item)
            cursor += itemLength
        }
        return (.array(items), cursor - offset)
    }

    private static func readMap(data: Data, at offset: Int, additionalInfo: UInt8) throws -> (CBORValue, Int) {
        if additionalInfo == 31 {
            var pairs: [(CBORValue, CBORValue)] = []
            var cursor = offset + 1
            while cursor < data.count && data[data.startIndex + cursor] != 0xFF {
                let (key, keyLength) = try decode(from: data, at: cursor)
                cursor += keyLength
                let (value, valueLength) = try decode(from: data, at: cursor)
                cursor += valueLength
                pairs.append((key, value))
            }
            return (.map(pairs), cursor - offset + 1)
        }
        let (count, headerLength) = try readUInt(data: data, at: offset, additionalInfo: additionalInfo)
        var pairs: [(CBORValue, CBORValue)] = []
        var cursor = offset + headerLength
        for _ in 0 ..< count {
            let (key, keyLength) = try decode(from: data, at: cursor)
            cursor += keyLength
            let (value, valueLength) = try decode(from: data, at: cursor)
            cursor += valueLength
            pairs.append((key, value))
        }
        return (.map(pairs), cursor - offset)
    }

    private static func readSpecial(data: Data, at offset: Int, additionalInfo: UInt8) throws -> (CBORValue, Int) {
        switch additionalInfo {
        case 20:
            return (.bool(false), 1)
        case 21:
            return (.bool(true), 1)
        case 22:
            return (.null, 1)
        case 25:
            // Float16
            guard offset + 2 < data.count else { throw CBORDecodingError.unexpectedEndOfData }
            let bits = UInt16(data[data.startIndex + offset + 1]) << 8
                | UInt16(data[data.startIndex + offset + 2])
            return (.float(decodeFloat16(bits)), 3)
        case 26:
            // Float32
            guard offset + 4 < data.count else { throw CBORDecodingError.unexpectedEndOfData }
            var bits: UInt32 = 0
            for i in 0 ..< 4 {
                bits = (bits << 8) | UInt32(data[data.startIndex + offset + 1 + i])
            }
            return (.float(Double(Float(bitPattern: bits))), 5)
        case 27:
            // Float64
            guard offset + 8 < data.count else { throw CBORDecodingError.unexpectedEndOfData }
            var bits: UInt64 = 0
            for i in 0 ..< 8 {
                bits = (bits << 8) | UInt64(data[data.startIndex + offset + 1 + i])
            }
            return (.float(Double(bitPattern: bits)), 9)
        default:
            throw CBORDecodingError.unsupportedType(additionalInfo)
        }
    }

    /// Decodes an IEEE 754 half-precision float (16-bit) to Double.
    private static func decodeFloat16(_ bits: UInt16) -> Double {
        let sign: Double = (bits >> 15) == 0 ? 1.0 : -1.0
        let exponent = Int((bits >> 10) & 0x1F)
        let mantissa = Double(bits & 0x03FF)
        switch exponent {
        case 0:
            return sign * pow(2.0, -14.0) * (mantissa / 1024.0)
        case 31:
            return mantissa == 0.0 ? sign * Double.infinity : Double.nan
        default:
            return sign * pow(2.0, Double(exponent - 15)) * (1.0 + mantissa / 1024.0)
        }
    }
}

// MARK: - Convenience accessors

extension CBORValue {
    var uintValue: UInt64? {
        if case let .uint(v) = self { return v }
        return nil
    }

    var intValue: Int? {
        if case let .uint(v) = self { return Int(exactly: v) }
        if case let .nint(v) = self { return Int(exactly: v) }
        return nil
    }

    var doubleValue: Double? {
        if case let .float(v) = self { return v }
        if case let .uint(v) = self { return Double(v) }
        if case let .nint(v) = self { return Double(v) }
        return nil
    }

    var stringValue: String? {
        if case let .text(v) = self { return v }
        return nil
    }

    var bytesValue: Data? {
        if case let .bytes(v) = self { return v }
        return nil
    }

    var arrayValue: [CBORValue]? {
        if case let .array(v) = self { return v }
        return nil
    }

    var mapValue: [(CBORValue, CBORValue)]? {
        if case let .map(v) = self { return v }
        return nil
    }

    /// Returns the value for an integer key from a CBOR map.
    func value(forIntKey key: Int) -> CBORValue? {
        guard let pairs = mapValue else { return nil }
        return pairs.first { $0.0.intValue == key }?.1
    }
}
