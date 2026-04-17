import Foundation

/// Mock implementation for use in SwiftUI Previews and unit tests.
///
/// Configure `result` before calling `scan()` to control what the mock returns.
public final class OpenPrintTagReaderMock: Sendable {
    public let result: Result<OpenPrintTagData, OpenPrintTagError>

    public init(result: Result<OpenPrintTagData, OpenPrintTagError>) {
        self.result = result
    }

    /// Returns a mock with a pre-filled Prusament PLA sample tag.
    public static var prusamentPLASample: OpenPrintTagReaderMock {
        OpenPrintTagReaderMock(result: .success(.prusamentPLASample))
    }

    public func scan() async throws -> OpenPrintTagData {
        try result.get()
    }
}

// MARK: - Sample data

public extension OpenPrintTagData {
    /// Sample data representing a typical Prusament PLA Galaxy Black spool.
    static var prusamentPLASample: OpenPrintTagData {
        OpenPrintTagData(
            instanceUUID: UUID(),
            packageUUID: UUID(),
            materialUUID: nil,
            brandUUID: nil,
            gtin: nil,
            brandSpecificInstanceId: nil,
            brandSpecificPackageId: nil,
            brandSpecificMaterialId: nil,
            materialClass: .fffFilament,
            materialType: .pla,
            materialName: "PLA Galaxy Black",
            brandName: "Prusament",
            materialAbbreviation: "PLA",
            writeProtection: .none,
            manufacturedDate: nil,
            expirationDate: nil,
            countryOfOrigin: "CZ",
            nominalNettoFullWeight: 1000.0,
            actualNettoFullWeight: 1004.0,
            emptyContainerWeight: 201.0,
            nominalFullLength: nil,
            actualFullLength: nil,
            primaryColor: OpenPrintTagColor(r: 10, g: 10, b: 10),
            secondaryColors: [],
            transmissionDistance: nil,
            tags: [.glitter],
            density: 1.24,
            filamentDiameter: 1.75,
            shoreHardnessA: nil,
            shoreHardnessD: nil,
            certifications: [],
            minNozzleDiameter: 0.4,
            minPrintTemperature: 190,
            maxPrintTemperature: 230,
            preheatTemperature: nil,
            minBedTemperature: 50,
            maxBedTemperature: 60,
            minChamberTemperature: nil,
            maxChamberTemperature: nil,
            chamberTemperature: nil,
            dryingTemperature: 50,
            dryingTime: 240,
            containerWidth: nil,
            containerOuterDiameter: nil,
            containerInnerDiameter: nil,
            containerHoleDiameter: nil,
            containerVolumetricCapacity: nil,
            viscosity18C: nil,
            viscosity25C: nil,
            viscosity40C: nil,
            viscosity60C: nil,
            cureWavelength: nil,
            consumedWeight: nil,
            workgroup: nil,
            generalPurposeRangeUser: nil,
            lastStirTime: nil
        )
    }
}
