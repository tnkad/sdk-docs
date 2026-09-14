---
description: 네이티브 오퍼월 SDK(TnkRwdSdk2)에서 하이브리드 SDK 로 옮길 때의 체크리스트와, TnkSession 공개 API 전수 대조표(그대로 쓰는 호출·이름만 바뀐 호출·걷어낼 호출)입니다.
---

# 네이티브 SDK 에서 이관

네이티브 오퍼월 SDK(`TnkRwdSdk2`)를 사용 중인 개발사를 위한 문서입니다.
신규 연동이라면 이 페이지는 건너뛰셔도 됩니다.

---

## 무엇이 달라졌나

네이티브 SDK 는 광고 목록·상세·포인트 화면을 **앱 안에서 직접** 그립니다.
하이브리드 SDK 는 그 화면들을 **WebView 안의 웹(FE)** 이 그립니다.

그래서 이관 원칙이 이렇게 정리됩니다.

- **세션 · 식별 · 설정 · 오퍼월/특정광고 진입 계열** → 이름 또는 시그니처를 유지했습니다.
  대부분 진입점(`TnkPpiHybSdk.shared`)만 바꾸면 그대로 컴파일됩니다.
- **포인트 조회 · 아이템 구매 · 인출 등 RPC 계열과 화면 URL 조회 계열** → **제공하지 않습니다.**
  해당 기능은 오퍼월 화면(FE) 안에서 처리되므로 개발사 코드에서 제거하시면 됩니다.

요약하면: **걷어낼 코드는 있어도, 새로 배워야 할 개념은 거의 없습니다.**
아래 **전체 API 대조표**에 네이티브 `TnkSession` 의 공개 API 를 전수 대조해 두었으니,
사용 중인 호출을 표에서 찾아 그대로 치환·제거하시면 이관이 끝납니다.
치환 작업 자체를 AI 도구에 맡기실 수도 있습니다 — [AI 도구에 문서 연결하기](../publisher/ai-tools.md)에
이 대조표를 근거로 코드베이스를 자동 치환시키는 프롬프트가 있습니다.

> 💡 **컴파일러가 이관을 안내합니다**: 이름이 바뀐 API(`TnkSession`, `initInstance`,
> `setAgreePrivacyPolicy`, `presentAdDetailView` 등)는 SDK 에 안내 스텁이 들어 있어,
> 의존성만 교체하고 빌드하면 각 호출 지점에서 **"~로 대체되었습니다" 컴파일 에러와
> Xcode fix-it** 이 뜹니다. 에러 목록이 곧 이관 체크리스트이고, 대부분 fix-it 클릭으로 끝납니다.
> (스텁은 컴파일 불가·자동완성 비노출이라 런타임과 API 표면에 영향이 없습니다.)

---

## 이관 체크리스트

- [ ] 의존성을 `TnkRwdSdk2` → `TnkPpiHyb` 로 교체 (SPM 또는 CocoaPods)
- [ ] `import TnkRwdSdk2` → `import TnkPpiHyb`
- [ ] `TnkSession.initInstance(appId:)` + `sharedInstance()` → `TnkPpiHybSdk.shared.configure(appId:)`
- [ ] `AdOfferwallViewController` present 코드 → `openOfferwall(from:)`
- [ ] 특정 광고 진입: `presentAdDetailView` → `adDetail`, `adJoin`/`adAction` 은 **같은 이름** (아래 대조표 참고)
- [ ] 포인트/RPC 호출부(`queryPoint`, `purchaseItem` 등) 제거
- [ ] `OfferwallEventListener` → `setRewardListener` / `setEventListener`
- [ ] ATT 요청을 `requestTrackingAuthorization` 으로 교체
- [ ] `Info.plist` 의 `tnkad_app_id` · `NSUserTrackingUsageDescription` 은 **그대로 유지** (변경 없음)
- [ ] 서버 콜백 URL 구현은 **그대로 유지** (변경 없음)

---

## 전체 API 대조표

네이티브 `TnkSession` 의 공개 API 를 전수 대조한 표입니다. **구분** 열의 의미:

- **그대로** — 이름이 같아 호출부 수정이 거의 없음 (진입점 `TnkPpiHybSdk.shared` 치환만)
- **치환** — 대응 API 가 있고 이름/시그니처만 다름
- **제거** — 하이브리드에 없음. 오퍼월(FE)이 대신 처리하므로 호출부를 지우면 됨
- **문의** — 대응 API 가 없는 부가 기능. 사용 중이라면 TnkFactory 담당자에게 문의

### 초기화 · 세션 · 식별

| 네이티브 (`TnkSession`) | 하이브리드 (`TnkPpiHybSdk.shared`) | 구분 |
|---|---|---|
| `TnkSession.initInstance(appId:)` | `configure(appId:)` | 치환 |
| `TnkSession.sharedInstance()` | `TnkPpiHybSdk.shared` | 치환 |
| `applicationStarted()` | `applicationStarted()` | **그대로** |
| `appStartedOnceAMonth()` | 불필요 — `applicationStarted()` 만 호출 | 제거 |
| `setUserName(_:)` (체이닝 반환) | `setUserName(_:)` (반환 없음) | **그대로** |
| `getUserName()` | `getUserName()` | **그대로** |
| `getApplicationId()` | `getAppId()` | 치환 |
| `getIdForAdvertising()` | `getAdid()` | 치환 |
| `sdkVersion()` | `TnkPpiHybSdk.version` | 치환 |
| `setPhoneNumber(_:)` | 없음 | 문의 |

### 개인정보 · 추적

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `setAgreePrivacyPolicy(_:)` | `setAgreePrivacy(_:)` | 치환 |
| `setCOPPA(_ coppa: Bool)` | `setCOPPA(_ coppa: Int)` — **타입이 Int** | 치환 |
| `setGDPRConsent(_ gdpr: Bool)` | `setGDPR(_ gdpr: Int)` — **타입이 Int** | 치환 |
| `openPrivacyTermAlert(...)` | 오퍼월(FE) 동의 화면. 사전 동의는 `setAgreePrivacy(true)` | 제거 |
| `setTrackingEnabled(_:)` | ATT 는 `requestTrackingAuthorization` 으로 요청 | 치환 |

### 오퍼월 · 특정 광고 진입

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `AdOfferwallViewController` present / `showMenuViewController(from:...)` | `openOfferwall(from:)` | 치환 |
| `presentAdDetailView(_:appId:...actionId:completion:)` | `adDetail(from:appId:actionId:)` | 치환 |
| `adJoin(_:appId:...actionId:completion:)` | `adJoin(from:appId:actionId:)` | **그대로** |
| `adAction(_:appId:...actionId:completion:)` | `adAction(from:appId:actionId:)` | **그대로** |
| `AdPlacementView` | 없음 | 문의 |

특정 광고 진입 3종은 의미가 네이티브와 같습니다 — `adDetail` 은 무조건 상세(닫으면 개발사 화면 복귀),
`adJoin` 은 상세 없이 바로 참여, `adAction` 은 리스트 클릭과 같은 분기. `actionId` 는 기본 0(CPS 만 5).
단 `subAppId` / `navigationPush` / `fullscreen` 등 화면 구성 파라미터와 `completion` 콜백은 받지 않습니다 —
화면 구성과 오류 안내를 오퍼월(FE)이 처리하기 때문입니다.

### 포인트 · RPC · 광고 데이터 — 전부 제거 대상

| 네이티브 | 대체 | 구분 |
|---|---|---|
| `queryPoint(...)` (2종) | 오퍼월(FE)이 조회·표시 | 제거 |
| `queryAdvertiseCount(...)` (3종) | `getAdvertiseTotalPoint { info in }` (PPI) / `getProductTotalPoint` (CPS) — 광고 수·포인트 합계를 `TotalPointInfo` 로 반환 | 치환 |
| `queryPublishState(...)` (2종) | 오퍼월(FE) | 제거 |
| `purchaseItem(_:cost:...)` (2종) / `withdrawPoints(...)` (2종) | 오퍼월(FE) | 제거 |
| `actionCompleted()` / `actionCompleted(actionName:)` | 지급은 서버가 처리, 완료 통지는 `setRewardListener` | 제거 |
| `addAdItemList(data:)` / `getAdItem(appId:)` / `getAdItemToJson(appId:)` | 광고 데이터는 앱에 넘기지 않음 — FE 가 서버에서 직접 수신 | 제거 |
| `getFaqPageUrl()` / `getHelpDeskUrl()` / `getRewardHistoryUrl()` / `getUseHistoryUrl()` / `getContactUsUrl()` / `getCpsMyPageUrl()` | 오퍼월(FE) 마이페이지에 내장 | 제거 |
| `showCustomTapViewController(...)` | 없음 | 문의 |
| `OfferwallEventListener` (`didAdDataLoaded` / `didAdItemClicked` / `didOfferwallRemoved` …) | `setRewardListener` (지급 완료) / `setEventListener` (범용) | 치환 |
| `plusInstance()` / `getEventWebView` / `openEventWebView` / `getEventLink` (이벤트·Plus 계열) | 없음 | 문의 |

> 적립 가능 포인트를 개발사 화면에 표시하려면 [9. 적립 가능 포인트 조회](total-point.md)를 사용하세요.
> 사용자의 **적립된 잔액**은 [서버 보상 콜백](../common/server-callback.md)으로 적립한 값을 개발사가 직접 관리합니다.

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

// 특정 광고 상세
TnkSession.sharedInstance()?.presentAdDetailView(self, appId: 123456) { success, error in }
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

// 특정 광고 상세 — 결과 콜백이 사라집니다 (오류 안내도 오퍼월이 표시)
sdk.adDetail(from: self, appId: 123456)
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
