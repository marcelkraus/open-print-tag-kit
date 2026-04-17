import Foundation

public enum MaterialClass: Int, Sendable, CaseIterable {
    case fffFilament = 0
    case slaResin = 1
}

public enum MaterialType: Int, Sendable, CaseIterable {
    case pla = 0
    case petg = 1
    case tpu = 2
    case abs = 3
    case asa = 4
    case pc = 5
    case pctg = 6
    case pp = 7
    case pa6 = 8
    case pa11 = 9
    case pa12 = 10
    case pa66 = 11
    case cpe = 12
    case tpe = 13
    case hips = 14
    case pha = 15
    case pet = 16
    case pei = 17
    case pbt = 18
    case pvb = 19
    case pva = 20
    case pekk = 21
    case peek = 22
    case bvoh = 23
    case tpc = 24
    case pps = 25
    case ppsu = 26
    case pvc = 27
    case peba = 28
    case pvdf = 29
    case ppa = 30
    case pcl = 31
    case pes = 32
    case pmma = 33
    case pom = 34
    case ppe = 35
    case ps = 36
    case psu = 37
    case tpi = 38
    case sbs = 39
    case obc = 40
    case eva = 41
}

public enum MaterialTag: Int, Sendable, CaseIterable {
    case filtrationRecommended = 0
    case biocompatible = 1
    case antibacterial = 2
    case airFiltering = 3
    case abrasive = 4
    case foaming = 5
    case selfExtinguishing = 6
    case paramagnetic = 7
    case radiationShielding = 8
    case highTemperature = 9
    case esdSafe = 10
    case conductive = 11
    case blend = 12
    case waterSoluble = 13
    case ipaSoluble = 14
    case limoneneSoluble = 15
    case matte = 16
    case silk = 17
    case translucent = 19
    case transparent = 20
    case iridescent = 21
    case pearlescent = 22
    case glitter = 23
    case glowInTheDark = 24
    case neon = 25
    case illuminescentColorChange = 26
    case temperatureColorChange = 27
    case gradualColorChange = 28
    case coextruded = 29
    case containsCarbon = 30
    case containsCarbonFiber = 31
    case containsCarbonNanoTubes = 32
    case containsGlass = 33
    case containsGlassFiber = 34
    case containsKevlar = 35
    case containsStone = 36
    case containsMagnetite = 37
    case containsOrganicMaterial = 38
    case containsCork = 39
    case containsWax = 40
    case containsWood = 41
    case containsBamboo = 42
    case containsPine = 43
    case containsCeramic = 44
    case containsBoronCarbide = 45
    case containsMetal = 46
    case containsBronze = 47
    case containsIron = 48
    case containsSteel = 49
    case containsSilver = 50
    case containsCopper = 51
    case containsAluminium = 52
    case containsBrass = 53
    case containsTungsten = 54
    case imitatesWood = 55
    case imitatesMetal = 56
    case imitatesMarble = 57
    case imitatesStone = 58
    case lithophane = 59
    case recycled = 60
    case homeCompostable = 61
    case industriallyCompostable = 62
    case bioBased = 63
    case lowOutgassing = 64
    case withoutPigments = 65
    case containsAlgae = 66
    case castable = 67
    case containsPtfe = 68
    case limitedEdition = 69
    case emiShielding = 70
    case highSpeed = 71
    case containsGraphene = 72
}

public enum MaterialCertification: Int, Sendable, CaseIterable {
    case ul2818 = 0
    case ul94V0 = 1
    case ul2904 = 2
}

public enum WriteProtection: Int, Sendable, CaseIterable {
    case none = 0
    case writeProtected = 1
    case permanentlyLocked = 2
}

public struct OpenPrintTagColor: Sendable, Equatable {
    public let r: UInt8
    public let g: UInt8
    public let b: UInt8
    public let a: UInt8

    public init(r: UInt8, g: UInt8, b: UInt8, a: UInt8 = 255) {
        self.r = r
        self.g = g
        self.b = b
        self.a = a
    }
}
