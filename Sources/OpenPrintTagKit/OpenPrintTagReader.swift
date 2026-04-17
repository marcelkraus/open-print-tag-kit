@preconcurrency import CoreNFC
import Foundation

/// Reads an OpenPrintTag NFC tag (ISO 15693) and returns the decoded data.
@MainActor
public final class OpenPrintTagReader: NSObject {
    /// Whether NFC tag reading is available on the current device.
    public static var isAvailable: Bool { NFCTagReaderSession.readingAvailable }

    /// The message displayed in the system NFC scan sheet.
    public var scanAlertMessage = "Hold iPhone near the filament spool."

    /// The message displayed after a successful scan.
    public var successAlertMessage = "Filament tag read successfully."

    private var continuation: CheckedContinuation<OpenPrintTagData, Error>?
    private var session: NFCTagReaderSession?

    override public init() {
        super.init()
    }

    /// Starts an NFC scan and returns the decoded tag data.
    ///
    /// Throws `OpenPrintTagError.notSupported` if NFC is unavailable on this
    /// device, or any other `OpenPrintTagError` case on failure.
    public func scan() async throws -> OpenPrintTagData {
        guard NFCTagReaderSession.readingAvailable else {
            throw OpenPrintTagError.notSupported
        }
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            guard let newSession = NFCTagReaderSession(
                pollingOption: .iso15693,
                delegate: self,
                queue: .main
            ) else {
                continuation.resume(throwing: OpenPrintTagError.notSupported)
                return
            }
            newSession.alertMessage = scanAlertMessage
            session = newSession
            newSession.begin()
        }
    }

    // MARK: - Private

    private func finish(with result: Result<OpenPrintTagData, Error>) {
        continuation?.resume(with: result)
        continuation = nil
        session = nil
    }
}

// MARK: - NFCTagReaderSessionDelegate

extension OpenPrintTagReader: NFCTagReaderSessionDelegate {
    public nonisolated func tagReaderSessionDidBecomeActive(_: NFCTagReaderSession) {
        // Intentionally left blank.
    }

    public nonisolated func tagReaderSession(
        _: NFCTagReaderSession,
        didInvalidateWithError error: Error
    ) {
        Task { @MainActor in
            let nfcError = error as? NFCReaderError
            if nfcError?.code == .readerSessionInvalidationErrorUserCanceled {
                finish(with: .failure(OpenPrintTagError.cancelled))
            } else {
                finish(with: .failure(OpenPrintTagError.sessionFailed(error)))
            }
        }
    }

    public nonisolated func tagReaderSession(
        _ session: NFCTagReaderSession,
        didDetect tags: [NFCTag]
    ) {
        guard let tag = tags.first else { return }
        let successMessage = Task { @MainActor in self.successAlertMessage }

        session.connect(to: tag) { error in
            if let error {
                session.invalidate(errorMessage: error.localizedDescription)
                Task { @MainActor [weak self] in
                    self?.finish(with: .failure(OpenPrintTagError.sessionFailed(error)))
                }
                return
            }

            guard case let .iso15693(iso15693Tag) = tag else {
                session.invalidate()
                Task { @MainActor [weak self] in
                    self?.finish(with: .failure(OpenPrintTagError.notOpenPrintTag))
                }
                return
            }

            iso15693Tag.readNDEF { message, error in
                if error != nil {
                    session.invalidate()
                    Task { @MainActor [weak self] in
                        self?.finish(with: .failure(OpenPrintTagError.notOpenPrintTag))
                    }
                    return
                }

                guard let message else {
                    session.invalidate()
                    Task { @MainActor [weak self] in
                        self?.finish(with: .failure(OpenPrintTagError.notOpenPrintTag))
                    }
                    return
                }

                let mimeType = "application/vnd.openprinttag"
                let record = message.records.first {
                    guard $0.typeNameFormat == .media else {
                        return false
                    }
                    let typeString = String(data: $0.type, encoding: .utf8)?
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                        .lowercased()
                    return typeString == mimeType
                }

                guard let record else {
                    session.invalidate()
                    Task { @MainActor [weak self] in
                        self?.finish(with: .failure(OpenPrintTagError.notOpenPrintTag))
                    }
                    return
                }

                Task { @MainActor [weak self] in
                    do {
                        let data = try OpenPrintTagParser.parse(payload: record.payload)
                        session.alertMessage = await successMessage.value
                        session.invalidate()
                        self?.finish(with: .success(data))
                    } catch {
                        session.invalidate()
                        self?.finish(with: .failure(OpenPrintTagError.invalidCBOR))
                    }
                }
            }
        }
    }
}
