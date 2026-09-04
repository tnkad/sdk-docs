---
description: TnkFactory 하이브리드 오퍼월 SDK(iOS) 연동 가이드. SPM · CocoaPods 설치부터 오퍼월 노출과 보상 지급까지 안내합니다.
---

# TnkPpiHyb — 하이브리드 오퍼월 SDK 연동 가이드 (iOS)

TnkFactory 하이브리드 오퍼월 SDK 입니다. 네이티브는 기기 컨텍스트 수집과 WKWebView 호스팅,
JS 브릿지를 담당하고 **오퍼월 화면과 보상 로직은 WebView 안의 웹(FE)이 처리**합니다.
그래서 오퍼월 UI 개선이나 개발사별 커스터마이징은 **앱 업데이트 없이** 반영됩니다.

- 최소 지원: **iOS 14.0** (ATT 사용)
- Swift 5.9 / xcframework 바이너리 배포
- 배포: [Swift Package Manager](install.md#swift-package-manager) · [CocoaPods](install.md#cocoapods)

---

## 연동에 필요한 것

시작하기 전에 [퍼블리셔 페이지](../publisher/app-id.md)에서 앱을 등록하고 아래 두 가지를 발급받으셔야 합니다.

| 항목 | 설명 |
|------|------|
| **개발사 앱 ID** (`tnkad_app_id`) | 앱마다 발급되는 UUID 형식의 식별자 |
| **앱 키** (`app_key`) | 서버 보상 콜백 검증에 사용. 개발사 백엔드에서만 사용하며 앱에 넣지 않습니다 |

---

## 빠른 시작

### 1. 설치 (Swift Package Manager)

Xcode → **File → Add Package Dependencies** 에 아래 URL 을 입력합니다.

```
https://github.com/tnkad/ios-ppi-hyb-sdk
```

### 2. Info.plist 에 ATT 문구 추가

```xml
<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 광고 제공을 위해 기기 광고 식별자(IDFA)를 사용합니다.</string>
```

### 3. 초기화하고 오퍼월 띄우기

```swift
import TnkPpiHyb

let sdk = TnkPpiHybSdk.shared
sdk.enableLogging(true)
sdk.configure(appId: "발급받은-앱-아이디")
sdk.setUserName("개발사-사용자-식별값")   // 보상 지급의 기준값
sdk.applicationStarted()

sdk.setRewardListener { reward in
    print("적립: \(reward.payPoint)\(reward.pointUnit ?? "")")
}

// 버튼 액션에서
sdk.openOfferwall(from: self)
```

ATT 동의 요청은 **앱이 활성 상태일 때만** 팝업이 뜹니다.

```swift
func sceneDidBecomeActive(_ scene: UIScene) {
    guard !didRequestATT else { return }
    didRequestATT = true
    TnkPpiHybSdk.shared.requestTrackingAuthorization { granted in }
}
```

---

## 다음 단계

| 문서 | 내용 |
|------|------|
| [1. 설치](install.md) | SPM · CocoaPods, 빌드 요구사항 |
| [2. Info.plist 설정](plist.md) | ATT · 사진/카메라 권한 문구, 앱 ID |
| [3. 초기화](initialize.md) | 초기화 순서, 사용자 식별값, ATT 동의 |
| [4. 오퍼월 띄우기](offerwall.md) | 풀스크린 / 뷰 삽입 |
| [5. 보상 지급 수신](reward.md) | `setRewardListener` 와 `RewardInfo` |
| [6. 딥링크](deeplink.md) | `tnkscheme://` 처리 |
| [7. 개인정보 · 사용자 속성](privacy.md) | 동의, COPPA/GDPR, 연령/성별 |
| [공개 API 목록](api.md) | 전체 시그니처 |
| [네이티브 SDK 에서 이관](migration.md) | `TnkRwdSdk2` 를 사용 중이라면 |
| [문제 해결](troubleshooting.md) | 자주 겪는 증상과 원인 |
| [서버 보상 콜백 URL](../common/server-callback.md) | **실제 포인트 지급 경로** (개발사 백엔드) |
| [지원 범위](../common/support-matrix.md) | 제공 / 미제공 기능 |

샘플 코드: [tnkad/ios-ppi-hyb-sample](https://github.com/tnkad/ios-ppi-hyb-sample) — SPM · CocoaPods 예제 앱 각 1개

---

문의: tech@tnkfactory.com
