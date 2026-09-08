---
description: 기존 네이티브 오퍼월 SDK(com.tnkfactory:rwd)에서 하이브리드 SDK 로 옮길 때의 체크리스트와, TnkSession·TnkOfferwall·TnkAdConfig 공개 API 전수 대조표입니다.
---

# 네이티브 SDK 에서 이관

기존 네이티브 오퍼월 SDK(`com.tnkfactory:rwd`)를 사용 중인 개발사를 위한 문서입니다.
신규 연동이라면 이 페이지는 건너뛰셔도 됩니다.

---

## 무엇이 달라졌나

네이티브 SDK 는 광고 목록·상세·포인트 화면을 **앱 안에서 직접** 그립니다.
하이브리드 SDK 는 그 화면들을 **WebView 안의 웹(FE)** 이 그립니다.

그래서 이관 원칙이 이렇게 정리됩니다.

- **세션 · 식별 · 설정 · 오퍼월/특정광고 진입 계열** → 이름 또는 시그니처를 유지했습니다.
  대부분 클래스명(`TnkSession` → `TnkPpiHybSdk`)만 바꾸면 그대로 컴파일됩니다.
- **포인트 조회 · 아이템 구매 · 인출 등 RPC 계열과 화면 커스터마이징 계열** → **제공하지 않습니다.**
  해당 기능은 오퍼월 화면(FE) 안에서 처리되거나 서버 설정으로 관리되므로 개발사 코드에서 제거하시면 됩니다.

요약하면: **걷어낼 코드는 있어도, 새로 배워야 할 개념은 거의 없습니다.**
아래 [전체 API 대조표](#전체-api-대조표)에 네이티브 SDK 의 공개 API 를 전수 대조해 두었으니,
사용 중인 호출을 표에서 찾아 그대로 치환·제거하시면 이관이 끝납니다.

> 💡 **Java 개발사에 좋은 소식**: 네이티브 SDK 의 `TnkSession`/`TnkAdConfig` 는 Kotlin `object` 라
> Java 에서 `TnkSession.INSTANCE.xxx()` 로 불러야 했지만, 하이브리드 SDK 는 모든 메서드가
> `@JvmStatic` 이라 `TnkPpiHybSdk.xxx(...)` 로 바로 호출됩니다.

---

## 이관 체크리스트

- [ ] 의존성 좌표를 `com.tnkfactory:rwd:...` → `com.tnkfactory.ad:hrwd` 로 교체 (최신 버전은 [1. 설치](install.md) 참고)
- [ ] import 경로를 `com.tnkfactory.ad.*` → `com.tnkfactory.ad.hrwd.*` 로 교체
- [ ] `TnkSession.*` 호출을 `TnkPpiHybSdk.*` 로 치환
- [ ] 특정 광고 진입: `adDetail` / `adJoin` / `adAction` 은 **같은 이름 그대로**, `showAdDetailDialog` → `adDetail` (아래 대조표 참고)
- [ ] 매니페스트에서 `com.tnkfactory.ad.AdWallActivity` `<activity>` 선언 **제거**
- [ ] 포인트/RPC 호출부(`queryPoint`, `purchaseItem` 등) 제거
- [ ] 디자인 커스터마이징(`TnkAdConfig` / `TnkStyle`) 제거 — 오퍼월 테마는 서버에서 개발사별로 관리
- [ ] 보상 지급 UI 갱신을 `setRewardListener` 로 이전
- [ ] 서버 콜백 URL 구현은 **그대로 유지** (변경 없음)
- [ ] `tnkad_app_id` meta-data 는 **그대로 유지** (변경 없음)
- [ ] `tnkad_tracking` meta-data 는 남겨두셔도 무해합니다 (하이브리드 SDK 는 이 값을 사용하지 않습니다)

---

## ⚠️ 매니페스트에서 반드시 제거할 것

네이티브 SDK 가이드에 따라 아래를 직접 선언해 두셨다면 **제거**하세요.

```xml
<!-- 제거 대상 -->
<activity android:name="com.tnkfactory.ad.AdWallActivity" ... />
```

하이브리드 SDK 가 같은 컴포넌트명을 `activity-alias` 로 병합하기 때문에,
남겨두면 매니페스트 머지 단계에서 빌드가 실패합니다.
(제거해도 기존에 `AdWallActivity` 를 참조하던 코드는 alias 를 통해 계속 동작합니다.)

---

## 전체 API 대조표

네이티브 SDK 의 공개 API(`TnkSession` · `TnkOfferwall` · `TnkAdConfig` 등)를 전수 대조한 표입니다.
**구분** 열의 의미:

- **그대로** — 이름·시그니처가 같아 클래스명 치환만으로 동작
- **치환** — 대응 API 가 있고 이름/시그니처만 다름
- **제거** — 하이브리드에 없음. 오퍼월(FE)·서버가 대신 처리하므로 호출부를 지우면 됨
- **문의** — 대응 API 가 없는 부가 기능. 사용 중이라면 TnkFactory 담당자에게 문의

### 초기화 · 세션 · 앱 실행

| 네이티브 (`TnkSession`) | 하이브리드 (`TnkPpiHybSdk`) | 구분 |
|---|---|---|
| `applicationStarted(context)` | `applicationStarted(context)` | **그대로** |
| `enableLogging(flag)` | `enableLogging(context, flag)` / `enableLogging(flag)` | **그대로** |
| `appStartedOnceAMonth(context)` | 불필요 — `applicationStarted()` 만 호출하면 SDK 가 내부 처리 | 제거 |
| `actionCompleted(context, actionName)` / `buyCompleted(context, itemName)` | 지급은 서버가 판정, 완료 통지는 `setRewardListener` | 제거 |
| `getReferrer(context)` | 불필요 — SDK 가 Install Referrer 를 내부 수집 | 제거 |
| `deleteTestLog(context)` / `prohibitConcurrentInvoke(...)` | 없음 | 제거 |
| `runOnMainThread` / `runOnIoThread` | SDK 유틸이 아닌 표준 API 사용 | 제거 |

### 사용자 · 기기 식별

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `TnkSession.setUserName(context, userName)` | `TnkPpiHybSdk.setUserName(context, userName)` | **그대로** |
| `TnkSession.getUserName(context)` | `TnkPpiHybSdk.getUserName(context)` | **그대로** |
| `TnkOfferwall.setUserAge(context, age)` / `setUserGender(context, gender)` | `TnkPpiHybSdk.setUserAge(context, age)` / `setUserGender(context, gender)` | **그대로** |
| `TnkSession.setDeviceIds(context, deviceId, udid)` | 없음 | 문의 |
| `TnkSession.isAdidLimit(context) { ... }` | 불필요 — 추적 제한 안내를 오퍼월(FE)이 참여 시점에 처리 | 제거 |

### 개인정보 동의

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `setAgreePrivacy(activity, isAgree)` | `setAgreePrivacy(context, agree)` | **그대로** |
| `getAgreePrivacy(activity)` | `isAgreePrivacy(context)` | 치환 |
| `showAgreePrivacyPopup(activity, listener)` | 오퍼월(FE) 동의 화면이 자동 표시. 이미 동의받았다면 `setAgreePrivacy(true)` 로 스킵 | 제거 |
| `TnkOfferwall.setCOPPA(bool)` / `setGdprConsent` | `TnkPpiHybSdk.setCOPPA(context, bool)` / `setGDPR(context, int)` | 치환 |
| `TnkOfferwall.showTermsDialog` / `termsCheck` | 오퍼월(FE) 동의 화면 | 제거 |
| `AgreePrivacyPopupListener` | 없음 (동의 화면이 FE 로 이동) | 제거 |

### 오퍼월 진입

| 네이티브 (`TnkOfferwall`) | 하이브리드 | 구분 |
|---|---|---|
| `TnkOfferwall(context)` + `startOfferwallActivity(context)` | 동일 코드 그대로 동작 (호환 클래스 제공). 신규 권장형은 `TnkPpiHybSdk.openOfferwall(context)` | **그대로** |
| `startOfferwallActivity(context, adId)` | `TnkPpiHybSdk.adAction(context, adId)` | 치환 |
| `load(listener)` + `getAdListView()` | XML 임베드 `TnkOfferwallView` — `loadOfferwall()` 한 번이면 끝 | 치환 |
| `getAdListView(adId)` | `TnkOfferwallView.loadOfferwall(null, mapOf("ad" to "<adId>"))` | 치환 |
| `loadWithNewsData(listener)` / `getEmbedAdList()` / `getEmbedNewsList()` / `getFeedPopup()` | 없음 | 문의 |
| `getAdPlacementView(activity)` (`AdPlacementView`) | 없음 | 문의 |
| `showMyMenu(activity)` | 오퍼월(FE) 마이페이지 | 제거 |
| `dataChanged()` / `getAdlistJson(...)` | 광고 데이터는 앱에 넘기지 않음 — FE 가 서버에서 직접 수신 | 제거 |

### 특정 광고 진입

| 네이티브 (`TnkOfferwall`) | 하이브리드 (`TnkPpiHybSdk`) | 구분 |
|---|---|---|
| `adDetail(context, appId, actionId) { ok, err -> }` | `adDetail(context, appId, actionId = 0)` | **그대로** (콜백만 제거) |
| `adJoin(context, appId, actionId) { ok, err -> }` | `adJoin(context, appId, actionId = 0)` | **그대로** (콜백만 제거) |
| `adAction(context, appId, actionId) { ok, err -> }` | `adAction(context, appId, actionId = 0)` | **그대로** (콜백만 제거) |
| `showAdDetailDialog(context, appId, actionId) { ok, err -> }` | `adDetail(context, appId, actionId = 0)` | 치환 |

의미는 네이티브와 같습니다 — `adDetail` 은 무조건 상세(닫으면 개발사 화면 복귀), `adJoin` 은 상세 없이
바로 참여, `adAction` 은 리스트 클릭과 같은 분기. `actionId` 는 기본 0(CPS 만 5).
`(Boolean, TnkError?)` 결과 콜백은 받지 않습니다 — 광고 조회·참여와 오류 안내를 오퍼월(FE)이 처리합니다.
네이티브에서 `@JvmOverloads` 가 없어 Java 는 4개 인자를 모두 넘겨야 했지만, 하이브리드는
`@JvmOverloads` 가 붙어 있어 Java 에서도 `adDetail(context, appId)` 로 호출됩니다.

### 포인트 · 상태 조회

| 네이티브 (`TnkSession` / `TnkOfferwall`) | 하이브리드 | 구분 |
|---|---|---|
| `TnkSession.queryAdvertiseCount(context, callback)` | `TnkPpiHybSdk.getAdvertiseTotalPoint(context) { info -> }` (PPI) / `getProductTotalPoint` (CPS) — 광고 수·포인트 합계를 `TotalPointInfo` 로 반환 | 치환 |
| `TnkOfferwall.getEarnPoint(...)` (3종) / `getEarnPointByFilter` | 위 `getAdvertiseTotalPoint` / `getProductTotalPoint` 또는 오퍼월(FE) 표시 | 치환 |
| `TnkSession.queryPoint(...)` (동기/비동기) | 오퍼월(FE)이 잔액을 조회·표시 | 제거 |
| `purchaseItem(...)` / `withdrawPoints(...)` (각 2종) | 오퍼월(FE) | 제거 |
| `queryPublishState` / `queryAdvertiseState` / `STATE_*` 상수 | 오퍼월(FE)·관리자 페이지 | 제거 |
| `getHelpdeskUrl` / `getRewardUrl` / `geFaqUrl` / `getHelpUrl` | 오퍼월(FE) 마이페이지에 내장 | 제거 |
| `ServiceCallback` / `TnkResultListener` / `TnkError` | 없음. 보상 완료는 `TnkRewardListener` | 제거 |

### 디자인 커스터마이징 · 화면 설정 — 전부 서버 관리로 이동

| 네이티브 | 대체 | 구분 |
|---|---|---|
| `TnkAdConfig.*` (`pointEffectType`, `useCuration`, `detailViewImageType`, `layoutConfig`, `setLayoutInfo` 등 전체) | 오퍼월 UI·레이아웃·테마는 서버에서 개발사별로 관리 — **SDK 업데이트 없이 반영** | 제거 |
| `TnkAdConfig.useTermsPopup = false` | `setAgreePrivacy(true)` | 치환 |
| `TnkAdConfig.headerConfig.startCategory` / `startFilterID` (시작 탭·필터) | 딥링크 `tnkscheme://select_menu?cat_id=..&filter_id=..` → `handleScheme` | 치환 |
| `TnkStyle.*` (애니메이션·언어·동의 버튼 색 등) | 서버 관리 / 오퍼월(FE) | 제거 |
| `TnkAdLayoutConfig` / `TnkHeaderConfig` / 커스텀 툴바·헤더 클래스 | 서버 관리 | 제거 |
| `TnkAdAnalytics` (UI 이벤트 수신) | `setEventListener` (웹 이벤트 원본 수신 — 이벤트 체계는 다름. 특정 이벤트가 필요하면 문의) | 치환 |
| `TnkAdHideUtil` / `TnkOnBackPressListener` / `TnkAdListModel` (준공개 내부 클래스) | 없음 | 문의 |
| 포인트 스토어 모듈(`rwd-store` 의 `RwdPlusStore*` 다이얼로그) | 없음 | 문의 |

> 개발사 자체 화면에 포인트 잔액을 표시하고 계셨다면 별도 협의가 필요합니다.
> TnkFactory 담당자에게 문의하세요.

---

## 코드 비교

### 네이티브 SDK

```kotlin
val offerwall = TnkOfferwall(this)
lifecycleScope.launch(Dispatchers.IO) {
    val adid = AdvertisingIdInfo.requestIdInfo(this@MainActivity)
    offerwall.setUserName(adid.id)
    offerwall.setCOPPA(false)
    offerwall.getEarnPoint { point ->
        binding.tvPoint.text = "받을 수 있는 포인트 : $point p"
    }
}
button.setOnClickListener { offerwall.startOfferwallActivity(this) }

// 특정 광고 상세
offerwall.adDetail(this, 123456L, 0) { success, error -> }
```

### 하이브리드 SDK

```kotlin
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
TnkPpiHybSdk.setCOPPA(applicationContext, false)
TnkPpiHybSdk.setRewardListener { reward ->
    refreshMyPointBalance()
}
TnkPpiHybSdk.getAdvertiseTotalPoint(this) { info ->
    binding.tvPoint.text = "받을 수 있는 포인트 : ${info?.pointAmount ?: 0} p"
}
button.setOnClickListener { TnkPpiHybSdk.openOfferwall(this) }

// 특정 광고 상세 — 결과 콜백이 사라집니다 (오류 안내도 오퍼월이 표시)
TnkPpiHybSdk.adDetail(this, 123456L)
```

광고 ID 를 직접 조회하는 절차(`AdvertisingIdInfo.requestIdInfo`)가 사라졌습니다.
SDK 가 백그라운드에서 수집하고 오퍼월 진입 시 준비를 보장합니다.
