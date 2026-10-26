---
description: 하이브리드 오퍼월 SDK 가 Android · iOS 에서 제공하는 기능, 현재 제공하지 않는 기능, 플랫폼별 차이를 정리한 표입니다.
---

# 지원 범위

하이브리드 오퍼월 SDK 의 **제공 기능**, **현재 제공하지 않는 기능**, **플랫폼별 차이**를 한눈에 확인하는 페이지입니다.
연동 범위를 정할 때, 그리고 기존 네이티브 SDK 에서 옮기기 전에 빠지는 기능이 없는지 볼 때 먼저 확인하세요.

---

## 제공하는 기능

| 기능 | Android | iOS | 비고 |
|------|:-------:|:---:|------|
| 전체 화면 오퍼월 | ✅ | ✅ | `openOfferwall` |
| 화면 안에 오퍼월 삽입 | ✅ | ✅ | `TnkOfferwallView` |
| 특정 광고 바로 진입 | ✅ (1.0.10 이상) | ✅ (1.0.0 이상) | `adDetail` / `adJoin` / `adAction` — Android 는 기존 네이티브 SDK 와 같은 이름, iOS 는 네이티브 `presentAdDetailView` 가 `adDetail` 로 바뀌었습니다(자세한 내용은 [Android 이관](../android/migration.md) · [iOS 이관](../ios/migration.md)) |
| 오퍼월 화면 옵션 | ✅ | ✅ | `hideHeader` · `hideBack` · `theme` — 화면 구성에 따라 적용되지 않는 옵션이 있을 수 있습니다 |
| 적립 가능 포인트 조회 | ✅ (1.0.10 이상) | ✅ (1.0.1 이상) | `getAdvertiseTotalPoint` / `getProductTotalPoint` |
| 딥링크 (`tnkscheme://`) | ✅ | ✅ | `handleScheme` |
| 보상 지급 완료 알림 | ✅ | ✅ | `setRewardListener` — 화면 갱신용 |
| 범용 이벤트 수신 | ✅ | ✅ | `setEventListener` |
| 서버 보상 콜백 | ✅ | ✅ | 개발사 백엔드. **실제 지급 경로** |
| 개발사 사용자 식별값 | ✅ | ✅ | `setUserName` |
| 개인정보 수집 동의 | ✅ | ✅ | `setAgreePrivacy` · `isAgreePrivacy` — `setAgreePrivacy(true)` 로 사전 동의를 알리면 오퍼월에 동의 팝업이 나오지 않습니다. 동의 상태는 기기에만 저장됩니다 |
| 개인정보 동의 철회 | ✅ (1.0.14 이상) | ✅ (1.0.5 이상) | `revokePrivacyConsent` — 호출하면 열려 있는 오퍼월이 첫 화면부터 다시 열려 동의 팝업이 나옵니다 |
| COPPA · GDPR | ✅ | ✅ | `setCOPPA` · `setGDPR` — 오퍼월을 열 때 TNK 서버로 전달됩니다 |
| 광고 식별자 수집 | ✅ | ✅ | Android 광고 ID(ADID) / iOS IDFA |
| ATT 동의 요청 | — | ✅ | iOS 전용 `requestTrackingAuthorization` |

> 네이티브 오퍼월 SDK 에서 옮겨오시는 경우, 어떤 호출을 그대로 쓸 수 있고 무엇을 걷어내야 하는지는
> [Android 이관](../android/migration.md) · [iOS 이관](../ios/migration.md)에 정리되어 있습니다.

---

## 현재 제공하지 않는 기능

아래 기능은 현재 하이브리드 SDK 에서 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요.

| 기능 | 안내 |
|------|------|
| 플레이스먼트 뷰 (네이티브 SDK 의 `AdPlacementView`) | 특정 광고·카테고리만 앱 화면 일부에 노출하는 플레이스먼트 뷰는 추후 제공될 예정입니다. 기존 네이티브 SDK 의 `AdPlacementView` 를 사용 중이시면 담당자에게 알려 주세요 |
| 광고 목록·상세 데이터 | 광고 목록과 상세는 오퍼월 화면이 직접 보여 주며, 앱으로 데이터를 넘기지 않습니다. 적립 가능 포인트 합계만 조회할 수 있습니다 — [Android](../android/total-point.md) · [iOS](../ios/total-point.md) |
| 포인트 잔액 조회 · 아이템 구매 · 인출 | 현재 하이브리드 SDK 에서는 제공하지 않습니다. 사용자 포인트는 [서버 보상 콜백](server-callback.md)으로 받은 값을 개발사 서버에서 직접 관리합니다. 사용자의 적립 내역은 오퍼월 화면의 '문의/내역' 메뉴에서 볼 수 있습니다 |
| 화면 디자인 커스터마이징 (`TnkAdConfig` · `TnkStyle` 등) | 앱 코드로 오퍼월 디자인을 바꾸는 설정은 현재 하이브리드 SDK 에서는 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요 |
| 뉴스·피드 삽입 (Android 네이티브 SDK 의 `loadWithNewsData` · `getEmbedAdList` · `getEmbedNewsList` · `getFeedPopup`) | 현재 하이브리드 SDK 에서는 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요 |
| 이벤트·Plus 계열, 커스텀 탭 화면 (iOS 네이티브 SDK 의 `plusInstance` · `showCustomTapViewController` 등) | 현재 하이브리드 SDK 에서는 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요 |
| 그 밖에 네이티브 SDK 에만 있던 부가 기능 | 이관 문서의 대조표에서 '현재 미제공(문의)' 로 표시된 항목입니다. 현재 하이브리드 SDK 에서는 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요 — [Android 이관](../android/migration.md) · [iOS 이관](../ios/migration.md) |

지원 기능은 순차적으로 확대하고 있습니다.

---

## 플랫폼별 차이

두 플랫폼을 함께 연동한다면 아래 차이를 먼저 확인하세요.

| 항목 | Android | iOS |
|------|---------|-----|
| 에뮬레이터 · 시뮬레이터 | Android 에뮬레이터·가상 기기에서는 오퍼월이 열리지 않습니다. 동작 확인은 실기기에서 해 주세요 — [문제 해결](../android/troubleshooting.md) | 시뮬레이터에서도 오퍼월 화면을 확인할 수 있습니다. 광고 참여·적립 확인은 실기기를 권장합니다 — [문제 해결](../ios/troubleshooting.md) |
| 오퍼월 열기 | `openOfferwall(context)` | `openOfferwall(from: presenter)` — 오퍼월을 띄울 화면(ViewController)을 넘깁니다 |
| 딥링크 `handleScheme` | `handleScheme(context, intent)` | `handleScheme(url, from: presenter)` — 앱이 딥링크로 막 실행되는 시점에는 `from:` 으로 오퍼월을 띄울 화면을 직접 넘기세요 — [iOS 딥링크](../ios/deeplink.md) |
| 광고 식별자 동의 | 별도 동의 요청은 없습니다. 기기에서 광고 ID 를 삭제하거나 추적을 제한한 사용자는 광고 ID 가 필요한 광고에 참여할 수 없습니다 | ATT 동의를 요청해야 합니다. 동의를 받지 못해도 오퍼월은 열리지만 참여할 수 있는 광고가 줄어들 수 있습니다 — [iOS 초기화](../ios/initialize.md)의 'ATT 동의 요청' |
| `setCOPPA` | `Boolean` (`true`: 적용) | `Int` (`1`: 적용, `0`: 해당 없음) |
| `setGDPR` 를 호출하지 않았을 때 | `-1`(지정하지 않음)로 전달됩니다 | `0` 으로 전달됩니다. GDPR 대상 사용자가 있는 앱은 두 플랫폼 모두에서 값을 직접 지정하세요 — [Android](../android/privacy.md) · [iOS](../ios/privacy.md) |
| `getAppId` | 호출하면 SDK 초기화가 진행됩니다 | 초기화하지 않습니다. SDK 호출 전에는 `nil` 일 수 있습니다 |
| 삽입형 `loadOfferwall` | 주소 없이 `loadOfferwall()` 만 호출해도 오퍼월을 불러옵니다 | 주소를 넘겨야 합니다. `loadOfferwall(buildOfferwallURL())` 처럼 호출하세요. `nil` 을 넘기면 오퍼월이 열리지 않고 다른 화면이 표시됩니다 |
| 삽입형 `onCloseRequested` 미등록 | 닫기를 누르면 오퍼월을 담은 화면(Activity)이 종료됩니다 | 닫기를 눌러도 아무 일도 일어나지 않습니다 (전체 화면은 SDK 가 닫습니다) |
| 삽입형 뷰 정리 | 화면 수명에 맞춰 자동으로 정리됩니다 | `cleanup()` 을 화면이 사라질 때(`deinit`) 한 번 호출합니다 |

시그니처 차이는 [Android 공개 API 목록](../android/api.md)의 'iOS 와 다른 점', [iOS 공개 API 목록](../ios/api.md)의 'Android 와 다른 점' 절을 참고하세요.

---

## 오퍼월 화면은 SDK 업데이트 없이 바뀝니다

광고 목록 레이아웃 개선이나 개발사별 테마 적용 같은 오퍼월 화면의 변경은 **SDK 버전을 올리지 않아도** 반영됩니다. 오퍼월 화면은 Android·iOS 가 같아서 화면과 보상 로직도 같습니다.

다만 새 API 가 추가되거나, 상태 바·내비게이션 바·설정 화면 이동처럼 앱 쪽에서 처리하는 동작이 개선된 경우에는 SDK 를 올려야 적용됩니다. 자세한 내용은 [Android](../android/changelog.md) · [iOS](../ios/changelog.md) 릴리스 노트를 확인하세요.
