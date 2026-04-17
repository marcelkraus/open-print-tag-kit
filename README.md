# OpenPrintTagKit

OpenPrintTagKit is a Swift package for reading [OpenPrintTag](https://openprinttag.org)
NFC tags embedded in 3D printing filament spools. It handles the full pipeline:
scanning an ISO 15693 tag via CoreNFC, parsing the CBOR-encoded payload, and
returning a strongly typed `OpenPrintTagData` value containing material
properties, print temperatures, color information, and more.

> **Experimental — use at your own risk.**
> This framework is under active development and the public API is not yet
> stable. Breaking changes can occur at any time without prior notice.

## Requirements

- iOS 17 or later
- A device with NFC hardware (iPhone 7 or later)

## Installation

Add the package to your project via Swift Package Manager:

```swift
.package(url: "https://github.com/marcelkraus/open-print-tag-kit", from: "0.1.0")
```

## Usage

```swift
import OpenPrintTagKit

let reader = OpenPrintTagReader()
let data = try await reader.scan()

print(data.materialName ?? "Unknown material")
print(data.minPrintTemperature ?? 0)
```

A mock implementation (`OpenPrintTagReaderMock`) is included for use in
previews and unit tests.

## Used in

OpenPrintTagKit will power NFC spool reading in
[3D Printing Cost Calculator](https://apps.apple.com/us/app/3d-printing-cost-calculator/id6502561182)
starting with version 1.8. Learn more about the app at
[www.krausgedruckt.de/app](https://www.krausgedruckt.de/app) (German).

## License

See [LICENSE](LICENSE).
