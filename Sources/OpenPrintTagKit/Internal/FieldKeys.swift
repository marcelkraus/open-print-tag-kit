// Integer key constants from the OpenPrintTag specification.
// Source: https://github.com/OpenPrintTag/openprinttag-specification

enum MainFieldKey: Int {
    case instanceUUID = 0
    case packageUUID = 1
    case materialUUID = 2
    case brandUUID = 3
    case gtin = 4
    case brandSpecificInstanceId = 5
    case brandSpecificPackageId = 6
    case brandSpecificMaterialId = 7
    case materialClass = 8
    case materialType = 9
    case materialName = 10
    case brandName = 11
    case writeProtection = 13
    case manufacturedDate = 14
    case expirationDate = 15
    case nominalNettoFullWeight = 16
    case actualNettoFullWeight = 17
    case emptyContainerWeight = 18
    case primaryColor = 19
    case secondaryColor0 = 20
    case secondaryColor1 = 21
    case secondaryColor2 = 22
    case secondaryColor3 = 23
    case secondaryColor4 = 24
    case transmissionDistance = 27
    case tags = 28
    case density = 29
    case filamentDiameter = 30
    case shoreHardnessA = 31
    case shoreHardnessD = 32
    case minNozzleDiameter = 33
    case minPrintTemperature = 34
    case maxPrintTemperature = 35
    case preheatTemperature = 36
    case minBedTemperature = 37
    case maxBedTemperature = 38
    case minChamberTemperature = 39
    case maxChamberTemperature = 40
    case chamberTemperature = 41
    case containerWidth = 42
    case containerOuterDiameter = 43
    case containerInnerDiameter = 44
    case containerHoleDiameter = 45
    case viscosity18C = 46
    case viscosity25C = 47
    case viscosity40C = 48
    case viscosity60C = 49
    case containerVolumetricCapacity = 50
    case cureWavelength = 51
    case materialAbbreviation = 52
    case nominalFullLength = 53
    case actualFullLength = 54
    case countryOfOrigin = 55
    case certifications = 56
    case dryingTemperature = 57
    case dryingTime = 58
}

enum AuxFieldKey: Int {
    case consumedWeight = 0
    case workgroup = 1
    case generalPurposeRangeUser = 2
    case lastStirTime = 3
}

enum MetaFieldKey: Int {
    case mainRegionOffset = 0
    case mainRegionSize = 1
    case auxRegionOffset = 2
    case auxRegionSize = 3
}
