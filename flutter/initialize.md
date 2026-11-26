---
description: Flutter 앱이 시작될 때 호출하는 초기화 코드와 순서를 안내합니다. initialize 로 앱 ID 지정, setUserName, 개인정보 동의(setAgreePrivacy), COPPA·GDPR, iOS 추적 동의 요청, 로그 설정을 설명합니다.
---

# 2. 초기화

이 페이지에서 하는 일: 앱이 시작될 때 SDK 에 앱 ID 와 사용자 식별값을 알려 주고, 오퍼월을 열 준비를 마칩니다. 개인정보 동의·COPPA·GDPR 처럼 해당하는 앱만 호출하는 항목도 여기서 설명합니다.

## 언제 필요한가

모든 개발사에게 필요합니다. `initialize` 와 사용자 식별값 설정(`setUserName`)은 **필수**이고, 나머지는 해당하는 경우에만 호출하는 선택 항목입니다.

---

## 앱 시작 시 한 번

아래 순서대로 호출합니다. 주석 처리된 줄은 해당하는 경우에만 풀어서 사용하세요.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tnk_ppi_hyb/tnk_ppi_hyb.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // runApp 전에 호출할 때 필요

  // 1) 앱 ID — 반드시 다른 SDK 호출보다 먼저
  await TnkPpiHybSdk.initialize(
    androidAppId: '<Android 앱 ID>',
    iosAppId: '<iOS 앱 ID>',
  );

  // 2) 로그 — 연동 확인용입니다. 출시 빌드에서는 꺼 둡니다.
  await TnkPpiHybSdk.enableLogging(kDebugMode);

  runApp(const MyApp());
}

// 로그인 직후처럼 사용자를 알 수 있는 시점에 호출합니다 (async 함수 안)
Future<void> onUserKnown() async {
  // 3) 사용자 식별값 (필수) — 사용자를 알 수 있는 시점에
  await TnkPpiHybSdk.setUserName('<사용자 식별값>');

  // 4) 앱에서 사용자에게 직접 개인정보 수집 동의를 받고 철회하지 않은 경우에만 — 반드시 setUserName 다음에
  // await TnkPpiHybSdk.setAgreePrivacy(true);

  // 5) 만 13세 미만 사용자가 있는 앱만 (true: 해당, false: 해당 없음)
  // await TnkPpiHybSdk.setCOPPA(isUnder13);

  // 6) iOS 에서 앱 추적 동의(ATT)를 요청하는 앱만 — 오퍼월을 열기 전에
  // await TnkPpiHybSdk.requestTrackingAuthorization();
}
```

| 순서 | 호출 | 필수 | 설명 |
|---|---|:-:|---|
| 1 | `initialize(androidAppId:, iosAppId:)` | ✅ | 실행 중인 플랫폼에 해당하는 앱 ID 를 SDK 에 알립니다. Android·iOS 앱 ID 를 둘 다 넘겨도 됩니다 |
| 2 | `enableLogging(bool)` | | SDK 로그를 켜고 끕니다(기본 꺼짐). 로그에 광고 ID 와 오퍼월 주소가 찍히므로 **디버그 빌드에서만** 켭니다(`kDebugMode`) |
| 3 | `setUserName(String)` | ✅ | 개발사의 사용자 식별값. 보상을 받을 사용자를 구분하는 값이며 [서버 보상 콜백](../common/server-callback.md)으로 전달됩니다 |
| 4 | `setAgreePrivacy(bool)` | | 앱이 개인정보 수집 동의를 직접 받았고 철회하지 않은 사용자에게만 `setUserName` 다음에 알립니다. 아래 '개인정보 동의' 참고 |
| 5 | `setCOPPA(bool)` | | 아동(만 13세 미만) 사용자 여부 |
| 6 | `requestTrackingAuthorization()` | | iOS 앱 추적 동의 팝업. 아래 'iOS 앱 추적 동의' 참고 |

### 앱 ID 지정

- `initialize` 는 실행 중인 플랫폼에 해당하는 값만 사용합니다. Android 에서는 `androidAppId`, iOS 에서는 `iosAppId` 입니다.
- 그 값이 `null` 이거나 빈 문자열이면 SDK 가 자체 설정을 찾습니다. Android 는 `AndroidManifest.xml` 의 `tnkad_app_id` 메타데이터, iOS 는 `Info.plist` 의 `tnkad_app_id` 입니다. 이미 그 설정에 앱 ID 를 넣어 두었다면 `initialize()` 를 인자 없이 호출해도 됩니다.
- `runApp` 전에 호출한다면 `WidgetsFlutterBinding.ensureInitialized()` 를 먼저 호출하세요.

### 호출 시점

`openOfferwall` 처럼 화면을 여는 메서드는 앱이 화면에 보이는 동안 호출합니다. 화면을 띄울 곳이 없으면 `PlatformException` 이 발생합니다(자세한 내용은 [3. 전체 화면 오퍼월](offerwall.md)).

---

## 개인정보 동의

모두 **선택 사항**입니다. 앱에서 동의를 따로 받지 않는다면 아무것도 호출하지 않아도 됩니다. 사용자가 오퍼월에 처음 들어갈 때 오퍼월이 동의 팝업으로 직접 받습니다.

| 호출 | 설명 |
|---|---|
| `setAgreePrivacy(true)` | 앱에서 이미 동의를 받았음을 SDK 에 알립니다. 오퍼월에 동의 팝업이 나오지 않습니다 |
| `isAgreePrivacy()` | 현재 동의가 기록되어 있는지 `bool` 로 돌려줍니다 |
| `revokePrivacyConsent()` | 앞서 준 동의를 철회합니다. 열려 있는 오퍼월은 첫 화면부터 다시 열려 동의 팝업이 나옵니다 |

```dart
// agreedInApp, consentRevoked: 앱이 사용자별로 기억해 두는 값 (이 플러그인이 대신 기억해 주지 않습니다)
Future<void> onUserKnown(bool agreedInApp, bool consentRevoked) async {
  await TnkPpiHybSdk.setUserName('<사용자 식별값>');
  if (agreedInApp && !consentRevoked) {
    await TnkPpiHybSdk.setAgreePrivacy(true); // 앱에서 동의를 받고 철회하지 않은 사용자만
  }
}

final agreed = await TnkPpiHybSdk.isAgreePrivacy(); // async 함수 안에서

// 사용자가 앱에서 동의를 철회하는 버튼을 눌렀을 때만
Future<void> onRevokePressed() async {
  await TnkPpiHybSdk.revokePrivacyConsent();
  // 앱에도 '철회함' 을 기억해 둡니다 (consentRevoked = true)
}
```

> ⚠️ **철회한 사용자에게 `setAgreePrivacy(true)` 를 다시 호출하면 철회가 취소됩니다.** 위 코드처럼 앱에서 동의·철회 여부를 기억해 두고, 철회한 사용자는 건너뛰세요. 앱 시작 때마다 모든 사용자에게 `true` 로 설정하면 철회가 취소됩니다. 사용자가 앱에서 다시 동의했을 때만 다시 호출하세요.

> ⚠️ `revokePrivacyConsent()` 는 **사용자의 철회 동작에서만** 호출하세요. 앱 시작이나 화면 복귀에서 부르면 오퍼월이 그때마다 첫 화면으로 돌아갑니다.

동의 팝업이 사용자에게 어떻게 보이는지, 거부했을 때의 화면, 철회 동작은 Android·iOS 와 같습니다 — [Android 7. 개인정보 설정](../android/privacy.md) · [iOS 7. 개인정보 설정](../ios/privacy.md)

### COPPA · GDPR

```dart
await TnkPpiHybSdk.setCOPPA(false);  // true: 만 13세 미만 사용자
await TnkPpiHybSdk.setGDPR(1);       // GDPR 대상 사용자가 있는 앱만, 값은 정수
```

> ⚠️ `setGDPR` 를 호출하지 않았을 때 SDK 의 기본값이 플랫폼마다 다릅니다(Android `-1`, iOS `0`). 플러그인은 이 값을 바꾸지 않습니다. GDPR 대상 사용자가 있는 앱은 두 플랫폼 모두에서 값을 직접 지정하세요 — [Android](../android/privacy.md) · [iOS](../ios/privacy.md)

---

## iOS 앱 추적 동의

iOS 는 앱 추적 동의(ATT)를 받지 못해도 오퍼월은 열리지만 참여할 수 있는 광고가 줄어들 수 있습니다. 앱 추적 동의를 요청하려면 오퍼월을 열기 전에 호출합니다.

```dart
final allowed = await TnkPpiHybSdk.requestTrackingAuthorization();
// allowed: true / false (iOS), null (Android)
```

- 결과는 추적이 허용되었는지(`bool`)입니다. Android 에서는 항상 `null` 이므로 플랫폼 분기 없이 호출해도 됩니다.
- `Info.plist` 에 `NSUserTrackingUsageDescription` 이 있어야 합니다(사진·카메라 문구도 필수) — [1. 설치](install.md)

---

## 그 밖의 호출

| 호출 | 설명 |
|---|---|
| `sdkVersion` | SDK 버전 문자열을 `Future<String>` 으로 돌려줍니다 |
| `getUserName()` | 저장된 사용자 식별값을 돌려줍니다. 없으면 `null` |
| `getAdid()` | SDK 가 가지고 있는 광고 ID 를 돌려줍니다 |
| `refreshAdid()` | 광고 ID 를 다시 읽습니다. Android 에서만 동작하고 iOS 에서는 아무 일도 하지 않습니다 |
| `applicationStarted()` | 앱이 시작되었음을 알립니다. 선택 사항이며, 호출하지 않아도 오퍼월은 동작합니다 |
| `clearApiSession()` | 저장된 서버 세션을 지워 다음 호출 때 다시 로그인하게 합니다. 로그아웃 뒤 다른 계정으로 `setUserName` 한 다음, [적립 가능 포인트](offerwall.md)를 조회하기 전에 호출합니다 |

다음: [3. 전체 화면 오퍼월](offerwall.md)
