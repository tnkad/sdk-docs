---
description: 기존 네이티브 오퍼월 SDK(com.tnkfactory:rwd)에서 하이브리드 SDK 로 옮길 때의 체크리스트와, 호환되는 API·제공하지 않는 API 목록입니다.
---

# 네이티브 SDK 에서 이관

기존 네이티브 오퍼월 SDK(`com.tnkfactory:rwd`)를 사용 중인 개발사를 위한 문서입니다.
신규 연동이라면 이 페이지는 건너뛰셔도 됩니다.

---

## 무엇이 달라졌나

네이티브 SDK 는 광고 목록·상세·포인트 화면을 **앱 안에서 직접** 그립니다.
하이브리드 SDK 는 그 화면들을 **WebView 안의 웹(FE)** 이 그립니다.

그래서 이관 원칙이 이렇게 정리됩니다.

- **세션 · 식별 · 설정 계열** → 시그니처를 그대로 유지했습니다. 클래스명만 바꾸면 됩니다.
- **포인트 조회 · 아이템 구매 · 인출 등 RPC 계열** → **제공하지 않습니다.**
  해당 기능은 오퍼월 화면(FE) 안에서 처리되므로 개발사 코드에서 제거하시면 됩니다.

---

## 이관 체크리스트

- [ ] 의존성 좌표를 `com.tnkfactory:rwd:...` → `com.tnkfactory.ad:hrwd:1.0.6` 으로 교체
- [ ] import 경로를 `com.tnkfactory.ad.*` → `com.tnkfactory.ad.hrwd.*` 로 교체
- [ ] `TnkSession.*` 호출을 `TnkPpiHybSdk.*` 로 치환
- [ ] 매니페스트에서 `com.tnkfactory.ad.AdWallActivity` `<activity>` 선언 **제거**
- [ ] 포인트/RPC 호출부(`queryPoint`, `purchaseItem` 등) 제거
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

## 그대로 쓸 수 있는 것

| 네이티브 SDK | 하이브리드 SDK |
|---|---|
| `TnkSession.applicationStarted(ctx)` | `TnkPpiHybSdk.applicationStarted(ctx)` |
| `TnkSession.enableLogging(ctx, bool)` | `TnkPpiHybSdk.enableLogging(ctx, bool)` |
| `TnkSession.setAgreePrivacy(ctx, bool)` | `TnkPpiHybSdk.setAgreePrivacy(ctx, bool)` |
| `TnkSession.setUserAge(ctx, int)` | `TnkPpiHybSdk.setUserAge(ctx, int)` |
| `TnkSession.setUserGender(ctx, TnkCode.MALE)` | `TnkPpiHybSdk.setUserGender(ctx, TnkCode.MALE)` |
| `setCOPPA` / `setGdprConsent` | `TnkPpiHybSdk.setCOPPA(ctx, bool)` / `setGDPR(ctx, int)` |
| `new TnkOfferwall(ctx)` 인스턴스 패턴 | `TnkOfferwall(ctx)` — `setUserName` / `setCOPPA` / `startOfferwallActivity` |
| meta-data `tnkad_app_id` | 동일 |
| ProGuard `-keep class com.tnkfactory.** { *; }` | 유효 (SDK 규칙이 자동 적용되므로 없어도 됨) |
| 서버 보상 콜백 URL 계약 | 동일 |

---

## 코드에서 걷어낼 호출

아래 호출들은 하이브리드 SDK 에 없습니다. **컴파일 오류가 나는 지점을 찾는 용도**로 쓰세요.
기능 관점에서 무엇이 제공되고 무엇이 안 되는지는 [지원 범위](../common/support-matrix.md)를 보시면 됩니다.

| 네이티브 SDK | 대체 |
|---|---|
| `queryPoint` (동기/비동기) | 오퍼월(FE)이 잔액을 조회·표시 |
| `purchaseItem` / `withdrawPoints` | 오퍼월(FE) |
| `actionCompleted` / `buyCompleted` | 지급은 서버가 처리, 완료 통지는 `setRewardListener` |
| `queryPublishState` / `queryAdvertiseCount` | 오퍼월(FE) |
| `TnkOfferwall.getEarnPoint(...)` | 오퍼월(FE)이 계산·표시 |
| `TnkOfferwall.load()` + `getAdListView()` | XML 임베드 `TnkOfferwallView` |
| `TnkOfferwall.showAdDetailDialog(...)` | 오퍼월(FE) 상세 화면 |
| `TnkAdConfig.pointEffectType` | 오퍼월(FE) 표시 정책 |
| `ServiceCallback` / `TnkResultListener` / `TnkError` | 제거. 보상 완료는 `TnkRewardListener` |

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
```

### 신규

```kotlin
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
TnkPpiHybSdk.setCOPPA(applicationContext, false)
TnkPpiHybSdk.setRewardListener { reward ->
    refreshMyPointBalance()
}
button.setOnClickListener { TnkPpiHybSdk.openOfferwall(this) }
```

광고 ID 를 직접 조회하는 절차(`AdvertisingIdInfo.requestIdInfo`)가 사라졌습니다.
SDK 가 백그라운드에서 수집하고 오퍼월 진입 시 준비를 보장합니다.
