---
description: 앱이 시작될 때 한 번 호출하는 SDK 초기화 코드와 호출 순서를 안내합니다. 앱 ID 지정(init), 사용자 식별값(setUserName), 로그, 광고 ID 확인 방법을 값별 동작과 함께 설명합니다.
---

# 3. 초기화

이 페이지에서 하는 일: 앱이 시작될 때 SDK 에 사용자 식별값을 알려 주고, 오퍼월을 열 준비를 마칩니다.

## 언제 필요한가

모든 개발사에게 필요합니다. 사용자 식별값 설정(`setUserName`)은 **필수**이고, 나머지는 해당하는 경우에만 호출하는 선택 항목입니다.

---

## 앱 시작 시 한 번

아래 순서대로 앱이 시작될 때 한 번 호출합니다. 주석 처리된 줄은 해당하는 경우에만 풀어서 사용하세요.

```kotlin
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk

// 1) 로그 — 연동 확인용입니다. 출시 빌드에서는 꺼 둡니다.
TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG)

// 2) 앱 ID 를 코드로 넣는 경우에만 — 반드시 다른 SDK 호출보다 먼저
//    (매니페스트에 tnkad_app_id 를 선언했다면 생략)
// TnkPpiHybSdk.init(applicationContext, "발급받은-앱-아이디")

// 3) 사용자 식별값 (필수) — 사용자를 알 수 있는 시점에
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")

// 4) 앱에서 사용자에게 직접 개인정보 수집 동의를 받은 경우에만 — 반드시 setUserName 다음에
// TnkPpiHybSdk.setAgreePrivacy(applicationContext, true)

// 5) 만 13세 미만 사용자가 있는 앱만 — 계정마다 setUserName 다음에 (true: 해당, false: 해당 없음)
// TnkPpiHybSdk.setCOPPA(applicationContext, isUnder13)

// 6) 보상 알림을 받으려면 오퍼월을 열기 전에 setRewardListener 를 등록합니다 (5. 보상 지급 수신)
```

Java

```java
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk;

// 1) 로그 — 연동 확인용입니다. 출시 빌드에서는 꺼 둡니다.
TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG);

// 2) 앱 ID 를 코드로 넣는 경우에만 — 반드시 다른 SDK 호출보다 먼저
//    (매니페스트에 tnkad_app_id 를 선언했다면 생략)
// TnkPpiHybSdk.init(getApplicationContext(), "발급받은-앱-아이디");

// 3) 사용자 식별값 (필수) — 사용자를 알 수 있는 시점에
TnkPpiHybSdk.setUserName(getApplicationContext(), "개발사-사용자-식별값");

// 4) 앱에서 사용자에게 직접 개인정보 수집 동의를 받은 경우에만 — 반드시 setUserName 다음에
// TnkPpiHybSdk.setAgreePrivacy(getApplicationContext(), true);

// 5) 만 13세 미만 사용자가 있는 앱만 — 계정마다 setUserName 다음에 (true: 해당, false: 해당 없음)
// TnkPpiHybSdk.setCOPPA(getApplicationContext(), isUnder13);

// 6) 보상 알림을 받으려면 오퍼월을 열기 전에 setRewardListener 를 등록합니다 (5. 보상 지급 수신)
```

> 💡 `BuildConfig` 를 찾을 수 없다는 오류가 나면 앱 모듈 `build.gradle(.kts)` 의 `android { buildFeatures { buildConfig = true } }` 를 켜거나, 디버그 여부를 판단하는 기존 방식을 그대로 쓰세요.

`Application.onCreate()` 또는 진입 Activity 의 `onCreate()` 어느 쪽에 두어도 됩니다.
`Context` 는 누수 방지를 위해 `applicationContext` 를 권장합니다.

| 순서 | 호출 | 필수 | 이 순서인 이유 |
|:-:|---|:-:|---|
| 1 | `enableLogging` | 선택 | 이후 호출의 로그부터 확인하려면 가장 먼저 둡니다 |
| 2 | `init` | 선택 | 다른 SDK 호출이 먼저 있으면 앱 ID 가 적용되지 않습니다 |
| 3 | `setUserName` | **필수** | 이후 동작은 이 사용자 기준입니다 |
| 4 | `setAgreePrivacy` | 선택 | `setUserName` 이 동의 상태를 초기화할 수 있어 그 다음에 호출합니다 |
| 5 | `setCOPPA` | 선택 | 설정한 값이 저장되어 유지되므로, 계정을 바꿀 때마다 `true` 또는 `false` 로 다시 설정합니다. 오퍼월을 열기 전에 설정하세요. 값별 동작은 [7. 개인정보 설정](privacy.md) |
| 6 | `setRewardListener` | 선택 | 오퍼월을 열기 전에 등록해야 보상 알림을 놓치지 않습니다 |

오퍼월은 위 설정이 끝난 뒤 버튼 클릭 등에서 `openOfferwall` 로 엽니다. 자세한 내용은 [4. 오퍼월 띄우기](offerwall.md)를 참고하세요.

---

## 앱 ID 지정 (`init`)

매니페스트에 `tnkad_app_id` 를 선언했다면 `init()` 을 호출하지 않아도 됩니다. SDK 를 처음 호출할 때 매니페스트 값으로 자동 초기화됩니다.
서버 설정 등으로 앱 ID 를 실행 중에 정해야 하는 경우에만 코드로 넣으세요.

```kotlin
TnkPpiHybSdk.init(applicationContext)                           // 매니페스트의 tnkad_app_id 사용
TnkPpiHybSdk.init(applicationContext, "발급받은-앱-아이디")        // 코드로 지정
```

| 상황 | 적용되는 앱 ID |
|---|---|
| `init` 을 호출하지 않음 | 매니페스트의 `tnkad_app_id` (SDK 를 처음 호출할 때 자동 적용) |
| `init(context)` 호출 (앱 ID 생략) | 매니페스트의 `tnkad_app_id` |
| `init(context, "앱ID")` 를 **가장 먼저** 호출 | 코드로 넘긴 앱 ID (매니페스트 값보다 우선) |
| `init(context, "앱ID")` 를 `setUserName`·`start`·`openOfferwall` 등 **다른 SDK 호출 뒤에** 호출 | **무시됩니다.** 이미 초기화가 끝나 매니페스트 값이 쓰이고(매니페스트에도 없으면 앱 ID 없이 동작), 오류나 알림은 없습니다 |

초기화는 앱이 실행되는 동안 한 번만 일어나며, 한 번 정해진 앱 ID 는 바꿀 수 없습니다.
코드로 넘긴 앱 ID 는 저장되지 않으므로 **앱이 실행될 때마다** 가장 먼저 호출해야 합니다.
`enableLogging` 과 `setRewardListener` 는 초기화를 일으키지 않으므로 `init` 앞에 두어도 됩니다.

```kotlin
// 올바른 순서 — init 이 가장 먼저
TnkPpiHybSdk.init(applicationContext, "발급받은-앱-아이디")
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
```

```kotlin
// 잘못된 순서 — setUserName 이 먼저 SDK 를 초기화하므로 아래 init 의 앱 ID 는 적용되지 않습니다
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
TnkPpiHybSdk.init(applicationContext, "발급받은-앱-아이디")
```

> ⚠️ 매니페스트에도 없고 `init` 으로도 넣지 않으면 앱 ID 가 없는 상태가 되어 오퍼월을 정상적으로 이용할 수 없습니다.
> 둘 중 하나는 반드시 지정해 주세요. 매니페스트 설정은 [2. AndroidManifest 설정](manifest.md)을 참고하세요.

초기화 상태와 적용된 앱 ID 는 다음으로 확인합니다.

```kotlin
TnkPpiHybSdk.isInitialized()    // Boolean
TnkPpiHybSdk.getAppId(applicationContext)   // String? — 하이픈이 제거된 앱 ID
```

| 호출 | 돌려주는 값 | 알아둘 점 |
|---|---|---|
| `isInitialized()` | 초기화가 끝났으면 `true` | 이 호출은 초기화를 시작하지 않습니다. `setUserName` 같은 다른 SDK 호출 전에는 `false` 일 수 있으며 정상입니다 |
| `getAppId(context)` | 적용된 앱 ID, 앱 ID 가 없으면 `null` | 이 호출도 초기화를 진행합니다. `init` 으로 앱 ID 를 넣는 앱은 `init` 보다 먼저 호출하지 마세요 |

---

## 사용자 식별값 (`setUserName`)

```kotlin
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
```

**보상 지급의 기준값**입니다. 개발사 서비스의 회원 ID 처럼 **사용자를 고유하게 식별하고
기기가 바뀌어도 유지되는 값**을 넣으세요. 이 값이 서버 보상 콜백의 사용자 식별 파라미터로
그대로 전달됩니다([서버 보상 콜백 URL](../common/server-callback.md) 참고).

> ⚠️ 로그인 전이라 식별값이 없다면 오퍼월 진입 자체를 로그인 이후로 미루는 편이 안전합니다.
> 임시값으로 진입했다가 나중에 바꾸면, 그 사이 발생한 보상이 임시값으로 지급되어 회수할 수 없습니다.

식별값을 바꾸면 개인정보 수집 동의 상태에도 영향이 있습니다 (SDK 1.0.11 이상).

| 호출 | 동의 상태 | 사용자가 보는 것 |
|---|---|---|
| 이전과 **같은 값**으로 호출 | 그대로 유지됩니다 | 변화 없음. 앱을 시작할 때마다 호출해도 됩니다 |
| 이전과 **다른 값**으로 호출 (최초 지정 포함) | 초기화되어 동의하지 않은 상태가 됩니다 (`isAgreePrivacy` 가 `false`) | 다음에 여는 오퍼월에서 개인정보 수집 동의 팝업이 나옵니다 |
| 다른 값으로 호출한 뒤 `setAgreePrivacy(context, true)` 를 이어서 호출 | 동의한 상태가 됩니다 | 동의 팝업이 나오지 않습니다 (앱에서 직접 동의를 받은 경우에만 사용) |

이미 열려 있는 오퍼월 화면은 바뀌지 않고, 다음에 여는 오퍼월부터 반영됩니다.

<figure><img src="../assets/common/consent-popup.png" alt="개인정보 수집 동의 팝업. 수집정보와 보유기간 안내, 거부와 동의 버튼이 있음" width="300"><figcaption><p>식별값이 바뀌면 다음에 여는 오퍼월에서 동의 팝업이 다시 나옵니다. 오퍼월 화면은 Android·iOS 가 같습니다.</p></figcaption></figure>

직접 동의를 받는 개발사는 앱을 시작할 때마다 `setUserName` → `setAgreePrivacy` 순서로 호출하세요.
직접 동의를 받지 않는 개발사는 `setAgreePrivacy` 를 호출하지 않습니다.
단, 동의를 철회한 사용자에게는 `true` 로 다시 설정하지 마세요. 자세한 내용은 [7. 개인정보 설정](privacy.md)의 '동의 철회' 항목을 참고하세요.

### 계정을 바꿀 때

로그아웃 후 다른 계정으로 로그인하는 경우 새 식별값으로 `setUserName` 을 다시 호출합니다.
적립 가능 포인트 조회([9. 적립 가능 포인트 조회](total-point.md))를 쓰는 앱은 이어서 `clearApiSession()` 도 호출하세요 (SDK 1.0.10 이상).

```kotlin
// 다른 계정으로 로그인했을 때
TnkPpiHybSdk.setUserName(applicationContext, "새-사용자-식별값")
TnkPpiHybSdk.clearApiSession()
```

`clearApiSession()` 을 호출하지 않으면 적립 가능 포인트 조회가 이전 사용자 정보로 처리될 수 있습니다.
포인트 조회를 쓰지 않는 앱은 호출하지 않아도 됩니다.

현재 설정된 값은 다음으로 조회합니다. 설정한 적이 없으면 `null` 입니다.

```kotlin
TnkPpiHybSdk.getUserName(applicationContext)   // String?
```

---

## 앱 실행 신호 (`start`) — 선택

```kotlin
TnkPpiHybSdk.start(applicationContext)
```

현재 버전에서는 호출하지 않아도 오퍼월 표시와 보상 지급에 영향이 없습니다. 기존 코드를 옮기는 경우가 아니라면 생략해도 됩니다.
다만 `start` 를 처음 호출하면 SDK 가 초기화되므로, 앱 ID 를 `init` 으로 넣는 앱은 `init` 다음에 호출하세요.

기존 네이티브 SDK(`com.tnkfactory:rwd`)에서 `TnkSession.applicationStarted(context)` 를 쓰셨다면,
`TnkPpiHybSdk.applicationStarted(context)` 로 클래스 이름만 바꿔 같은 위치에 두셔도 됩니다. `start(context)` 와 같은 메서드입니다.

```kotlin
TnkPpiHybSdk.applicationStarted(applicationContext)   // start(applicationContext) 와 같은 동작
```

---

## 로그 (`enableLogging`)

```kotlin
TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG)
```

| 설정 | Logcat 에서 보이는 것 | 언제 쓰나 |
|---|---|---|
| `true` | 태그 `TnkPpiHyb` 로 SDK 초기화, 오퍼월 열기, 적립 가능 포인트 조회 결과 같은 연동 확인용 로그가 보입니다 | 개발·테스트 중 |
| `false` (기본값) | 태그 `TnkPpiHyb` 의 SDK 로그가 나오지 않습니다 | 출시 빌드 |
| 호출하지 않음 | `false` 와 같습니다 | — |

> 💡 `enableLogging` 은 태그 `TnkPpiHyb` 로그만 켜고 끕니다. 오퍼월 화면에서 남기는 로그(태그 `TnkOfferwall` 등)는 이 설정과 관계없이 출력될 수 있습니다.

> ⚠️ 출시 빌드에서는 끄세요. 로그에 사용자 정보가 담긴 값이 포함될 수 있습니다.

---

## 광고 ID (ADID)

SDK 가 광고 ID 를 자동으로 가져옵니다. **오퍼월을 열기 전에 기다릴 필요가 없습니다.**
`openOfferwall()` 과 화면 안 오퍼월 뷰의 `loadOfferwall()` 이 광고 ID 준비를 마친 뒤 화면을 띄웁니다.

앱 화면에 값을 보여 주거나 개발 빌드에서 값을 확인해야 할 때만 아래를 사용하세요. 확인이 끝나면 로그 코드는 지우세요. 출시 빌드에서 광고 ID·사용자 식별값을 로그로 남기지 마세요.

```kotlin
// 현재 값 (메인 스레드에서 호출 가능)
val currentAdid = TnkPpiHybSdk.getAdid(applicationContext)

// 광고 ID 를 받으면 한 번 호출됩니다 (메인 스레드)
TnkPpiHybSdk.onAdidReady { id ->
    if (BuildConfig.DEBUG) Log.i("TNK", "adid = $id")   // 확인용 (개발 빌드 전용)
}

// 사용자가 기기 설정에서 광고 ID 를 재설정·삭제한 뒤 앱으로 돌아왔을 때
TnkPpiHybSdk.refreshAdid(applicationContext)
```

Java

```java
import kotlin.Unit;

TnkPpiHybSdk.onAdidReady(adid -> {
    if (BuildConfig.DEBUG) Log.i("TNK", "adid = " + adid);   // 확인용 (개발 빌드 전용)
    return Unit.INSTANCE;   // Kotlin 함수 타입 콜백은 Unit 을 돌려줘야 합니다
});
```

### `getAdid` 가 돌려주는 값

| 상황 | 돌려주는 값 |
|---|---|
| 광고 ID 를 이미 받음 | 하이픈 없는 32자리 소문자 |
| 아직 받기 전이고, 이전 실행에서 받은 값이 있음 | 이전 실행에서 받은 값 |
| 아직 받기 전이고, 이전 값도 없음 (설치 직후 첫 실행 등) | `"00000000000000000000000000000000"` (32자리 0) |

### `onAdidReady` 콜백이 오는 경우와 오지 않는 경우

| 상황 | 콜백 |
|---|---|
| 광고 ID 를 받는 순간 | 한 번 호출됩니다 (메인 스레드) |
| 등록할 때 이미 광고 ID 를 받은 상태 | 등록하자마자 호출됩니다 |
| 사용자가 기기 설정에서 광고 ID 를 삭제했거나, Google Play 서비스를 쓸 수 없는 기기 | **호출되지 않습니다** |
| `onAdidReady` 만 등록하고 다른 SDK 호출이 없음 | **호출되지 않습니다.** 이 호출은 초기화를 시작하지 않으므로 `setUserName` 등과 함께 사용하세요 |

콜백이 오기를 기다리느라 화면 진행을 막지 마세요. 오퍼월은 이 콜백과 관계없이 열 수 있습니다.

> 💡 사용자가 기기에서 광고 추적을 제한한 경우에도 오퍼월은 열립니다. 다만 광고 ID 가 필요한 광고에 참여하려 하면 오퍼월이 광고 추적 허용이 필요하다는 안내를 보여 주고 참여를 멈춥니다. 개발사가 따로 처리할 코드는 없습니다.

### 광고 ID 를 다시 받아야 할 때

앱이 실행되는 동안 사용자가 광고 ID 를 재설정하거나 삭제하면, 앱을 다시 실행하기 전까지 SDK 는 이전 광고 ID 를 계속 사용합니다.
바로 반영하려면 화면이 다시 보일 때(`onResume()`) `refreshAdid(context)` 를 호출하세요. 오퍼월이 사용하는 광고 ID 도 함께 갱신됩니다.
앱을 다시 실행하면 자동으로 반영되므로 이 호출은 선택입니다.

다시 받은 광고 ID 를 콜백으로 받으려면 `refreshAdid` 를 호출한 직후 `onAdidReady` 를 다시 등록하세요. 이미 호출된 콜백은 다시 호출되지 않습니다.

> 💡 `buildOfferwallUrl()` 로 오퍼월 주소를 직접 만드는 경우에는 광고 ID 를 기다리지 않습니다. 앱 첫 실행 직후에는 광고 ID 가 비어 있을 수 있으니, 보통은 `openOfferwall()` 이나 `loadOfferwall()` 을 사용하세요.

---

다음: [4. 오퍼월 띄우기](offerwall.md)
