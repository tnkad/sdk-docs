---
description: 개발사가 앱에서 직접 호출하는 하이브리드 오퍼월 SDK(Android)의 공개 API 시그니처와 동작을 정리했습니다. TnkPpiHybSdk, TnkOfferwall, TnkOfferwallView, TnkPlacementView 와 콜백 타입을 다룹니다.
---

# 공개 API 목록 (개발사 사용 API)

이 페이지에서 하는 일: 개발사 앱이 직접 호출하는 공개 API 의 시그니처와 값별 동작을 한곳에서 찾아봅니다.

## 언제 필요한가

연동 중에 특정 메서드의 정확한 시그니처나 설정값별 동작을 확인할 때 찾아보는 참고 페이지입니다.
처음 연동한다면 [3. 초기화](initialize.md)와 [4. 오퍼월 띄우기](offerwall.md)부터 읽으세요.
기존 네이티브 SDK(`com.tnkfactory:rwd`)에서 옮기는 경우에는 [네이티브 SDK 에서 이관](migration.md)을 함께 참고하세요.

이 페이지에 없는 클래스와 메서드는 개발사가 사용하도록 안내하는 대상이 아닙니다.
필요한 기능이 목록에 없다면 담당자에게 문의해 주세요.

패키지: `com.tnkfactory.ad.hrwd` — 단, `TnkOfferwallView` · `TnkPlacementView` · `TnkPlacementListener` · `TnkPlacementListenerAdapter` · `TnkPlacementPubInfo` · `TnkPlacementAdItem` · `TnkPlacementClickCallback` 는 `com.tnkfactory.ad.hrwd.webview` 패키지에 있습니다.

모든 `TnkPpiHybSdk` 메서드는 `@JvmStatic` 이므로 Java 에서 `TnkPpiHybSdk.xxx(...)` 로 호출합니다.
Kotlin 함수 타입을 받는 콜백(`onAdidReady`, `getTotalPoint`, `getAdvertiseTotalPoint`, `getProductTotalPoint`, `TnkOfferwallView.onCloseRequested`)은
Java 에서 `return Unit.INSTANCE;` 로 끝내야 합니다.

```java
import kotlin.Unit;

TnkPpiHybSdk.getAdvertiseTotalPoint(getApplicationContext(), info -> {
    // 결과 처리 (메인 스레드)
    return Unit.INSTANCE;
});

offerwallView.setOnCloseRequested(() -> {
    // 닫기 처리 (탭 전환 등)
    return Unit.INSTANCE;
});
```

`setRewardListener` 와 `setEventListener` 는 인터페이스(`TnkRewardListener`, `TnkEventListener`)를 받으므로 Java 람다에서 값을 돌려주지 않아도 됩니다.

---

## 처음 연동할 때 쓰는 API

| 하는 일 | API | 필수 |
|---|---|:-:|
| 사용자 식별값 설정 | `TnkPpiHybSdk.setUserName` | 필수 |
| 오퍼월 열기 | `TnkPpiHybSdk.openOfferwall` (전체 화면) 또는 `TnkOfferwallView` (앱 화면 안에 삽입) | 필수 |
| 보상 알림 받기 | `TnkPpiHybSdk.setRewardListener` | 선택 |
| 지면 광고를 앱 화면 일부에 표시 | `TnkPlacementView` ([10. 플레이스먼트 뷰](placement.md)) | 선택 |

---

## `TnkPpiHybSdk`

### 초기화 · 수명주기

| 시그니처 | 설명 |
|---|---|
| `init(context: Context, appId: String? = null)` | 명시 초기화(선택). 앱 ID 를 매니페스트 대신 코드로 넣을 때 사용합니다. **다른 SDK 호출보다 먼저** 호출해야 적용되며, 이후에 호출하면 무시됩니다. `appId` 를 생략하면 매니페스트의 `tnkad_app_id` 를 사용합니다 ([3. 초기화](initialize.md)) |
| `start(context: Context)` | 앱 실행 신호(선택). 호출하지 않아도 오퍼월 표시와 보상 지급에는 영향이 없습니다 |
| `applicationStarted(context: Context)` | `start()` 와 같은 메서드입니다 (기존 네이티브 SDK 의 이름) |
| `isInitialized(): Boolean` | 초기화가 끝났으면 `true`. 이 호출은 초기화를 시작하지 않으므로 다른 SDK 호출 전에는 `false` 일 수 있습니다 |
| `enableLogging(enabled: Boolean)` | 로그 켜기/끄기. 기본값은 `false` 입니다 |
| `enableLogging(context: Context, enabled: Boolean)` | 위와 같습니다 (기존 네이티브 SDK 와 같은 시그니처) |
| `VERSION: String` | SDK 버전 문자열 |

### 사용자 · 개인정보

| 시그니처 | 설명 |
|---|---|
| `setUserName(context: Context, userName: String)` | 개발사 사용자 식별값. **보상 지급 기준값**입니다. 이전과 다른 값으로 바꾸면 동의 상태가 초기화됩니다 (최초 지정 포함, SDK 1.0.11 이상) |
| `getUserName(context: Context): String?` | 설정된 식별값. 설정한 적이 없으면 `null` |
| `getAppId(context: Context): String?` | 적용된 개발사 앱 ID (하이픈 제거). 앱 ID 가 없으면 `null`. 이 호출은 초기화도 진행하므로 `init` 보다 먼저 호출하지 마세요 |
| `setAgreePrivacy(context: Context, agree: Boolean)` | 개인정보 수집 동의 상태를 저장합니다. 개발사 앱이 직접 동의를 받은 경우에만 `true` 로 설정하세요 (직접 받지 않는 개발사는 호출하지 않음). 앱 시작 시마다 `setUserName` 다음에 호출하는 것을 권장하며, 동의를 철회한 사용자에게는 `true` 로 다시 설정하지 않습니다 ([7. 개인정보 설정](privacy.md)의 '동의 철회' 항목). 값별 동작은 아래 표 |
| `isAgreePrivacy(context: Context): Boolean` | 동의 상태 조회. 오퍼월에서의 동의·거부 결과도 반영됩니다 (SDK 1.0.11 이상) |
| `revokePrivacyConsent(context: Context)` | 개인정보 동의를 철회합니다. `context` 외에 넘길 값과 반환값이 없습니다. 호출 즉시 동의가 해제되고, 열려 있는 오퍼월은 첫 화면부터 다시 열려 동의 팝업을 보여 줍니다. 사용자가 철회하는 동작에서만 호출하세요. 반복·자동 호출은 금지입니다 (SDK 1.0.14 이상, [7. 개인정보 설정](privacy.md)의 '동의 철회' 항목) |
| `setCOPPA(context: Context, enabled: Boolean)` | 만 13세 미만 사용자 여부. 값별 동작은 아래 표 |
| `setGDPR(context: Context, gdpr: Int)` | GDPR 동의 여부. `Boolean` 이 아니라 `Int` 를 받습니다. 값별 동작은 아래 표 |
| `setUserAge(context: Context, age: Int)` | 기존 네이티브 SDK 코드와의 호환을 위해 남겨 둔 메서드입니다. 호출해도 오류는 나지 않지만, 현재 버전에서는 오퍼월에 반영되지 않습니다. 필요하신 경우 담당자에게 문의해 주세요 |
| `setUserGender(context: Context, gender: Int)` | 위와 같습니다. `TnkCode.MALE`(1) 또는 `TnkCode.FEMALE`(2) 를 넘깁니다 |
| `setUserGender(context: Context, gender: String)` | 위와 같습니다. `"M"` 또는 `"F"` 를 넘깁니다 |

#### 값별 동작

| 호출 | 사용자가 보는 것 · 동작 |
|---|---|
| `setAgreePrivacy(context, true)` | 다음에 여는 오퍼월부터 동의 팝업이 나오지 않고, 도움말 탭의 '개인 정보 수집 동의 해제' 버튼도 보이지 않습니다 |
| `setAgreePrivacy(context, false)` | 다음에 여는 오퍼월에서 동의 팝업이 나옵니다. 이미 열려 있는 화면은 바뀌지 않습니다 (즉시 반영하려면 `revokePrivacyConsent`) |
| `setAgreePrivacy` 를 호출하지 않음 | 오퍼월에 처음 들어갈 때 동의 팝업이 나오고, 사용자가 동의하면 이후에는 나오지 않습니다 |
| `setCOPPA(context, true)` | 이 사용자를 만 13세 미만으로 서버에 알립니다. 다음에 여는 오퍼월부터 적용됩니다 |
| `setCOPPA(context, false)` 또는 호출하지 않음 | 해당 없음으로 처리됩니다 (기본값) |
| `setGDPR(context, 1)` | 사용자가 GDPR 에 동의한 것으로 서버에 알립니다 (기존 네이티브 SDK 의 `setGdprConsent(context, true)` 와 같은 값) |
| `setGDPR(context, 0)` | 사용자가 GDPR 에 동의하지 않은 것으로 알립니다 (기존 `setGdprConsent(context, false)` 와 같은 값) |
| `setGDPR` 를 호출하지 않음 | 지정하지 않은 상태(`-1`)로 전달됩니다 |

`setCOPPA`·`setGDPR` 설정은 기기에 저장되어 다음 실행에도 유지됩니다. 계정을 바꾸는 앱은 그때마다 다시 설정하고, 오퍼월을 열기 전에 호출하세요.

> ⚠️ `setGDPR` 에 넘기는 값은 GDPR 대상인지가 아니라 사용자의 **동의 여부**입니다. GDPR 대상 사용자가 있는 앱은 동의 여부를 직접 지정하세요 ([7. 개인정보 설정](privacy.md)의 'GDPR' 항목).

### 광고 ID (ADID)

| 시그니처 | 설명 |
|---|---|
| `getAdid(context: Context): String` | 현재 광고 ID. 메인 스레드에서 호출할 수 있습니다. 받기 전이면 이전 실행에서 받은 값, 처음이면 `"00000000000000000000000000000000"` (32자리 0) 입니다. 형식은 하이픈 없는 32자리 소문자입니다 |
| `onAdidReady(callback: (String) -> Unit)` | 광고 ID 를 받으면 한 번 호출됩니다 (메인 스레드). 이미 받은 상태면 등록하자마자 호출됩니다. 광고 ID 를 받을 수 없는 기기(삭제했거나 Google Play 서비스가 없는 기기)에서는 호출되지 않습니다. 이 호출은 초기화를 시작하지 않습니다 |
| `refreshAdid(context: Context)` | 광고 ID 를 다시 받아 옵니다. 이후 여는 오퍼월에는 새 값이 쓰입니다. 다시 받은 결과를 콜백으로 받으려면 `refreshAdid` 를 호출한 직후 `onAdidReady` 를 다시 등록하세요. 이미 호출된 콜백은 다시 호출되지 않습니다 |

### 오퍼월

| 시그니처 | 설명 |
|---|---|
| `openOfferwall(context: Context, extraParams: Map<String, String>? = null)` | 전체 화면으로 오퍼월을 엽니다. `extraParams` 로 `hideHeader`·`hideBack`·`theme` 를 지정할 수 있습니다 ([4. 오퍼월 띄우기](offerwall.md)). 버튼 처리처럼 메인 스레드에서 호출하고, `context` 에는 지금 보이는 화면의 Activity 를 넘기는 것을 권장합니다 |
| `buildOfferwallUrl(context: Context, extraParams: Map<String, String>? = null): String` | 오퍼월 주소를 문자열로 바로 만들어 돌려줍니다. 광고 ID 수집을 기다리지 않으므로 앱 첫 실행 직후에는 광고 ID 가 비어 있을 수 있습니다. `TnkOfferwall.show` 나 `loadOfferwall(url)` 에 넘길 때만 사용하고, 보통은 `openOfferwall` / `loadOfferwall()` 을 사용하세요 |

> ⚠️ `buildOfferwallUrl` 이 만든 주소에는 사용자 정보가 담겨 있습니다. 로그로 남기거나 저장·외부로 보내지 말고 바로 `loadOfferwall` / `show` 에 넘기세요.

### 특정 광고 진입

기존 네이티브 SDK 의 `adDetail` / `adJoin` / `adAction` 과 같은 이름·의미입니다.
`actionId` 는 기본 0, CPS(쇼핑) 광고만 5 를 지정합니다.
결과 콜백은 없습니다. 광고 조회·참여와 오류 안내는 오퍼월 화면이 처리합니다.

| 시그니처 | 설명 |
|---|---|
| `adDetail(context: Context, appId: Long, actionId: Int = 0)` | 해당 광고의 **상세 화면으로 바로 진입**합니다. 닫으면 오퍼월도 닫혀 개발사 화면으로 돌아옵니다 |
| `adJoin(context: Context, appId: Long, actionId: Int = 0)` | 상세 없이 **바로 참여**한 뒤 광고주 페이지로 이동합니다 |
| `adAction(context: Context, appId: Long, actionId: Int = 0)` | 리스트 클릭과 같은 규칙(상세 또는 바로 참여)으로 엽니다. 닫으면 오퍼월 홈이 보입니다 |

### 적립 가능 포인트 조회 (SDK 1.0.10 이상)

기존 네이티브 SDK 의 `getEarnPoint` · `queryAdvertiseCount` 는 `getTotalPoint` 하나로 바꿀 수 있습니다 (SDK 1.0.16 이상). 일반·구매형을 나눠 받는 `getAdvertiseTotalPoint` / `getProductTotalPoint` 는 1.0.10 이상에서 쓸 수 있습니다.
통신은 백그라운드에서 하고, 콜백은 메인 스레드로 옵니다. iOS 에서도 같은 기능을 제공합니다 (`getTotalPoint` 는 iOS SDK 1.0.6 이상, 나머지는 1.0.1 이상).

| 시그니처 | 설명 |
|---|---|
| `getTotalPoint(context: Context, callback: (TotalPointInfo?) -> Unit)` | 비구매형(PPI)과 구매형(CPS)을 합산한 적립 가능 포인트·광고 수를 한 번에 돌려줍니다 (SDK 1.0.16 이상). 한쪽 조회만 실패하면 성공한 쪽의 값만 담아 `isSuccess` 가 `true` 로 옵니다. 일반·구매형을 나눠 보거나 실패를 구분하려면 아래 두 함수를 각각 사용하세요 |
| `getAdvertiseTotalPoint(context: Context, callback: (TotalPointInfo?) -> Unit)` | 비구매형(PPI) 적립 가능 포인트·광고 수 (SDK 1.0.10 이상) |
| `getProductTotalPoint(context: Context, callback: (TotalPointInfo?) -> Unit)` | 구매형(CPS) 적립 가능 포인트·광고 수 (SDK 1.0.10 이상) |
| `clearApiSession()` | 포인트 조회에 쓰는 사용자 정보를 초기화합니다. 로그아웃 후 다른 계정으로 로그인하는 등 `setUserName` 을 다른 값으로 바꾼 직후에 호출하면, 다음 조회부터 새 사용자 기준으로 처리합니다 |

콜백으로 받은 값에 따라 다음과 같이 처리하세요.

| 콜백으로 받은 값 | 의미 | 화면에서 할 일 |
|---|---|---|
| `null` | 통신이나 인증에 실패했습니다 | 포인트 문구를 표시하지 않습니다 |
| `isSuccess == false` | 서버가 오류로 응답했습니다. 사유가 있으면 `retMessage` 에 담깁니다 | 포인트 문구를 표시하지 않습니다 (`pointAmount` 를 쓰지 마세요) |
| `isSuccess == true` | 정상입니다 | `pointAmount`(포인트 총합)와 `adCount`(광고 수)를 표시합니다 |

`info != null && info.isSuccess` 를 확인한 뒤에 표시하세요. `null` 이 아니라고 해서 성공은 아닙니다.
자세한 사용법은 [9. 적립 가능 포인트 조회](total-point.md)를 참고하세요.

### 콜백 등록

| 시그니처 | 설명 |
|---|---|
| `setRewardListener(listener: TnkRewardListener?)` | 보상 지급 완료 알림. 콜백은 메인 스레드로 옵니다. 리스너는 하나만 유지되어 다시 등록하면 교체되고, `null` 을 넘기면 해제됩니다. 오퍼월을 열기 전에 등록하세요 (등록 전에 도착한 알림은 전달되지 않습니다). 화면에서 등록했다면 그 화면의 `onDestroy()` 에서 `null` 로 해제하세요 |
| `setEventListener(listener: TnkEventListener?)` | 오퍼월 화면에서 발생한 이벤트를 이벤트 이름과 JSON 문자열 그대로 받습니다. 고급·디버깅 용도이며, 보상 알림은 `setRewardListener` 를 사용하세요. 콜백은 메인 스레드로 오고, 등록·해제 규칙은 `setRewardListener` 와 같습니다 |

### 딥링크

| 시그니처 | 설명 |
|---|---|
| `handleScheme(context: Context, url: String?): Boolean` | `tnkscheme://` 딥링크이면 SDK 가 처리하고 `true` 를 돌려줍니다. `tnkscheme` 이 아니거나 명령이 없는 주소이면 `false` 이므로 앱이 직접 처리하세요 |
| `handleScheme(context: Context, intent: Intent?): Boolean` | 위와 같습니다 |

---

## `TnkOfferwall`

기존 네이티브 SDK 의 인스턴스 방식을 그대로 쓸 수 있도록 제공합니다. 새로 연동한다면 `TnkPpiHybSdk.openOfferwall` 을 사용하세요.

```kotlin
class TnkOfferwall(context: Context) {
    fun setUserName(userName: String)
    fun setCOPPA(enabled: Boolean)
    fun startOfferwallActivity(activity: Activity)

    companion object {
        @JvmStatic fun show(context: Context, url: String)
    }
}
```

`show(context, url)` 에는 `TnkPpiHybSdk.buildOfferwallUrl()` 로 만든 주소만 넘기세요. 보통은 `TnkPpiHybSdk.openOfferwall()` 을 권장합니다.

---

## `TnkOfferwallView`

XML 에 배치해 오퍼월을 앱 화면 안에 삽입하는 뷰입니다.

```kotlin
class TnkOfferwallView : FrameLayout {
    fun loadOfferwall(url: String? = null, extraParams: Map<String, String>? = null)
    fun setSafeAreaTopPx(cssPx: Float)
    var onCloseRequested: (() -> Unit)?
}
```

`import com.tnkfactory.ad.hrwd.webview.TnkOfferwallView` 로 가져오고, XML 태그도 `<com.tnkfactory.ad.hrwd.webview.TnkOfferwallView ... />` 로 씁니다.

| 호출 | 동작 |
|---|---|
| `loadOfferwall()` | SDK 가 오퍼월 주소를 만들어 엽니다 (광고 ID 준비를 기다린 뒤) |
| `loadOfferwall(null, extraParams)` | 위와 같고, `extraParams` 가 반영됩니다 |
| `loadOfferwall(url)` | 넘긴 주소를 엽니다. 이때 `extraParams` 는 쓰이지 않으므로 필요한 파라미터는 주소에 담아야 합니다. `buildOfferwallUrl` 로 만든 주소만 넘기세요 |

`setSafeAreaTopPx(cssPx)` 는 앱이 상태 표시줄 아래까지 그리는 경우(edge-to-edge) 상단 안전 영역 높이를 CSS px(= 픽셀 ÷ density)로 전달합니다.

### 닫기 요청 (`onCloseRequested`)

오퍼월 화면에서 사용자가 닫기를 누르면 호출됩니다. 네트워크 오류 안내의 '닫기' 도 같은 규칙입니다.

| 설정 | 사용자가 닫기를 누르면 |
|---|---|
| 등록함 | 등록한 코드가 실행됩니다. 화면은 저절로 닫히지 않으니 탭 전환 등을 직접 처리하세요 |
| 등록하지 않음 (`null`) | 오퍼월 뷰가 들어 있는 Activity 가 종료됩니다. 앱 화면 안에 삽입한 경우 그 화면이 닫힙니다 |

> iOS 는 등록하지 않으면 아무 동작도 하지 않습니다. 아래 'iOS 와 다른 점'을 참고하세요.

---

## `TnkPlacementView` (SDK 1.0.17 이상)

지면(플레이스먼트) 하나의 광고 묶음을 앱 화면 일부에 보여 주는 뷰입니다. 사용 방법은 [10. 플레이스먼트 뷰](placement.md)를 보세요.

```kotlin
class TnkPlacementView @JvmOverloads constructor(
    context: Context,
    attrs: AttributeSet? = null,
    defStyleAttr: Int = 0,
) : FrameLayout {
    var listener: TnkPlacementListener?
    var layoutKey: String?              // load 전에 설정
    var verticalScrollEnabled: Boolean  // load 전에 설정, 기본 false
    var maxHeight: Int                  // load 전에 설정, dp, 기본 0 (제한 없음)
    var theme: String?                  // load 전에 설정. "light" · "dark"
    var filterIds: List<Int>?           // load 전에 설정
    var dataOnly: Boolean               // load 전에 설정, 기본 false
    var pubInfo: TnkPlacementPubInfo?   // 읽기 전용 (private set)
    val placementId: String?            // 읽기 전용. 마지막으로 load 한 지면 ID
    var adList: List<TnkPlacementAdItem> // 읽기 전용 (private set)
    fun getAdListJson(): String
    fun load(placementId: String)
    fun refresh()
    fun clickItem(appId: Long, onResult: ((success: Boolean, code: Int) -> Unit)? = null)
    fun clickItem(appId: Long)                                        // 결과가 필요 없을 때 (Java 포함)
    fun clickItem(appId: Long, callback: TnkPlacementClickCallback?)  // Java 용

    companion object {
        const val CODE_TIMEOUT: Int = -2
        const val CODE_UNKNOWN: Int = -1
    }
}
```

`import com.tnkfactory.ad.hrwd.webview.TnkPlacementView` 로 가져오고, XML 태그는 `<com.tnkfactory.ad.hrwd.webview.TnkPlacementView ... />` 로 씁니다. Java 에서는 `setListener` · `setLayoutKey` · `setVerticalScrollEnabled` · `setMaxHeight` · `setTheme` · `setFilterIds` · `setDataOnly` 로 설정합니다.

| 멤버 | 설명 |
|---|---|
| `listener` | 이 뷰의 이벤트를 받는 리스너. 뷰마다 따로 등록하며, 등록하지 않아도 동작은 같습니다 |
| `layoutKey` | 지면을 그릴 레이아웃 키. `DEFAULT` · `BOX` · `FEED_DOUBLE` · `FEED_SWIPE` · `FEED_SWIPE_DOUBLE` · `ING_CAMPAIGN` · `FEED` · `SIMPLE_LIST` · `ADAPTIVE` 중 하나이며 대소문자는 구분하지 않습니다. 모르는 키는 기본 레이아웃으로 그립니다. 같은 키라도 일반 지면과 쇼핑 지면의 모양이 다를 수 있으며, `SIMPLE_LIST` 는 두 지면 모두 같은 심플 리스트로 그립니다. TnkFactory 에서 지면 레이아웃을 정해 둔 경우에는 그 설정이 먼저 적용될 수 있습니다 |
| `verticalScrollEnabled` | 고정 높이에서 내용이 넘칠 때 지면 안 세로 스크롤을 허용합니다. 기본 `false` |
| `maxHeight` | 지면 높이의 상한(dp). 기본 `0` 은 제한 없음입니다. 0 보다 크면 내용 높이만큼 늘어나다가 이 높이에서 멈추고, 내용이 더 크면 `verticalScrollEnabled` 와 관계없이 지면 안에서 스크롤되며 양 끝에서는 앱의 스크롤로 이어집니다. `onHeightChanged` 는 내용 높이와 `maxHeight` 중 작은 값을 알립니다. 쓸 때는 지면 높이를 고정하지 마세요. `dataOnly` 일 때는 무시합니다 |
| `theme` | 지면과 지면에서 SDK 가 여는 전체 화면 오퍼월의 테마. `"light"` · `"dark"` 만 유효하고 그 밖의 값·`null` 은 기기(앱) 설정을 따릅니다. 지면 뷰 자체의 배경은 투명하고 카드와 행은 테마색으로 그려집니다 |
| `filterIds` | 보여 줄 항목을 `filter_id` 로 고릅니다. 목록 순서대로 id 마다 첫 항목 1건. 1~999999999 정수만, 중복은 처음 값만, 최대 50개 |
| `dataOnly` | `true` 면 지면을 그리지 않고 `onLoaded` · `onFailed` · `pubInfo` · `adList` 만 갱신합니다. 뷰는 `load` 를 시작할 때부터 `GONE` 이고 `onHeightChanged` 는 오지 않습니다. 뷰는 화면 계층 안에 두어야 합니다. 기본 `false` |
| `pubInfo` | 지면 정보(`TnkPlacementPubInfo`). `onLoaded` 직전에 설정되고 새 `load`·실패·정리 때 `null` 이 됩니다. 화면 구성용입니다 |
| `placementId` | 마지막으로 `load` 한 지면 ID. 한 번도 `load` 하지 않았으면 `null` |
| `adList` · `getAdListJson()` | 마지막으로 불러온 광고 목록(`List<TnkPlacementAdItem>`)과 같은 내용의 JSON 배열 문자열(없으면 `"[]"`). `onLoaded` 직전에 설정되므로 그 콜백 안에서 읽을 수 있고, 새 `load`·실패·정리 때 비워집니다. 화면 표시용이며 보상·과금 판단에 쓰지 마세요 |
| `load(placementId)` | 지면 ID 로 지면을 불러옵니다. 성공하면 자동으로 표시됩니다. 메인 스레드에서 호출하세요 |
| `refresh()` | 요청하는 동안 접지 않고 서버에서 목록을 다시 받아 바꿉니다. 받은 목록이 화면에 있는 목록과 같으면 보던 페이지와 가로 스크롤 위치가 그대로 유지되고, 달라졌으면 목록을 1페이지부터 새로 그립니다. 새 목록이 0건이면 접히고, 0건이던 지면에 광고가 생기면 다시 펼쳐집니다. 불러온 적이 없거나 불러오는 중이면 무시하고, 실패한 상태이면 `load` 와 같습니다. 메인 스레드에서 호출하세요 |
| `clickItem(appId, onResult)` | (Java 는 `TnkPlacementClickCallback` 을 넘깁니다) 사용자가 그 광고 행을 누른 것과 같게 처리합니다. 결과는 `onResult(success, code)` 로 정확히 1번 옵니다. `code`: `0` 화면 열기 시작 · `1003` 목록에 없는 `appId` · `1004` 앞선 요청 처리 중 · `-1` 그 밖의 실패 · `-2` 3초 안에 응답 없음. 동작은 `success` 로 나누고 `code` 는 기록·진단용으로 쓰세요. 성공은 화면 열기를 시작했다는 뜻이며 참여·보상 완료가 아닙니다. 사용자의 동작(버튼 탭 등)에 대한 응답으로만 호출하세요. 메인 스레드에서 호출하세요 |
| `CODE_TIMEOUT` (`-2`) | `onFailed` 의 코드. `load` 뒤 5초 안에 결과가 없을 때 |
| `CODE_UNKNOWN` (`-1`) | `onFailed` 의 코드. 네트워크 오류·에뮬레이터·빈 지면 ID 등 기타 실패 |

| `layout_height` | 동작 |
|---|---|
| `wrap_content` | 불러온 뒤 내용 높이(+ padding)에 맞춰집니다. 불러오기 전·0건·실패면 0 |
| 고정 dp | 불러오기 성공 뒤 그 높이를 유지합니다(불러오기 전·0건·실패면 `wrap_content` 와 같이 0). 넘치는 부분은 잘리고, `verticalScrollEnabled` 가 `true` 이거나 `maxHeight` 가 0 보다 크면 지면 안에서 스크롤됩니다 |
| `wrap_content` + `maxHeight` | 내용 높이에 맞춰지다가 `maxHeight` 에서 멈추고, 내용이 더 크면 지면 안에서 스크롤됩니다 |

---

## 콜백 타입과 값 객체

```kotlin
fun interface TnkRewardListener {
    fun onRewardCompleted(reward: RewardInfo)
}
```

```kotlin
fun interface TnkEventListener {
    fun onEvent(type: String, rawJson: String)
}
```

```kotlin
data class RewardInfo(
    val appId: Long,
    val appName: String?,
    val payPoint: Long,
    val pointUnit: String?,
    val payType: Int,
    val actionId: Int,
)
```

필드 의미와 코드값은 [5. 보상 지급 수신](reward.md)을 참고하세요.

```kotlin
interface TnkPlacementListener {
    fun onLoaded(placementId: String, count: Int, customData: String)
    fun onFailed(placementId: String, code: Int)
    fun onItemClicked(placementId: String, appId: Long, appName: String)
    fun onItemClosed(placementId: String, appId: Long) {}
    fun onMoreClicked(placementId: String): Boolean
    fun onHeightChanged(placementId: String, heightCssPx: Int) {}
}

open class TnkPlacementListenerAdapter : TnkPlacementListener

fun interface TnkPlacementClickCallback {
    fun onResult(success: Boolean, code: Int)   // Java 에서 clickItem 의 결과를 받을 때
}

data class TnkPlacementPubInfo(
    val placementId: String,
    val adType: Int,          // 0 일반 · 1 쇼핑 · 2 제휴몰 · 3 뉴스 · 4 이벤트 · 5 퀴즈, 값이 없으면 -1
    val title: String,
    val moreLabel: String,
    val customData: String,
    val pointUnit: String,
    val layoutKey: String,    // 실제로 그려진 레이아웃의 키. 알 수 없으면 ""
)

data class TnkPlacementAdItem(
    val appId: Long, val actionId: Int, val appName: String,
    val imageUrl: String, val iconUrl: String,
    val point: Long, val originalPoint: Long, val pointUnit: String, val pointText: String,
    val price: Long, val originalPrice: Long, val discountRate: Int,
    val isMultiMission: Boolean, val campaignType: Int, val campaignTypeName: String,
    val likeYn: String, val filterId: Int, val isLink: Boolean, val actionDesc: String,
)
```

`TnkPlacementListener` 의 콜백은 모두 메인 스레드에서 호출됩니다. `TnkPlacementListenerAdapter` 는 모든 콜백이 빈 구현이고 `onMoreClicked` 는 `false` 를 돌려줍니다. Java 에서는 `TnkPlacementListenerAdapter` 를 상속하세요.

| 콜백 | 설명 |
|---|---|
| `onLoaded` | 불러오기 성공. `pubInfo` · `adList` 가 먼저 설정된 뒤 이 콜백이 오고, 그다음에 `onHeightChanged` 가 옵니다. `count` 는 불러온 광고 수(레이아웃에 따라 화면에 보이는 개수보다 많을 수 있음, 0 이면 광고 없음, 뷰는 접힘), `customData` 는 지면에 설정된 값(없으면 빈 문자열) |
| `onFailed` | 불러오기 실패. 뷰는 접힙니다. `-2`: 5초 안에 응답 없음, `-1`: 기타 실패, 그 밖의 값은 서버가 알려 준 코드 — 계속되면 담당자에게 문의 |
| `onItemClicked` | 지면 안의 광고를 누른 즉시 1번(오퍼월을 열기 전). 일반 광고는 이후 SDK 가 광고 상세를 전체 화면 오퍼월로 엽니다. 지면이나 항목에 따라 다른 화면이 열릴 수 있고, 이때 `appId` 는 광고 ID 가 아닐 수 있습니다. `appName` 은 누른 행의 이름(없으면 빈 문자열)입니다. 화면 통지용이므로 보상·과금 판단에 쓰지 마세요 |
| `onItemClosed` | 항목을 눌러 SDK 가 연 화면(전체 화면 오퍼월 또는 앱 안에서 열린 페이지)이 닫혔을 때 1번. 외부 브라우저로 연 링크·더보기·정리된 뒤에는 호출하지 않습니다. 기본 구현은 빈 함수입니다 |
| `onMoreClicked` | 지면의 '더보기'(레이아웃에 따라 머리글 또는 아래쪽 버튼)를 눌렀을 때. `true` 면 앱이 직접 처리, `false` 면 SDK 가 오퍼월 첫 화면을 엽니다 |
| `onHeightChanged` | 지면 내용 높이(dp, 0 이상 5000 이하)가 바뀌었을 때. `maxHeight` 를 쓰면 내용 높이와 `maxHeight` 중 작은 값입니다. `dataOnly` 일 때는 오지 않습니다. Android 는 접힐 때 0 을 보내지 않으므로(iOS 는 보냅니다) 접힘은 `onLoaded`(`count` 0) 또는 `onFailed` 로 판단하세요 |

```kotlin
data class TotalPointInfo(
    val pointAmount: Long,   // 적립 가능 포인트 총합
    val adCount: Int,        // 적립 가능 광고 수
    val retCode: Int,        // 0 이면 성공, 응답 코드가 없으면 -1
    val retMessage: String?, // 서버가 오류로 응답했을 때의 사유 (없으면 null)
) {
    val isSuccess: Boolean   // retCode == 0
}
```

```kotlin
object TnkCode {
    const val MALE: Int = 1
    const val FEMALE: Int = 2
}
```

---

## iOS 와 다른 점

| 항목 | Android | iOS |
|---|---|---|
| 앱 ID 지정 | `init(context, appId)` / 매니페스트 `tnkad_app_id` | `configure(appId:)` / `Info.plist` `tnkad_app_id` |
| `getAppId` 의 자동 초기화 | 호출하면 초기화가 진행됩니다 | 초기화하지 않습니다 (SDK 호출 전에는 `nil`) |
| `setCOPPA` | `Boolean` | `Int` |
| `setGDPR` 를 호출하지 않았을 때 | 지정하지 않은 상태(`-1`)로 전달 | `0`(동의하지 않음)으로 전달 |
| 광고 ID 준비 콜백 | `onAdidReady` / `refreshAdid` | 없음 (`getAdid()` 만) |
| ATT 동의 요청 | 해당 없음 | `requestTrackingAuthorization` |
| `loadOfferwall` | `url` 생략 가능, `extraParams` 도 받음 | URL 하나만 받음 — `buildOfferwallURL(extraParams:)` 결과를 넘겨야 하며, `nil` 을 넘기면 오퍼월이 열리지 않고 다른 화면이 표시됨 |
| 상단 안전 영역 전달 | `setSafeAreaTopPx(cssPx)` | 없음 |
| 뷰 정리 | 생명주기 자동 처리 | `cleanup()` 수동 호출 |
| `onCloseRequested` 미등록 시 닫기 | 뷰가 들어 있는 Activity 종료 | 아무 동작 없음 — 닫기 처리를 직접 등록 |
| 플레이스먼트 뷰 리스너 | `listener: TnkPlacementListener?` | `delegate: TnkPlacementViewDelegate?` (weak 참조, 모든 메서드 선택 구현) |
| 플레이스먼트 뷰 `onHeightChanged` 인자 | `heightCssPx: Int` (dp) | `height: Double` (pt) |
| 플레이스먼트 뷰 `maxHeight` | `Int` (dp) | `CGFloat` (pt) |
| 플레이스먼트 뷰 접힘 알림 | `onHeightChanged(0)` 을 보내지 않음 | 광고 없음으로 바뀜·실패·새 `load`·`cleanup()` 때 `onHeightChanged(0)` 을 보냄 |
| 플레이스먼트 뷰 정리 | 화면 생명주기에 따라 자동 | 뷰 해제 때 자동, 먼저 정리하려면 `cleanup()` |
| 플레이스먼트 뷰 실패 코드 상수 | `TnkPlacementView.CODE_TIMEOUT`(-2) · `CODE_UNKNOWN`(-1) | 상수 없이 `-2`·`-1` 숫자 사용 |
| 플레이스먼트 뷰 읽기 전용 속성 | `pubInfo` · `placementId` · `adList` · `getAdListJson()` | `pubInfo` · `placementId` · `contentHeight` · `adList` · `adListJson` |
| 플레이스먼트 뷰 `clickItem` | `clickItem(appId: Long, onResult)` | `clickItem(appId: Int64, completion:)` |
