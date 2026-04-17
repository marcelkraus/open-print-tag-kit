import Foundation
@testable import OpenPrintTagKit
import Testing

// All hex payloads below are manually crafted from the CBOR specification
// (RFC 7049) to verify the decoder without requiring real NFC hardware.

struct CBORDecoderTests {
    // MARK: - Unsigned Integers

    @Test("Decodes inline uint (0–23)")
    func decodesInlineUInt() throws {
        // 0x00 = major type 0 (uint), additional info 0 → value 0
        let (value, bytesRead) = try CBORDecoder.decode(from: Data([0x00]))
        #expect(value.uintValue == 0)
        #expect(bytesRead == 1)
    }

    @Test("Decodes 1-byte uint")
    func decodes1ByteUInt() throws {
        // 0x18 0x64 = major type 0, additional info 24 → next byte = 100
        let (value, bytesRead) = try CBORDecoder.decode(from: Data([0x18, 0x64]))
        #expect(value.uintValue == 100)
        #expect(bytesRead == 2)
    }

    @Test("Decodes 2-byte uint")
    func decodes2ByteUInt() throws {
        // 0x19 0x03 0xE8 = 1000
        let (value, bytesRead) = try CBORDecoder.decode(from: Data([0x19, 0x03, 0xE8]))
        #expect(value.uintValue == 1000)
        #expect(bytesRead == 3)
    }

    // MARK: - Negative Integers

    @Test("Decodes negative integer")
    func decodesNegativeInteger() throws {
        // 0x20 = major type 1, additional info 0 → -1 - 0 = -1
        let (value, bytesRead) = try CBORDecoder.decode(from: Data([0x20]))
        #expect(value.intValue == -1)
        #expect(bytesRead == 1)
    }

    // MARK: - Text Strings

    @Test("Decodes short text string")
    func decodesShortTextString() throws {
        // 0x63 = major type 3, length 3; then "PLA"
        let bytes: [UInt8] = [0x63, 0x50, 0x4C, 0x41]
        let (value, bytesRead) = try CBORDecoder.decode(from: Data(bytes))
        #expect(value.stringValue == "PLA")
        #expect(bytesRead == 4)
    }

    // MARK: - Byte Strings

    @Test("Decodes byte string")
    func decodesByteString() throws {
        // 0x43 = major type 2, length 3; then 0x01 0x02 0x03
        let bytes: [UInt8] = [0x43, 0x01, 0x02, 0x03]
        let (value, bytesRead) = try CBORDecoder.decode(from: Data(bytes))
        #expect(value.bytesValue == Data([0x01, 0x02, 0x03]))
        #expect(bytesRead == 4)
    }

    // MARK: - Floats

    @Test("Decodes float32")
    func decodesFloat32() throws {
        // 0xFA = float32; 0x44 0x7A 0x00 0x00 = 1000.0f
        let bytes: [UInt8] = [0xFA, 0x44, 0x7A, 0x00, 0x00]
        let (value, bytesRead) = try CBORDecoder.decode(from: Data(bytes))
        #expect(value.doubleValue == 1000.0)
        #expect(bytesRead == 5)
    }

    @Test("Decodes float16 zero")
    func decodesFloat16Zero() throws {
        // 0xF9 0x00 0x00 = float16, value 0.0
        let bytes: [UInt8] = [0xF9, 0x00, 0x00]
        let (value, bytesRead) = try CBORDecoder.decode(from: Data(bytes))
        #expect(value.doubleValue == 0.0)
        #expect(bytesRead == 3)
    }

    // MARK: - Booleans

    @Test("Decodes true")
    func decodesTrue() throws {
        let (value, _) = try CBORDecoder.decode(from: Data([0xF5]))
        if case let .bool(b) = value {
            #expect(b == true)
        } else {
            Issue.record("Expected bool, got \(value)")
        }
    }

    @Test("Decodes false")
    func decodesFalse() throws {
        let (value, _) = try CBORDecoder.decode(from: Data([0xF4]))
        if case let .bool(b) = value {
            #expect(b == false)
        } else {
            Issue.record("Expected bool, got \(value)")
        }
    }

    // MARK: - Arrays

    @Test("Decodes array of uints")
    func decodesArrayOfUInts() throws {
        // 0x83 = major type 4, length 3; then 0x01 0x02 0x03
        let bytes: [UInt8] = [0x83, 0x01, 0x02, 0x03]
        let (value, bytesRead) = try CBORDecoder.decode(from: Data(bytes))
        let items = value.arrayValue
        #expect(items?.count == 3)
        #expect(items?[0].uintValue == 1)
        #expect(items?[1].uintValue == 2)
        #expect(items?[2].uintValue == 3)
        #expect(bytesRead == 4)
    }

    // MARK: - Maps

    @Test("Decodes integer-keyed map")
    func decodesIntegerKeyedMap() throws {
        // {0: "PLA"} → 0xA1 0x00 0x63 0x50 0x4C 0x41
        let bytes: [UInt8] = [0xA1, 0x00, 0x63, 0x50, 0x4C, 0x41]
        let (value, bytesRead) = try CBORDecoder.decode(from: Data(bytes))
        #expect(value.value(forIntKey: 0)?.stringValue == "PLA")
        #expect(bytesRead == 6)
    }

    // MARK: - Error handling

    @Test("Throws on empty data")
    func throwsOnEmptyData() {
        #expect(throws: CBORDecodingError.unexpectedEndOfData) {
            try CBORDecoder.decode(from: Data())
        }
    }

    // MARK: - OpenPrintTag field parsing

    @Test("Parses minimal OpenPrintTag payload")
    func parsesMinimalPayload() throws {
        // Minimal main region: {10: "Test PLA", 11: "Brand", 16: 1000.0}
        // CBOR: A3           = map(3 entries)
        //       0A           = key 10
        //       68 54657374 504C41 = text(8) "Test PLA"
        //       0B           = key 11
        //       65 4272616E64 = text(5) "Brand"
        //       10           = key 16
        //       FA 44 7A 00 00 = float32 1000.0
        let bytes: [UInt8] = [
            0xA3,
            0x0A,
            0x68, 0x54, 0x65, 0x73, 0x74, 0x20, 0x50, 0x4C, 0x41,
            0x0B,
            0x65, 0x42, 0x72, 0x61, 0x6E, 0x64,
            0x10,
            0xFA, 0x44, 0x7A, 0x00, 0x00,
        ]
        let data = try OpenPrintTagParser.parse(payload: Data(bytes))
        #expect(data.materialName == "Test PLA")
        #expect(data.brandName == "Brand")
        #expect(data.nominalNettoFullWeight == 1000.0)
    }
}
