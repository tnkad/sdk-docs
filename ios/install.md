---
description: Swift Package Manager 와 CocoaPods 로 TnkPpiHyb SDK 를 설치하는 방법. iOS 15.0 이상, xcframework 바이너리 배포이며, App Store 제출 때 개발사가 작성할 개인정보 항목도 안내합니다.
---

# 1. 설치

이 페이지에서 하는 일: Swift Package Manager(SPM) 또는 CocoaPods 로 SDK 를 앱에 추가하고, 설치가 됐는지 확인합니다.

---

## 언제 필요한가

iOS 앱에 SDK 를 붙이는 모든 개발사에게 필요합니다(필수).
SPM 과 CocoaPods 중 **한 가지만** 고르세요.

---

## 빌드 요구사항

| 항목 | 값 |
|------|-----|
| 배포 타깃 | **iOS 15.0** 이상 |
| 호출 언어 | **Swift** — Objective-C 앱은 Swift 파일을 하나 추가해 그 안에서 SDK 를 호출해 주세요. 도움이 필요하면 담당자에게 문의해 주세요 |
| 배포 형태 | xcframework (바이너리) |
| 지원 아키텍처 | 실기기 `arm64`, 시뮬레이터 `arm64` · `x86_64` |
| Xcode | 최신 버전 권장 — SDK 는 최신 Xcode 로 빌드해 배포합니다. 오래된 Xcode 에서 SDK 모듈을 불러오지 못하는 빌드 오류가 나면 Xcode 를 업데이트해 주세요 |

SDK 는 `UIKit`, `WebKit`, `CryptoKit`, `AdSupport`, `AppTrackingTransparency`, `CoreTelephony`
프레임워크를 사용합니다. 별도로 링크하실 필요는 없습니다.

> 💡 빌드 중 SDK 모듈을 불러오지 못하면 Xcode 를 최신으로 업데이트해 보세요. 그래도 해결되지 않으면 오류 메시지와 Xcode 버전을 담당자에게 알려 주세요.

---

## Swift Package Manager

Xcode → **File → Add Package Dependencies** 에 아래 URL 을 입력합니다.

```
https://github.com/tnkad/ios-ppi-hyb-sdk
```

1. **Dependency Rule** 을 **Up to Next Major Version** 으로 두고, 버전 칸에는 [릴리스 노트](changelog.md)의 최신 버전을 입력합니다. 그러면 1.x 의 최신 버전을 받습니다.
2. **Add Package** 를 누릅니다.
3. 추가할 타깃으로 앱 타깃을 선택합니다. 라이브러리 이름은 `TnkPpiHyb` 입니다.

`Package.swift` 를 직접 쓰는 경우에는 패키지 의존성과 **타깃 의존성**을 모두 적어야 합니다.

```swift
dependencies: [
    .package(url: "https://github.com/tnkad/ios-ppi-hyb-sdk", from: "1.0.6")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "TnkPpiHyb", package: "ios-ppi-hyb-sdk")
        ]
    )
]
```

> 💡 패키지 의존성(`.package`)만 적고 타깃 의존성(`.product`)을 빼면 패키지는 받아지지만 `import TnkPpiHyb` 를 쓸 수 없습니다.
> `package:` 에는 URL 의 마지막 이름(`ios-ppi-hyb-sdk`)을, `name:` 에는 라이브러리 이름(`TnkPpiHyb`)을 넣습니다.

---

## CocoaPods

`Podfile`

```ruby
platform :ios, '15.0'

target 'YourApp' do
  use_frameworks!
  pod 'TnkPpiHyb', '~> 1.0'
end
```

`'~> 1.0'` 은 1.x 의 최신 버전을 받습니다.

```sh
pod install
open YourApp.xcworkspace     # .xcodeproj 가 아님에 주의
```

> ⚠️ 한 앱에 SPM 과 CocoaPods 를 **함께 쓰지 마세요.** 같은 SDK 가 중복으로 들어가 빌드나 실행에서 문제가 생길 수 있습니다.
> CocoaPods 를 쓰는 프로젝트라도 이 SDK 만 SPM 으로 추가할 수는 있습니다. 그 경우 `Podfile` 에는 `pod 'TnkPpiHyb'` 를 넣지 않습니다.

---

## 설치 확인

```swift
import TnkPpiHyb

print(TnkPpiHybSdk.version)   // 설치한 SDK 버전이 출력됩니다
```

---

## App Store 제출 때 — 개인정보 항목

SDK 에는 개인정보 보호 매니페스트(`PrivacyInfo.xcprivacy`)가 들어 있지만, 현재 SDK 는 **수집하는 정보와 사용하는 API 를 선언하는 칸이 비어 있습니다**(추적 여부는 `false` 로만 표시됩니다).
따라서 SDK 가 앱의 개인정보 답변을 대신해 주지 않습니다. App Store Connect 의 **앱 개인정보 보호** 항목은 앱 전체 기준으로 개발사가 직접 작성해 주세요.

오퍼월이 사용하는 정보는 다음과 같습니다. 답변을 작성할 때 참고하세요.

| 정보 | 사용하는 경우 |
|------|------|
| 광고 식별자(IDFA) | 사용자가 추적 허용(ATT)을 한 경우 |
| 앱 공급자 식별자(IDFV) | 항상 |
| 개발사 사용자 식별값 | `setUserName` 으로 넘긴 값 |
| 기기·앱 정보 | 기기 모델, iOS 버전, 언어·지역·시간대, 통신사 이름(조회되는 경우), 앱 버전과 번들 ID |
| COPPA · GDPR 설정값 | `setCOPPA` · `setGDPR` 로 설정한 값 |

이 정보는 광고 참여와 보상 처리에 사용됩니다. 위 표는 SDK 코드에서 확인한 항목이며, 최종 답변은 개발사의 개인정보 처리방침과 내부 검토 기준에 맞게 작성해 주세요.
App Store Connect 에 업로드할 때 개인정보 보호 매니페스트 관련 안내가 표시되면 담당자에게 알려 주세요.

---

다음: [2. Info.plist 설정](plist.md)
