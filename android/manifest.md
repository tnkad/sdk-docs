---
description: 개발사가 선언할 tnkad_app_id 와 딥링크 인텐트 필터, 그리고 SDK 가 자동 병합하므로 선언하면 안 되는 권한·Activity 목록입니다.
---

# 2. AndroidManifest 설정

## 개발사가 선언하는 것

### 개발사 앱 ID (필수)

```xml
<application ...>

    <meta-data
        android:name="tnkad_app_id"
        android:value="발급받은-앱-아이디" />

</application>
```

하이픈(`-`)이 포함된 형태 그대로 넣으셔도 됩니다. SDK 가 내부에서 제거합니다.

> 매니페스트 대신 코드로 넣을 수도 있습니다.
> 서버 설정 등으로 앱 ID 를 런타임에 주입해야 하는 경우에 사용하세요.
> ```kotlin
> TnkPpiHybSdk.init(context, "발급받은-앱-아이디")
> ```
> 우선순위는 **`init()` 인자 → 이전에 저장된 값 → 매니페스트 `tnkad_app_id`** 순입니다.

### 딥링크 (선택)

`tnkscheme://` 딥링크를 받을 경우에만 필요합니다.
자세한 내용은 [6. 딥링크](deeplink.md)를 참고하세요.

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

---

## SDK 가 자동 병합하는 것 — 개발사는 선언하지 마세요

아래 항목은 SDK 의 매니페스트에 이미 들어 있고 빌드 시 자동으로 병합됩니다.
**개발사 매니페스트에 중복 선언하면 머지 충돌이 발생할 수 있습니다.**

| 종류 | 내용 | 용도 |
|------|------|------|
| 권한 | `android.permission.INTERNET` | 네트워크 통신 |
| 권한 | `android.permission.ACCESS_NETWORK_STATE` | 네트워크 상태 확인 |
| 권한 | `com.google.android.gms.permission.AD_ID` | 광고 ID 조회 (Android 13+) |
| `<queries>` | `ACTION_MAIN` / `CATEGORY_LAUNCHER` | 광고 앱 설치 여부 감지 (Android 11+) |
| Activity | `com.tnkfactory.ad.hrwd.webview.TnkOfferwallActivity` | 전체화면 오퍼월 |
| activity-alias | `com.tnkfactory.ad.AdWallActivity` | 네이티브 SDK 호환 라우팅 |

> ✅ **`QUERY_ALL_PACKAGES` 는 사용하지 않습니다.**
> 설치앱 감지는 `<queries>` 의 런처 인텐트 가시성만으로 처리하므로
> Google Play 의 민감 권한 심사 대상이 아닙니다.

> ⚠️ **네이티브 SDK 를 사용 중인 개발사는** 기존 매니페스트에 직접 선언해 둔
> `<activity android:name="com.tnkfactory.ad.AdWallActivity" ... />` 를 **반드시 제거**하세요.
> SDK 가 병합하는 activity-alias 와 충돌해 빌드가 실패합니다.
> 자세한 내용은 [네이티브 SDK 에서 이관](migration.md)을 참고하세요.

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

    </application>

</manifest>
```

---

다음: [3. 초기화](initialize.md)
