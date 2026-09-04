---
description: 개인정보 수집 동의, COPPA·GDPR 설정, 연령·성별 등 사용자 속성을 SDK 에 전달하는 방법입니다.
---

# 7. 개인정보 · 사용자 속성

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

## 연령 · 성별

개발사가 알고 있는 사용자 정보를 SDK 에 전달해 둘 수 있습니다.

```kotlin
TnkPpiHybSdk.setUserAge(context, 23)

TnkPpiHybSdk.setUserGender(context, TnkCode.MALE)     // 남성
TnkPpiHybSdk.setUserGender(context, TnkCode.FEMALE)   // 여성
```

문자열 형태도 지원합니다.

```kotlin
TnkPpiHybSdk.setUserGender(context, "M")
TnkPpiHybSdk.setUserGender(context, "F")
```

| 상수 | 값 |
|------|-----|
| `TnkCode.MALE` | `1` |
| `TnkCode.FEMALE` | `2` |

> 연령과 성별 값은 현재 **SDK 에 저장만 되고 서버로 전송되지 않습니다.**
> 광고 매칭에 반영이 필요하시면 TnkFactory 담당자에게 문의해 주세요.

---

다음: [공개 API 목록](api.md)
