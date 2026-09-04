---
description: 네이티브 오퍼월 SDK(TnkRwdSdk2)에서 하이브리드 SDK 로 옮길 때의 체크리스트와, 그대로 쓸 수 있는 호출·걷어낼 호출 목록입니다.
---

# 네이티브 SDK 에서 이관

네이티브 오퍼월 SDK(`TnkRwdSdk2`)를 사용 중인 개발사를 위한 문서입니다.
신규 연동이라면 이 페이지는 건너뛰셔도 됩니다.

---

## 무엇이 달라졌나

네이티브 SDK 는 광고 목록·상세·포인트 화면을 **앱 안에서 직접** 그립니다.
하이브리드 SDK 는 그 화면들을 **WebView 안의 웹(FE)** 이 그립니다.

그래서 이관 원칙이 이렇게 정리됩니다.

- **세션 · 식별 · 설정 계열** → 시그니처를 그대로 유지했습니다. 진입점만 바꾸면 됩니다.
- **포인트 조회 · 아이템 구매 · 인출 등 RPC 계열** → **제공하지 않습니다.**
  해당 기능은 오퍼월 화면(FE) 안에서 처리되므로 개발사 코드에서 제거하시면 됩니다.

---

## 이관 체크리스트

- [ ] 의존성을 `TnkRwdSdk2` → `TnkPpiHyb` 로 교체 (SPM 또는 CocoaPods)
- [ ] `import TnkRwdSdk2` → `import TnkPpiHyb`
- [ ] `TnkSession.initInstance(appId:)` + `sharedInstance()` → `TnkPpiHybSdk.shared.configure(appId:)`
- [ ] `AdOfferwallViewController` present 코드 → `openOfferwall(from:)`
- [ ] 포인트/RPC 호출부(`queryPoint`, `purchaseItem` 등) 제거
- [ ] `OfferwallEventListener` → `setRewardListener` / `setEventListener`
- [ ] ATT 요청을 `requestTrackingAuthorization` 으로 교체
- [ ] `Info.plist` 의 `tnkad_app_id` · `NSUserTrackingUsageDescription` 은 **그대로 유지** (변경 없음)
- [ ] 서버 콜백 URL 구현은 **그대로 유지** (변경 없음)

---

## 그대로 쓸 수 있는 것

| 네이티브 SDK | 하이브리드 SDK |
|---|---|
| `TnkSession.initInstance(appId:)` / `sharedInstance()` | `TnkPpiHybSdk.shared.configure(appId:)` |
| `sharedInstance()?.applicationStarted()` | `TnkPpiHybSdk.shared.applicationStarted()` |
| `sharedInstance()?.setUserName(_:)` | `TnkPpiHybSdk.shared.setUserName(_:)` / `getUserName()` |
| `Info.plist` 의 `tnkad_app_id` | 동일하게 읽습니다. 넣어두면 `configure` 생략 가능 |
| `Info.plist` 의 `NSUserTrackingUsageDescription` | 동일하게 필요합니다 |
| 서버 보상 콜백 URL 계약 | 동일 |

`applicationStarted()` 와 `setUserName(_:)` 은 **이름이 그대로**라 호출부를 고치실 필요가 없습니다.

---

## 코드에서 걷어낼 호출

아래 호출들은 하이브리드 SDK 에 없습니다. **컴파일 오류가 나는 지점을 찾는 용도**로 쓰세요.
기능 관점에서 무엇이 제공되고 무엇이 안 되는지는 [지원 범위](../common/support-matrix.md)를 보시면 됩니다.

| 네이티브 SDK | 대체 |
|---|---|
| `queryPoint` / `queryPublishState` / `queryAdvertiseCount` | 오퍼월(FE)이 조회·표시 |
| `purchaseItem(_:cost:)` / `withdrawPoints(_:)` | 오퍼월(FE) |
| `actionCompleted(actionName:)` | 지급은 서버가 처리, 완료 통지는 `setRewardListener` |
| `presentAdDetailView(...)` / `adJoin(...)` | 오퍼월(FE) 상세 화면 |
| `openPrivacyTermAlert(...)` | 오퍼월(FE) 동의 화면 (`setAgreePrivacy(true)` 로 건너뛸 수 있음) |
| `OfferwallEventListener` (`didAdDataLoaded` / `didAdItemClicked` / `didOfferwallRemoved` …) | `setRewardListener` (지급 완료) / `setEventListener` (범용) |
| `AdPlacementView` | 제공하지 않습니다. 사용 중이라면 문의 |

> 개발사 자체 화면에 포인트 잔액을 표시하고 계셨다면 별도 협의가 필요합니다.
> TnkFactory 담당자에게 문의하세요.

---

## 코드 비교

### 네이티브 SDK

```swift
import TnkRwdSdk2

// ATT 팝업 → 초기화
TnkAlerts.showATTPopup(self) {
    TnkSession.initInstance(appId: "발급받은-앱-아이디")
    TnkSession.sharedInstance()?.applicationStarted()
} denyAction: { }

// 오퍼월 표시
let vc = AdOfferwallViewController()
vc.title = "오퍼월"
let nav = UINavigationController(rootViewController: vc)
nav.modalPresentationStyle = .fullScreen
present(nav, animated: true)
```

### 하이브리드 SDK

```swift
import TnkPpiHyb

let sdk = TnkPpiHybSdk.shared
sdk.configure(appId: "발급받은-앱-아이디")
sdk.setUserName("개발사-사용자-식별값")
sdk.applicationStarted()

sdk.setRewardListener { [weak self] reward in
    self?.refreshMyPointBalance()
}

// ATT 는 앱이 활성 상태일 때 (sceneDidBecomeActive)
sdk.requestTrackingAuthorization { granted in }

// 오퍼월 표시 — 화면 구성 코드가 사라집니다
sdk.openOfferwall(from: self)
```

`UINavigationController` 로 감싸 present 하던 코드가 한 줄로 줄어듭니다.
오퍼월 화면의 네비게이션·타이틀·닫기는 웹(FE)이 처리합니다.

---

## 주의: ATT 요청 시점

네이티브 SDK 는 `TnkAlerts.showATTPopup` 으로 팝업과 초기화를 함께 처리했습니다.
하이브리드 SDK 는 **초기화와 ATT 요청을 분리**합니다.

```swift
// 초기화 — 앱 시작 시
sdk.configure(appId: "발급받은-앱-아이디")

// ATT — 앱이 활성 상태가 된 뒤에 (별도 시점)
func sceneDidBecomeActive(_ scene: UIScene) {
    guard !didRequestATT else { return }
    didRequestATT = true
    sdk.requestTrackingAuthorization { granted in }
}
```

> ⚠️ 활성 이전 시점(`willConnectTo` 등)에서 호출하면 **팝업이 뜨지 않고** 상태가 `.notDetermined` 로 남습니다.
> 자세한 내용은 [3. 초기화](initialize.md)를 참고하세요.
