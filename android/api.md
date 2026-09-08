---
description: TnkPpiHybSdk, TnkOfferwall, TnkOfferwallView 등 하이브리드 오퍼월 SDK(Android)가 제공하는 공개 API 전체 시그니처입니다.
---

# 공개 API 목록

패키지: `com.tnkfactory.ad.hrwd`

모든 `TnkPpiHybSdk` 메서드는 `@JvmStatic` 이므로 Java 에서 `TnkPpiHybSdk.xxx(...)` 로 호출합니다.

---

## `TnkPpiHybSdk`

### 초기화 · 수명주기

| 시그니처 | 설명 |
|---|---|
| `init(context: Context, appId: String? = null)` | 명시 초기화(선택). `appId` 가 `null` 이면 저장값 → 매니페스트 순으로 폴백 |
| `start(context: Context)` | 앱 실행 신호. 실행 카운트 / Install Referrer 수집 |
| `applicationStarted(context: Context)` | `start()` 와 동일 (네이티브 SDK 호환) |
| `isInitialized(): Boolean` | 초기화 완료 여부 |
| `enableLogging(enabled: Boolean)` | 로그 on/off |
| `enableLogging(context: Context, enabled: Boolean)` | 위와 동일 (네이티브 SDK 호환) |
| `VERSION: String` | SDK 버전 문자열 |

### 사용자 · 개인정보

| 시그니처 | 설명 |
|---|---|
| `setUserName(context: Context, userName: String)` | 개발사 사용자 식별값. **보상 지급 기준값** |
| `getUserName(context: Context): String?` | 설정된 식별값 조회 |
| `getAppId(context: Context): String?` | 적용된 개발사 앱 ID (하이픈 제거) |
| `setAgreePrivacy(context: Context, agree: Boolean)` | 개인정보 동의 상태. `true` 면 오퍼월 동의 화면 스킵 |
| `isAgreePrivacy(context: Context): Boolean` | 동의 상태 조회 |
| `setCOPPA(context: Context, enabled: Boolean)` | 만 13세 미만 여부 |
| `setGDPR(context: Context, gdpr: Int)` | GDPR 설정값 |

### 광고 ID (ADID)

| 시그니처 | 설명 |
|---|---|
| `getAdid(context: Context): String` | 캐시된 값. 메인 스레드에서 호출 가능 |
| `onAdidReady(callback: (String) -> Unit)` | 수집 완료 콜백(1회성, 메인 스레드) |
| `refreshAdid(context: Context)` | 재조회 요청 |

### 오퍼월

| 시그니처 | 설명 |
|---|---|
| `openOfferwall(context: Context, extraParams: Map<String, String>? = null)` | 전체화면 오퍼월 진입 |
| `buildOfferwallUrl(context: Context, extraParams: Map<String, String>? = null): String` | 오퍼월 URL 조립 |

### 특정 광고 진입

네이티브 SDK 의 `adDetail` / `adJoin` / `adAction` 과 같은 이름·의미입니다.
`actionId` 는 기본 0, CPS(쇼핑) 광고만 5 를 지정합니다.
결과 콜백은 없습니다 — 광고 조회·참여와 오류 안내를 오퍼월(FE)이 처리합니다.

| 시그니처 | 설명 |
|---|---|
| `adDetail(context: Context, appId: Long, actionId: Int = 0)` | 해당 광고의 **상세 화면으로 바로 진입**. 닫으면 오퍼월도 닫혀 개발사 화면으로 복귀 |
| `adJoin(context: Context, appId: Long, actionId: Int = 0)` | 상세 없이 **바로 참여** 후 광고주 페이지로 이동 |
| `adAction(context: Context, appId: Long, actionId: Int = 0)` | 리스트 클릭과 동일 규칙(상세 또는 바로 참여). 닫으면 오퍼월 홈 |

### 적립 가능 포인트 조회

네이티브 SDK 의 `queryAdvertiseCount` / `getEarnPoint` 에 대응합니다. 네트워크 I/O 는 백그라운드에서
수행되고 콜백은 메인 스레드로 옵니다. 실패 시 `null` 이 전달됩니다 (Android 전용 — iOS 는 미제공).

| 시그니처 | 설명 |
|---|---|
| `getAdvertiseTotalPoint(context: Context, callback: (TotalPointInfo?) -> Unit)` | 비구매형(PPI) 적립 가능 포인트·광고 수 |
| `getProductTotalPoint(context: Context, callback: (TotalPointInfo?) -> Unit)` | 구매형(CPS) 적립 가능 포인트·광고 수 |

`TotalPointInfo`: `pointAmount: Long`(포인트 총합) · `adCount: Int`(광고 수) · `retCode: Int` · `retMessage: String?` · `isSuccess: Boolean`

### 콜백 등록

| 시그니처 | 설명 |
|---|---|
| `setRewardListener(listener: TnkRewardListener?)` | 보상 지급 완료 알림 |
| `setEventListener(listener: TnkEventListener?)` | 웹(FE) 이벤트 원본 수신 |

### 딥링크

| 시그니처 | 설명 |
|---|---|
| `handleScheme(context: Context, url: String?): Boolean` | 스킴 처리. 소비 여부 반환 |
| `handleScheme(context: Context, intent: Intent?): Boolean` | 위와 동일 |

---

## `TnkOfferwall`

네이티브 SDK 의 인스턴스 패턴 호환용입니다.

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

---

## `TnkOfferwallView`

XML 에 배치해 오퍼월을 화면 안에 삽입하는 뷰입니다.

```kotlin
class TnkOfferwallView : FrameLayout {
    fun loadOfferwall(url: String? = null, extraParams: Map<String, String>? = null)
    fun setSafeAreaTopPx(cssPx: Float)
    var onCloseRequested: (() -> Unit)?
}
```

---

## `TnkRewardListener`

```kotlin
fun interface TnkRewardListener {
    fun onRewardCompleted(reward: RewardInfo)
}
```

## `TnkEventListener`

```kotlin
fun interface TnkEventListener {
    fun onEvent(type: String, rawJson: String)
}
```

## `RewardInfo`

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
