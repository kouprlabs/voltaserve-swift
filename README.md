# Voltaserve Swift

## Getting Started

Prerequisites:

- Install [Swift](https://www.swift.org/) via [Xcode](https://developer.apple.com/xcode/) or [Swift Version Manager](https://github.com/kylef/swiftenv), the supported Swift version is 5.10.
- Install [SwiftLint](https://github.com/realm/SwiftLint).

This is a Swift package, it can be installed using the [Swift Package Manager](https://www.swift.org/documentation/package-manager/) and imported in your code as follows:

```swift
import VoltaserveCore
```

Format code:

```shell
swift format -i -r .
```

Lint code:

```shell
swift format lint -r .
```

```shell
swiftlint lint --strict .
```

## Tests

The test suite expects the following accounts to exist:

| Email            | Password    |
| ---------------- | ----------- |
| test@koupr.com   | `Passw0rd!` |
| test+1@koupr.com | `Passw0rd!` |

Build and run with Docker:

```shell
docker build -t voltaserve/swift-tests . && docker run --rm \
    -e API_HOST=host.docker.internal \
    -e IDP_HOST=host.docker.internal \
    -e USERNAME='test@koupr.com' \
    -e PASSWORD='Passw0rd!' \
    -e OTHER_USERNAME='test+1@koupr.com' \
    -e OTHER_PASSWORD='Passw0rd!' \
    voltaserve/swift-tests
```

In Linux you should replace `host.docker.internal` with the host IP address, it can be found as follows:

```shell
ip route | grep default | awk '{print $3}'
```

## Licensing

Voltaserve Swift is released under the [MIT License](LICENSE).
