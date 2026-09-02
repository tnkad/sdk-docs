---
description: tnkscheme:// 딥링크를 받아 오퍼월의 특정 화면으로 진입시키는 방법. URL 스킴 등록과 SceneDelegate 처리를 안내합니다.
---

# 6. 딥링크

`tnkscheme://` 로 시작하는 딥링크를 받으면 오퍼월의 특정 화면으로 바로 진입시킬 수 있습니다.
푸시 알림이나 외부 배너에서 오퍼월의 특정 카테고리로 보내는 용도로 사용합니다.

딥링크를 쓰지 않는다면 이 페이지는 건너뛰셔도 됩니다.

```
tnkscheme://select_menu?cat_id=3
```

---

## 1. URL 스킴 등록

`Info.plist`

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>com.example.app.tnk</string>
    <key>CFBundleURLSchemes</key>
    <array><string>tnkscheme</string></array>
  </dict>
</array>
```

---

## 2. SDK 에 전달

앱이 떠 있을 때와 딥링크로 처음 실행될 때(콜드스타트) **양쪽 모두** 처리해야 합니다.

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    // 앱이 이미 떠 있는 경우
    func scene(_ scene: UIScene, openURLContexts contexts: Set<UIOpenURLContext>) {
        contexts.forEach { TnkPpiHybSdk.shared.handleScheme($0.url) }
    }

    // 딥링크로 앱이 처음 뜨는 경우
    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        // ... SDK 초기화와 화면 구성을 먼저 마친 뒤
        connectionOptions.urlContexts.forEach { TnkPpiHybSdk.shared.handleScheme($0.url) }
    }
}
```

문자열을 직접 넘길 수도 있습니다.

```swift
TnkPpiHybSdk.shared.handleScheme("tnkscheme://select_menu?cat_id=3")
```

---

## 동작 방식

- 오퍼월이 떠 있으면 **바로 전달**하고, 없으면 **오퍼월을 열어 전달**합니다.
- 앱 부팅 중 도착한 딥링크는 큐에 담았다가 웹이 준비되면 한 번에 전달합니다.
  그래서 `willConnectTo` 에서 호출해도 유실되지 않습니다.

---

## 반환값

`handleScheme` 은 SDK 가 그 URL 을 **소비했는지**를 `Bool` 로 돌려줍니다.

```swift
let consumed = TnkPpiHybSdk.shared.handleScheme(url)
if !consumed {
    handleMyOwnDeeplink(url)   // tnkscheme 이 아니므로 개발사 앱이 자체 처리
}
```

개발사가 여러 스킴을 함께 쓰는 경우, `false` 일 때만 자체 라우팅으로 넘기면 됩니다.

오퍼월을 띄울 화면을 지정해야 한다면 `from:` 을 넘기세요.

```swift
TnkPpiHybSdk.shared.handleScheme(url, from: rootViewController)
```

> 어떤 액션(`select_menu` 등)을 지원하는지는 오퍼월(FE)이 결정합니다.
> 새 액션이 추가되어도 **SDK 를 업데이트할 필요가 없습니다.**
> 사용 가능한 딥링크 목록은 TnkFactory 담당자에게 문의하세요.

---

## 테스트

시뮬레이터에서 바로 확인할 수 있습니다.

```sh
xcrun simctl openurl booted "tnkscheme://select_menu?cat_id=3"
```

---

다음: [7. 개인정보 · 사용자 속성](privacy.md)
