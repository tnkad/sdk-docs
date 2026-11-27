---
description: Flutter 앱에 tnk_ppi_hyb 플러그인을 설치하는 방법. pubspec 의존성, Android 공개 Maven 저장소와 오퍼월 Activity 테마, iOS 최소 버전, SPM·CocoaPods 선택과 SDK 업데이트 방법, 추적 동의 문구 설정을 안내합니다.
---

# 1. 설치

이 페이지에서 하는 일: `tnk_ppi_hyb` 플러그인을 앱에 추가하고, Android·iOS 에서 빌드되도록 플랫폼 설정을 합니다.

## 언제 필요한가

Flutter 앱에 오퍼월을 붙이는 모든 개발사에게 필요합니다(필수). 기존 `tnk_flutter_rwd` 플러그인과 함께 쓰는 경우에는 [기존 플러그인에서 이관](migration.md)의 '한 앱에 함께 두기'를 함께 보세요.

---

## 플러그인 추가

```bash
flutter pub add tnk_ppi_hyb
```

또는 `pubspec.yaml` 에 직접 추가합니다.

```yaml
dependencies:
  tnk_ppi_hyb: ^1.0.0
```

pub.dev 에서 게시자가 인증된 `tnkfactory.com` 인지 확인하고 받으세요.

플러그인은 하이브리드(V4) SDK(Android `com.tnkfactory.ad:hrwd` 1.0.19, iOS `TnkPpiHyb` 1.0.9)를 함께 가져옵니다. 이 SDK 들을 앱에 따로 추가하지 않습니다.

---

## Android

### Maven 저장소 추가

SDK 는 TnkFactory 공개 Maven 저장소로 배포됩니다. Gradle 은 플러그인의 의존성을 **앱의 저장소**로 찾으므로, 앱의 저장소 목록(`android/build.gradle` 또는 `android/build.gradle.kts` 의 `allprojects { repositories { ... } }`)에 아래를 추가합니다.

```kotlin
maven {
    url = uri("https://repository.tnkad.net:8443/repository/public/")
    content { includeGroup("com.tnkfactory.ad") }
}
```

`content` 필터는 이 저장소를 TNK 그룹(`com.tnkfactory.ad`)에만 쓰게 하여 다른 의존성은 이 저장소에서 찾지 않게 합니다.

**안 하면:** 앱 빌드가 `Could not find com.tnkfactory.ad:hrwd:1.0.19` 로 실패합니다.

> ⚠️ 기존 `tnk_flutter_rwd` 플러그인과 한 앱에 함께 두는 동안에는 `content` 필터를 **넣지 마세요.** 필터가 기존 SDK(`com.tnkfactory:rwd`)를 가려 빌드가 실패합니다 — [기존 플러그인에서 이관](migration.md)

### MainActivity

`MainActivity` 는 기본 `FlutterActivity` 그대로 둡니다. 매니페스트에 SDK 의 Activity 를 선언할 필요도 없습니다. SDK 가 직접 가져옵니다.

단, 앱 화면 안에 넣은 오퍼월(`TnkOfferwallView`)에서 파일 선택(예: 문의에 사진 첨부)을 쓰려면 `FlutterFragmentActivity` 를 상속해야 합니다 — [5. 화면 안에 오퍼월 넣기](embedded-offerwall.md)

### 오퍼월 화면 테마

오퍼월은 자체 상단 헤더를 그리므로, 플러그인이 SDK 의 오퍼월 Activity(`com.tnkfactory.ad.hrwd.webview.TnkOfferwallActivity`)에 ActionBar 가 없는 테마를 지정합니다(밝은 테마, 기기가 다크 모드이면 어두운 테마). 대부분 따로 할 일이 없습니다.

이 Activity 에 앱 테마를 쓰려면 앱 매니페스트에 Activity 를 선언하고 `tools:replace="android:theme"` 을 붙입니다(`<manifest>` 에 `xmlns:tools="http://schemas.android.com/tools"` 추가).

```xml
<activity
    android:name="com.tnkfactory.ad.hrwd.webview.TnkOfferwallActivity"
    android:theme="@style/MyOfferwallTheme"
    tools:replace="android:theme" />
```

**안 하면(`tools:replace` 없이 테마를 선언하면):** 매니페스트 병합이 테마 충돌로 실패합니다.

---

## iOS

- 최소 지원 버전은 **iOS 15.0** 입니다.
- 플러그인은 Swift Package Manager(SPM)와 CocoaPods 를 모두 제공합니다. Flutter 버전에 따라 쓰이는 방식이 다릅니다.

### SPM 과 CocoaPods

- **Flutter 3.44 이상:** SPM 이 기본입니다. 따로 할 일이 없습니다.
- **Flutter 3.41~3.43:** SPM 이 기본으로 꺼져 있어 CocoaPods 로 빌드되고, iOS SDK(`TnkPpiHyb`)는 CocoaPods 로 받을 수 있는 버전에 머뭅니다. 이후 iOS SDK 를 받으려면 앱 `pubspec.yaml` 에 아래를 넣어 SPM 으로 전환하세요. 이 설정은 해당 프로젝트에만 적용되며 전역 설정이 아닙니다.

```yaml
flutter:
  config:
    enable-swift-package-manager: true
```

- **CocoaPods 로 빌드하는 경우:** CocoaPods 공용 저장소(trunk)가 2026-12-02 부터 읽기 전용이 되므로, 그 뒤에 나오는 SDK 는 SPM 으로만 받을 수 있습니다. 이 플러그인은 `TnkPpiHyb` 1.0.9 이상 1.1 미만(`~> 1.0.9`)을 받습니다.
- **업데이트:** SPM 은 `flutter pub upgrade tnk_ppi_hyb` 를 실행하면 플러그인 새 버전이 맞는 SDK 를 가져옵니다. CocoaPods 는 플러그인을 올린 뒤 `pod install` 이 `TnkPpiHyb` 버전 충돌을 알리면(`Podfile.lock` 이 옛 버전을 잡고 있는 경우) `cd ios && pod update TnkPpiHyb` 를 실행합니다.
- **`TnkPpiHyb` 를 앱에 따로 추가하지 마세요.** `Podfile` 의 `pod 'TnkPpiHyb'` 와 Xcode 의 패키지 추가 모두 해당합니다. 플러그인이 이미 가져오므로 같은 SDK 가 중복으로 들어가거나 플러그인과 다른 버전에 묶여 빌드나 실행에서 문제가 생길 수 있습니다(공개 iOS 가이드 [1. 설치](../ios/install.md)의 경고와 같은 이유).

### Info.plist 권한 문구

`ios/Runner/Info.plist` 에 아래 세 가지 사용 목적 문구를 **필수**로 넣습니다.

| 키 | 이 문구가 쓰이는 때 | 문구가 없으면 |
|---|---|---|
| `NSUserTrackingUsageDescription` | 코드에서 `requestTrackingAuthorization()` 을 호출하면 iOS 가 띄우는 추적 허용(ATT) 팝업 | 추적 허용 팝업이 뜨지 않거나, 요청하는 순간 앱이 종료될 수 있습니다. 팝업이 뜨지 않으면 광고 식별자(IDFA)를 사용할 수 없습니다 |
| `NSPhotoLibraryUsageDescription` | 오퍼월의 문의하기에서 캡처 이미지를 첨부하려고 사진 보관함을 열 때 | 항상 넣어 두세요 |
| `NSCameraUsageDescription` | 같은 첨부 화면에서 카메라로 촬영을 선택할 때 | 그 순간 앱이 종료됩니다 |

```xml
<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 광고 제공을 위해 기기 광고 식별자(IDFA)를 사용합니다.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>문의하기에 캡처 이미지를 첨부하기 위해 사진 보관함을 사용합니다.</string>

<key>NSCameraUsageDescription</key>
<string>문의하기에 첨부할 사진을 촬영하기 위해 카메라를 사용합니다.</string>
```

문구는 앱 상황에 맞게 바꾸세요. 자세한 내용은 [iOS 2. Info.plist 설정](../ios/plist.md)에 있습니다. `requestTrackingAuthorization()` 호출 방법은 [2. 초기화](initialize.md)에 있습니다.

---

## 설치 확인

`flutter pub get` 후 Android·iOS 빌드가 끝나면 설치가 끝난 것입니다. 다음 단계에서 앱 ID 를 넣어 초기화합니다.

다음: [2. 초기화](initialize.md)
