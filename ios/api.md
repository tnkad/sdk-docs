---
description: 개발사가 앱에서 직접 호출하는 하이브리드(V4) 오퍼월 SDK(iOS)의 공개 API 시그니처와 동작을 정리했습니다. TnkPpiHybSdk, TnkOfferwall, TnkOfferwallView, TnkPlacementView 와 값 객체를 다룹니다.
---

# 공개 API 목록 (개발사 사용 API)

이 페이지에서 하는 일: 개발사 앱이 직접 호출하는 공개 API 의 시그니처와 값별 동작을 한곳에서 찾아봅니다.

## 언제 필요한가

연동 중에 특정 메서드의 정확한 시그니처나 설정값별 동작을 확인할 때 찾아보는 참고 페이지입니다.
처음 연동한다면 [3. 초기화](initialize.md)와 [4. 오퍼월 띄우기](offerwall.md)부터 읽으세요.
기존 네이티브(V3) SDK(`TnkRwdSdk2`)에서 옮기는 경우에는 [네이티브(V3) SDK 에서 이관](migration.md)을 함께 참고하세요.

이 페이지에 없는 클래스와 메서드는 개발사가 사용하도록 안내하는 대상이 아닙니다.
필요한 기능이 목록에 없다면 담당자에게 문의해 주세요.

모듈: `TnkPpiHyb`

```swift
import TnkPpiHyb
```

---

## 처음 연동할 때 쓰는 API

| 하는 일 | API | 필수 |
|---|---|:-:|
| 사용자 식별값 설정 | `TnkPpiHybSdk.shared.setUserName` | 필수 |
| 오퍼월 열기 | `openOfferwall(from:)` (전체 화면) 또는 `TnkOfferwallView` (앱 화면 안에 삽입) | 필수 |
| 보상 알림 받기 | `setRewardListener` | 선택 |
| 지면 광고를 앱 화면 일부에 표시 | `TnkPlacementView` ([10. 플레이스먼트 뷰](placement.md)) | 선택 |

---

## `TnkPpiHybSdk`

싱글턴입니다. 모든 인스턴스 메서드는 `TnkPpiHybSdk.shared` 로 접근합니다.

### 타입 프로퍼티

| 시그니처 | 설명 |
|---|---|
| `static let shared: TnkPpiHybSdk` | 싱글턴 인스턴스 |
| `static let version: String` | SDK 버전 문자열 |

### 초기화 · 수명주기

| 시그니처 | 설명 |
|---|---|
| `configure(appId: String)` | 앱 ID 로 초기화합니다(선택). `Info.plist` 에 `tnkad_app_id` 가 있으면 생략할 수 있습니다. **처음 한 번만, 다른 SDK 호출보다 먼저** 호출해야 적용됩니다. `Info.plist` 에 값이 있는데 다른 SDK 호출 뒤에 호출하면 무시됩니다 ([3. 초기화](initialize.md)) |
| `configure(_ config: TnkPpiHybConfig)` | `TnkPpiHybConfig(appId: "발급받은-앱-아이디")` 를 넘기는 형태로, `configure(appId:)` 와 같은 동작입니다. 일반 연동에서는 `configure(appId:)` 를 사용하세요 |
| `start()` | 앱 실행 신호(선택). 호출하지 않아도 오퍼월 표시와 보상 지급에는 영향이 없습니다 |
| `applicationStarted()` | `start()` 와 같은 메서드입니다 (기존 네이티브(V3) SDK 의 이름) |
| `var isInitialized: Bool` | 초기화가 끝났으면 `true`. 이 호출은 초기화를 시작하지 않으므로, `Info.plist` 방식에서는 다른 SDK 호출 전에 `false` 일 수 있습니다 |
| `enableLogging(_ enabled: Bool)` | 로그 켜기/끄기. 기본값은 `false` 입니다 |

### 사용자 · 개인정보

| 시그니처 | 설명 |
|---|---|
| `setUserName(_ userName: String)` | 개발사 사용자 식별값. **보상 지급 기준값**입니다. 이전과 다른 값으로 바꾸면 동의 상태가 초기화됩니다 (최초 지정 포함, SDK 1.0.2 이상) |
| `getUserName() -> String?` | 설정된 식별값. 설정한 적이 없으면 `nil` |
| `getAppId() -> String?` | 적용된 개발사 앱 ID (하이픈 제거). 이 호출은 초기화를 시작하지 않으므로 SDK 호출 전에는 `nil` 일 수 있습니다 |
| `setAgreePrivacy(_ agree: Bool)` | 개인정보 수집 동의 상태를 저장합니다. 개발사 앱이 직접 동의를 받은 경우에만 `true` 로 설정하세요 (직접 받지 않는 개발사는 호출하지 않음). 앱 시작 시마다 `setUserName` 다음에 호출하는 것을 권장하며, 동의를 철회한 사용자에게는 `true` 로 다시 설정하지 않습니다 ([7. 개인정보 설정](privacy.md)의 '동의 철회' 항목). 값별 동작은 아래 표 |
| `isAgreePrivacy() -> Bool` | 동의 상태 조회. 오퍼월에서의 동의·거부 결과도 반영됩니다 (SDK 1.0.2 이상) |
| `revokePrivacyConsent()` | 개인정보 동의를 철회합니다. 파라미터·반환값이 없습니다. 호출 즉시 동의가 해제되고, 열려 있는 오퍼월은 첫 화면부터 다시 열려 동의 팝업을 보여 줍니다. 사용자가 철회하는 동작에서만 호출하세요. 반복·자동 호출은 금지입니다 (SDK 1.0.5 이상, [7. 개인정보 설정](privacy.md)의 '동의 철회' 항목) |
| `setCOPPA(_ coppa: Int)` | 만 13세 미만 사용자 여부. 값별 동작은 아래 표 |
| `setGDPR(_ gdpr: Int)` | GDPR 동의 여부. `Bool` 이 아니라 `Int` 를 받습니다. 값별 동작은 아래 표 |
| `setUserAge(_ age: Int)` | 기존 네이티브(V3) SDK 코드와의 호환을 위해 남겨 둔 메서드입니다. 호출해도 오류는 나지 않지만, 현재 버전에서는 오퍼월에 반영되지 않습니다. 필요하신 경우 담당자에게 문의해 주세요 |
| `setUserGender(_ gender: Int)` | 위와 같습니다. `TnkCode.MALE`(1) 또는 `TnkCode.FEMALE`(2) 를 넘깁니다 |

#### 값별 동작

| 호출 | 사용자가 보는 것 · 동작 |
|---|---|
| `setAgreePrivacy(true)` | 다음에 여는 오퍼월부터 동의 팝업이 나오지 않고, 도움말 탭의 '개인 정보 수집 동의 해제' 버튼도 보이지 않습니다 |
| `setAgreePrivacy(false)` | 다음에 여는 오퍼월에서 동의 팝업이 나옵니다. 이미 열려 있는 화면은 바뀌지 않습니다 (즉시 반영하려면 `revokePrivacyConsent()`) |
| `setAgreePrivacy` 를 호출하지 않음 | 오퍼월에 처음 들어갈 때 동의 팝업이 나오고, 사용자가 동의하면 이후에는 나오지 않습니다 |
| `setCOPPA(1)` | 이 사용자를 만 13세 미만으로 서버에 알립니다. 다음에 여는 오퍼월부터 적용됩니다 |
| `setCOPPA(0)` 또는 호출하지 않음 | 해당 없음으로 처리됩니다 (기본값) |
| `setGDPR(1)` | 사용자가 GDPR 에 동의한 것으로 서버에 알립니다 (기존 네이티브(V3) SDK 의 `setGDPRConsent(true)` 와 같은 값) |
| `setGDPR(0)` | 사용자가 GDPR 에 동의하지 않은 것으로 알립니다 (기존 `setGDPRConsent(false)` 와 같은 값) |
| `setGDPR` 를 호출하지 않음 | `0` 으로 전달됩니다. 즉 동의하지 않은 것으로 알립니다 |

`setCOPPA`·`setGDPR` 설정은 기기에 저장되어 다음 실행에도 유지됩니다. 계정을 바꾸는 앱은 그때마다 다시 설정하고, 오퍼월을 열기 전에 호출하세요.

> ⚠️ `setGDPR` 에 넘기는 값은 GDPR 대상인지가 아니라 사용자의 **동의 여부**입니다. GDPR 대상 사용자가 있는 앱은 동의 여부를 직접 지정하세요 ([7. 개인정보 설정](privacy.md)의 'GDPR' 항목).

### 광고 식별자 · ATT

| 시그니처 | 설명 |
|---|---|
| `requestTrackingAuthorization(_ completion: ((Bool) -> Void)? = nil)` | ATT 추적 허용 팝업을 요청합니다. 앱이 활성 상태가 될 때까지 기다렸다가 팝업을 띄웁니다. 이미 응답한 사용자에게는 팝업 없이 이전 응답이 전달됩니다. `completion`: 허용하면 `true`, 허용하지 않거나 제한되면 `false` (메인 스레드) |
| `getAdid() -> String` | 현재 IDFA. 허용한 경우 하이픈 없는 32자리 소문자이고, ATT 전이거나 허용하지 않은 경우 `"00000000000000000000000000000000"` (32자리 0) 입니다 |

### 오퍼월

| 시그니처 | 설명 |
|---|---|
| `openOfferwall(from presenter: UIViewController, animated: Bool = true, extraParams: [String: String]? = nil)` | 전체 화면으로 오퍼월을 엽니다. `extraParams` 로 `hideHeader`·`hideBack`·`theme` 를 지정할 수 있습니다 ([4. 오퍼월 띄우기](offerwall.md)) |
| `buildOfferwallURL(extraParams: [String: String]? = nil) -> URL?` | 오퍼월 주소를 바로 만들어 돌려줍니다. 앱 화면 안에 삽입할 때 `TnkOfferwallView.loadOfferwall(_:)` 에 넘기거나, `TnkOfferwall.show` 에 넘길 때 사용합니다. 전체 화면으로 열 때는 보통 `openOfferwall(from:)` 을 사용하세요 |

> ⚠️ `buildOfferwallURL` 이 만든 주소에는 사용자 정보가 담겨 있습니다. 로그로 남기거나 저장·외부로 보내지 말고 바로 `loadOfferwall(_:)` / `show` 에 넘기세요.

### 특정 광고 진입

기존 네이티브(V3) SDK 의 `presentAdDetailView` / `adJoin` / `adAction` 에 대응합니다 (Android 하이브리드(V4)와 같은 이름).
`actionId` 는 기본 0, CPS(쇼핑) 광고만 5 를 지정합니다.
결과 콜백은 없습니다. 광고 조회·참여와 오류 안내는 오퍼월 화면이 처리합니다.

| 시그니처 | 설명 |
|---|---|
| `adDetail(from presenter: UIViewController, appId: Int64, actionId: Int = 0, animated: Bool = true)` | 해당 광고의 **상세 화면으로 바로 진입**합니다. 닫으면 오퍼월도 닫혀 개발사 화면으로 돌아옵니다 |
| `adJoin(from presenter: UIViewController, appId: Int64, actionId: Int = 0, animated: Bool = true)` | 상세 없이 **바로 참여**한 뒤 광고주 페이지로 이동합니다 |
| `adAction(from presenter: UIViewController, appId: Int64, actionId: Int = 0, animated: Bool = true)` | 리스트 클릭과 같은 규칙(상세 또는 바로 참여)으로 엽니다. 닫으면 오퍼월 홈이 보입니다 |

### 적립 가능 포인트 조회 (SDK 1.0.1 이상)

기존 네이티브(V3) SDK 의 `queryAdvertiseCount`(일반·구매형 합계)는 `getTotalPoint` 로 바꿀 수 있습니다 (SDK 1.0.6 이상). 일반·구매형을 나눠 받는 `getAdvertiseTotalPoint` / `getProductTotalPoint` 는 1.0.1 이상에서 쓸 수 있습니다.
콜백은 **메인 스레드**로 옵니다. Android 에서도 같은 기능을 제공합니다 (`getTotalPoint` 는 Android SDK 1.0.16 이상, 나머지는 1.0.10 이상).

| 시그니처 | 설명 |
|---|---|
| `getTotalPoint(_ completion: @escaping (TotalPointInfo?) -> Void)` | 비구매형(PPI)과 구매형(CPS)을 합산한 적립 가능 포인트·광고 수를 한 번에 돌려줍니다 (SDK 1.0.6 이상). 한쪽 조회만 실패하면 성공한 쪽의 값만 담아 `isSuccess` 가 `true` 로 옵니다. 일반·구매형을 나눠 보거나 실패를 구분하려면 아래 두 함수를 각각 사용하세요 |
| `getAdvertiseTotalPoint(_ completion: @escaping (TotalPointInfo?) -> Void)` | 비구매형(PPI) 적립 가능 포인트·광고 수 (SDK 1.0.1 이상) |
| `getProductTotalPoint(_ completion: @escaping (TotalPointInfo?) -> Void)` | 구매형(CPS) 적립 가능 포인트·광고 수 (SDK 1.0.1 이상) |
| `clearApiSession()` | 포인트 조회에 쓰는 사용자 정보를 초기화합니다. 로그아웃 후 다른 계정으로 로그인하는 등 `setUserName` 을 다른 값으로 바꾼 직후에 호출하면, 다음 조회부터 새 사용자 기준으로 처리합니다 |

콜백으로 받은 값에 따라 다음과 같이 처리하세요.

| 콜백으로 받은 값 | 의미 | 화면에서 할 일 |
|---|---|---|
| `nil` | 통신이나 인증에 실패했습니다 | 포인트 문구를 표시하지 않습니다 |
| `isSuccess == false` | 서버가 오류로 응답했습니다. 사유가 있으면 `retMessage` 에 담깁니다 | 포인트 문구를 표시하지 않습니다 (`pointAmount` 를 쓰지 마세요) |
| `isSuccess == true` | 정상입니다 | `pointAmount`(포인트 총합)와 `adCount`(광고 수)를 표시합니다 |

`info?.isSuccess == true` 를 확인한 뒤에 표시하세요. `nil` 이 아니라고 해서 성공은 아닙니다.
자세한 사용법은 [9. 적립 가능 포인트 조회](total-point.md)를 참고하세요.

### 콜백 등록

| 시그니처 | 설명 |
|---|---|
| `setRewardListener(_ listener: ((RewardInfo) -> Void)?)` | 보상 지급 완료 알림. 콜백은 메인 스레드로 옵니다. 리스너는 하나만 유지되어 다시 등록하면 교체되고, `nil` 을 넘기면 해제됩니다. SDK 가 클로저를 계속 들고 있으므로 클로저 안에서 화면을 참조할 때는 `[weak self]` 를 쓰세요. 오퍼월을 열기 전에 등록하세요 (등록 전에 도착한 알림은 전달되지 않습니다) |
| `setEventListener(_ listener: ((String, String) -> Void)?)` | 오퍼월 화면에서 발생한 이벤트를 이벤트 이름과 JSON 문자열 그대로 받습니다. 고급·디버깅 용도이며, 보상 알림은 `setRewardListener` 를 사용하세요. 콜백은 메인 스레드로 오고, 등록·해제 규칙은 `setRewardListener` 와 같습니다 |

### 딥링크

| 시그니처 | 설명 |
|---|---|
| `handleScheme(_ url: URL?, from presenter: UIViewController? = nil) -> Bool` | `tnkscheme://` 딥링크이면 SDK 가 처리하고 `true` 를 돌려줍니다. `tnkscheme` 이 아니거나 명령이 없는 주소이면 `false` 이므로 앱이 직접 처리하세요. `presenter` 를 생략하면 SDK 가 가장 위에 보이는 화면에서 오퍼월을 엽니다. 앱이 딥링크로 막 시작되는 시점(`willConnectTo`)과 백그라운드에서 돌아오는 시점(`openURLContexts`)에는 화면을 찾지 못할 수 있으니 `presenter` 를 넘기세요. 푸시 알림을 눌러 앱이 열릴 때 부르는 경우도 같습니다 ([6. 딥링크](deeplink.md)) |
| `handleScheme(_ urlString: String?, from presenter: UIViewController? = nil) -> Bool` | 위와 같습니다 |

---

## `TnkOfferwall`

```swift
public enum TnkOfferwall {
    public static func show(from presenter: UIViewController, url: URL?, animated: Bool = true)
}
```

`url` 에는 `TnkPpiHybSdk.shared.buildOfferwallURL()` 결과만 넘기세요. `buildOfferwallURL()` 이 `nil` 을 돌려주면 `show` 를 호출하지 마세요.
`url` 에 `nil` 을 넘기면 오퍼월이 열리지 않고 다른 화면이 표시됩니다.
보통은 `TnkPpiHybSdk.shared.openOfferwall(from:)` 을 권장합니다.

```swift
if let url = TnkPpiHybSdk.shared.buildOfferwallURL() {
    TnkOfferwall.show(from: self, url: url)
}
```

---

## `TnkOfferwallView`

`UIView` 서브클래스입니다. 앱 화면 안에 오퍼월을 삽입할 때 사용합니다.

```swift
public final class TnkOfferwallView: UIView {
    public override init(frame: CGRect)

    public var onCloseRequested: (() -> Void)?
    public var onStatusBarStyleChanged: ((UIStatusBarStyle) -> Void)?
    public private(set) var requestedStatusBarStyle: UIStatusBarStyle

    public func loadOfferwall(_ url: URL?)
    public func goBackIfPossible() -> Bool
    public func cleanup()
}
```

| 멤버 | 설명 |
|---|---|
| `loadOfferwall(_:)` | `TnkPpiHybSdk.shared.buildOfferwallURL()` 결과를 넘겨 오퍼월을 엽니다. `buildOfferwallURL()` 이 `nil` 을 돌려주면 호출하지 마세요. `nil` 을 넘기면 오퍼월이 열리지 않고 다른 화면이 표시됩니다 |
| `onCloseRequested` | 사용자가 닫기를 누르면 호출됩니다. 아래 '닫기 요청' 참고 |
| `onStatusBarStyleChanged` · `requestedStatusBarStyle` | 오퍼월 화면이 바라는 상태 표시줄 글자색이 바뀌면 `onStatusBarStyleChanged` 가 호출됩니다. 화면에서 `setNeedsStatusBarAppearanceUpdate()` 를 호출하고, `preferredStatusBarStyle` 이 `requestedStatusBarStyle` 을 돌려주게 하세요 ([4. 오퍼월 띄우기](offerwall.md)) |
| `goBackIfPossible()` | 오퍼월 안에 이전 화면이 있으면 한 단계 뒤로 가고 `true` 를, 되돌아갈 곳이 없으면 `false` 를 돌려줍니다 |
| `cleanup()` | 오퍼월을 담은 화면을 더 이상 쓰지 않을 때(`deinit`) 한 번 호출합니다 |

> ⚠️ `cleanup()` 을 호출한 뒤에는 그 뷰로 오퍼월을 다시 열 수 없습니다. 탭 전환처럼 화면이 잠시 가려지는 경우에는 호출하지 마세요. 자세한 내용은 [4. 오퍼월 띄우기](offerwall.md)를 참고하세요.

### 닫기 요청 (`onCloseRequested`)

오퍼월 화면에서 사용자가 닫기를 누르면 호출됩니다. 네트워크 오류 안내의 '닫기' 도 같은 규칙입니다.

| 설정 | 사용자가 닫기를 누르면 |
|---|---|
| 등록함 | 등록한 코드가 실행됩니다. 화면은 저절로 닫히지 않으니 화면 닫기나 탭 전환 등을 직접 처리하세요 |
| 등록하지 않음 (`nil`) | **아무 동작도 하지 않습니다.** 삽입한 오퍼월에서는 닫기를 직접 등록해야 합니다 |

> `openOfferwall(from:)` 으로 연 전체 화면은 SDK 가 닫기를 처리하므로 따로 등록하지 않아도 됩니다.
> Android 는 등록하지 않으면 Activity 가 종료됩니다. 아래 'Android 와 다른 점'을 참고하세요.

---

## `TnkPlacementView` (SDK 1.0.7 이상)

`UIView` 서브클래스입니다. 지면(플레이스먼트) 하나의 광고 묶음을 앱 화면 일부에 보여 줍니다. 사용 방법은 [10. 플레이스먼트 뷰](placement.md)를 보세요.

```swift
public final class TnkPlacementView: UIView {
    public override init(frame: CGRect)

    public weak var delegate: TnkPlacementViewDelegate?
    public private(set) var contentHeight: CGFloat
    public var verticalScrollEnabled: Bool   // load 전에 설정, 기본 false
    public var maxHeight: CGFloat            // load 전에 설정, pt, 기본 0 (제한 없음)
    public var layoutKey: String?            // load 전에 설정
    public var theme: String?                // load 전에 설정. "light" · "dark"
    public var filterIds: [Int]?             // load 전에 설정
    public var dataOnly: Bool                // load 전에 설정, 기본 false
    public private(set) var pubInfo: TnkPlacementPubInfo?
    public private(set) var placementId: String?
    public private(set) var adList: [TnkPlacementAdItem]
    public private(set) var adListJson: String

    public func load(placementId: String)
    public func refresh()
    public func clickItem(appId: Int64, completion: ((Bool, Int) -> Void)? = nil)
    public func cleanup()
}
```

| 멤버 | 설명 |
|---|---|
| `delegate` | 이벤트를 받는 쪽. weak 참조이므로 앱이 붙잡고 있는 객체(화면)여야 합니다 |
| `load(placementId:)` | 지면 ID 로 지면을 불러옵니다. 성공하면 자동으로 그려집니다. 메인 스레드에서 호출하세요 |
| `layoutKey` | 지면을 그릴 레이아웃 키. `DEFAULT` · `BOX` · `FEED_DOUBLE` · `FEED_SWIPE` · `FEED_SWIPE_DOUBLE` · `ING_CAMPAIGN` · `FEED` · `SIMPLE_LIST` · `ADAPTIVE` 중 하나이며 대소문자는 구분하지 않습니다. 모르는 키는 기본 레이아웃으로 그립니다. 같은 키라도 일반 지면과 쇼핑 지면의 모양이 다를 수 있으며, `SIMPLE_LIST` 는 두 지면 모두 같은 심플 리스트로 그립니다. TnkFactory 에서 지면 레이아웃을 정해 둔 경우에는 그 설정이 먼저 적용될 수 있습니다 |
| `verticalScrollEnabled` | 고정 높이에서 내용이 넘칠 때 뷰 안 세로 스크롤을 켭니다. 기본 `false` |
| `maxHeight` | 지면 높이의 상한(pt). 기본 `0` 은 제한 없음입니다. 0 보다 크면 내용 높이만큼 늘어나다가 이 높이에서 멈추고, 내용이 더 크면 `verticalScrollEnabled` 와 관계없이 뷰 안에서 스크롤되며 양 끝에서는 앱의 스크롤로 이어집니다. `onHeightChanged` 는 내용 높이와 `maxHeight` 중 작은 값을 알립니다(`contentHeight` 는 내용 높이 그대로). 쓸 때는 지면 높이를 고정하지 마세요. `dataOnly` 일 때는 무시합니다 |
| `theme` | 지면과 지면에서 SDK 가 여는 전체 화면 오퍼월의 테마. `"light"` · `"dark"` 만 유효하고 그 밖의 값·`nil` 은 기기(앱) 설정을 따릅니다. 지면 뷰 자체의 배경은 투명하고 카드와 행은 테마색으로 그려집니다 |
| `filterIds` | 보여 줄 항목을 `filter_id` 로 고릅니다. 목록 순서대로 id 마다 첫 항목 1건. 1~999999999 정수만, 중복은 처음 값만, 최대 50개 |
| `dataOnly` | `true` 면 지면을 그리지 않고 `onLoaded` · `onFailed` · `pubInfo` · `adList` 만 갱신합니다. 뷰는 `load` 를 시작할 때부터 높이 0 + `isHidden = true` 이고 `onHeightChanged` 는 오지 않습니다. 뷰는 화면 계층 안에 두어야 합니다. 기본 `false` |
| `pubInfo` | 지면 정보(`TnkPlacementPubInfo`). `onLoaded` 직전에 설정되고 새 `load`·실패·정리 때 `nil` 이 됩니다. 화면 구성용입니다 |
| `contentHeight` | 지금 그려진 내용의 높이(pt). 불러오기 전·0건·실패면 0 |
| `placementId` | 마지막으로 `load` 에 넘긴 지면 ID |
| `adList` · `adListJson` | 마지막으로 불러온 광고 목록(`[TnkPlacementAdItem]`)과 같은 내용의 JSON 배열 문자열(없으면 `"[]"`). `onLoaded` 직전에 설정되므로 그 콜백 안에서 읽을 수 있고, 새 `load`·실패·정리 때 비워집니다. 화면 표시용이며 보상·과금 판단에 쓰지 마세요 |
| `refresh()` | 요청하는 동안 접지 않고 서버에서 목록을 다시 받아 바꿉니다. 받은 목록이 화면에 있는 목록과 같으면 보던 페이지와 가로 스크롤 위치가 그대로 유지되고, 달라졌으면 목록을 1페이지부터 새로 그립니다. 새 목록이 0건이면 접히고, 0건이던 지면에 광고가 생기면 다시 펼쳐집니다(이때 `isHidden` 도 풀립니다). 불러온 적이 없거나 불러오는 중이면 무시하고, 실패한 상태이면 `load` 와 같습니다. 메인 스레드에서 호출하세요 |
| `clickItem(appId:completion:)` | 사용자가 그 광고 행을 누른 것과 같게 처리합니다. 결과는 `completion(success, code)` 로 정확히 1번 옵니다. `code`: `0` 화면 열기 시작 · `1003` 목록에 없는 `appId` · `1004` 앞선 요청 처리 중 · `-1` 그 밖의 실패 · `-2` 3초 안에 응답 없음. 동작은 `success` 로 나누고 `code` 는 기록·진단용으로 쓰세요. 성공은 화면 열기를 시작했다는 뜻이며 참여·보상 완료가 아닙니다. 사용자의 동작(버튼 탭 등)에 대한 응답으로만 호출하세요. 메인 스레드에서 호출하세요 |
| `cleanup()` | 내부 화면과 타이머를 정리합니다. 부르지 않아도 뷰가 해제될 때 스스로 정리합니다. `cleanup()` 뒤에 `load` 를 다시 부르면 다시 불러옵니다 |

높이 제약을 주지 않으면 뷰 높이가 내용 높이를 따르고, `maxHeight` 를 쓰면 내용 높이에 맞춰지다가 `maxHeight` 에서 멈추며 내용이 더 크면 뷰 안에서 스크롤됩니다. 높이 제약이나 고정 frame 높이를 주면 그 높이를 유지합니다. `verticalScrollEnabled`·`maxHeight` 를 쓰지 않으면 넘치는 부분은 위쪽 기준으로 잘립니다.

### `TnkPlacementViewDelegate`

```swift
@objc public protocol TnkPlacementViewDelegate: NSObjectProtocol {
    @objc optional func onLoaded(placementId: String, count: Int, customData: String)
    @objc optional func onFailed(placementId: String, code: Int)
    @objc optional func onItemClicked(placementId: String, appId: Int64, appName: String)
    @objc optional func onItemClosed(placementId: String, appId: Int64)
    @objc optional func onMoreClicked(placementId: String) -> Bool
    @objc optional func onHeightChanged(placementId: String, height: Double)
}

@objc public final class TnkPlacementPubInfo: NSObject {
    @objc public let placementId: String
    @objc public let adType: Int          // 0 일반 · 1 쇼핑 · 2 제휴몰 · 3 뉴스 · 4 이벤트 · 5 퀴즈, 값이 없으면 -1
    @objc public let title: String
    @objc public let moreLabel: String
    @objc public let customData: String
    @objc public let pointUnit: String
    @objc public let layoutKey: String    // 실제로 그려진 레이아웃의 키. 알 수 없으면 ""
}

@objc public final class TnkPlacementAdItem: NSObject {
    @objc public let appId: Int64
    @objc public let actionId: Int
    @objc public let appName: String
    @objc public let imageUrl: String
    @objc public let iconUrl: String
    @objc public let point: Int64
    @objc public let originalPoint: Int64
    @objc public let pointUnit: String
    @objc public let pointText: String
    @objc public let price: Int64
    @objc public let originalPrice: Int64
    @objc public let discountRate: Int
    @objc public let isMultiMission: Bool
    @objc public let campaignType: Int
    @objc public let campaignTypeName: String
    @objc public let actionDesc: String
    @objc public let likeYn: String
    @objc public let filterId: Int
    @objc public let isLink: Bool
}
```

모든 메서드가 선택 구현이며 메인 스레드에서 호출됩니다. 메서드 이름이나 인자 레이블이 다르면 컴파일 오류 없이 호출되지 않습니다. `NSObject` 하위 클래스(`UIViewController` 등)만 채택할 수 있습니다.

| 콜백 | 설명 |
|---|---|
| `onLoaded` | 불러오기 성공. `pubInfo` · `adList` 가 먼저 설정된 뒤 이 콜백이 오고, 그다음에 `onHeightChanged` 가 옵니다. `count` 는 불러온 광고 수(레이아웃에 따라 화면에 보이는 개수보다 많을 수 있음, 0 이면 광고 없음, 뷰는 높이 0 + `isHidden = true`), `customData` 는 지면에 설정된 값(없으면 빈 문자열) |
| `onFailed` | 불러오기 실패. 뷰는 접힙니다. `-2`: 5초 안에 응답 없음, `-1`: 기타 실패, 그 밖의 값은 서버가 알려 준 코드 — 계속되면 담당자에게 문의 |
| `onItemClicked` | 지면 안의 광고를 누른 즉시 1번(오퍼월을 열기 전). 일반 광고는 이후 SDK 가 광고 상세를 전체 화면 오퍼월로 엽니다. 지면이나 항목에 따라 다른 화면이 열릴 수 있고, 이때 `appId` 는 광고 ID 가 아닐 수 있습니다. `appName` 은 누른 행의 이름(없으면 빈 문자열)입니다. 화면 통지용이므로 보상·과금 판단에 쓰지 마세요 |
| `onItemClosed` | 항목을 눌러 SDK 가 연 화면(전체 화면 오퍼월 또는 앱 안에서 열린 페이지)이 닫혔을 때 1번. 외부 브라우저로 연 링크·더보기·정리된 뒤에는 호출하지 않습니다. 오퍼월 위에 다른 전체 화면이 올라간 채 화면들이 한꺼번에 닫혀도 1번 호출합니다 |
| `onMoreClicked` | 지면의 '더보기'(레이아웃에 따라 머리글 또는 아래쪽 버튼)를 눌렀을 때. `true` 면 앱이 직접 처리, `false` 이거나 구현하지 않으면 SDK 가 오퍼월 첫 화면을 엽니다 |
| `onHeightChanged` | 지면 내용 높이(pt, 0 이상 5000 이하)가 바뀔 때. `maxHeight` 를 쓰면 내용 높이와 `maxHeight` 중 작은 값입니다. 직전 높이가 0 보다 컸다면 접힘(광고 없음으로 바뀜·실패)·새 `load`·`cleanup()` 때 0 이 옵니다. Android 는 0 을 보내지 않으므로 접힘은 `onLoaded`(`count` 0) 또는 `onFailed` 로 판단하세요. `dataOnly` 일 때는 오지 않습니다 |

---

## 값 객체

```swift
public struct RewardInfo {
    public let appId: Int64
    public let appName: String?
    public let payPoint: Int64
    public let pointUnit: String?
    public let payType: Int
    public let actionId: Int
}
```

필드 의미와 코드값은 [5. 보상 지급 수신](reward.md)을 참고하세요.

```swift
public struct TotalPointInfo {
    public let pointAmount: Int64   // 적립 가능 포인트 총합
    public let adCount: Int         // 적립 가능 광고 수
    public let retCode: Int         // 0 이면 성공, 응답 코드가 없으면 -1
    public let retMessage: String?  // 서버가 오류로 응답했을 때의 사유 (없으면 nil)
    public var isSuccess: Bool      // retCode == 0
}
```

```swift
public enum TnkCode {
    public static let MALE = 1
    public static let FEMALE = 2
}
```

> 기존 네이티브(V3) SDK 의 호출 이름(`TnkSession`, `initInstance(appId:)` 등)으로 코드를 작성하면 컴파일 오류와 함께 새 이름이 안내됩니다.
> 자세한 내용은 [네이티브(V3) SDK 에서 이관](migration.md)을 참고하세요.

---

## Android 와 다른 점

| 항목 | iOS | Android |
|---|---|---|
| 앱 ID 지정 | `configure(appId:)` / `Info.plist` `tnkad_app_id` | `init(context, appId)` / 매니페스트 `tnkad_app_id` |
| `getAppId` 의 자동 초기화 | 초기화하지 않습니다 (SDK 호출 전에는 `nil`) | 호출하면 초기화가 진행됩니다 |
| `setCOPPA` | `Int` | `Boolean` |
| `setGDPR` 를 호출하지 않았을 때 | `0`(동의하지 않음)으로 전달 | 지정하지 않은 상태(`-1`)로 전달 |
| 광고 ID 준비 콜백 | 없음 (`getAdid()` 만) | `onAdidReady` / `refreshAdid` |
| ATT 동의 요청 | `requestTrackingAuthorization` | 해당 없음 |
| `loadOfferwall` | URL 하나만 받음 — `buildOfferwallURL(extraParams:)` 결과를 넘겨야 하며, `nil` 을 넘기면 오퍼월이 열리지 않고 다른 화면이 표시됨 | `url` 생략 가능, `extraParams` 도 받음 |
| 상단 안전 영역 전달 | 없음 | `setSafeAreaTopPx(cssPx)` |
| 뷰 정리 | `cleanup()` 수동 호출 | 생명주기 자동 처리 |
| `onCloseRequested` 미등록 시 닫기 | 아무 동작 없음 — 닫기 처리를 직접 등록 | 뷰가 들어 있는 Activity 종료 |
| 플레이스먼트 뷰 리스너 | `delegate: TnkPlacementViewDelegate?` (weak 참조, 모든 메서드 선택 구현) | `listener: TnkPlacementListener?` |
| 플레이스먼트 뷰 `onHeightChanged` 인자 | `height: Double` (pt) | `heightCssPx: Int` (dp) |
| 플레이스먼트 뷰 `maxHeight` | `CGFloat` (pt) | `Int` (dp) |
| 플레이스먼트 뷰 접힘 알림 | 광고 없음으로 바뀜·실패·새 `load`·`cleanup()` 때 `onHeightChanged(0)` 을 보냄 | `onHeightChanged(0)` 을 보내지 않음 |
| 플레이스먼트 뷰 정리 | 뷰 해제 때 자동, 먼저 정리하려면 `cleanup()` | 화면 생명주기에 따라 자동 |
| 플레이스먼트 뷰 실패 코드 상수 | 상수 없이 `-2`·`-1` 숫자 사용 | `TnkPlacementView.CODE_TIMEOUT`(-2) · `CODE_UNKNOWN`(-1) |
| 플레이스먼트 뷰 읽기 전용 속성 | `pubInfo` · `placementId` · `contentHeight` · `adList` · `adListJson` | `pubInfo` · `placementId` · `adList` · `getAdListJson()` |
| 플레이스먼트 뷰 `clickItem` | `clickItem(appId: Int64, completion:)` | `clickItem(appId: Long, onResult)` |
