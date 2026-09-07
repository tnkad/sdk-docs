---
description: 개인정보 수집 동의와 COPPA·GDPR 설정을 SDK 에 전달하는 방법입니다.
---

# 7. 개인정보 설정

모두 선택 사항입니다. 필요한 항목만 사용하세요.

---

## 개인정보 수집 동의

개발사 앱이 이미 자체 동의 절차를 거쳤다면, 그 결과를 SDK 에 알려 **오퍼월의 동의 화면을 건너뛸 수 있습니다.**

```kotlin
TnkPpiHybSdk.setAgreePrivacy(context, true)
```

현재 상태 조회

```kotlin
val agreed = TnkPpiHybSdk.isAgreePrivacy(context)   // Boolean
```

> 설정하지 않으면(기본값) 오퍼월 최초 진입 시 웹 화면에서 동의를 받습니다.
> 개발사가 이미 동의를 받았다면 `true` 로 설정해 중복 노출을 없애는 편이 좋습니다.

---

## COPPA (만 13세 미만)

```kotlin
TnkPpiHybSdk.setCOPPA(context, true)
```

만 13세 미만 사용자임을 표시합니다. 세션 정보로 서버에 전달되어 광고 노출 정책에 반영됩니다.

---

## GDPR

```kotlin
TnkPpiHybSdk.setGDPR(context, 1)   // 1 = GDPR 적용 대상
```

세션 정보의 `gdpr` 파라미터로 서버에 전달됩니다. 네이티브 SDK 의 `setGdprConsent` 에 대응합니다.

---

다음: [공개 API 목록](api.md)
