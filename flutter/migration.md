---
description: 기존 Flutter 플러그인 tnk_flutter_rwd 에서 하이브리드(V4) 플러그인 tnk_ppi_hyb 로 옮기는 방법. 의존성 교체, 앱 ID 지정, 한 앱에 함께 두기, 호출 변화, 플레이스먼트 키 대응, 기존 메서드 42개 전체 대조표를 안내합니다.
---

# 기존 플러그인에서 이관

이 페이지에서 하는 일: 기존 Flutter 플러그인 `tnk_flutter_rwd`(네이티브(V3) SDK 기반)를 쓰는 앱을 하이브리드(V4) 플러그인 `tnk_ppi_hyb` 로 옮깁니다. 바뀌는 점과 기존 메서드 전체의 대응을 보여 드립니다.

## 언제 필요한가

기존 `tnk_flutter_rwd` 플러그인을 이미 쓰고 있는 개발사에게만 필요합니다. 신규 연동이라면 이 페이지는 건너뛰고 [연동 가이드](README.md)부터 시작하세요.

`tnk_flutter_rwd` 와 `tnk_ppi_hyb` 는 **서로 다른 패키지**입니다. 한 앱에 함께 두는 구성은 Android 에서 실제 기기로 확인했고, iOS 는 확인되지 않았습니다(아래 '한 앱에 함께 두기'). 기존 플러그인의 새 버전으로 올리는 것이 아니라 다른 플러그인으로 바꾸는 작업입니다.

---

## 한눈에 보기

| 구분 | 내용 |
|---|---|
| **그대로** | 개발사 앱 ID(`tnkad_app_id`), 서버 보상 콜백 URL 과 그 구현, `setUserName`·`setCOPPA` 에 넘기는 값 |
| **바뀜** | 패키지(`tnk_flutter_rwd` → `tnk_ppi_hyb`)와 import, 호출 대상(`TnkFlutterRwd()` 인스턴스 → `TnkPpiHybSdk` 의 `static` 메서드), 앱 ID 를 넣는 방식, 응답 방식(JSON 문자열 → 반환값·예외), 오퍼월 열기(`showAdList` → `openOfferwall`), 보상·닫힘 알림(MethodChannel → `Stream`), 플레이스먼트(`getPlacementJsonData`·`onItemClick` → `TnkPlacementView`·`loadPlacementData`), 적립 가능 포인트(`getEarnPoint` → `getTotalPoint`), 개인정보 동의 호출 |
| **빠짐** | 포인트 잔액 조회·구매·인출, 오퍼월 디자인 설정, 화면 닫기 메서드, 이벤트 웹페이지 등 (아래 '하이브리드(V4)에 없는 기능') |

> ⚠️ **TNK 서버에 사용자 포인트 관리를 맡긴 앱**(`getQueryPoint`·`purchaseItem`·`withdrawPoints` 사용)은 이관 전에 담당자에게 문의해 주세요. 하이브리드(V4) 오퍼월에는 잔액 조회·구매·인출 화면이 없어 현재 제공하지 않습니다. 하이브리드(V4)에서는 [서버 보상 콜백](../common/server-callback.md)으로 받은 포인트를 개발사 서버에서 관리합니다.

### 이관 순서

- [ ] 1. `pubspec.yaml` 에 `tnk_ppi_hyb` 를 **추가**합니다(기존 플러그인은 아직 지우지 않아도 됩니다). Android 는 Maven 저장소를 필터 없이 선언하고 기존 Activity 선언은 그대로 둡니다(아래 '한 앱에 함께 두기'). iOS 는 함께 두는 구성이 확인되지 않았습니다
- [ ] 2. 앱 시작 시 `TnkPpiHybSdk.initialize(...)` 로 앱 ID 를 넣습니다 (아래 '앱 ID 지정 방식')
- [ ] 3. 기능별로 호출을 바꿉니다(예: 오퍼월 열기 `showAdList` → `openOfferwall`. `showAdListWithPlacement` 는 아래 대조표 38행) (아래 '메서드 대조표')
- [ ] 4. 플레이스먼트는 JSON 키가 모델 필드로 바뀌었는지 확인합니다 (아래 '플레이스먼트 키 대응')
- [ ] 5. 모두 옮겼으면 `tnk_flutter_rwd` 의존성과 필터 없는 Maven 선언을 정리하고, `content { includeGroup("com.tnkfactory.ad") }` 필터를 되돌립니다
- [ ] 6. 서버 보상 콜백은 그대로 동작하는지 실제 광고 참여로 확인합니다

---

## 한 앱에 함께 두기

두 플러그인을 한 앱에 함께 두는 구성은 **Android 에서 실제 기기로 확인**했습니다(기존 오퍼월은 기존 호출로, 새 오퍼월은 `openOfferwall` 로 열림). 출시 전에 실기기로 확인하세요. **iOS 는 함께 두는 구성이 확인되지 않았습니다.**

### Android

Android 에서는 아래 두 가지를 확인하세요.

**1) Maven 저장소를 필터 없이 선언합니다.** [1. 설치](install.md)의 `content { includeGroup("com.tnkfactory.ad") }` 필터를 **빼세요.** 필터가 기존 SDK(`com.tnkfactory:rwd`)와 그 의존 라이브러리(`groupie`)를 가려 빌드가 `Could not find com.tnkfactory:rwd` 로 실패합니다. 이 저장소는 `google()`·`mavenCentral()` 뒤에 선언하세요.

```kotlin
maven {
    url = uri("https://repository.tnkad.net:8443/repository/public/")
}
```

**2) 기존 Activity(`com.tnkfactory.ad.AdWallActivity`) 선언은 그대로 둡니다.** 기존 플러그인이 선언하므로 앱에서 할 일은 없습니다. 앱 매니페스트에서 `tools:node="remove"` 로 지우지 마세요. 지우면 기존 `showAdList`·`showAdListWithPlacement` 가 오퍼월 화면을 찾지 못해 실패합니다(기존 플러그인이 실패 메시지를 돌려주며, 앱이 종료되지는 않습니다).

> ⚠️ 함께 두는 동안 기존 플러그인의 `showAdList`·`showAdListWithPlacement` 는 기존 오퍼월을, 새 플러그인의 `openOfferwall` 은 하이브리드(V4) 오퍼월을 엽니다. 기존 오퍼월이 닫힐 때는 새 플러그인의 `offerwallClosed` 가 오지 않습니다.

### iOS

기존 플러그인은 `TnkRwdSdk2` 를, 새 플러그인은 `TnkPpiHyb` 를 각각 가져옵니다. 한 앱에 함께 두는 구성은 확인되지 않았으므로, 일부 화면을 기존 플러그인으로 유지해야 한다면 이관 전에 담당자에게 문의해 주세요. 기존 SDK 에서 받은 개인정보 동의는 하이브리드(V4) SDK 를 처음 쓸 때 한 번만 이어지며, 그 뒤의 변경은 서로 반영되지 않습니다. 앱 ID 지정 방식은 아래를 보세요.

---

## 의존성 교체

모두 옮긴 뒤에는 `pubspec.yaml` 에서 기존 플러그인을 지웁니다.

```diff
 dependencies:
-  tnk_flutter_rwd: ^0.8.14
+  tnk_ppi_hyb: ^1.0.0
```

```diff
-import 'package:tnk_flutter_rwd/tnk_flutter_rwd.dart';
+import 'package:tnk_ppi_hyb/tnk_ppi_hyb.dart';
```

| | 기존 `tnk_flutter_rwd` | 하이브리드(V4) `tnk_ppi_hyb` |
|---|---|---|
| 요구 버전 | Dart 2.18.5 이상, Flutter 2.5 이상 | Flutter 3.41 이상, Dart 3.11 이상 |
| 호출 방식 | `final _tnk = TnkFlutterRwd();` 인스턴스의 메서드 | `TnkPpiHybSdk.메서드()` — 모두 `static` |
| 응답 | 대부분 `Future<String?>`(`"success"`·`"fail"` 또는 JSON 문자열) | 반환값이 있는 호출은 그 값, 나머지는 `Future<void>`. 화면 열기·지면 불러오기 실패는 예외, 조회 실패는 `null` 또는 결과 값 |
| 플랫폼 SDK | Android `com.tnkfactory:rwd`, iOS `TnkRwdSdk2` | Android `com.tnkfactory.ad:hrwd`, iOS `TnkPpiHyb` — [설치](install.md) |

---

## 앱 ID 지정 방식

| | 기존 | 하이브리드(V4) |
|---|---|---|
| Android | `AndroidManifest.xml` 의 `<meta-data android:name="tnkad_app_id" .../>` | `initialize(androidAppId: ...)`, 또는 같은 매니페스트 선언 |
| iOS | `Info.plist` 의 `tnkad_app_id` | `initialize(iosAppId: ...)`, 또는 같은 `Info.plist` 선언 |

```dart
await TnkPpiHybSdk.initialize(
  androidAppId: '<Android 앱 ID>',
  iosAppId: '<iOS 앱 ID>',
);
```

- 하이브리드(V4)도 앱 ID 는 같은 이름의 매니페스트 메타데이터·`Info.plist` 값을 찾습니다. 기존 선언이 이미 있다면 `initialize()` 를 인자 없이 호출해도 됩니다. 실행 중인 플랫폼의 값이 `null` 이거나 빈 문자열이면 이 선언을 찾습니다.
- 코드로 넘기는 방식(`initialize`)이면 매니페스트·`Info.plist` 에 앱 ID 를 넣지 않아도 됩니다. 기존 플러그인이 아직 앱에 남아 있다면 기존 선언은 그 플러그인이 쓰므로 지우지 마세요.
- 앱 ID(`tnkad_app_id`)는 그대로 쓰는 값입니다.

---

## `MainActivity` 요구 차이

| | 기존 | 하이브리드(V4) |
|---|---|---|
| Android `MainActivity` | **`FlutterFragmentActivity` 필수.** `FlutterActivity` 이면 일부 화면이 실패 응답을 돌려줍니다 | 기본 `FlutterActivity` 그대로 둡니다. 앱 화면 안에 넣은 오퍼월(`TnkOfferwallView`)에서 파일 첨부를 쓸 때만 `FlutterFragmentActivity` 가 필요합니다 — [5. 화면 안에 오퍼월 넣기](embedded-offerwall.md) |
| Android 오퍼월 Activity | 기존 `AdWallActivity` 를 플러그인이 등록 | SDK 의 `TnkOfferwallActivity` 를 플러그인이 ActionBar 없는 테마로 등록 — [1. 설치](install.md) |

기존에 `FlutterFragmentActivity` 로 바꿔 두었다면 그대로 두어도 문제없습니다.

---

## 호출이 바뀌는 곳

### 오퍼월 열기

```diff
-final _tnk = TnkFlutterRwd();
-await _tnk.showATTPopup();                 // iOS
-await _tnk.setCOPPA(false);
-await _tnk.setUserName('<사용자 식별값>');
-await _tnk.showAdList('무료 충전소');
+await TnkPpiHybSdk.requestTrackingAuthorization(); // iOS (선택)
+await TnkPpiHybSdk.setCOPPA(false);
+await TnkPpiHybSdk.setUserName('<사용자 식별값>');
+await TnkPpiHybSdk.openOfferwall();
```

오퍼월 상단의 제목은 오퍼월 화면이 정하므로 제목을 넘기는 인자는 없습니다. `showAdList(title, appId)` 로 광고 번호를 함께 넘기던 코드는 `adAction`(또는 `adDetail`·`adJoin`)으로 바꿉니다.

### 응답 처리

기존 `presentAdDetailView`·`adJoin`·`adAction` 은 `{"res_code": ..., "res_message": ...}` 형태의 JSON 문자열을 돌려주었습니다. 하이브리드(V4)는 결과를 돌려주지 않습니다. `Future` 는 화면을 열도록 요청했을 때 끝나고, 화면을 띄울 곳이 없으면 `PlatformException`(Android `no_activity`, iOS `no_presenter`)이 발생합니다. `jsonDecode` 로 `res_code` 를 읽던 코드는 지우고 예외 처리로 바꾸세요 — [3. 전체 화면 오퍼월](offerwall.md)

### 오퍼월 이벤트와 닫힘

기존에는 `MethodChannel('tnk_flutter_rwd')` 의 `tnkAnalytics` 로 이벤트를 받고, `activity_finish` 로 닫힘을 알았습니다. 하이브리드(V4)는 용도별 `Stream` 입니다.

| 기존 | 하이브리드(V4) |
|---|---|
| `activity_finish` 이벤트(오퍼월 닫힘) | `TnkPpiHybSdk.offerwallClosed` |
| (보상은 서버 콜백으로만 알 수 있었음) | `TnkPpiHybSdk.rewards` — 화면 갱신용. 지급은 서버 콜백 |
| 그 밖의 `tnk_ev_*` 이벤트 | `TnkPpiHybSdk.events` — 고급 사용·디버깅 전용. 이름과 내용이 기존과 다르며 예고 없이 바뀔 수 있습니다 |

### 개인정보 동의

| 기존 | 하이브리드(V4) |
|---|---|
| `setNoUsePrivacyAlert()` — 동의 팝업 끄기 | `setAgreePrivacy(true)` — **앱에서 직접 동의를 받은(철회하지 않은) 사용자에게만, `setUserName` 다음에** 호출합니다. 팝업이 나오지 않습니다 |
| `setUserTermsAgree(agree)` | `setAgreePrivacy(agree)` — `true` 는 위와 같은 조건에서만. 사용자 철회 용도였다면 `revokePrivacyConsent()` |
| `isUserTermsAgree()` | `isAgreePrivacy()` |

> ⚠️ 기존 `setNoUsePrivacyAlert()` 는 앱 시작 때 모든 사용자에게 거는 설정이었을 수 있습니다. 앱 시작 때 모든 사용자에게 `setNoUsePrivacyAlert()` 를 호출했다면 같은 자리에 `setAgreePrivacy(true)` 를 넣지 마세요. 동의하지 않은 사용자까지 '동의함' 으로 기록됩니다. 앱에서 동의를 받고 철회하지 않은 사용자에게만 `setUserName` 다음에 호출하세요. 철회한 사용자에게 `true` 를 다시 호출하면 철회가 취소됩니다.

[2. 초기화](initialize.md)의 '개인정보 동의'를 보세요.

---

## 플레이스먼트 키 대응

`getPlacementJsonData` 가 돌려주던 JSON 키는 `TnkPlacementData` 의 모델 필드로 바뀌었습니다. 옛 JSON 키 이름의 별칭은 없습니다. 아래 표로 바꾸세요.

| 기존 | 하이브리드(V4) |
|---|---|
| `getPlacementJsonData(id)` | `TnkPpiHybSdk.loadPlacementData(id)` (JSON 이 아닌 `adList` 와 `pubInfo` 모델) |
| `onItemClick(appId)` (`String` → `int`) | `data.clickItem(appId)` (`TnkPlacementClickResult`(`success`, `code`) 를 돌려줌) |
| `app_id` / `app_nm` / `img_url` | `appId` / `appName` / `imageUrl` (그리고 새로 `iconUrl`) |
| `pnt_amt` / `org_amt` / `pnt_unit` | `point` / `originalPoint` / `pointUnit` (그리고 새로 `pointText`) |
| `prd_price` / `org_prd_price` / `sale_dc_rate` | `price` / `originalPrice` / `discountRate` |
| `multi_yn` / `cmpn_type` / `cmpn_type_name` / `like_yn` | `isMultiMission` / `campaignType` / `campaignTypeName` / `likeYn` |
| (없음) | 새로: `actionId`, `filterId`, `isLink`, `actionDesc` |
| `PlacementPubInfo` | `TnkPlacementPubInfo` (`placementId`, `adType`, `title`, `moreLabel`, `customData`, `pointUnit`, `layoutKey`. 기존의 `ctype_surl` 은 없습니다) |

- 기존 `tnk_placement_model.dart` 의 `praserJsonToTnkPlacementAdItem()` 은 필요 없습니다. 모델이 이미 타입을 가집니다.
- 하이브리드(V4)에는 SDK 가 지면을 그려 주는 `TnkPlacementView` 위젯이 새로 있습니다 — [4. 플레이스먼트](placement.md)
- 같은 앱에 등록된 지면 ID 는 그대로 씁니다. 오래 전에 만든 지면이 보이지 않으면 담당자에게 확인해 주세요.

---

## 메서드 대조표

기존 `tnk_flutter_rwd` 의 `TnkFlutterRwd` 클래스가 가진 **공개 메서드 42개 전체**입니다. 새 API 가 있으면 그것을, 없으면 '현재 지원하지 않음' 으로 적었습니다. 두 번째 열의 메서드는 모두 `TnkPpiHybSdk` 의 `static` 입니다.

| # | 기존 `TnkFlutterRwd` | 하이브리드(V4) `TnkPpiHybSdk` | 비고 |
|--:|---|---|---|
| 1 | `getPlatformVersion()` | 현재 지원하지 않음 | 기존에는 기기 OS 버전 문자열을 돌려주었습니다. `sdkVersion` 은 OS 가 아닌 SDK 버전이라 대체 API 가 아닙니다 |
| 2 | `setCategoryAndFilter(category, filter)` | 현재 지원하지 않음 | 시작 탭·필터는 딥링크로 지정합니다: `handleScheme('tnkscheme://select_menu?cat_id=…&filter_id=…')` |
| 3 | `openEventWebView(eventId)` | 현재 지원하지 않음 | Android 전용이었음 |
| 4 | `showCustomTapActivity(url, deep_link)` | 현재 지원하지 않음 | 기존에도 두 플랫폼 모두 비활성(`"fail"`) |
| 5 | `showAdList(title, [appId])` | `openOfferwall()` | 제목 인자 없음. `appId` 를 넘기던 호출은 `adAction` 으로 |
| 6 | `setUserName(userName)` | `setUserName(userName)` | 이름 그대로 |
| 7 | `setCOPPA(coppa)` | `setCOPPA(enabled)` | 이름 그대로 |
| 8 | `applicationStarted()` | `applicationStarted()` | 선택 사항 |
| 9 | `showATTPopup()` | `requestTrackingAuthorization()` | iOS 전용. 결과를 `bool?` 로 돌려줍니다(Android 는 `null`) |
| 10 | `getEarnPoint()` | `getTotalPoint()` | `TotalPointInfo?` 를 돌려주고, 포인트는 `pointAmount`. 개인정보 동의 전에는 조회하지 않고 `retCode` `-3`(`TotalPointInfo.retCodePrivacyNotAgreed`)을 돌려주므로, 기존 코드를 옮긴 앱은 동의 전에는 포인트 문구가 보이지 않을 수 있습니다 |
| 11 | `setNoUsePointIcon()` | 현재 지원하지 않음 | 오퍼월 디자인 설정 |
| 12 | `setNoUsePrivacyAlert()` | `setAgreePrivacy(true)` | 앱에서 직접 동의를 받은(철회하지 않은) 사용자에게만, `setUserName` 다음에. 위 '개인정보 동의' 경고 참고 |
| 13 | `getQueryPoint()` | 현재 지원하지 않음 | 잔액은 서버 보상 콜백으로 개발사 서버가 관리 |
| 14 | `purchaseItem(itemId, cost)` | 현재 지원하지 않음 | 포인트 차감 |
| 15 | `withdrawPoints(description)` | 현재 지원하지 않음 | 포인트 인출 |
| 16 | `setCustomUI(colorMap)` | 현재 지원하지 않음 | iOS 전용이었음. 오퍼월 디자인 설정 |
| 17 | `getOfferWallEvent(methodCall)` | `rewards` · `offerwallClosed` · `events` | 메서드 대신 `Stream`. 위 '오퍼월 이벤트와 닫힘' |
| 18 | `getPlacementJsonData(placementId)` | `loadPlacementData(placementId)` | JSON 대신 모델 |
| 19 | `onItemClick(app_id)` | `TnkPlacementData.clickItem(appId)` | `TnkPlacementClickResult`(`success`, `code`) 를 돌려줍니다. `appId` 는 `int` |
| 20 | `setUseTermsPopup(isUse)` | `setAgreePrivacy(true)` | `setUseTermsPopup(false)` 는 12번 `setNoUsePrivacyAlert()` 와 같은 동작입니다. 12번과 같은 조건(앱에서 직접 동의를 받은 사용자에게만)에서만 바꾸세요. 팝업을 켜고 끄는 설정 자체는 없습니다 |
| 21 | `setUserTermsAgree(agree)` | `setAgreePrivacy(agree)` | `true` 는 12번과 같은 조건에서만. 사용자 철회 용도였다면 철회 버튼에서 `revokePrivacyConsent()` |
| 22 | `isUserTermsAgree()` | `isAgreePrivacy()` | |
| 23 | `setPrivacyAgreementListener({onAgreed, onRevoked})` | 현재 지원하지 않음 | 동의 상태는 `isAgreePrivacy()` 로 조회, 철회는 `revokePrivacyConsent()` |
| 24 | `setCustomUnitIcon(map)` | 현재 지원하지 않음 | 오퍼월 디자인 설정 |
| 25 | `closeAllView()` | 현재 지원하지 않음 | iOS 전용이었음. 닫힘 알림은 `offerwallClosed` |
| 26 | `closeOfferwall()` | 현재 지원하지 않음 | iOS 전용이었음. 사용자가 오퍼월의 닫기(X)로 닫습니다 |
| 27 | `closeAdDetail()` | 현재 지원하지 않음 | iOS 전용이었음 |
| 28 | `setCustomUIDefault(map)` | 현재 지원하지 않음 | iOS 전용이었음. 오퍼월 디자인 설정 |
| 29 | `presentAdDetailView(appId, [actionId])` | `adDetail(appId, {actionId})` | `actionId` 는 이름 있는 인자 |
| 30 | `adJoin(appId, [actionId, useTopViewController, fullscreen])` | `adJoin(appId, {actionId})` | iOS 전용이던 `useTopViewController`·`fullscreen` 은 현재 지원하지 않음 |
| 31 | `adAction(appId, [actionId])` | `adAction(appId, {actionId})` | |
| 32 | `setPubCustomUi([type])` | 현재 지원하지 않음 | iOS 전용이었음 |
| 33 | `showEventWebPage(map)` | 현재 지원하지 않음 | 이벤트 웹페이지 |
| 34 | `showMyEarnPointList(map)` | 현재 지원하지 않음 | 적립 내역은 오퍼월 화면의 '문의/내역' 메뉴에서 봅니다 |
| 35 | `nativeTnkEventScheme(url)` | `handleScheme(url)` | `bool` 을 돌려줍니다 |
| 36 | `openTnkEventScheme(url)` | `handleScheme(url)` | 기존은 `tnkscheme://offerwall` 만 처리했습니다. 하이브리드(V4)의 링크 종류는 [Android 6. 딥링크](../android/deeplink.md) |
| 37 | `openTnkEventScheme2(url)` | `handleScheme(url)` | `analytics` 링크를 앱 채널로 전달하는 동작은 현재 지원하지 않음 |
| 38 | `showAdListWithPlacement(placementId, categoryId, filterId)` | 현재 지원하지 않음 | Android 전용이었음. 시작 탭·필터는 2번 행의 딥링크 |
| 39 | `setOfferwallTheme(theme)` | `openOfferwall(extraParams: {'theme': 'dark'})` | 앱 시작 때 한 번 지정하던 전역 설정이 아니라 `openOfferwall` 을 열 때마다 넘깁니다. `light`·`dark`(소문자)만 지원하고, 넣지 않으면 기기 설정을 따릅니다(기존 `system`·`unspecified` 에 해당). `adDetail`·`adJoin`·`adAction` 에는 테마를 지정할 수 없습니다 |
| 40 | `getOfferwallTheme()` | 현재 지원하지 않음 | |
| 41 | `setOfferwallOpaqueNavigationBar(opaque, {color})` | 현재 지원하지 않음 | iOS 전용이었음 |
| 42 | `normalizeOfferwallTheme(theme)` (`static`) | 현재 지원하지 않음 | 기존 플러그인의 보조 함수. `theme` 값은 소문자 `light`·`dark` 를 그대로 넘깁니다 |

> 기존 플러그인에는 이 클래스 밖에 `TnkSchemeHandler`(웹 화면의 `tnkscheme://` 링크를 명령으로 연결하는 보조 클래스)도 있었습니다. 하이브리드(V4)에는 대응하는 클래스가 없습니다. 링크는 `handleScheme` 에 그대로 넘기세요.

---

## 하이브리드(V4)에 없는 기능

아래 기능은 현재 하이브리드(V4) SDK·플러그인에서 지원하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요.

| 기능 | 기존 메서드 | 안내 |
|---|---|---|
| 포인트 잔액 조회 · 구매 · 인출 | `getQueryPoint` · `purchaseItem` · `withdrawPoints` | 사용자 포인트는 [서버 보상 콜백](../common/server-callback.md)으로 받은 값을 개발사 서버에서 직접 관리합니다 |
| 오퍼월 UI 커스터마이징 | `setNoUsePointIcon` · `setCustomUnitIcon` · `setCustomUI` · `setCustomUIDefault` · `setPubCustomUi` · `setOfferwallOpaqueNavigationBar` | 앱 코드로 오퍼월 디자인을 바꾸는 설정은 없습니다. 오퍼월 화면 변경은 TnkFactory 가 적용합니다 |
| 화면 닫기 | `closeOfferwall` · `closeAdDetail` · `closeAllView` | 닫힘은 알 수 있습니다(`offerwallClosed`). 코드로 닫을 수는 없습니다 |
| 이벤트 웹페이지 · 적립 내역 화면 | `showEventWebPage` · `openEventWebView` · `showMyEarnPointList` | 적립 내역은 오퍼월 화면의 '문의/내역' 메뉴에서 볼 수 있습니다 |
| 시작 탭·필터 지정, 지면 설정으로 오퍼월 열기 | `setCategoryAndFilter` · `showAdListWithPlacement` | 딥링크 `handleScheme` 로 탭·필터를 지정합니다 |
| 개인정보 동의 상태 변화 알림 | `setPrivacyAgreementListener` | `isAgreePrivacy()` 로 조회합니다 |
| 약관 팝업 표시 설정 | `setUseTermsPopup` | 팝업을 켜고 끄는 설정은 없습니다. 앱에서 직접 동의를 받은 사용자에게만 `setAgreePrivacy(true)` 를 호출하면 동의 팝업이 나오지 않습니다 |

전체 기능 목록과 플랫폼별 차이는 [지원 범위](../common/support-matrix.md)에 있습니다.

다음: [연동 가이드로 돌아가기](README.md)
