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
| `static let protocolVersion: String` | 브릿지 프로토콜 버전 |
| `static let offerwallBaseURL: String` | 오퍼월 랜딩 기본 URL |

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
| `getAppId() -> String?` | 적용된 개발사 앱 ID |
| `setAgreePrivacy(_ agree: Bool)` | 개인정보 동의 상태 |
| `isAgreePrivacy() -> Bool` | 동의 상태 조회 |
| `setCOPPA(_ coppa: Int)` | 만 13세 미만 여부 |
| `setGDPR(_ gdpr: Int)` | GDPR 설정값 |
| `setUserAge(_ age: Int)` | 연령 |
| `setUserGender(_ gender: Int)` | 성별. `TnkCode.MALE` / `TnkCode.FEMALE` |

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

## `TnkCode`

```swift
public enum TnkCode {
    static let MALE: Int    // 1
    static let FEMALE: Int  // 2
}
```

---

## Android 와 다른 점

| 항목 | iOS | Android |
|---|---|---|
| `setCOPPA` | `Int` | `Bool` |
| `setUserGender` | `Int` 만 | `Int` / `String` 둘 다 |
| 광고 ID 준비 콜백 | 없음 (`getAdid()` 만) | `onAdidReady` / `refreshAdid` |
| ATT 동의 요청 | ✅ | 해당 없음 |
| 뷰 정리 | `cleanup()` 수동 호출 | 생명주기 자동 처리 |
