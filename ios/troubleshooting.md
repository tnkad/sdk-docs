---
description: 오퍼월 미노출, ATT 팝업 미표시, 보상 미지급, 딥링크 무반응 등 iOS 연동 중 자주 겪는 증상의 원인과 해결 방법입니다.
---

# 문제 해결

## 먼저 로그를 켜세요

```swift
TnkPpiHybSdk.shared.enableLogging(true)
```

Xcode 콘솔에 `[TnkPpiHyb]` 접두어로 출력됩니다. 초기화 직후 아래를 찍어보면
대부분의 설정 문제가 바로 드러납니다.

```swift
let sdk = TnkPpiHybSdk.shared
print("version=\(TnkPpiHybSdk.version)",
      "initialized=\(sdk.isInitialized)",
      "appId=\(sdk.getAppId() ?? "nil")",
      "userName=\(sdk.getUserName() ?? "nil")")
```

---

## 빌드 · 설치

### `No such module 'TnkPpiHyb'`

- **CocoaPods**: `.xcodeproj` 가 아니라 **`.xcworkspace`** 를 여셨는지 확인하세요.
- **SPM**: File → Packages → Reset Package Caches 후 다시 받아보세요.

### 배포 타깃 오류

SDK 는 **iOS 14.0** 이상입니다. 앱의 Minimum Deployments 를 확인하세요.

### 시뮬레이터에서 링크 실패

배포된 xcframework 는 실기기 `arm64` 와 시뮬레이터 `arm64`·`x86_64` 를 모두 포함합니다.
그래도 실패한다면 Derived Data 를 지우고 다시 빌드해보세요.

---

## ATT 팝업이 뜨지 않습니다

### 앱이 활성 상태가 아닐 때 호출했습니다

`scene(_:willConnectTo:options:)` 처럼 **활성화 이전** 시점에 호출하면 팝업이 뜨지 않고
상태가 `.notDetermined` 로 남습니다. `sceneDidBecomeActive` 에서 호출하세요.

### 이미 한 번 응답했습니다

ATT 는 사용자당 1회만 묻습니다. 다시 확인하려면 앱을 삭제 후 재설치하거나,
설정 → 개인정보 보호 → 추적 에서 상태를 바꾸세요.

### `NSUserTrackingUsageDescription` 이 없습니다

이 키가 없으면 팝업 대신 **앱이 크래시**합니다. [2. Info.plist 설정](plist.md)을 확인하세요.

---

## 오퍼월이 비어 있거나 뜨지 않습니다

### 앱 ID 가 적용되지 않았습니다

```swift
print(TnkPpiHybSdk.shared.getAppId() ?? "nil")
```

`nil` 이면 `configure(appId:)` 를 호출하지 않았거나 `Info.plist` 의 `tnkad_app_id` 가 없습니다.

### 사용자 식별값이 없습니다

`setUserName(_:)` 을 호출하지 않으면 보상 대상을 특정할 수 없어 오퍼월이 정상 동작하지 않습니다.

### 번들 ID 가 어드민 등록값과 다릅니다

TNK 는 **번들 ID 로 앱을 식별**합니다. 디버그 빌드에서 번들 ID 에
접미사를 붙이고 계시다면 등록되지 않은 앱으로 취급됩니다.

---

## 참여 가능한 광고가 너무 적습니다

ATT 동의를 받지 않으면 IDFA 가 없어 매칭되는 광고가 크게 줄어듭니다.
`requestTrackingAuthorization` 호출 여부와 사용자의 실제 동의 여부를 확인하세요.

---

## 이미지 첨부 · 사진 촬영이 실패합니다

`NSPhotoLibraryUsageDescription`, `NSCameraUsageDescription` 문구가 `Info.plist` 에
있는지 확인하세요. 문구가 없으면 시스템이 권한 요청 자체를 차단합니다.

---

## 보상이 지급되지 않습니다

`setRewardListener` 는 **UI 알림용**입니다. 실제 포인트 지급은 서버 콜백으로 이루어집니다.

1. 퍼블리셔 페이지에 개발사 콜백 URL 이 등록되어 있는지 확인
2. 콜백 서버가 **HTTP 200** 을 응답하는지 확인
3. `md_chk` 검증이 정식 규격과 맞는지 확인
4. `setUserName(_:)` 에 넣은 값과 콜백의 `md_user_nm` 이 일치하는지 확인

자세한 내용은 [서버 보상 콜백 URL](../common/server-callback.md)을 참고하세요.

---

## 삽입한 오퍼월이 이상합니다

### 화면이 비어 있습니다

`loadOfferwall(_:)` 을 호출하셨는지, 넘긴 URL 이 `nil` 이 아닌지 확인하세요.

```swift
guard let url = TnkPpiHybSdk.shared.buildOfferwallURL() else { return }
offerwall.loadOfferwall(url)
```

URL 자체는 초기화 전에도 반환됩니다. 화면이 비어 있다면 위의 앱 ID · 사용자 식별값 항목을 먼저 확인하세요.

### 화면을 닫아도 메모리가 줄지 않습니다

`cleanup()` 을 호출하지 않았습니다. `deinit` 이나 `viewDidDisappear` 에서 호출하세요.

### 상태바 글자색이 배경과 겹칩니다

`onStatusBarStyleChanged` 에서 `setNeedsStatusBarAppearanceUpdate()` 를 호출하고,
`preferredStatusBarStyle` 이 `offerwall.requestedStatusBarStyle` 을 반환하도록 하세요.

---

## 딥링크가 동작하지 않습니다

- `Info.plist` 의 `CFBundleURLTypes` 에 `tnkscheme` 이 등록됐는지 확인
- `openURLContexts` 와 `willConnectTo` **양쪽 모두**에서 `handleScheme` 을 호출하는지 확인
- 반환값이 `false` 라면 `tnkscheme` 이 아닌 URL 입니다

```sh
xcrun simctl openurl booted "tnkscheme://select_menu?cat_id=3"
```

---

## 그 밖의 문의

tech@tnkfactory.com
