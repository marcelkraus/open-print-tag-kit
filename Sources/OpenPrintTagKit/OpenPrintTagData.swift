import Foundation

public struct OpenPrintTagData: Sendable {
    // MARK: - Identifiers

    public let instanceUUID: UUID?
    public let packageUUID: UUID?
    public let materialUUID: UUID?
    public let brandUUID: UUID?
    public let gtin: Double?
    public let brandSpecificInstanceId: String?
    public let brandSpecificPackageId: String?
    public let brandSpecificMaterialId: String?

    // MARK: - Classification

    public let materialClass: MaterialClass?
    public let materialType: MaterialType?
    public let materialName: String?
    public let brandName: String?
    public let materialAbbreviation: String?

    // MARK: - Meta

    public let writeProtection: WriteProtection?
    public let manufacturedDate: Date?
    public let expirationDate: Date?
    public let countryOfOrigin: String?

    // MARK: - Weight & Length

    /// Advertised material weight in grams.
    public let nominalNettoFullWeight: Double?

    /// Actual measured weight of this specific spool in grams.
    public let actualNettoFullWeight: Double?

    /// Weight of the empty container in grams.
    public let emptyContainerWeight: Double?

    /// Advertised filament length in millimeters.
    public let nominalFullLength: Double?

    /// Actual filament length in millimeters.
    public let actualFullLength: Double?

    // MARK: - Color

    public let primaryColor: OpenPrintTagColor?
    public let secondaryColors: [OpenPrintTagColor]

    /// Material opacity value (0.1–100).
    public let transmissionDistance: Double?

    // MARK: - Material Properties

    public let tags: [MaterialTag]
    public let density: Double?
    public let filamentDiameter: Double?
    public let shoreHardnessA: Int?
    public let shoreHardnessD: Int?
    public let certifications: [MaterialCertification]

    // MARK: - Nozzle

    /// Minimum recommended nozzle diameter in millimeters.
    public let minNozzleDiameter: Double?

    // MARK: - Print Temperatures

    public let minPrintTemperature: Int?
    public let maxPrintTemperature: Int?
    public let preheatTemperature: Int?

    // MARK: - Bed Temperatures

    public let minBedTemperature: Int?
    public let maxBedTemperature: Int?

    // MARK: - Chamber Temperatures

    public let minChamberTemperature: Int?
    public let maxChamberTemperature: Int?
    public let chamberTemperature: Int?

    // MARK: - Drying

    public let dryingTemperature: Int?

    /// Recommended drying duration in minutes.
    public let dryingTime: Int?

    // MARK: - Container Dimensions

    public let containerWidth: Int?
    public let containerOuterDiameter: Int?
    public let containerInnerDiameter: Int?
    public let containerHoleDiameter: Int?

    /// Maximum container capacity in milliliters.
    public let containerVolumetricCapacity: Double?

    // MARK: - Viscosity (Resins)

    public let viscosity18C: Double?
    public let viscosity25C: Double?
    public let viscosity40C: Double?
    public let viscosity60C: Double?

    // MARK: - SLA

    /// Light wavelength for curing in nanometers.
    public let cureWavelength: Int?

    // MARK: - Auxiliary

    /// Amount of material already consumed from this spool in grams.
    public let consumedWeight: Double?

    /// Workgroup identifier used for detecting first usage of the material.
    public let workgroup: String?

    /// Semantics identifier for general-purpose key range fields.
    public let generalPurposeRangeUser: String?

    /// Timestamp when the resin was last stirred.
    public let lastStirTime: Date?
}
