import Foundation

/// Parses an OpenPrintTag NDEF payload (CBOR-encoded) into an OpenPrintTagData value.
enum OpenPrintTagParser {
    /// The NDEF payload of an OpenPrintTag record may contain up to three
    /// consecutive CBOR maps: meta, main, and optional aux. The meta map
    /// specifies the byte offsets of the other two regions.
    static func parse(payload: Data) throws -> OpenPrintTagData {
        // Decode the first CBOR map from the payload. It is either the meta
        // region (if it contains only meta keys 0–3) or the main region.
        let (firstMap, firstMapSize) = try CBORDecoder.decode(from: payload, at: 0)

        guard let firstPairs = firstMap.mapValue else {
            throw OpenPrintTagError.invalidCBOR
        }

        let isMetaRegion = firstPairs.allSatisfy { pair in
            guard let key = pair.0.intValue else { return false }
            return MetaFieldKey(rawValue: key) != nil
        }

        let mainOffset: Int
        let auxOffset: Int?

        if isMetaRegion, firstPairs.isEmpty == false {
            mainOffset = firstMap.value(forIntKey: MetaFieldKey.mainRegionOffset.rawValue)
                .flatMap(\.intValue) ?? firstMapSize
            auxOffset = firstMap.value(forIntKey: MetaFieldKey.auxRegionOffset.rawValue)
                .flatMap(\.intValue)
        } else {
            // No meta region — the first map is the main region.
            mainOffset = 0
            auxOffset = nil
        }

        let (mainMap, mainMapSize) = try CBORDecoder.decode(from: payload, at: mainOffset)
        var auxMap: CBORValue? = nil

        if let auxOffset {
            auxMap = try? CBORDecoder.decode(from: payload, at: auxOffset).value
        } else {
            let afterMain = mainOffset + mainMapSize
            if afterMain < payload.count {
                auxMap = try? CBORDecoder.decode(from: payload, at: afterMain).value
            }
        }

        return buildData(mainMap: mainMap, auxMap: auxMap)
    }

    // MARK: - Building OpenPrintTagData

    private static func buildData(mainMap: CBORValue, auxMap: CBORValue?) -> OpenPrintTagData {
        OpenPrintTagData(
            instanceUUID: mainMap.uuidValue(forKey: MainFieldKey.instanceUUID.rawValue),
            packageUUID: mainMap.uuidValue(forKey: MainFieldKey.packageUUID.rawValue),
            materialUUID: mainMap.uuidValue(forKey: MainFieldKey.materialUUID.rawValue),
            brandUUID: mainMap.uuidValue(forKey: MainFieldKey.brandUUID.rawValue),
            gtin: mainMap.value(forIntKey: MainFieldKey.gtin.rawValue)?.doubleValue,
            brandSpecificInstanceId: mainMap.value(forIntKey: MainFieldKey.brandSpecificInstanceId.rawValue)?.stringValue,
            brandSpecificPackageId: mainMap.value(forIntKey: MainFieldKey.brandSpecificPackageId.rawValue)?.stringValue,
            brandSpecificMaterialId: mainMap.value(forIntKey: MainFieldKey.brandSpecificMaterialId.rawValue)?.stringValue,
            materialClass: mainMap.enumValue(forKey: MainFieldKey.materialClass.rawValue),
            materialType: mainMap.enumValue(forKey: MainFieldKey.materialType.rawValue),
            materialName: mainMap.value(forIntKey: MainFieldKey.materialName.rawValue)?.stringValue,
            brandName: mainMap.value(forIntKey: MainFieldKey.brandName.rawValue)?.stringValue,
            materialAbbreviation: mainMap.value(forIntKey: MainFieldKey.materialAbbreviation.rawValue)?.stringValue,
            writeProtection: mainMap.enumValue(forKey: MainFieldKey.writeProtection.rawValue),
            manufacturedDate: mainMap.dateValue(forKey: MainFieldKey.manufacturedDate.rawValue),
            expirationDate: mainMap.dateValue(forKey: MainFieldKey.expirationDate.rawValue),
            countryOfOrigin: mainMap.value(forIntKey: MainFieldKey.countryOfOrigin.rawValue)?.stringValue,
            nominalNettoFullWeight: mainMap.value(forIntKey: MainFieldKey.nominalNettoFullWeight.rawValue)?.doubleValue,
            actualNettoFullWeight: mainMap.value(forIntKey: MainFieldKey.actualNettoFullWeight.rawValue)?.doubleValue,
            emptyContainerWeight: mainMap.value(forIntKey: MainFieldKey.emptyContainerWeight.rawValue)?.doubleValue,
            nominalFullLength: mainMap.value(forIntKey: MainFieldKey.nominalFullLength.rawValue)?.doubleValue,
            actualFullLength: mainMap.value(forIntKey: MainFieldKey.actualFullLength.rawValue)?.doubleValue,
            primaryColor: mainMap.colorValue(forKey: MainFieldKey.primaryColor.rawValue),
            secondaryColors: [
                mainMap.colorValue(forKey: MainFieldKey.secondaryColor0.rawValue),
                mainMap.colorValue(forKey: MainFieldKey.secondaryColor1.rawValue),
                mainMap.colorValue(forKey: MainFieldKey.secondaryColor2.rawValue),
                mainMap.colorValue(forKey: MainFieldKey.secondaryColor3.rawValue),
                mainMap.colorValue(forKey: MainFieldKey.secondaryColor4.rawValue),
            ].compactMap { $0 },
            transmissionDistance: mainMap.value(forIntKey: MainFieldKey.transmissionDistance.rawValue)?.doubleValue,
            tags: mainMap.enumArrayValue(forKey: MainFieldKey.tags.rawValue),
            density: mainMap.value(forIntKey: MainFieldKey.density.rawValue)?.doubleValue,
            filamentDiameter: mainMap.value(forIntKey: MainFieldKey.filamentDiameter.rawValue)?.doubleValue,
            shoreHardnessA: mainMap.value(forIntKey: MainFieldKey.shoreHardnessA.rawValue)?.intValue,
            shoreHardnessD: mainMap.value(forIntKey: MainFieldKey.shoreHardnessD.rawValue)?.intValue,
            certifications: mainMap.enumArrayValue(forKey: MainFieldKey.certifications.rawValue),
            minNozzleDiameter: mainMap.value(forIntKey: MainFieldKey.minNozzleDiameter.rawValue)?.doubleValue,
            minPrintTemperature: mainMap.value(forIntKey: MainFieldKey.minPrintTemperature.rawValue)?.intValue,
            maxPrintTemperature: mainMap.value(forIntKey: MainFieldKey.maxPrintTemperature.rawValue)?.intValue,
            preheatTemperature: mainMap.value(forIntKey: MainFieldKey.preheatTemperature.rawValue)?.intValue,
            minBedTemperature: mainMap.value(forIntKey: MainFieldKey.minBedTemperature.rawValue)?.intValue,
            maxBedTemperature: mainMap.value(forIntKey: MainFieldKey.maxBedTemperature.rawValue)?.intValue,
            minChamberTemperature: mainMap.value(forIntKey: MainFieldKey.minChamberTemperature.rawValue)?.intValue,
            maxChamberTemperature: mainMap.value(forIntKey: MainFieldKey.maxChamberTemperature.rawValue)?.intValue,
            chamberTemperature: mainMap.value(forIntKey: MainFieldKey.chamberTemperature.rawValue)?.intValue,
            dryingTemperature: mainMap.value(forIntKey: MainFieldKey.dryingTemperature.rawValue)?.intValue,
            dryingTime: mainMap.value(forIntKey: MainFieldKey.dryingTime.rawValue)?.intValue,
            containerWidth: mainMap.value(forIntKey: MainFieldKey.containerWidth.rawValue)?.intValue,
            containerOuterDiameter: mainMap.value(forIntKey: MainFieldKey.containerOuterDiameter.rawValue)?.intValue,
            containerInnerDiameter: mainMap.value(forIntKey: MainFieldKey.containerInnerDiameter.rawValue)?.intValue,
            containerHoleDiameter: mainMap.value(forIntKey: MainFieldKey.containerHoleDiameter.rawValue)?.intValue,
            containerVolumetricCapacity: mainMap.value(forIntKey: MainFieldKey.containerVolumetricCapacity.rawValue)?.doubleValue,
            viscosity18C: mainMap.value(forIntKey: MainFieldKey.viscosity18C.rawValue)?.doubleValue,
            viscosity25C: mainMap.value(forIntKey: MainFieldKey.viscosity25C.rawValue)?.doubleValue,
            viscosity40C: mainMap.value(forIntKey: MainFieldKey.viscosity40C.rawValue)?.doubleValue,
            viscosity60C: mainMap.value(forIntKey: MainFieldKey.viscosity60C.rawValue)?.doubleValue,
            cureWavelength: mainMap.value(forIntKey: MainFieldKey.cureWavelength.rawValue)?.intValue,
            consumedWeight: auxMap?.value(forIntKey: AuxFieldKey.consumedWeight.rawValue)?.doubleValue,
            workgroup: auxMap?.value(forIntKey: AuxFieldKey.workgroup.rawValue)?.stringValue,
            generalPurposeRangeUser: auxMap?.value(forIntKey: AuxFieldKey.generalPurposeRangeUser.rawValue)?.stringValue,
            lastStirTime: auxMap?.dateValue(forKey: AuxFieldKey.lastStirTime.rawValue)
        )
    }
}

// MARK: - CBORValue parsing helpers

private extension CBORValue {
    func uuidValue(forKey key: Int) -> UUID? {
        guard let bytes = value(forIntKey: key)?.bytesValue, bytes.count == 16 else {
            return nil
        }
        return UUID(uuid: bytes.withUnsafeBytes { $0.load(as: uuid_t.self) })
    }

    func dateValue(forKey key: Int) -> Date? {
        guard let raw = value(forIntKey: key) else { return nil }
        if let seconds = raw.doubleValue {
            return Date(timeIntervalSince1970: seconds)
        }
        return nil
    }

    func colorValue(forKey key: Int) -> OpenPrintTagColor? {
        guard let bytes = value(forIntKey: key)?.bytesValue else { return nil }
        guard bytes.count >= 3 else { return nil }
        let r = bytes[bytes.startIndex]
        let g = bytes[bytes.startIndex + 1]
        let b = bytes[bytes.startIndex + 2]
        let a: UInt8 = bytes.count >= 4 ? bytes[bytes.startIndex + 3] : 255
        return OpenPrintTagColor(r: r, g: g, b: b, a: a)
    }

    func enumValue<T: RawRepresentable>(forKey key: Int) -> T? where T.RawValue == Int {
        guard let raw = value(forIntKey: key)?.intValue else { return nil }
        return T(rawValue: raw)
    }

    func enumArrayValue<T: RawRepresentable>(forKey key: Int) -> [T] where T.RawValue == Int {
        guard let items = value(forIntKey: key)?.arrayValue else { return [] }
        return items.compactMap { $0.intValue.flatMap { T(rawValue: $0) } }
    }
}
