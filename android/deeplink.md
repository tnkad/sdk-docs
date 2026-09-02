---
description: tnkscheme:// 딥링크를 받아 오퍼월의 특정 화면으로 진입시키는 방법. 인텐트 필터 설정과 handleScheme 호출 위치를 안내합니다.
---

# 6. 딥링크

`tnkscheme://` 로 시작하는 딥링크를 받으면 오퍼월의 특정 화면으로 바로 진입시킬 수 있습니다.
푸시 알림이나 외부 배너에서 오퍼월의 특정 카테고리로 보내는 용도로 사용합니다.

딥링크를 쓰지 않는다면 이 페이지는 건너뛰셔도 됩니다.

```
tnkscheme://select_menu?cat_id=3
```

---

## 1. 매니페스트에 인텐트 필터 추가

```xml
<activity
    android:name=".MainActivity"
    android:exported="true"
    android:launchMode="singleTop">

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

> `android:launchMode="singleTop"` 을 지정하세요.
> 앱이 이미 떠 있을 때 새 인스턴스를 만드는 대신 `onNewIntent()` 로 들어옵니다.

---

## 2. 인텐트를 SDK 에 전달

`onCreate()` 와 `onNewIntent()` **양쪽 모두**에서 넘겨야 합니다.
앱이 꺼져 있을 때는 `onCreate()`, 떠 있을 때는 `onNewIntent()` 로 들어옵니다.

```kotlin
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ...
        TnkPpiHybSdk.handleScheme(this, intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        TnkPpiHybSdk.handleScheme(this, intent)
    }
}
```

Java

```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    // ...
    TnkPpiHybSdk.handleScheme(this, getIntent());
}

@Override
protected void onNewIntent(Intent intent) {
    super.onNewIntent(intent);
    setIntent(intent);
    TnkPpiHybSdk.handleScheme(this, intent);
}
```

URL 문자열을 직접 넘길 수도 있습니다.

```kotlin
TnkPpiHybSdk.handleScheme(this, "tnkscheme://select_menu?cat_id=3")
```

---

## 반환값

`handleScheme()` 은 SDK 가 그 인텐트를 **소비했는지**를 `Boolean` 으로 돌려줍니다.

```kotlin
val consumed = TnkPpiHybSdk.handleScheme(this, intent)
if (!consumed) {
    // tnkscheme 딥링크가 아니므로 개발사 앱이 자체 처리
    handleMyOwnDeeplink(intent)
}
```

개발사가 여러 스킴을 함께 쓰는 경우, `false` 일 때만 자체 라우팅으로 넘기면 됩니다.

> 어떤 액션(`select_menu` 등)을 지원하는지는 오퍼월(FE)이 결정합니다.
> 새 액션이 추가되어도 **SDK 를 업데이트할 필요가 없습니다.**
> 사용 가능한 딥링크 목록은 TnkFactory 담당자에게 문의하세요.

---

다음: [7. 개인정보 · 사용자 속성](privacy.md)
