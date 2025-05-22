# AsyncLocation

[![Swift](https://img.shields.io/badge/Swift-6.1%2B-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20%7C%20watchOS%20macOS-lightgrey.svg)](#platform-support)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

**AsyncLocation** is a lightweight Swift package that provides an `async/await`-based wrapper around `CLLocationManager`.

---

## ✨ Features

- ✅ Simple `async/await` API
- ✅ Async location authorization request
- ✅ Async location request

---

## 🔧 Installation

### Swift Package Manager (SPM)

Add this package to your dependencies in `Package.swift`:

```swift
.package(url: "https://github.com/mikaoj/AsyncLocation.git", from: "1.0.0")
```

Then add `"AsyncLocation"` to your target dependencies:

```swift
.target(
  name: "YourApp",
  dependencies: [
    "AsyncLocation"
  ]
)
```

Or install via Xcode:

1. Go to **File > Add Packages…**
2. Paste the URL: `https://github.com/mikaoj/AsyncLocation.git`

---

## 📦 Usage

```swift
import AsyncLocation
import CoreLocation

let manager = AsyncLocationManager()

let status = await manager.requestWhenInUseAuthorization()
let locations = await manager.requestLocation()
if let location = locations.first {
    print("Location: \(location.coordinate.latitude), \(location.coordinate.longitude)")
}
```

---

## 📱 Platform Support

| Platform | Support        |
|----------|----------------|
| iOS      | ✅ iOS 14+     |
| watchOS  | ✅ watchOS 7+  |
| macOS    | ✅ macOS 11+   |
