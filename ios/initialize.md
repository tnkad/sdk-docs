---
description: 앱이 시작될 때 한 번 호출하는 SDK 초기화 코드와 호출 순서를 안내합니다. 앱 ID 지정(configure), 사용자 식별값(setUserName), 로그, ATT 동의 요청 시점을 값별 동작과 함께 설명합니다.
---

# 3. 초기화

이 페이지에서 하는 일: 앱이 시작될 때 SDK 에 사용자 식별값을 알려 주고, 오퍼월을 열 준비를 마칩니다.

## 언제 필요한가

모든 개발사에게 필요합니다. 사용자 식별값 설정(`setUserName`)은 **필수**이고, 나머지는 해당하는 경우에만 호출하는 선택 항목입니다.

---

## 앱 시작 시 한 번

아래 순서대로 앱이 시작될 때 한 번 호출합니다. 주석 처리된 줄은 해당하는 경우에만 풀어서 사용하세요.

```swift
import TnkPpiHyb

let sdk = TnkPpiHybSdk.shared

// 1) 로그 — 연동 확인용입니다. 출시 빌드에서는 꺼 둡니다.
#if DEBUG
sdk.enableLogging(true)
#endif

// 2) 앱 ID — 반드시 다른 SDK 호출보다 먼저
//    (Info.plist 에 tnkad_app_id 를 넣어 두었다면 생략)
sdk.configure(appId: "발급받은-앱-아이디")

// 3) 사용자 식별값 (필수) — 사용자를 알 수 있는 시점에
sdk.setUserName("개발사-사용자-식별값")

// 4) 앱에서 사용자에게 직접 개인정보 수집 동의를 받은 경우에만 — 반드시 setUserName 다음에
// sdk.setAgreePrivacy(true)

// 5) 만 13세 미만 사용자가 있는 앱만 — 계정마다 setUserName 다음에 (1: 해당, 0: 해당 없음)
// sdk.setCOPPA(isUnder13 ? 1 : 0)

// 6) 보상 알림을 받으려면 오퍼월을 열기 전에 setRewardListener 를 등록합니다 (5. 보상 지급 수신)
```

`SceneDelegate.scene(_:willConnectTo:options:)` 또는 `AppDelegate.application(_:didFinishLaunchingWithOptions:)` 에 두시면 됩니다.
ATT 동의 요청은 이 블록이 아니라 `sceneDidBecomeActive` 에서 따로 호출합니다. 아래 'ATT 동의 요청' 절을 참고하세요.

| 순서 | 호출 | 필수 | 이 순서인 이유 |
|:-:|---|:-:|---|
| 1 | `enableLogging` | 선택 | 이후 호출의 로그부터 확인하려면 가장 먼저 둡니다 |
| 2 | `configure` | 선택 | Info.plist 에 값이 있는데 다른 SDK 호출이 먼저 있으면 앱 ID 가 적용되지 않습니다 |
| 3 | `setUserName` | **필수** | 이후 동작은 이 사용자 기준입니다 |
| 4 | `setAgreePrivacy` | 선택 | `setUserName` 이 동의 상태를 초기화할 수 있어 그 다음에 호출합니다 |
| 5 | `setCOPPA` | 선택 | 값이 저장되어 유지되므로 계정을 바꿀 때마다 `0` 또는 `1` 로 다시 설정합니다. 오퍼월을 열기 전에 설정하세요. 값별 동작은 [7. 개인정보 설정](privacy.md) |
| 6 | `setRewardListener` | 선택 | 오퍼월을 열기 전에 등록해야 보상 알림을 놓치지 않습니다 |

오퍼월은 위 설정이 끝난 뒤 버튼 액션 등에서 `openOfferwall(from:)` 으로 엽니다. 자세한 내용은 [4. 오퍼월 띄우기](offerwall.md)를 참고하세요.

---

## 앱 ID 지정 (`configure`)

앱 ID 는 두 가지 방법 중 하나로 넣습니다.

- 코드: `sdk.configure(appId: "발급받은-앱-아이디")`
- `Info.plist`: 키 `tnkad_app_id` 에 앱 ID 를 넣어 두면 `configure` 호출을 생략할 수 있습니다 ([2. Info.plist 설정](plist.md))

```swift
sdk.configure(appId: "발급받은-앱-아이디")
```

| 상황 | 적용되는 앱 ID |
|---|---|
| `configure` 를 호출하지 않음 | `Info.plist` 의 `tnkad_app_id` (SDK 를 처음 호출할 때 자동 적용) |
| `configure(appId:)` 를 **가장 먼저** 호출 | 코드로 넘긴 앱 ID (`Info.plist` 값보다 우선) |
| `Info.plist` 에 `tnkad_app_id` 가 있는데, `configure(appId:)` 를 `setUserName`·`openOfferwall` 등 **다른 SDK 호출 뒤에** 호출 | **무시됩니다.** 이미 `Info.plist` 값으로 초기화가 끝나 있고, 오류나 알림은 없습니다 |

초기화는 앱이 실행되는 동안 한 번만 일어나며, 한 번 정해진 앱 ID 는 바꿀 수 없습니다.
코드로 넘긴 앱 ID 는 저장되지 않으므로 **앱이 실행될 때마다** 가장 먼저 호출해야 합니다.
`enableLogging` 과 `setRewardListener` 는 초기화를 일으키지 않으므로 `configure` 앞에 두어도 됩니다.

```swift
// 올바른 순서 — configure 가 가장 먼저
sdk.configure(appId: "발급받은-앱-아이디")
sdk.setUserName("개발사-사용자-식별값")
```

```swift
// 잘못된 순서 — Info.plist 에 tnkad_app_id 가 있으면 setUserName 이 먼저 SDK 를 초기화하므로
// 아래 configure 의 앱 ID 는 적용되지 않습니다
sdk.setUserName("개발사-사용자-식별값")
sdk.configure(appId: "발급받은-앱-아이디")
```

`Info.plist` 에 `tnkad_app_id` 가 없다면 위 상황은 생기지 않습니다. 그래도 순서를 단순하게 두려면 `configure` 를 가장 먼저 호출하세요.

> ⚠️ `Info.plist` 에도 없고 `configure` 로도 넣지 않으면 앱 ID 가 없는 상태가 되어 오퍼월을 정상적으로 이용할 수 없습니다.
> 둘 중 하나는 반드시 지정해 주세요.

초기화 상태와 적용된 앱 ID 는 다음으로 확인합니다.

```swift
sdk.isInitialized    // Bool
sdk.getAppId()       // String? — 하이픈이 제거된 앱 ID
```

| 호출 | 돌려주는 값 | 알아둘 점 |
|---|---|---|
| `isInitialized` | 초기화가 끝났으면 `true` | 이 호출은 초기화를 시작하지 않습니다 |
| `getAppId()` | 적용된 앱 ID, 아직 없으면 `nil` | 이 호출도 초기화를 시작하지 않습니다 |

`Info.plist` 로만 앱 ID 를 넣고 `configure` 를 생략했다면, `setUserName` 이나 오퍼월 열기 같은 SDK 호출이 한 번 일어난 뒤에 값이 채워집니다.
그 전에는 `isInitialized` 가 `false`, `getAppId()` 가 `nil` 이며 정상입니다.

---

## 사용자 식별값 (`setUserName`)

```swift
sdk.setUserName("개발사-사용자-식별값")
```

**보상 지급의 기준값**입니다. 개발사 서비스의 회원 ID 처럼 **사용자를 고유하게 식별하고
기기가 바뀌어도 유지되는 값**을 넣으세요. 이 값이 서버 보상 콜백의 사용자 식별 파라미터로
그대로 전달됩니다([서버 보상 콜백 URL](../common/server-callback.md) 참고).

> ⚠️ 로그인 전이라 식별값이 없다면 오퍼월 진입 자체를 로그인 이후로 미루는 편이 안전합니다.
> 임시값으로 진입했다가 나중에 바꾸면, 그 사이 발생한 보상이 임시값으로 지급되어 회수할 수 없습니다.

식별값을 바꾸면 개인정보 수집 동의 상태에도 영향이 있습니다 (SDK 1.0.2 이상).

| 호출 | 동의 상태 | 사용자가 보는 것 |
|---|---|---|
| 이전과 **같은 값**으로 호출 | 그대로 유지됩니다 | 변화 없음. 앱을 시작할 때마다 호출해도 됩니다 |
| 이전과 **다른 값**으로 호출 (최초 지정 포함) | 초기화되어 동의하지 않은 상태가 됩니다 (`isAgreePrivacy()` 가 `false`) | 다음에 여는 오퍼월에서 개인정보 수집 동의 팝업이 나옵니다 |
| 다른 값으로 호출한 뒤 `setAgreePrivacy(true)` 를 이어서 호출 | 동의한 상태가 됩니다 | 동의 팝업이 나오지 않습니다 (앱에서 직접 동의를 받은 경우에만 사용) |

이미 열려 있는 오퍼월 화면은 바뀌지 않고, 다음에 여는 오퍼월부터 반영됩니다.

<figure><img src="../assets/common/consent-popup.png" alt="개인정보 수집 동의 팝업. 수집정보와 보유기간 안내, 거부와 동의 버튼이 있음" width="300"><figcaption><p>식별값이 바뀌면 다음에 여는 오퍼월에서 동의 팝업이 다시 나옵니다. 오퍼월 화면은 Android·iOS 가 같습니다.</p></figcaption></figure>

직접 동의를 받는 개발사는 앱을 시작할 때마다 `setUserName` → `setAgreePrivacy` 순서로 호출하세요.
직접 동의를 받지 않는 개발사는 `setAgreePrivacy` 를 호출하지 않습니다.
단, 동의를 철회한 사용자에게는 `true` 로 다시 설정하지 마세요. 자세한 내용은 [7. 개인정보 설정](privacy.md)의 '동의 철회' 항목을 참고하세요.

### 계정을 바꿀 때

로그아웃 후 다른 계정으로 로그인하는 경우 새 식별값으로 `setUserName` 을 다시 호출합니다.
적립 가능 포인트 조회([9. 적립 가능 포인트 조회](total-point.md))를 쓰는 앱은 이어서 `clearApiSession()` 도 호출하세요 (SDK 1.0.1 이상).

```swift
// 다른 계정으로 로그인했을 때
sdk.setUserName("새-사용자-식별값")
sdk.clearApiSession()
```

`clearApiSession()` 을 호출하지 않으면 적립 가능 포인트 조회가 이전 사용자 정보로 처리될 수 있습니다.
포인트 조회를 쓰지 않는 앱은 호출하지 않아도 됩니다.

현재 설정된 값은 다음으로 조회합니다. 설정한 적이 없으면 `nil` 입니다.

```swift
sdk.getUserName()   // String?
```

---

## 앱 실행 신호 (`applicationStarted`) — 선택

```swift
sdk.applicationStarted()
```

현재 버전에서는 호출하지 않아도 오퍼월 표시와 보상 지급에 영향이 없습니다. 기존 코드를 옮기는 경우가 아니라면 생략해도 됩니다.

기존 네이티브 SDK(`TnkRwdSdk2`)에서 `TnkSession.sharedInstance()?.applicationStarted()` 를 쓰셨다면,
`TnkPpiHybSdk.shared.applicationStarted()` 로 바꿔 같은 위치에 두셔도 됩니다. `start()` 와 같은 메서드입니다.

---

## 로그 (`enableLogging`)

```swift
#if DEBUG
sdk.enableLogging(true)
#endif
```

| 설정 | Xcode 콘솔에서 보이는 것 | 언제 쓰나 |
|---|---|---|
| `true` | 접두어 `[TnkPpiHyb]` 로 SDK 초기화, 오퍼월 열기, 적립 가능 포인트 조회 결과 같은 연동 확인용 로그가 보입니다 | 개발·테스트 중 |
| `false` (기본값) | `[TnkPpiHyb]` 로그가 출력되지 않습니다 | 출시 빌드 |
| 호출하지 않음 | `false` 와 같습니다 | — |

> ⚠️ 출시 빌드에서는 끄세요. 로그에 사용자 정보가 담긴 값이 포함될 수 있습니다.

---

## ATT 동의 요청

IDFA 를 쓰려면 사용자에게 추적 허용을 물어야 합니다. `sceneDidBecomeActive` 에서 한 번 호출하는 것을 권장합니다.

```swift
final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    private var didRequestATT = false

    func sceneDidBecomeActive(_ scene: UIScene) {
        guard !didRequestATT else { return }
        didRequestATT = true
        TnkPpiHybSdk.shared.requestTrackingAuthorization { granted in
            // granted == true 이면 이후 getAdid() 가 실제 IDFA 를 돌려줍니다
        }
    }
}
```

SDK 는 앱이 활성 상태가 될 때까지 기다렸다가 팝업을 띄웁니다. 그래서 호출 위치 때문에 팝업이 빠지지는 않습니다.
다만 사용자가 앱 화면을 본 뒤에 묻는 것이 자연스러우므로 `sceneDidBecomeActive` 를 권장합니다.
`completion` 은 메인 스레드로 호출됩니다.

| 사용자 응답 | `granted` | 이후 `getAdid()` |
|---|:-:|---|
| 허용 | `true` | 실제 IDFA (하이픈 없는 32자리 소문자) |
| 허용 안 함 · 제한 | `false` | `"00000000000000000000000000000000"` (32자리 0) |
| 이미 응답한 적이 있음 | 이전 응답이 바로 전달됩니다 | 이전 응답에 따름 |
| 기기 설정의 '앱이 추적을 요청하도록 허용'이 꺼져 있음 | `false` (팝업 없이 바로 전달됩니다) | `"00000000000000000000000000000000"` (32자리 0) |

이미 응답한 사용자에게는 팝업이 다시 뜨지 않습니다.

<figure><img src="../assets/ios/att-system-prompt.png" alt="iOS 시스템의 추적 허용 팝업. 앱 이름과 사용 목적 문구, 앱에 추적 금지 요청과 허용 버튼이 있음" width="300"><figcaption><p>앱이 추적 허용을 요청하면 iOS 가 이 팝업을 보여 줍니다. 사용 목적 문구는 Info.plist 의 NSUserTrackingUsageDescription 값입니다.</p></figcaption></figure>

허용하지 않아도 오퍼월은 열립니다.
다만 추적 허용이 필요한 광고에 참여하려 하면 오퍼월이 추적 허용이 필요하다는 안내를 보여 주고 참여를 멈춥니다. 사용자는 이 안내에서 앱 설정 화면으로 바로 이동할 수 있습니다.

<figure><img src="../assets/common/tracking-denied-popup.png" alt="추적 허용이 필요하다는 팝업. 설정에서 추적 허용을 켠 뒤 다시 시도하라는 안내와 취소, 설정으로 이동 버튼" width="300"><figcaption><p>추적 허용을 거부한 사용자가 추적 허용이 필요한 광고에 참여하려 하면 보이는 안내입니다.</p></figcaption></figure>

> ⚠️ ATT 팝업을 쓰려면 `Info.plist` 에 `NSUserTrackingUsageDescription` 문구가 있어야 합니다.
> [2. Info.plist 설정](plist.md)을 먼저 확인하세요.

---

## 광고 식별자 (IDFA)

```swift
sdk.getAdid()   // String
```

| 상황 | 돌려주는 값 |
|---|---|
| ATT 를 허용함 | 하이픈 없는 32자리 소문자 IDFA |
| ATT 전이거나, 허용하지 않음 | `"00000000000000000000000000000000"` (32자리 0) |

오퍼월을 열기 전에 따로 기다릴 필요는 없습니다. 값을 화면에 보여 주거나 개발 빌드에서 확인해야 할 때만 사용하세요. 확인이 끝나면 로그 코드는 지우세요. 출시 빌드에서 광고 식별자·사용자 식별값을 로그로 남기지 마세요.

---

다음: [4. 오퍼월 띄우기](offerwall.md)
