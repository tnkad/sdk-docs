---
description: 매니페스트에 넣을 tnkad_app_id 와 딥링크 인텐트 필터, 앱 ID 를 코드로 넣을 때의 호출 순서, SDK 가 자동으로 추가하는 권한·Activity, Google Play 제출 때 확인할 항목을 안내합니다.
---

# 2. AndroidManifest 설정

이 페이지에서 하는 일: 매니페스트에 **앱 ID**(필수)와 **딥링크 인텐트 필터**(선택)를 넣고, SDK 가 자동으로 추가하는 항목을 확인합니다.

---

## 언제 필요한가

- **앱 ID** — 모든 Android 개발사에게 필요합니다(필수).
- **딥링크 인텐트 필터** — `tnkscheme://` 링크를 앱 밖(웹 페이지 등)에서 받을 때만 필요합니다(선택).
- **`AdWallActivity` 선언 제거** — 기존 네이티브 SDK(`com.tnkfactory:rwd`)를 쓰던 개발사에게만 해당합니다.

---

## 개발사가 선언하는 것

### 개발사 앱 ID (필수)

`<application>` 태그 **안에** 넣습니다.

```xml
<application ...>

    <meta-data
        android:name="tnkad_app_id"
        android:value="발급받은-앱-아이디" />

</application>
```

하이픈(`-`)이 포함된 형태 그대로 넣으셔도 됩니다. SDK 가 하이픈을 제거해서 사용합니다.

**안 하면:** (아래 '코드로 넣기'도 쓰지 않는다면) 앱 ID 가 없어 TNK 가 어느 앱인지 알 수 없고, 오퍼월이 정상적으로 열리지 않을 수 있습니다.

### 앱 ID 를 코드로 넣기 (선택)

서버 설정 등으로 앱 ID 를 실행 중에 정해야 하는 경우에만 사용하세요. 매니페스트 값은 그대로 두어도 됩니다.
`Application.onCreate()` 에서 **다른 `TnkPpiHybSdk` 함수보다 먼저** 호출합니다.

```kotlin
class MyApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        TnkPpiHybSdk.init(this, "발급받은-앱-아이디")
    }
}
```

`MyApplication` 은 매니페스트 `<application android:name=".MyApplication" ...>` 에 등록해야 합니다.

`init()` 은 **처음 한 번만** 적용됩니다. `setUserName()`, `start()`, `openOfferwall()` 같은 SDK 함수는 처음 호출될 때 SDK 를 자동으로 초기화하므로, 그 뒤에 부른 `init(context, "앱ID")` 의 값은 무시됩니다.

| 상황 | 적용되는 앱 ID |
|------|------|
| `init(context, "앱ID")` 를 다른 SDK 함수보다 먼저 호출 | 코드로 넘긴 값 (매니페스트 값보다 우선) |
| `setUserName()`·`start()`·`openOfferwall()` 같은 SDK 함수를 먼저 호출한 뒤 `init(context, "앱ID")` 호출 | 매니페스트의 값. 매니페스트에도 없으면 앱 ID 없음 — 나중에 넘긴 값은 무시됩니다 |
| 매니페스트만 설정하고 `init` 은 호출하지 않음 | 매니페스트의 값 |
| 매니페스트에도 없고 `init(context, "앱ID")` 도 호출하지 않음 | 앱 ID 없음 — 오퍼월이 정상적으로 열리지 않을 수 있습니다 |
| `init(context, "")` 처럼 빈 값을 넘김 | 넘기지 않은 것과 같아서 매니페스트의 값을 씁니다 |

> 💡 `enableLogging()` 은 SDK 를 초기화하지 않으므로 `init` 보다 먼저 호출해도 됩니다.
> 적용된 앱 ID 는 `TnkPpiHybSdk.getAppId(context)` 로 확인할 수 있습니다(하이픈이 빠진 형태).

### 딥링크 (선택)

`tnkscheme://` 링크를 앱 밖(웹 페이지 등)에서 받을 때만 필요합니다. 자세한 내용은 [6. 딥링크](deeplink.md)를 참고하세요.

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

> 💡 앱 안(푸시·배너 등)에서 SDK 로 직접 넘길 때는 `TnkPpiHybSdk.handleScheme(context, "tnkscheme://...")` 에 문자열을 그대로 전달하면 되므로 인텐트 필터가 필요 없습니다.
> `tnkscheme` 는 TNK 오퍼월을 붙인 앱이 함께 쓰는 이름입니다. 같은 스킴을 등록한 앱이 한 기기에 여러 개 있으면 Android 가 앱 선택 창을 띄울 수 있습니다.

---

## SDK 가 자동으로 추가하는 것 — 따로 선언하지 않아도 됩니다

아래 항목은 SDK 의 매니페스트에 이미 들어 있어서 빌드할 때 자동으로 합쳐집니다.
앱에 `INTERNET` 같은 권한이 이미 선언돼 있어도 문제없습니다.

| 종류 | 내용 | 용도 |
|------|------|------|
| 권한 | `android.permission.INTERNET` | 네트워크 통신 |
| 권한 | `android.permission.ACCESS_NETWORK_STATE` | 네트워크 상태 확인 |
| 권한 | `com.google.android.gms.permission.AD_ID` | 광고 ID 조회 (`targetSdk` 33 이상 앱에 필요) |
| `<queries>` | `ACTION_MAIN` / `CATEGORY_LAUNCHER` | 광고 앱 설치 여부 확인 (Android 11+ 패키지 가시성) |
| Activity | `com.tnkfactory.ad.hrwd.webview.TnkOfferwallActivity` | 전체 화면으로 여는 오퍼월 화면 |
| activity-alias | `com.tnkfactory.ad.AdWallActivity` | 기존 네이티브 SDK 에서 쓰던 화면 이름을 받아 주는 연결 항목 |

> ⚠️ 위 Activity 를 앱 매니페스트에서 같은 이름으로 **다른 속성값**으로 다시 선언하지 마세요. 속성값이 서로 다르면 병합 충돌로 빌드가 실패할 수 있습니다.

> ✅ **`QUERY_ALL_PACKAGES` 는 사용하지 않습니다.**
> 설치앱 확인은 `<queries>` 의 런처 인텐트 가시성만으로 처리하므로 Google Play 의 민감 권한 심사 대상이 아닙니다.

> ⚠️ **기존 네이티브 SDK 를 사용 중인 개발사는** 매니페스트에 직접 선언해 둔
> `<activity android:name="com.tnkfactory.ad.AdWallActivity" ... />` 를 **제거해 주세요.**
> 해당 화면은 이제 SDK 가 자동으로 연결하므로, 기존 선언이 남아 있으면 빌드 오류나 화면 충돌이 생길 수 있습니다.
> 자세한 내용은 [네이티브 SDK 에서 이관](migration.md)을 참고하세요.

### Google Play 에 앱을 제출할 때

SDK 가 `AD_ID` 권한을 포함하므로, Play Console 에서 다음을 확인해 주세요.

- **앱 콘텐츠 → 광고 ID** 에서 '앱이 광고 ID 를 사용함'을 선택합니다.
- **데이터 보안** 양식에는 기기 또는 기타 ID(광고 ID)와 사용자 ID(`setUserName` 으로 넘긴 값)를 사용한다는 내용을 반영합니다.
- 매니페스트에서 `AD_ID` 권한을 `tools:node="remove"` 로 지우지 마세요. 지우면 광고 ID 를 읽을 수 없어 0 으로만 채워지고, 광고 ID 로 기기를 구분하는 [테스트 기기 등록](../publisher/test-device.md)도 적용되지 않습니다.

최종 답변은 개발사의 개인정보 처리방침과 내부 검토 기준에 맞게 작성해 주세요.

---

## 전체 예시

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <application
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.MyApp">

        <meta-data
            android:name="tnkad_app_id"
            android:value="발급받은-앱-아이디" />

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

    </application>

</manifest>
```

---

다음: [3. 초기화](initialize.md)
