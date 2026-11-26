---
description: TnkFactory 하이브리드(V4) 오퍼월 SDK 의 Flutter 플러그인(tnk_ppi_hyb) 빠른 시작. 요구사항, 설치, 초기화, 사용자 식별값, 오퍼월 열기까지 최소 연동 흐름을 안내합니다.
---

# tnk_ppi_hyb — 하이브리드(V4) 오퍼월 Flutter 플러그인 연동 가이드

이 페이지에서 하는 일: Flutter 앱에 하이브리드(V4) 오퍼월 플러그인 `tnk_ppi_hyb` 를 붙이는 최소 흐름을 보여 줍니다. 마지막까지 마치면 버튼을 눌러 오퍼월을 열 수 있습니다.

`tnk_ppi_hyb` 는 Android·iOS 하이브리드(V4) SDK 를 Dart 에서 부르게 해 주는 Flutter 플러그인입니다. 전체 화면 오퍼월, 특정 광고 바로 진입, 적립 가능 포인트 조회, 보상 알림, 플레이스먼트(지면 광고 목록), 앱 화면 안에 넣는 오퍼월을 제공합니다.

오퍼월 화면은 SDK 가 앱 안에 띄우는 웹 화면으로 제공되며, Android·iOS 에서 같은 화면을 사용합니다. 화면 개선이나 개발사별 맞춤 설정(담당자에게 요청)은 TnkFactory 가 적용하며, 앱을 다시 배포하지 않아도 반영됩니다.

---

## 언제 필요한가

Flutter 앱에 오퍼월을 처음 붙이는 모든 개발사에게 필요합니다(필수).
이미 기존 `tnk_flutter_rwd` 플러그인을 쓰고 있다면 [기존 플러그인에서 이관](migration.md)을 먼저 보세요. 두 플러그인은 서로 다른 패키지입니다. 한 앱에 함께 두는 구성은 Android 에서 실제 기기로 확인했습니다(기존 오퍼월은 기존 호출로, 새 오퍼월은 `openOfferwall` 로 열림). iOS 는 확인되지 않았습니다(자세한 내용은 이관 페이지).

시작하기 전에 [퍼블리셔 페이지](../publisher/app-id.md)에서 앱을 등록하고 아래 두 가지를 발급받아야 합니다. Android 와 iOS 는 앱 ID 가 각각 다를 수 있습니다.

| 항목 | 설명 |
|------|------|
| **개발사 앱 ID** (`tnkad_app_id`) | 앱마다 발급되는 식별자 — [발급 방법](../publisher/app-id.md) |
| **앱 키** (`app_key`) | 서버 보상 콜백 검증에 사용. 개발사 백엔드에서만 사용하며 앱에 넣지 않습니다 |

> ⚠️ TNK 는 **패키지명(Android) / 번들 ID(iOS)로 앱을 식별**합니다. 퍼블리셔 페이지에 등록한 값과 실제 앱의 값이 다르면 오퍼월이 정상적으로 표시되지 않을 수 있습니다. 설정이 어려우면 담당자에게 문의해 주세요.

---

## 요구사항

| 항목 | 최소 | 비고 |
|------|------|------|
| Flutter / Dart | **3.41 / 3.11** | 플러그인이 선언한 최소 버전입니다. 확인은 Flutter 3.47 로 했습니다 |
| Android | `minSdk` 21 (Android 5.0), `compileSdk` 35 이상, JDK 17 | 하이브리드(V4) Android SDK 의 요구사항입니다 |
| iOS | 15.0 | 하이브리드(V4) iOS SDK 의 요구사항입니다 |

플러그인이 사용하는 하이브리드(V4) SDK 버전은 아래와 같습니다.

| 플랫폼 | 하이브리드(V4) SDK |
|---|---|
| Android | `com.tnkfactory.ad:hrwd` 1.0.18 |
| iOS | `TnkPpiHyb` 1.0.8 |

> ⚠️ Android 에뮬레이터·가상 기기에서는 오퍼월이 열리지 않습니다. 동작 확인은 실기기에서 해 주세요.

> ⚠️ 한 프로세스에 Flutter 엔진이 여러 개인 앱(add-to-app)은 지원하지 않습니다. SDK 가 프로세스당 리스너를 하나만 유지합니다.

---

## 빠른 시작

### 1. 플러그인과 저장소 추가

`pubspec.yaml` 에 플러그인을 추가하고, Android 는 SDK 를 받을 Maven 저장소를 추가합니다. 자세한 내용은 [1. 설치](install.md)에 있습니다. iOS 는 `Info.plist` 에 추적·사진·카메라 사용 문구 3개가 필요합니다(`NSUserTrackingUsageDescription`·`NSPhotoLibraryUsageDescription`·`NSCameraUsageDescription`). 카메라 문구가 없으면 오퍼월의 문의하기 첨부에서 '카메라로 촬영' 을 선택하는 순간 앱이 종료됩니다 — [iOS 2. Info.plist 설정](../ios/plist.md)

```yaml
dependencies:
  tnk_ppi_hyb: ^1.0.0
```

**안 하면(Android 에서 저장소를 추가하지 않으면):** Android 빌드가 `Could not find com.tnkfactory.ad:hrwd:1.0.18` 로 실패합니다.

### 2. 초기화

앱 시작 시 한 번 앱 ID 를 넣어 초기화합니다. `runApp` 전에 호출하면 `WidgetsFlutterBinding.ensureInitialized()` 를 먼저 호출해야 합니다.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:tnk_ppi_hyb/tnk_ppi_hyb.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await TnkPpiHybSdk.initialize(
    androidAppId: '<Android 앱 ID>',
    iosAppId: '<iOS 앱 ID>',
  );
  await TnkPpiHybSdk.enableLogging(kDebugMode); // 연동 확인용, 출시 빌드에서는 꺼 둡니다
  runApp(const MyApp());
}
```

**안 하면:** 앱 ID 를 알 수 없어(매니페스트·Info.plist 에도 선언하지 않았다면) 오퍼월이 정상적으로 열리지 않습니다.

### 3. 사용자 식별값 설정

사용자를 알 수 있는 시점(로그인 직후 등)에 개발사 사용자 식별값을 설정합니다.

```dart
await TnkPpiHybSdk.setUserName('<사용자 식별값>');
```

**안 하면:** 보상이 어느 사용자의 것인지 알 수 없습니다.

### 4. 오퍼월 열기

```dart
await TnkPpiHybSdk.openOfferwall();
```

호출하면 오퍼월이 앱 화면 위에 전체 화면으로 열립니다. 사용자가 닫으면 앱 화면으로 돌아옵니다.

### 5. 서버 보상 콜백 구현

실제 포인트 지급은 서버 콜백으로 처리합니다. 앱에서 받는 `rewards` 알림은 화면 갱신용입니다.

> ⚠️ 클라이언트 알림만 믿고 지급하면 위·변조로 부정 적립이 발생합니다. [서버 보상 콜백 URL](../common/server-callback.md)을 반드시 구현하세요.

---

## 기능별 가이드

| 하고 싶은 일 | 페이지 |
|---|---|
| 플러그인·Maven 저장소·플랫폼 설정 | [1. 설치](install.md) |
| 초기화, 사용자 식별값, 개인정보 동의, COPPA·GDPR | [2. 초기화](initialize.md) |
| 전체 화면 오퍼월, 보상 알림, 적립 가능 포인트, 특정 광고 진입, 딥링크 | [3. 전체 화면 오퍼월](offerwall.md) |
| 앱 화면 일부에 지면 광고 목록 표시 (`TnkPlacementView`, `loadPlacementData`) | [4. 플레이스먼트](placement.md) |
| 앱 화면 안(예: 하단 탭)에 오퍼월 전체 삽입 (`TnkOfferwallView`) | [5. 화면 안에 오퍼월 넣기](embedded-offerwall.md) |
| 기존 `tnk_flutter_rwd` 에서 옮기기 | [기존 플러그인에서 이관](migration.md) |

플랫폼과 무관한 내용은 공통 문서에 있습니다.

- [서버 보상 콜백 URL](../common/server-callback.md) — 실제 포인트 지급 경로입니다. **반드시 구현하셔야 합니다.**
- [지원 범위](../common/support-matrix.md) — 제공 기능과 현재 제공하지 않는 기능
- Android·iOS 하이브리드(V4) SDK 가이드: [Android](../android/README.md) · [iOS](../ios/README.md) — 오퍼월 화면, 개인정보 동의 팝업 같은 동작 설명이 같습니다.

> 💡 Flutter 플러그인의 Dart API 는 하이브리드(V4) SDK 의 호출 이름을 따릅니다. 대표 클래스는 `TnkPpiHybSdk` 이고 모든 메서드가 `static` 입니다.

문의: tech@tnkfactory.com
