# Voltaserve Swift

## Getting Started

Prerequisites:
- Install [Swift](https://www.swift.org/) via [Xcode](https://developer.apple.com/xcode/) or [Swift Version Manager](https://github.com/kylef/swiftenv), the supported Swift version is 5.10.
- Install [SwiftFormat](https://github.com/nicklockwood/SwiftFormat).
- Install [SwiftLint](https://github.com/realm/SwiftLint).

This is a Swift package, it can be installed using the [Swift Package Manager](https://www.swift.org/documentation/package-manager/) and  imported in your code as follows:

```swift
import Voltaserve
```

Format code:

```
swiftformat .
```

Lint code:

```
swiftlint .
```

## Tests

Build Docker image:

```shell
docker build -t voltaserve/swift-tests .
```

The test suite expects the following accounts to exist:

| Email                   | Password    |
| ----------------------- | ----------- |
| test@koupr.com          | `Passw0rd!` |
| test+1@koupr.com        | `Passw0rd!` |

Run with Docker:

```shell
docker run --rm \
    -e API_HOST=host.docker.internal \
    -e IDP_HOST=host.docker.internal \
    -e USERNAME='test@koupr.com' \
    -e PASSWORD='Passw0rd!' \
    voltaserve/tests
```

In Linux you should replace `host.docker.internal` with the host IP address, it can be found as follows:

```shell
ip route | grep default | awk '{print $3}'
```
