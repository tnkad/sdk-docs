---
description: 빌드 오류, 오퍼월 미노출, 보상 미지급, 딥링크 동작 실패 등 연동 중 자주 겪는 증상의 원인과 해결 방법입니다.
---

# 문제 해결

## 먼저 로그를 켜세요

```kotlin
TnkPpiHybSdk.enableLogging(true)
```

Logcat 에서 태그 `TnkPpiHyb` 로 필터링하면 초기화, 세션 생성, 오퍼월 URL, 브릿지 이벤트가 보입니다.

```bash
adb logcat -s TnkPpiHyb
```

초기화 직후 아래를 찍어보면 대부분의 설정 문제가 바로 드러납니다.

```kotlin
Log.i("TNK", "version=${TnkPpiHybSdk.VERSION}" +
        " initialized=${TnkPpiHybSdk.isInitialized()}" +
        " appId=${TnkPpiHybSdk.getAppId(this)}" +
        " userName=${TnkPpiHybSdk.getUserName(this)}")
```

---

## 빌드 오류

### `requires ... compile against version 36 or later`

호스트 앱의 `compileSdk` 가 낮습니다. **36 이상**으로 올리세요.

```kotlin
android {
    compileSdk = 36
}
```

### `Could not find com.tnkfactory.ad:hrwd:1.0.6`

TnkFactory Maven 저장소가 등록되지 않았습니다.
[1. 설치](install.md)의 저장소 등록을 확인하세요.

```
maven("https://repository.tnkad.net:8443/repository/public/")
```

`settings.gradle.kts` 에 `repositoriesMode` 가 `FAIL_ON_PROJECT_REPOS` 로 되어 있는데
저장소를 모듈 `build.gradle` 쪽에 추가했다면 무시됩니다.
`settings.gradle.kts` 의 `dependencyResolutionManagement` 안에 넣으세요.

### `Manifest merger failed ... AdWallActivity`

개발사 매니페스트에 `com.tnkfactory.ad.AdWallActivity` 를 직접 선언해 두었습니다.
그 `<activity>` 블록을 **제거**하세요.
자세한 내용은 [네이티브 SDK 에서 이관](migration.md)을 참고하세요.

---

## 오퍼월이 뜨지 않거나 빈 화면입니다

### 앱 ID 가 적용되지 않았습니다

```kotlin
Log.i("TNK", "appId=${TnkPpiHybSdk.getAppId(this)}")
```

`null` 이거나 빈 값이면 매니페스트의 `tnkad_app_id` meta-data 가 `<application>` 태그 **안**에
있는지 확인하세요. 빌드 변형별로 매니페스트가 갈라지는 경우 해당 변형에도 들어 있어야 합니다.

### 패키지명이 어드민 등록값과 다릅니다

TNK 어드민은 **패키지명(`applicationId`)으로 앱을 식별**합니다.
`applicationIdSuffix` 로 `.debug` 등을 붙인 빌드는 등록되지 않은 패키지로 취급되어
세션이 만들어지지 않습니다.

```kotlin
// 이런 설정이 있으면 디버그 빌드에서 오퍼월이 뜨지 않습니다
android {
    buildTypes {
        debug {
            applicationIdSuffix = ".debug"   // ← TNK 연동 테스트 시 제거
        }
    }
}
```

### 네트워크 오류 팝업이 뜹니다

오퍼월 페이지 로드에 실패했습니다. 기기의 네트워크 상태를 먼저 확인하고,
회사 네트워크나 VPN 을 통해 접속 중이라면 `tnkfactory.com` 도메인 접근이 차단되지 않았는지 확인하세요.

---

## 보상이 지급되지 않습니다

`setRewardListener` 는 **UI 알림용**입니다. 실제 포인트 지급은 서버 콜백으로 이루어집니다.

1. TNK 어드민에 개발사 콜백 URL 이 등록되어 있는지 확인
2. 콜백 서버가 **HTTP 200** 을 응답하는지 확인 (200 이 아니면 재시도 후 24시간 뒤 폐기)
3. `md_chk` 검증이 정식 규격과 맞는지 확인
4. `setUserName()` 에 넣은 값과 콜백의 `md_user_nm` 이 일치하는지 확인

자세한 내용은 [서버 보상 콜백 URL](../common/server-callback.md)을 참고하세요.

> 로그인 전 임시값으로 오퍼월에 진입했다가 나중에 `setUserName()` 을 바꾸면
> 그 사이 발생한 보상은 임시값으로 지급되어 회수할 수 없습니다.
> 오퍼월 진입은 사용자 식별값이 확정된 뒤로 미루세요.

---

## 삽입한 오퍼월(`TnkOfferwallView`)이 동작하지 않습니다

### 화면이 비어 있습니다

`loadOfferwall()` 을 호출하셨는지 확인하세요. XML 배치만으로는 로드되지 않습니다.

### 탭을 오갈 때마다 처음부터 다시 로드됩니다

화면이 보일 때마다 `loadOfferwall()` 을 호출하고 있습니다.
**최초 1회만 호출하고 이후에는 뷰의 visibility 만 토글**하세요.
그래야 스크롤 위치와 진행 중인 참여 상태가 유지됩니다.

### 닫기 버튼을 누르면 화면 전체가 종료됩니다

`onCloseRequested` 를 등록하지 않으면 기본 동작으로 호스트 Activity 가 `finish()` 됩니다.
탭 임베드 시나리오라면 등록하세요.

```kotlin
binding.offerwallView.onCloseRequested = {
    binding.bottomNav.selectedItemId = R.id.nav_home
}
```

### 콘텐츠가 상태바에 가려집니다

edge-to-edge 화면이라면 상단 inset 을 전달하세요.

```kotlin
binding.offerwallView.setSafeAreaTopPx(topInsetPx / resources.displayMetrics.density)
```

---

## 딥링크가 동작하지 않습니다

- 매니페스트에 `tnkscheme` intent-filter 가 있는지 확인
- `android:launchMode="singleTop"` 인지 확인
- `onCreate()` 와 `onNewIntent()` **양쪽 모두**에서 `handleScheme()` 을 호출하는지 확인
- `onNewIntent()` 에서 `setIntent(intent)` 를 먼저 호출했는지 확인

터미널에서 직접 테스트할 수 있습니다.

```bash
adb shell am start -a android.intent.action.VIEW -d "tnkscheme://select_menu?cat_id=3" 앱.패키지명
```

---

## 그 밖의 문의

tech@tnkfactory.com
