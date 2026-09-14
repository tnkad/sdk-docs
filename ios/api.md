---
description: TnkPpiHybSdk, TnkOfferwall, TnkOfferwallView 등 하이브리드 오퍼월 SDK(iOS)가 제공하는 공개 API 전체 시그니처입니다.
---

# 공개 API 목록

모듈: `TnkPpiHyb`

```swift
import TnkPpiHyb
```

---

## `TnkPpiHybSdk`

싱글턴입니다. 모든 인스턴스 메서드는 `TnkPpiHybSdk.shared` 로 접근합니다.

### 타입 프로퍼티

| 시그니처 | 설명 |
|---|---|
| `static let shared: TnkPpiHybSdk` | 싱글턴 인스턴스 |
| `static let version: String` | SDK 버전 |

### 초기화 · 수명주기

| 시그니처 | 설명 |
|---|---|
| `configure(appId: String)` | 앱 ID 로 초기화 |
| `configure(_ config: TnkPpiHybConfig)` | 설정 객체로 초기화 |
| `start()` | 앱 실행 신호 |
| `applicationStarted()` | `start()` 와 동일 (네이티브 SDK 호환) |
| `var isInitialized: Bool` | 초기화 완료 여부 |
| `enableLogging(_ enabled: Bool)` | 로그 on/off |

### 사용자 · 개인정보

| 시그니처 | 설명 |
|---|---|
| `setUserName(_ userName: String)` | 개발사 사용자 식별값. **보상 지급 기준값** |
| `getUserName() -> String?` | 설정된 식별값 조회 |
| `getAppId() -> String?` | 적용된 개발사 앱 ID (하이픈 제거) |
| `setAgreePrivacy(_ agree: Bool)` | 개인정보 동의 상태 |
| `isAgreePrivacy() -> Bool` | 동의 상태 조회 |
| `setCOPPA(_ coppa: Int)` | 만 13세 미만 여부 |
| `setGDPR(_ gdpr: Int)` | GDPR 설정값 |

### 광고 식별자 · ATT

| 시그니처 | 설명 |
|---|---|
| `requestTrackingAuthorization(_ completion: ((Bool) -> Void)? = nil)` | ATT 동의 요청. **앱 활성 상태에서만** 팝업이 뜸 |
| `getAdid() -> String` | IDFA. 미동의 시 기본값 |

### 오퍼월

| 시그니처 | 설명 |
|---|---|
| `openOfferwall(from presenter: UIViewController, animated: Bool = true, extraParams: [String: String]? = nil)` | 풀스크린 오퍼월 진입 |
| `buildOfferwallURL(extraParams: [String: String]? = nil) -> URL?` | 오퍼월 URL 조립 |

### 특정 광고 진입

네이티브 SDK 의 `presentAdDetailView` / `adJoin` / `adAction` 에 대응합니다 (Android 하이브리드와 같은 이름).
`actionId` 는 기본 0, CPS(쇼핑) 광고만 5 를 지정합니다.
결과 콜백은 없습니다 — 광고 조회·참여와 오류 안내를 오퍼월(FE)이 처리합니다.

| 시그니처 | 설명 |
|---|---|
| `adDetail(from presenter: UIViewController, appId: Int64, actionId: Int = 0, animated: Bool = true)` | 해당 광고의 **상세 화면으로 바로 진입**. 닫으면 오퍼월도 닫혀 개발사 화면으로 복귀 |
| `adJoin(from presenter: UIViewController, appId: Int64, actionId: Int = 0, animated: Bool = true)` | 상세 없이 **바로 참여** 후 광고주 페이지로 이동 |
| `adAction(from presenter: UIViewController, appId: Int64, actionId: Int = 0, animated: Bool = true)` | 리스트 클릭과 동일 규칙(상세 또는 바로 참여). 닫으면 오퍼월 홈 |

### 적립 가능 포인트 조회

콜백은 **메인 스레드**로 오며, 실패 시 `nil` 이 전달됩니다.

| 시그니처 | 설명 |
|---|---|
| `getAdvertiseTotalPoint(_ completion: @escaping (TotalPointInfo?) -> Void)` | 비구매형(PPI) 적립 가능 포인트·광고 수 |
| `getProductTotalPoint(_ completion: @escaping (TotalPointInfo?) -> Void)` | 구매형(CPS) 적립 가능 포인트·광고 수 |

`TotalPointInfo`: `pointAmount: Int64`(포인트 총합) · `adCount: Int`(광고 수) · `retCode: Int` · `retMessage: String?` · `isSuccess: Bool`

### 콜백 등록

| 시그니처 | 설명 |
|---|---|
| `setRewardListener(_ listener: ((RewardInfo) -> Void)?)` | 보상 지급 완료 알림 |
| `setEventListener(_ listener: ((String, String) -> Void)?)` | 웹(FE) 이벤트 원본 수신 |

### 딥링크

| 시그니처 | 설명 |
|---|---|
| `handleScheme(_ url: URL?, from presenter: UIViewController? = nil) -> Bool` | 스킴 처리. 소비 여부 반환 |
| `handleScheme(_ urlString: String?, from presenter: UIViewController? = nil) -> Bool` | 위와 동일 |

---

## `TnkOfferwall`

```swift
public enum TnkOfferwall {
    static func show(from presenter: UIViewController, url: URL?, animated: Bool = true)
}
```

---

## `TnkOfferwallView`

`UIView` 서브클래스입니다. 화면 안에 오퍼월을 삽입할 때 사용합니다.

```swift
final class TnkOfferwallView: UIView {
    var onCloseRequested: (() -> Void)?
    var onStatusBarStyleChanged: ((UIStatusBarStyle) -> Void)?
    var requestedStatusBarStyle: UIStatusBarStyle { get }

    func loadOfferwall(_ url: URL?)
    func goBackIfPossible() -> Bool
    func cleanup()
}
```

> 화면이 사라질 때 `cleanup()` 을 호출해야 WKWebView 와 브릿지 핸들러가 해제됩니다.

---

## `TnkPpiHybConfig`

```swift
public struct TnkPpiHybConfig {
    var appId: String
    var offerwallURL: URL?

    init(appId: String, offerwallURL: URL? = nil)
}
```

---

## `RewardInfo`

```swift
public struct RewardInfo {
    let appId: Int64
    let appName: String?
    let payPoint: Int64
    let pointUnit: String?
    let payType: Int
    let actionId: Int
}
```

필드 의미와 코드값은 [5. 보상 지급 수신](reward.md)을 참고하세요.

---

## Android 와 다른 점

| 항목 | iOS | Android |
|---|---|---|
| `setCOPPA` | `Int` | `Boolean` |
| 광고 ID 준비 콜백 | 없음 (`getAdid()` 만) | `onAdidReady` / `refreshAdid` |
| `loadOfferwall` | URL 하나만 받음 — 파라미터는 `buildOfferwallURL(extraParams:)` 에 | `url` + `extraParams` 둘 다 받음 |
| 상단 안전영역 전달 | 없음 | `setSafeAreaTopPx(cssPx:)` |
| ATT 동의 요청 | ✅ | 해당 없음 |
| 뷰 정리 | `cleanup()` 수동 호출 | 생명주기 자동 처리 |
