---
description: Swift Package Manager 와 CocoaPods 로 TnkPpiHyb SDK 를 설치하는 방법. iOS 14.0 이상, Swift 5.9, xcframework 바이너리 배포입니다.
---

# 1. 설치

## 빌드 요구사항

| 항목 | 값 |
|------|-----|
| 배포 타깃 | **iOS 14.0** 이상 |
| Swift | **5.9** |
| 배포 형태 | xcframework (바이너리) |
| 지원 아키텍처 | 실기기 `arm64`, 시뮬레이터 `arm64` · `x86_64` |

SDK 는 `UIKit`, `WebKit`, `CryptoKit`, `AdSupport`, `AppTrackingTransparency`, `CoreTelephony`
프레임워크를 사용합니다. 별도로 링크하실 필요는 없습니다.

> 개인정보 보호 매니페스트(`PrivacyInfo.xcprivacy`)가 SDK 에 포함되어 있어
> App Store 제출 시 별도 작업이 필요하지 않습니다.

---

## Swift Package Manager

Xcode → **File → Add Package Dependencies** 에 아래 URL 을 입력하고 버전을 선택합니다.

```
https://github.com/tnkad/ios-ppi-hyb-sdk
```

`Package.swift` 를 직접 쓰는 경우:

```swift
dependencies: [
    .package(url: "https://github.com/tnkad/ios-ppi-hyb-sdk", from: "0.1.0")
]
```

---

## CocoaPods

`Podfile`

```ruby
platform :ios, '14.0'

target 'YourApp' do
  use_frameworks!
  pod 'TnkPpiHyb'
end
```

```sh
pod install
open YourApp.xcworkspace     # .xcodeproj 가 아님에 주의
```

> CocoaPods 워크스페이스를 쓰면서 SPM 으로 이 SDK 를 추가해도 됩니다. 둘 중 편한 쪽을 고르세요.

---

## 설치 확인

```swift
import TnkPpiHyb

print(TnkPpiHybSdk.version)
```

---

다음: [2. Info.plist 설정](plist.md)
