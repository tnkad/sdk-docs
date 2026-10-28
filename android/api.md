---
description: 개발사가 앱에서 직접 호출하는 하이브리드 오퍼월 SDK(Android)의 공개 API 시그니처와 동작을 정리했습니다. TnkPpiHybSdk, TnkOfferwall, TnkOfferwallView 와 콜백 타입을 다룹니다.
---

# 공개 API 목록 (개발사 사용 API)

이 페이지에서 하는 일: 개발사 앱이 직접 호출하는 공개 API 의 시그니처와 값별 동작을 한곳에서 찾아봅니다.

## 언제 필요한가

연동 중에 특정 메서드의 정확한 시그니처나 설정값별 동작을 확인할 때 찾아보는 참고 페이지입니다.
처음 연동한다면 [3. 초기화](initialize.md)와 [4. 오퍼월 띄우기](offerwall.md)부터 읽으세요.
기존 네이티브 SDK(`com.tnkfactory:rwd`)에서 옮기는 경우에는 [네이티브 SDK 에서 이관](migration.md)을 함께 참고하세요.

이 페이지에 없는 클래스와 메서드는 개발사가 사용하도록 안내하는 대상이 아닙니다.
필요한 기능이 목록에 없다면 담당자에게 문의해 주세요.

패키지: `com.tnkfactory.ad.hrwd` — 단, `TnkOfferwallView` 는 `com.tnkfactory.ad.hrwd.webview` 패키지에 있습니다.

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
