---
description: 개인정보 수집 동의와 COPPA·GDPR 설정을 TnkPpiHyb SDK 에 전달하는 방법입니다.
---

# 7. 개인정보 설정

모두 선택 사항입니다. 필요한 항목만 사용하세요.

```swift
let sdk = TnkPpiHybSdk.shared
```

---

## 개인정보 수집 동의

개발사 앱이 이미 자체 동의 절차를 거쳤다면, 그 결과를 SDK 에 알려 **오퍼월의 동의 팝업을 건너뛸 수 있습니다.**

```swift
sdk.setUserName("개발사-사용자-식별값")   // 1) 사용자 식별값을 먼저
sdk.setAgreePrivacy(true)                // 2) 그 다음 동의 상태
sdk.isAgreePrivacy()                     // Bool
```

### 동작 요약

| 상황 | 동작 | 적용 버전 |
|---|---|---|
| `setAgreePrivacy(true)` 로 설정 | 오퍼월에 동의 팝업이 나오지 않고, "개인 정보 수집 동의 해제" 메뉴도 노출되지 않습니다. | 전체 |
| 그 외 (`true` 로 설정하지 않은 경우) | 동의 전에는 오퍼월 진입 시 동의 팝업으로 사용자 동의를 받고, 동의 후에는 "개인 정보 수집 동의 해제" 메뉴가 노출됩니다. | 전체 |
| 오퍼월에서 사용자가 동의/거부 | SDK 에 저장되어 `isAgreePrivacy()` 에 반영됩니다. | SDK 1.0.2 이상 |
| 이전 버전 SDK 에서 저장된 동의 | 동의로 유지되며, 해제 메뉴로 철회할 수 있습니다. | SDK 1.0.3 이상 |
| 오퍼월의 동의 판정 | SDK 에 저장된 동의 상태를 기준으로 합니다. 재설치·데이터 복원 후에도 SDK 기준입니다. | SDK 1.0.3 이상 |
| `setUserName` 으로 이전과 다른 사용자 지정 (최초 지정 포함) | 동의 상태가 초기화되어 `isAgreePrivacy()` 가 `false` 가 됩니다. | SDK 1.0.2 이상 |

### 호출 순서

사용자가 바뀌면 동의 상태가 초기화되므로, 항상 **`setUserName` → `setAgreePrivacy`** 순서로 호출하세요 (SDK 1.0.2 이상).
`setAgreePrivacy(true)` 를 먼저 호출한 뒤 `setUserName` 으로 다른 사용자를 지정하면 동의 상태가 지워집니다.
앱을 시작할 때마다 이 순서로 호출하는 것을 권장합니다.

> 동의 상태의 기준은 `isAgreePrivacy()` 입니다. 오퍼월에서의 동의·거부 여부는 이 값을 읽어 확인하세요.

### 동의 철회

`setAgreePrivacy(true)` 로 설정한 앱에서는 오퍼월에 "개인 정보 수집 동의 해제" 메뉴가 나오지 않습니다.
사용자가 동의를 철회할 수 있는 수단은 **매체 앱이 직접 제공**해야 하며, 철회 시 `setAgreePrivacy(false)` 를 호출하세요.
다만 철회 후 오퍼월에서 동의 화면이 다시 나타나는 것까지 보장되지는 않습니다.

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

다음: [8. 특정 광고 진입](ad-entry.md)
