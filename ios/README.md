---
description: TnkFactory 하이브리드 오퍼월 SDK(iOS) 빠른 시작. 설치, Info.plist 문구, 앱 ID, 사용자 식별값, 동의 전달, 추적 허용(ATT) 요청, 오퍼월 열기까지 7단계 최소 연동을 안내합니다.
---

# TnkPpiHyb — 하이브리드 오퍼월 SDK 연동 가이드 (iOS)

이 페이지에서 하는 일: 7단계로 iOS 앱에 오퍼월을 붙입니다. 마지막 단계까지 마치면 버튼을 눌러 오퍼월을 열 수 있습니다.

오퍼월 화면은 SDK 가 앱 안에 띄우는 웹 화면으로 제공됩니다. 화면 개선이나 개발사별 맞춤 설정(담당자에게 요청)은 TnkFactory 가 적용하며, 앱을 다시 배포하지 않아도 반영됩니다.
Android 와 iOS 는 같은 오퍼월 화면을 사용하므로 사용자가 보는 화면은 같습니다.

---

## 언제 필요한가

iOS 앱에 오퍼월을 처음 붙이는 모든 개발사에게 필요합니다(필수).
이미 기존 네이티브 SDK(`TnkRwdSdk2`)를 쓰고 있다면 [네이티브 SDK 에서 이관](migration.md)을 먼저 보세요.

시작하기 전에 [퍼블리셔 페이지](../publisher/app-id.md)에서 앱을 등록하고 아래 두 가지를 발급받아야 합니다.

| 항목 | 설명 |
|------|------|
| **개발사 앱 ID** (`tnkad_app_id`) | 앱마다 발급되는 UUID 형식의 식별자 |
| **앱 키** (`app_key`) | 서버 보상 콜백 검증에 사용. 개발사 백엔드에서만 사용하며 앱에 넣지 않습니다 |

> ⚠️ TNK 는 **번들 ID(Bundle Identifier)로 앱을 식별**합니다. 퍼블리셔 페이지에 등록한 번들 ID 와 실제 앱의 번들 ID 가 다르면 오퍼월이 정상적으로 표시되지 않을 수 있습니다.
> 테스트용으로 번들 ID 를 따로 쓰는 빌드(예: 접미사가 붙은 빌드)가 있다면, 그 번들 ID 로 앱을 하나 더 등록하고 거기서 발급된 APP ID 를 해당 빌드에 넣어 주세요. 설정이 어려우면 담당자에게 문의해 주세요.

## 개발 환경 요약

| 항목 | 값 |
|------|-----|
| 최소 지원 | **iOS 15.0** |
| 호출 언어 | Swift |
| 배포 형태 | xcframework (Swift Package Manager · CocoaPods) |

자세한 요구사항은 [1. 설치](install.md)를 보세요.

---

## 빠른 시작

아래 7단계를 순서대로 따라 하면 됩니다. 각 단계 끝의 **안 하면** 은 그 단계를 건너뛰었을 때 생기는 일입니다.

### 1. 설치 (Swift Package Manager)

Xcode → **File → Add Package Dependencies** 에 아래 URL 을 입력합니다.

```
https://github.com/tnkad/ios-ppi-hyb-sdk
```

Dependency Rule 은 **Up to Next Major Version** 으로 두고 버전 칸에는 [릴리스 노트](changelog.md)의 최신 버전을 입력합니다. 그러면 1.x 의 최신 버전을 받습니다. 추가할 타깃은 앱 타깃을 선택합니다.
CocoaPods 로 설치하는 방법은 [1. 설치](install.md)를 보세요.

**안 하면:** SDK 를 가져오지 못해 `import TnkPpiHyb` 가 되지 않고, 빌드가 실패합니다.

### 2. Info.plist 에 권한 문구 추가

iOS 가 사용자에게 보여 주는 권한 안내 문구입니다. 이 문구가 있어야 팝업이 뜨고 기능이 동작합니다.

```xml
<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 광고 제공을 위해 기기 광고 식별자(IDFA)를 사용합니다.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>문의하기에 캡처 이미지를 첨부하기 위해 사진 보관함을 사용합니다.</string>

<key>NSCameraUsageDescription</key>
<string>문의하기에 첨부할 사진을 촬영하기 위해 카메라를 사용합니다.</string>
```

**안 하면:** `NSUserTrackingUsageDescription` 문구가 없으면 추적 허용(ATT) 팝업이 뜨지 않거나, 요청하는 순간 앱이 종료될 수 있습니다. `NSCameraUsageDescription` 이 없으면 오퍼월 '문의하기'에서 카메라 촬영을 선택하는 순간 앱이 종료됩니다.
각 키가 쓰이는 때와 마이크·앱 ID 설정은 [2. Info.plist 설정](plist.md)을 보세요.

### 3. 앱 ID 설정과 초기화

앱이 시작될 때 한 번 호출합니다. `SceneDelegate.scene(_:willConnectTo:options:)` 또는 `AppDelegate.application(_:didFinishLaunchingWithOptions:)` 에 두면 됩니다.

```swift
import TnkPpiHyb

let sdk = TnkPpiHybSdk.shared

#if DEBUG
sdk.enableLogging(true)                       // 디버그 빌드에서만 SDK 로그 출력
#endif

sdk.configure(appId: "발급받은-앱-아이디")      // 다른 SDK 함수보다 먼저 호출
sdk.applicationStarted()                      // (선택) 앱 실행 신호
```

`Info.plist` 에 `tnkad_app_id` 를 넣어 두었다면 `configure(appId:)` 호출은 생략할 수 있습니다. 두 방식을 함께 쓸 때의 순서는 [2. Info.plist 설정](plist.md)을 보세요.
`applicationStarted()` 는 현재 SDK 에서는 호출해도 오퍼월 동작이 달라지지 않습니다. Android 와 같은 코드 구성을 유지하려고 두어도 됩니다.

**안 하면:** 앱 ID 가 없으면 TNK 가 어느 앱인지 알 수 없어 오퍼월이 정상적으로 열리지 않을 수 있습니다. 로그를 켜지 않으면 Xcode 콘솔에 SDK 로그가 나오지 않습니다.

### 4. 사용자 식별값 설정

개발사 서비스의 회원 ID 처럼 사용자를 고유하게 구분하는 값을 넘깁니다. 이 값이 **보상 지급의 기준**입니다.

```swift
sdk.setUserName("개발사-사용자-식별값")
```

사용자 식별값을 이전과 다른 값으로 바꾸면(계정 전환, 최초 설정 포함) 개인정보 수집 동의가 초기화되어, 오퍼월을 열 때 동의 팝업이 다시 나옵니다. 앱에서 동의를 받는 경우에는 이어서 5단계의 `setAgreePrivacy` 를 호출하세요.
같은 값을 다시 설정하면 동의 상태는 그대로 유지됩니다.

**안 하면:** 보상을 받을 사용자를 구분할 수 없습니다. 반드시 설정해 주세요.

### 5. (선택) 앱에서 받은 개인정보 수집 동의 전달

앱에서 이미 개인정보 수집 동의를 받았다면, **`setUserName` 다음에** 동의 상태를 넘깁니다.

```swift
sdk.setUserName("개발사-사용자-식별값")
sdk.setAgreePrivacy(true)   // 사용자가 앱에서 동의한 경우에만
```

| 호출 | 오퍼월을 열 때 사용자가 보는 것 | 언제 쓰나 |
|------|------|------|
| `setAgreePrivacy(true)` | 동의 팝업 없이 오퍼월이 바로 열립니다. 오퍼월 도움말에는 '개인 정보 수집 동의 해제' 링크가 나오지 않습니다 | 앱에서 개인정보 수집 동의를 직접 받은 경우 |
| `setAgreePrivacy(false)` | 다음에 열 때 동의 팝업이 나옵니다(오퍼월 안에서 동의한 적이 있어도 다시 묻습니다). 이미 열려 있는 오퍼월은 바뀌지 않습니다 | 동의 철회에는 쓰지 마세요. 철회는 `revokePrivacyConsent` 를 사용합니다 |
| 호출하지 않음 | 처음 열 때 동의 팝업이 먼저 나옵니다. 동의하면 다음부터는 나오지 않고, 거부하면 안내 화면이 나옵니다(다음에 들어갈 때 다시 묻습니다) | 앱에서 동의를 받지 않는 경우(기본) |

<figure><img src="../assets/common/compare-consent-not-agreed-vs-agreed.png" alt="왼쪽은 동의 팝업이 보이는 오퍼월, 오른쪽은 팝업 없이 바로 목록이 보이는 오퍼월" width="600"><figcaption><p>왼쪽은 동의 전달을 하지 않았을 때, 오른쪽은 setAgreePrivacy(true) 로 전달했을 때의 첫 화면입니다. 오퍼월 화면은 Android·iOS 가 같습니다.</p></figcaption></figure>

**안 하면:** 오류가 아닙니다. 사용자가 오퍼월 안의 동의 팝업에서 직접 동의합니다.

> ⚠️ 앱에서 동의를 받은 경우 오퍼월 안에는 동의 해제 메뉴가 나오지 않으므로, 동의를 해제하는 수단은 앱에서 제공해 주세요.
> 앱에서 동의를 철회한 사용자에게는 `true` 를 다시 넘기지 마세요. 철회가 취소됩니다.
> 자세한 내용과 나머지 값은 [7. 개인정보 설정](privacy.md)을 보세요.

### 6. 추적 허용(ATT) 요청

광고 식별자(IDFA)를 쓰려면 사용자의 추적 허용이 필요합니다. 앱이 활성 상태가 된 뒤(`sceneDidBecomeActive` 권장)에 한 번 요청합니다. 3단계의 시작 코드와는 따로 호출합니다.

```swift
// SceneDelegate.swift
private var didRequestATT = false

func sceneDidBecomeActive(_ scene: UIScene) {
    guard !didRequestATT else { return }
    didRequestATT = true
    TnkPpiHybSdk.shared.requestTrackingAuthorization { granted in
        // granted == true: 사용자가 허용 → 광고 식별자(IDFA)를 사용합니다
    }
}
```

앱이 아직 활성 상태가 아니어도 SDK 가 활성화될 때까지 기다렸다가 팝업을 띄웁니다. 그래도 사용자가 앱 화면을 본 뒤에 묻는 것이 자연스러우므로 `sceneDidBecomeActive` 를 권장합니다 — [3. 초기화](initialize.md)의 'ATT 동의 요청' 항목

| 사용자 선택 | `granted` | 이후 |
|------|:-:|------|
| 허용 | `true` | 광고 식별자(IDFA)가 전달됩니다 |
| 허용 안 함 · 제한 | `false` | IDFA 가 0 으로만 채워져 전달됩니다. 오퍼월은 열리지만 참여할 수 있는 광고가 줄어들 수 있습니다 |
| 이미 선택한 적 있음 | 선택한 결과 | iOS 정책상 팝업이 다시 뜨지 않고 결과만 돌려줍니다 |

<figure><img src="../assets/ios/att-system-prompt.png" alt="iOS 시스템의 추적 허용 팝업. 앱 이름과 사용 목적 문구, 앱에 추적 금지 요청과 허용 버튼이 있음" width="300"><figcaption><p>앱이 추적 허용을 요청하면 iOS 가 이 팝업을 보여 줍니다. 회색 안내 문구는 Info.plist 에 적은 내용이고, 앱 이름은 앱마다 다릅니다.</p></figcaption></figure>

**안 하면:** ATT 팝업이 뜨지 않아 광고 식별자(IDFA)가 0 으로 전달됩니다. 오퍼월은 열리지만 참여할 수 있는 광고가 줄어들 수 있습니다.

### 7. 오퍼월 열기

버튼 액션 등 사용자가 오퍼월을 열 때 호출합니다. 오퍼월이 전체 화면으로 열립니다.

```swift
@objc private func openOfferwall() {
    TnkPpiHybSdk.shared.openOfferwall(from: self)
}
```

<figure><img src="../assets/ios/ios-fullscreen-device.png" alt="iOS 기기 전체 화면에 열린 오퍼월. 위에 상태 바, 오퍼월 헤더와 탭, 검색창, 광고 목록이 보임" width="300"><figcaption><p>오퍼월은 기기 화면 전체를 사용하는 전체 화면으로 열립니다.</p></figcaption></figure>

**안 하면:** 이 호출이 있어야 오퍼월이 열립니다. 열리지 않으면 [문제 해결](troubleshooting.md)을 확인하세요.

> ⚠️ 포인트 지급은 앱이 아니라 **서버 보상 콜백**으로 처리합니다. 앱의 `setRewardListener` 는 화면 갱신용입니다(사용법은 [5. 보상 지급 수신](reward.md)). → [서버 보상 콜백 URL](../common/server-callback.md)

### 전체 코드

위 단계를 모으면 다음과 같습니다. 시작 코드(3~5단계)와 ATT 요청(6단계)은 `SceneDelegate` 의 서로 다른 메서드에 두고, 오퍼월 열기(7단계)는 오퍼월을 여는 화면에 둡니다.

```swift
// SceneDelegate.swift
import UIKit
import TnkPpiHyb

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var didRequestATT = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // 3~5. 앱 시작 시 한 번 (AppDelegate 를 쓰는 앱은 application(_:didFinishLaunchingWithOptions:))
        let sdk = TnkPpiHybSdk.shared

        #if DEBUG
        sdk.enableLogging(true)
        #endif

        sdk.configure(appId: "발급받은-앱-아이디")
        sdk.applicationStarted()
        sdk.setUserName("개발사-사용자-식별값")        // 보상 지급의 기준값

        // sdk.setAgreePrivacy(true)                 // (선택) 앱에서 동의를 받은 경우에만
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // 6. ATT 는 앱이 활성 상태가 된 뒤 한 번
        guard !didRequestATT else { return }
        didRequestATT = true
        TnkPpiHybSdk.shared.requestTrackingAuthorization { granted in }
    }
}
```

```swift
// 오퍼월을 여는 화면(UIViewController)에서 — 7. 오퍼월 열기
@objc private func openOfferwall() {
    TnkPpiHybSdk.shared.openOfferwall(from: self)
}
```

샘플 코드: [tnkad/ios-ppi-hyb-sample](https://github.com/tnkad/ios-ppi-hyb-sample) — SPM · CocoaPods 예제 앱 각 1개

---

## 다음 단계

| 문서 | 내용 |
|------|------|
| [1. 설치](install.md) | SPM · CocoaPods, 빌드 요구사항, App Store 개인정보 항목 |
| [2. Info.plist 설정](plist.md) | ATT · 사진/카메라 권한 문구, 앱 ID |
| [3. 초기화](initialize.md) | 초기화 순서, 사용자 식별값, ATT 동의 |
| [4. 오퍼월 띄우기](offerwall.md) | 전체 화면으로 열기 / 화면 안에 넣기 |
| [5. 보상 지급 수신](reward.md) | `setRewardListener` 와 `RewardInfo` |
| [6. 딥링크](deeplink.md) | `tnkscheme://` 처리 |
| [7. 개인정보 설정](privacy.md) | 수집 동의, COPPA/GDPR |
| [8. 특정 광고 진입](ad-entry.md) | 배너·푸시에서 특정 광고로 바로 진입 |
| [9. 적립 가능 포인트 조회](total-point.md) | "최대 N포인트 적립 가능" 표시용 |
| [공개 API 목록](api.md) | 전체 시그니처 |
| [네이티브 SDK 에서 이관](migration.md) | 기존 네이티브 SDK(`TnkRwdSdk2`)를 사용 중이라면 |
| [문제 해결](troubleshooting.md) | 자주 겪는 증상과 원인 |
| [릴리스 노트](changelog.md) | 버전별 변경 사항 |
| [서버 보상 콜백 URL](../common/server-callback.md) | **실제 포인트 지급 경로** (개발사 백엔드) |
| [지원 범위](../common/support-matrix.md) | 제공 기능 한눈에 보기 |

---

문의: tech@tnkfactory.com
