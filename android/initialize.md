---
description: SDK 초기화 순서와 개발사 사용자 식별값(setUserName) 설정 방법. 광고 ID(ADID) 수집 시점과 로그 활성화를 함께 다룹니다.
---

# 3. 초기화

## 최소 코드

```kotlin
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk

TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG)
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
TnkPpiHybSdk.start(applicationContext)
```

Java

```java
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk;

TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG);
TnkPpiHybSdk.setUserName(getApplicationContext(), "개발사-사용자-식별값");
TnkPpiHybSdk.start(getApplicationContext());
```

`Application.onCreate()` 또는 진입 Activity 의 `onCreate()` 어느 쪽에 두어도 됩니다.
`Context` 는 누수 방지를 위해 `applicationContext` 를 권장합니다.

---

## 명시적 `init()` 은 선택입니다

`TnkPpiHybSdk.init()` 을 직접 호출하지 않아도 됩니다.
`setUserName()` 이나 오퍼월 진입(`openOfferwall()`, `TnkOfferwall`, `TnkOfferwallView`)이
내부적으로 초기화를 보장합니다.

앱 ID 를 코드로 주입해야 하는 경우에만 명시 호출하세요.

```kotlin
TnkPpiHybSdk.init(context)                          // 매니페스트의 tnkad_app_id 사용
TnkPpiHybSdk.init(context, "발급받은-앱-아이디")      // 명시 주입
```

초기화 여부는 다음으로 확인합니다.

```kotlin
TnkPpiHybSdk.isInitialized()   // Boolean
TnkPpiHybSdk.getAppId(context) // 적용된 앱 ID (하이픈 제거된 형태)
```

---

## `start()` — 앱 실행 신호 (선택)

```kotlin
TnkPpiHybSdk.start(applicationContext)
```

실행 카운트와 Install Referrer 를 수집합니다. 광고 요청을 보내지는 않습니다.
네이티브 SDK 의 `applicationStarted()` 와 동일하며, 호환을 위해 그 이름도 유지합니다.

```kotlin
TnkPpiHybSdk.applicationStarted(context)   // start(context) 와 동일
```

---

## 사용자 식별값 (`setUserName`)

```kotlin
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
```

**보상 지급의 기준값**입니다. 개발사 서비스의 회원 ID 처럼 **사용자를 고유하게 식별하고
기기가 바뀌어도 유지되는 값**을 넣으세요. 이 값이 서버 보상 콜백의 `md_user_nm` 으로
그대로 전달됩니다([서버 보상 콜백 URL](../common/server-callback.md) 참고).

> ⚠️ 로그인 전이라 식별값이 없다면 오퍼월 진입 자체를 로그인 이후로 미루는 편이 안전합니다.
> 임시값으로 진입했다가 나중에 바꾸면, 그 사이 발생한 보상이 임시값으로 지급되어 회수할 수 없습니다.

현재 설정된 값은 다음으로 조회합니다.

```kotlin
TnkPpiHybSdk.getUserName(context)   // String?
```

---

## 로그

```kotlin
TnkPpiHybSdk.enableLogging(true)
```

`Logcat` 에서 태그 `TnkPpiHyb` 로 필터링하면 세션 생성, 오퍼월 URL, 브릿지 이벤트를 확인할 수 있습니다.
릴리스 빌드에서는 꺼두세요.

```kotlin
TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG)
```

---

## 광고 ID (ADID)

SDK 가 백그라운드에서 자동 수집합니다. **오퍼월 진입 전에 기다릴 필요가 없습니다** —
`openOfferwall()` 이 내부적으로 수집 완료를 보장한 뒤 화면을 띄웁니다.

개발사가 ADID 값 자체를 화면에 표시하거나 로깅해야 할 때만 아래를 사용하세요.

```kotlin
// 현재 캐시된 값 (메인 스레드에서 호출 가능, 수집 전이면 기본값)
val adid = TnkPpiHybSdk.getAdid(context)

// 수집 완료 시점 콜백 — 1회성, 메인 스레드에서 호출됨
TnkPpiHybSdk.onAdidReady { adid ->
    Log.i("TNK", "adid = $adid")
}

// 사용자가 시스템 설정에서 광고 ID 를 초기화한 경우 재조회
TnkPpiHybSdk.refreshAdid(context)
```

`onResume()` 마다 `refreshAdid()` 를 호출하면 사용자가 설정에서 광고 ID 를 리셋하고
돌아오는 경우도 반영됩니다.

---

다음: [4. 오퍼월 띄우기](offerwall.md)
