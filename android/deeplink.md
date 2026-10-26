---
description: tnkscheme:// 딥링크를 받아 오퍼월의 특정 카테고리로 보내는 방법. 인텐트 필터 설정, handleScheme 호출 위치, 반환값 처리를 안내합니다.
---

# 6. 딥링크

푸시 알림이나 외부 배너에서 `tnkscheme://` 로 시작하는 링크를 받으면, 오퍼월의 특정 카테고리로 바로 보내는 방법입니다.

선택 기능입니다. 딥링크를 쓰지 않는다면 이 페이지는 건너뛰셔도 됩니다.

```
tnkscheme://select_menu?cat_id=3
```

---

## 지원하는 딥링크

| 링크 | 사용자가 보는 것 |
|---|---|
| `tnkscheme://select_menu?cat_id={카테고리 ID}` | 오퍼월이 열리고 해당 카테고리 탭이 선택됩니다. |
| `tnkscheme://select_menu?cat_id={카테고리 ID}&filter_id={필터 ID}` | 해당 카테고리 탭에서 그 필터까지 선택됩니다. 필터가 그 탭에 없으면 '전체'가 선택됩니다. |

<figure><img src="../assets/common/tab-selected-game.png" alt="게임 탭이 선택된 오퍼월 화면. 게임 탭에 밑줄이 있고 아래에 필터 칩과 광고 목록이 보임" width="300"><figcaption><p>딥링크를 받으면 오퍼월이 열리고 지정한 탭(여기서는 게임)이 선택됩니다. 오퍼월 화면은 Android·iOS 가 같습니다.</p></figcaption></figure>

카테고리·필터 ID 와 그 밖에 사용할 수 있는 딥링크 목록은 TnkFactory 담당자에게 문의하세요. 오퍼월의 화면 구성에 따라 이동하지 않을 수 있으며, 이때는 오퍼월 첫 화면이 열립니다. 새로운 딥링크가 추가되어도 **SDK 를 업데이트할 필요가 없습니다.**

---

## 1. 매니페스트에 인텐트 필터 추가

```xml
<activity
    android:name=".MainActivity"
    android:exported="true">

    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>

    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="tnkscheme" />
    </intent-filter>

</activity>
```

> 💡 `launchMode` 는 앱의 기존 설정을 그대로 두셔도 됩니다. SDK 때문에 바꿀 필요는 없습니다.

> ⚠️ `tnkscheme` 는 TNK 오퍼월을 붙인 여러 앱이 함께 쓰는 스킴입니다. 같은 기기에 그런 앱이 여러 개 있으면 Android 가 앱 선택 창을 띄울 수 있습니다. 앱 밖에서 보내는 링크는 앱 고유 스킴이나 앱 링크로 받은 뒤, 앱 안에서 `handleScheme(this, "tnkscheme://select_menu?cat_id=3")` 처럼 문자열로 넘기는 방식을 권장합니다.

---

## 2. 인텐트를 SDK 에 전달

딥링크 인텐트는 `onCreate()` 와 `onNewIntent()` **양쪽 모두**에서 넘겨야 합니다. 앱이 처음 실행되거나 새 화면으로 열리면 `onCreate()`, 이미 맨 위에 떠 있는 화면으로 들어오면 `onNewIntent()` 로 들어옵니다. 어느 쪽으로 올지는 앱 설정과 화면 상태에 따라 다르므로 양쪽에서 모두 호출하세요.

```kotlin
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ... SDK 설정(setUserName 등)을 먼저 마친 뒤
        if (savedInstanceState == null) {   // 화면 회전 등으로 다시 만들어질 때 중복 처리 방지
            handleDeeplink(intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleDeeplink(intent)
    }

    private fun handleDeeplink(intent: Intent?) {
        // tnkscheme 딥링크가 아니면 false 가 돌아오므로 앱이 직접 처리합니다.
        if (!TnkPpiHybSdk.handleScheme(this, intent)) {
            handleMyOwnDeeplink(intent)   // 개발사 코드
        }
    }
}
```

Java

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    // ... SDK 설정(setUserName 등)을 먼저 마친 뒤
    if (savedInstanceState == null) {   // 화면 회전 등으로 다시 만들어질 때 중복 처리 방지
        handleDeeplink(getIntent());
    }
}

@Override
protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
    handleDeeplink(intent);
}

private void handleDeeplink(Intent intent) {
    // tnkscheme 딥링크가 아니면 false 가 돌아오므로 앱이 직접 처리합니다.
    if (!TnkPpiHybSdk.handleScheme(this, intent)) {
        handleMyOwnDeeplink(intent);   // 개발사 코드
    }
}
```

> ⚠️ `onCreate()` 에서는 `savedInstanceState == null` 일 때만 호출하세요. 조건 없이 호출하면 딥링크로 들어온 뒤 화면 회전·다크 모드 전환 등으로 화면이 다시 만들어질 때 같은 딥링크가 한 번 더 처리되어, 오퍼월을 닫은 뒤에도 오퍼월이 다시 열릴 수 있습니다.

이전 가이드대로 `onCreate()` 에서 조건 없이 호출하고 있다면 아래처럼 바꾸세요.

```diff
 override fun onCreate(savedInstanceState: Bundle?) {
     super.onCreate(savedInstanceState)
-    TnkPpiHybSdk.handleScheme(this, intent)
+    if (savedInstanceState == null) {
+        TnkPpiHybSdk.handleScheme(this, intent)
+    }
 }
```

URL 문자열을 직접 넘길 수도 있습니다. 푸시 데이터에서 링크를 문자열로 받는 경우에 씁니다.

```kotlin
TnkPpiHybSdk.handleScheme(this, "tnkscheme://select_menu?cat_id=3")
```

로그인 뒤에야 사용자 식별값을 알 수 있는 앱은 로그인 전에 받은 링크를 보관해 두세요. `setUserName` 을 호출한 다음에 `handleScheme` 에 넘기면 됩니다. 식별값 없이 연 오퍼월에서 생긴 보상은 올바른 사용자에게 지급되지 않을 수 있습니다([3. 초기화](initialize.md)).

---

## 동작 방식

딥링크를 받았을 때 오퍼월의 상태에 따라 사용자가 보는 것이 달라집니다.

| 딥링크를 받은 때 | 사용자가 보는 것 |
|---|---|
| 오퍼월이 열려 있지 않음 | 전체 화면 오퍼월이 열리고 해당 화면으로 이동합니다. 딥링크로 앱을 처음 실행해도 같습니다. |
| 전체 화면 오퍼월이 열려 있음 | 그 오퍼월에서 바로 해당 화면으로 이동합니다. |
| 앱 화면 안에 넣은 오퍼월(`TnkOfferwallView`)을 로드해 둠 | 새로 열지 않고 그 오퍼월에서 이동합니다. 오퍼월이 숨겨진 탭 안에 있으면 사용자 눈에 보이지 않습니다. |

> ⚠️ 앱 화면 안에 넣은 오퍼월을 탭에 두었다면, `handleScheme()` 을 부르기 **전에 오퍼월 탭으로 전환**하고 그 화면의 오퍼월을 불러(`loadOfferwall()`) 두세요. 탭의 오퍼월을 아직 불러오지 않은 상태에서 부르면 SDK 가 전체 화면 오퍼월을 따로 열어, 탭의 오퍼월과 전체 화면 오퍼월이 함께 생길 수 있습니다. 탭 전환은 SDK 가 하지 않으므로 앱에서 처리해야 합니다.

---

## 반환값

`handleScheme()` 은 SDK 가 그 딥링크를 **받아 처리했는지**를 `Boolean` 으로 돌려줍니다.

| 반환값 | 의미 | 개발사가 할 일 |
|---|---|---|
| `true` | `tnkscheme://` 딥링크로 받아들여 오퍼월을 열었거나 열려 있는 오퍼월로 보냈습니다. | 아무것도 하지 않습니다. 오퍼월이 탭 안에 있다면 `handleScheme()` 을 부르기 전에 오퍼월 탭으로 전환해 둡니다. |
| `false` | `tnkscheme://` 딥링크가 아니거나 명령이 없어 SDK 는 아무것도 하지 않았습니다. | 앱이 자체 딥링크로 처리합니다. |

개발사가 여러 스킴을 함께 쓰는 경우, `false` 일 때만 자체 라우팅으로 넘기면 됩니다.

> `true` 는 딥링크를 받아들였다는 뜻이며, 해당 화면이 열렸다는 보장은 아닙니다. 어느 오퍼월에서 이동했는지도 알려 주지 않습니다. 지원하지 않는 링크이거나 대상 카테고리가 없으면 오퍼월이 열리기만 하고 화면은 이동하지 않습니다.

---

## 테스트

USB 로 연결한 **실제 기기**에서 확인하세요. 에뮬레이터에서는 오퍼월이 열리지 않습니다.

```bash
adb shell am start -a android.intent.action.VIEW -d "tnkscheme://select_menu?cat_id=3"
```

---

다음: [7. 개인정보 설정](privacy.md)
