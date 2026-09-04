---
description: 개인정보 수집 동의, COPPA·GDPR 설정, 연령·성별 등 사용자 속성을 TnkPpiHyb SDK 에 전달하는 방법입니다.
---

# 7. 개인정보 · 사용자 속성

모두 선택 사항입니다. 필요한 항목만 사용하세요.

```swift
let sdk = TnkPpiHybSdk.shared
```

---

## 개인정보 수집 동의

개발사 앱이 이미 자체 동의 절차를 거쳤다면, 그 결과를 SDK 에 알려 **오퍼월의 동의 화면을 건너뛸 수 있습니다.**

```swift
sdk.setAgreePrivacy(true)
sdk.isAgreePrivacy()      // Bool
```

> 설정하지 않으면(기본값) 오퍼월 최초 진입 시 웹 화면에서 동의를 받습니다.
> 개발사가 이미 동의를 받았다면 `true` 로 설정해 중복 노출을 없애는 편이 좋습니다.

> ATT 동의(`requestTrackingAuthorization`)와는 별개입니다.
> ATT 는 IDFA 사용에 대한 애플의 동의 절차이고, 이쪽은 오퍼월 서비스 이용 동의입니다.

---

## COPPA (만 13세 미만)

```swift
sdk.setCOPPA(1)   // 1 = 만 13세 미만
```

> Android 는 `Bool` 을 받지만 **iOS 는 `Int`** 입니다. 크로스 플랫폼으로 코드를 옮기실 때 주의하세요.

---

## GDPR

```swift
sdk.setGDPR(1)    // 1 = GDPR 적용 대상
```

---

## 연령 · 성별

```swift
sdk.setUserAge(25)
sdk.setUserGender(TnkCode.MALE)     // 남성
sdk.setUserGender(TnkCode.FEMALE)   // 여성
```

| 상수 | 값 |
|------|-----|
| `TnkCode.MALE` | `1` |
| `TnkCode.FEMALE` | `2` |

> 연령과 성별 값은 현재 **SDK 에 저장만 되고 서버로 전송되지 않습니다.**
> 광고 매칭에 반영이 필요하시면 TnkFactory 담당자에게 문의해 주세요.

---

다음: [공개 API 목록](api.md)
