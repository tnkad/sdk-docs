---
description: 개인정보 수집 동의와 COPPA·GDPR 설정을 SDK 에 전달하는 방법입니다.
---

# 7. 개인정보 설정

모두 선택 사항입니다. 필요한 항목만 사용하세요.

---

## 개인정보 수집 동의

개발사 앱이 이미 자체 동의 절차를 거쳤다면, 그 결과를 SDK 에 알려 **오퍼월의 동의 팝업을 건너뛸 수 있습니다.**

> **사용 전제**: 개발사 앱이 자체 화면(가입 약관 등)에서 사용자에게 TNK 오퍼월 이용에 필요한 개인정보 수집 동의(오퍼월 동의 팝업과 같은 내용)를 직접 받은 경우에만 `setAgreePrivacy(context, true)` 를 호출하세요. 동의를 받지 않은 사용자에게는 호출하지 마세요. 직접 받지 않는 개발사는 이 설정을 생략하면 되며, 동의 전에는 오퍼월(특정 광고 진입 포함)에 들어갈 때 동의 팝업으로 받습니다.
> 이렇게 설정하면 오퍼월의 동의 팝업과 "동의 해제" 메뉴가 나오지 않으므로, 동의 내용 고지와 철회 수단 제공(예: `revokePrivacyConsent` 를 호출하는 개발사 앱 화면)은 개발사 앱이 맡습니다 — [동의 철회](#동의-철회)

```kotlin
TnkPpiHybSdk.setUserName(context, "개발사-사용자-식별값")   // 1) 사용자 식별값을 먼저
TnkPpiHybSdk.setAgreePrivacy(context, true)                // 2) 그 다음 동의 상태
```

현재 상태 조회

```kotlin
val agreed = TnkPpiHybSdk.isAgreePrivacy(context)   // Boolean
```

### 동작 요약

| 상황 | 동작 | 적용 버전 |
|---|---|---|
| `setAgreePrivacy(context, true)` 로 설정 | 오퍼월에 동의 팝업이 나오지 않고, "개인 정보 수집 동의 해제" 메뉴도 노출되지 않습니다. | 전체 |
| 그 외 (`true` 로 설정하지 않은 경우) | 동의 전에는 오퍼월 진입 시 동의 팝업으로 사용자 동의를 받고, 동의 후에는 "개인 정보 수집 동의 해제" 메뉴가 노출됩니다. 단, 이전 버전(레거시 SDK 포함)에서 저장된 동의의 해제 메뉴 노출은 Android 1.0.12 이상입니다. | 전체 |
| 오퍼월에서 사용자가 동의/거부 | SDK 에 저장되어 `isAgreePrivacy(context)` 에 반영됩니다. | SDK 1.0.11 이상 |
| 이전 버전 SDK(레거시 SDK 포함)에서 저장된 동의 | 동의로 유지되며, 해제 메뉴로 철회할 수 있습니다. | SDK 1.0.12 이상 |
| 오퍼월의 동의 판정 | SDK 에 저장된 동의 상태를 기준으로 합니다. 재설치·데이터 복원 후에도 SDK 기준입니다. | SDK 1.0.12 이상 |
| `setUserName` 으로 이전과 다른 사용자 지정 (최초 지정 포함) | 동의 상태가 초기화되어 `isAgreePrivacy(context)` 가 `false` 가 됩니다. | SDK 1.0.11 이상 |

### 호출 순서

사용자가 바뀌면 동의 상태가 초기화되므로, 항상 **`setUserName` → `setAgreePrivacy`** 순서로 호출하세요 (SDK 1.0.11 이상).
`setAgreePrivacy(context, true)` 를 먼저 호출한 뒤 `setUserName` 으로 다른 사용자를 지정하면 동의 상태가 지워집니다.
직접 동의를 받은 개발사는 앱을 시작할 때마다 이 순서로 호출하는 것을 권장합니다. 단, 사용자가 동의를 철회했다면 `true` 로 다시 설정하지 마세요 — [동의 철회](#동의-철회)

> 동의 상태의 기준은 `isAgreePrivacy(context)` 입니다. 오퍼월에서의 동의·거부 여부는 이 값을 읽어 확인하세요.

### 동의 철회

`setAgreePrivacy(context, true)` 로 설정한 앱에서는 오퍼월에 "개인 정보 수집 동의 해제" 메뉴가 나오지 않습니다.
사용자가 동의를 철회할 수 있는 수단은 **개발사 앱이 직접 제공**해야 하며, 사용자가 철회하면 `revokePrivacyConsent` 를 호출하세요 (SDK 1.0.14 이상).

```kotlin
// 앱의 "동의 철회" 버튼 처리 안에서
TnkPpiHybSdk.revokePrivacyConsent(context)
```

파라미터·반환값·화면은 없습니다. 호출하면 다음과 같이 동작합니다.

- 동의가 즉시 해제됩니다 (`isAgreePrivacy(context)` 가 `false`).
- 열려 있는 오퍼월은 첫 화면부터 다시 열리며 동의 팝업을 보여 줍니다. 보고 있던 위치 등 진행 상태는 초기화됩니다.
- 이후 오퍼월에 진입할 때도 동의 팝업부터 시작합니다.
- 현재 동의 상태는 `isAgreePrivacy(context)` 로 조회합니다. 철회가 끝나면 `false` 를 돌려줍니다.

**주의할 점**

- **사용자의 철회 동작에서만 호출하세요.** 반복하거나 자동으로 호출하면 안 됩니다. 앱 시작이나 화면 복귀(`onResume` 등)마다 부르면 오퍼월이 그때마다 첫 화면으로 돌아갑니다. 메인 스레드(버튼 처리 등)에서 호출하는 것을 권장합니다.
- **철회한 사용자에게 `setAgreePrivacy(context, true)` 를 다시 호출하면 철회가 취소됩니다.** 앱 시작 시마다 `true` 로 설정해 사전 동의를 알리는 방식이라면, 철회한 사용자는 제외하도록 앱에서 철회 여부를 직접 기억해 분기하세요.
- **SDK 가 만든 주소로 연 오퍼월에 즉시 반영됩니다.** `openOfferwall`, 특정 광고 진입(`adDetail` 등), 화면 안에 삽입한 `TnkOfferwallView.loadOfferwall()`, 그리고 `buildOfferwallUrl` 결과를 `TnkOfferwall.show` 등에 넘기는 기존 방식이 모두 해당합니다. 임의로 만든 주소로 연 화면은 대상이 아닙니다.
- 동의 상태는 서버에 저장하지 않고 이 기기에만 보관합니다. 다른 기기나 앱을 다시 설치한 뒤에는 이어진다고 보장되지 않으며, 보관 기간은 SDK 가 관리하지 않습니다.

`setAgreePrivacy(context, false)` 는 저장된 동의 값만 바꾸고, 열려 있는 오퍼월은 그대로 둡니다.
`revokePrivacyConsent` 가 없는 SDK 1.0.13 이하에서는 철회 시 `setAgreePrivacy(context, false)` 를 호출하세요.
다만 철회 후 오퍼월에서 동의 화면이 다시 나타나는 것까지 보장되지는 않습니다 (Android 1.0.12 이상에서는 다음 진입 시 다시 표시).

> 개발사 앱이 사용자에게 직접 동의를 받았다면 `true` 로 설정해 중복 노출을 없애는 편이 좋습니다.

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

다음: [8. 특정 광고 진입](ad-entry.md)
