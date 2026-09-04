---
description: TnkPpiHyb SDK 초기화 순서와 개발사 사용자 식별값 설정, ATT 동의 요청 시점을 안내합니다.
---

# 3. 초기화

## 최소 코드

앱 시작 시 1회 호출합니다.

```swift
import TnkPpiHyb

let sdk = TnkPpiHybSdk.shared
sdk.enableLogging(true)                      // 릴리스에서는 false
sdk.configure(appId: "발급받은-앱-아이디")    // Info.plist 에 tnkad_app_id 가 있으면 생략 가능
sdk.setUserName("개발사-사용자-식별값")
sdk.applicationStarted()
```

`SceneDelegate.scene(_:willConnectTo:options:)` 또는 `AppDelegate.didFinishLaunching` 에 두시면 됩니다.

---

## 앱 ID

```swift
sdk.configure(appId: "발급받은-앱-아이디")
```

`Info.plist` 에 `tnkad_app_id` 를 넣어두었다면 **`configure` 호출 자체를 생략**할 수 있습니다
(SDK 가 첫 사용 시점에 자동 초기화합니다). 오퍼월 URL 을 직접 지정해야 하는 경우에는 설정 객체를 쓸 수 있습니다.

```swift
sdk.configure(TnkPpiHybConfig(appId: "발급받은-앱-아이디"))
```

적용된 값은 다음으로 확인합니다.

```swift
sdk.getAppId()        // String?
sdk.isInitialized     // Bool
```

---

## 사용자 식별값 (`setUserName`)

```swift
sdk.setUserName("개발사-사용자-식별값")
```

**보상 지급의 기준값**입니다. 개발사 서비스의 회원 ID 처럼 **사용자를 고유하게 식별하고
기기가 바뀌어도 유지되는 값**을 넣으세요. 이 값이 서버 보상 콜백의 `md_user_nm` 으로
그대로 전달됩니다([서버 보상 콜백 URL](../common/server-callback.md) 참고).

> ⚠️ 로그인 전이라 식별값이 없다면 오퍼월 진입 자체를 로그인 이후로 미루는 편이 안전합니다.
> 임시값으로 진입했다가 나중에 바꾸면, 그 사이 발생한 보상이 임시값으로 지급되어 회수할 수 없습니다.

```swift
sdk.getUserName()   // String?
```

---

## `applicationStarted()`

```swift
sdk.applicationStarted()
```

앱 실행 신호를 보냅니다. 광고 요청을 보내지는 않습니다. `start()` 와 동일합니다.

---

## ATT 동의 요청

**앱이 활성 상태일 때만** 팝업이 뜹니다. `sceneDidBecomeActive` 에서 1회 호출하세요.

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var didRequestATT = false

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard !didRequestATT else { return }
        didRequestATT = true
        TnkPpiHybSdk.shared.requestTrackingAuthorization { granted in
            // 동의 후 IDFA 실값이 확정됩니다
        }
    }
}
```

> `willConnectTo`(활성 이전)에서 부르면 **팝업이 뜨지 않고** 상태가 `.notDetermined` 로 남습니다.
> 이 경우 사용자는 동의 여부를 물어보지도 못한 채 광고 매칭률만 떨어집니다.

`Info.plist` 에 `NSUserTrackingUsageDescription` 이 없으면 팝업 대신 앱이 크래시합니다.
[2. Info.plist 설정](plist.md)을 먼저 확인하세요.

---

## 광고 식별자 (IDFA)

```swift
sdk.getAdid()   // String
```

ATT 동의 전이거나 사용자가 거부한 경우 기본값이 반환됩니다.
오퍼월 진입 전에 별도로 대기하실 필요는 없습니다.

---

## 로그

```swift
sdk.enableLogging(true)
```

Xcode 콘솔에 `[TnkPpiHyb]` 접두어로 출력됩니다. 릴리스 빌드에서는 꺼두세요.

```swift
#if DEBUG
sdk.enableLogging(true)
#endif
```

---

다음: [4. 오퍼월 띄우기](offerwall.md)
