import Foundation

public enum OpenPrintTagError: Error, Sendable {
    /// NFC is not available on this device.
    case notSupported

    /// The user cancelled the NFC scan.
    case cancelled

    /// An NFC tag was found but it is not an OpenPrintTag.
    case notOpenPrintTag

    /// The tag payload could not be decoded as valid CBOR.
    case invalidCBOR

    /// The NFC session encountered an error.
    case sessionFailed(Error)
}
