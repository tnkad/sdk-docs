---
description: TnkFactory 하이브리드 오퍼월 SDK(Android) 빠른 시작. 설치, 앱 ID, 초기화, 사용자 식별값, 동의 전달, 오퍼월 열기까지 6단계 최소 연동을 안내합니다.
---

# TnkPpiHyb — 하이브리드 오퍼월 SDK 연동 가이드 (Android)

이 페이지에서 하는 일: 6단계로 Android 앱에 오퍼월을 붙입니다. 마지막 단계까지 마치면 버튼을 눌러 오퍼월을 열 수 있습니다.

오퍼월 화면은 SDK 가 앱 안에 띄우는 웹 화면으로 제공됩니다. 화면 개선이나 개발사별 맞춤 설정(담당자에게 요청)은 TnkFactory 가 적용하며, 앱을 다시 배포하지 않아도 반영됩니다.
Android 와 iOS 는 같은 오퍼월 화면을 사용하므로 사용자가 보는 화면은 같습니다.

---

## 언제 필요한가

Android 앱에 오퍼월을 처음 붙이는 모든 개발사에게 필요합니다(필수).
이미 기존 네이티브 SDK(`com.tnkfactory:rwd`)를 쓰고 있다면 [네이티브 SDK 에서 이관](migration.md)을 먼저 보세요(의존성은 추가가 아니라 교체합니다).

시작하기 전에 [퍼블리셔 페이지](../publisher/app-id.md)에서 앱을 등록하고 아래 두 가지를 발급받아야 합니다.

| 항목 | 설명 |
|------|------|
| **개발사 앱 ID** (`tnkad_app_id`) | 앱마다 발급되는 UUID 형식의 식별자 |
| **앱 키** (`app_key`) | 서버 보상 콜백 검증에 사용. 개발사 백엔드에서만 사용하며 앱에 넣지 않습니다 |

> ⚠️ TNK 는 **패키지명(`applicationId`)으로 앱을 식별**합니다. 퍼블리셔 페이지에 등록한 패키지명과 실제 앱의 `applicationId` 가 다르면 오퍼월이 정상적으로 표시되지 않을 수 있습니다.
> `applicationIdSuffix` 로 `.debug` 등을 붙인 빌드로 테스트하려면, 그 패키지명으로 앱을 하나 더 등록하고 거기서 발급된 APP ID 를 해당 빌드에 넣어 주세요. 설정이 어려우면 담당자에게 문의해 주세요.

## 개발 환경 요약

| 항목 | 값 |
|------|-----|
| 최소 지원 | **Android 5.0 (API 21)** |
| `compileSdk` | **35 이상** |
| 빌드 JDK | **17 이상** |
| Kotlin (Kotlin 으로 개발하는 앱) | SDK 는 **Kotlin 2** 로 빌드됨 — 앱의 Kotlin Gradle 플러그인이 많이 낮으면 빌드 오류가 날 수 있습니다 |
| 배포 형태 | AAR (TnkFactory Maven 저장소) |

자세한 요구사항은 [1. 설치](install.md)를 보세요.

> ⚠️ Android 에뮬레이터·가상 기기에서는 오퍼월이 열리지 않습니다. 동작 확인은 실기기에서 해 주세요.

---

## 빠른 시작

아래 6단계를 순서대로 따라 하면 됩니다. 각 단계 끝의 **안 하면** 은 그 단계를 건너뛰었을 때 생기는 일입니다.

### 1. 저장소와 의존성 추가

SDK 를 내려받을 Maven 저장소와 의존성을 Gradle 에 추가합니다.

`settings.gradle.kts`

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven("https://repository.tnkad.net:8443/repository/public/")
    }
}
```

앱 모듈의 `build.gradle.kts`

```kotlin
dependencies {
    implementation("com.tnkfactory.ad:hrwd:1.0.15")
}
```

**안 하면:** SDK 를 내려받지 못해 `TnkPpiHybSdk` 를 찾을 수 없고, 빌드가 실패합니다.

### 2. 앱 ID 등록

퍼블리셔 페이지에서 발급받은 앱 ID 를 `AndroidManifest.xml` 에 넣습니다.

```xml
<application ...>
    <meta-data
        android:name="tnkad_app_id"
        android:value="발급받은-앱-아이디" />
</application>
```

**안 하면:** TNK 가 어느 앱인지 알 수 없어 오퍼월이 정상적으로 열리지 않을 수 있습니다.
앱 ID 를 코드로 넣는 방법은 [2. AndroidManifest 설정](manifest.md)을 보세요.

### 3. 초기화

앱이 시작될 때 로그 설정과 앱 실행 신호를 호출합니다.
`Application.onCreate()` 나 첫 화면의 `onCreate()` 어디에 두어도 됩니다.

```kotlin
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk

TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG)   // 디버그 빌드에서만 SDK 로그 출력
TnkPpiHybSdk.start(applicationContext)          // (선택) 앱 실행 신호
```

> 💡 `BuildConfig` 를 찾을 수 없다는 오류가 나면 앱 모듈 `build.gradle(.kts)` 의 `android { buildFeatures { buildConfig = true } }` 를 켜거나, 디버그 여부를 판단하는 기존 방식을 그대로 쓰세요.

`init()` 은 직접 호출하지 않아도 됩니다. `setUserName()`, `openOfferwall()` 같은 SDK 함수를 처음 호출할 때 자동으로 초기화됩니다.
`start()` 는 현재 SDK 에서는 호출하지 않아도 오퍼월 동작이 달라지지 않습니다. iOS 와 같은 코드 구성을 유지하려고 두어도 됩니다.

**안 하면:** 건너뛰어도 오퍼월은 열립니다. 로그를 켜지 않으면 Logcat 의 `TnkPpiHyb` 태그 로그가 나오지 않습니다.

### 4. 사용자 식별값 설정

개발사 서비스의 회원 ID 처럼 사용자를 고유하게 구분하는 값을 넘깁니다. 이 값이 **보상 지급의 기준**입니다.

```kotlin
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
```

사용자 식별값을 이전과 다른 값으로 바꾸면(계정 전환, 최초 설정 포함) 개인정보 수집 동의가 초기화되어, 오퍼월을 열 때 동의 팝업이 다시 나옵니다. 앱에서 동의를 받는 경우에는 이어서 5단계의 `setAgreePrivacy` 를 호출하세요.
같은 값을 다시 설정하면 동의 상태는 그대로 유지됩니다.

**안 하면:** 보상을 받을 사용자를 구분할 수 없습니다. 반드시 설정해 주세요.

### 5. (선택) 앱에서 받은 개인정보 수집 동의 전달

앱에서 이미 개인정보 수집 동의를 받았다면, **`setUserName` 다음에** 동의 상태를 넘깁니다.

```kotlin
TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")
TnkPpiHybSdk.setAgreePrivacy(applicationContext, true)   // 사용자가 앱에서 동의한 경우에만
```

| 호출 | 오퍼월을 열 때 사용자가 보는 것 | 언제 쓰나 |
|------|------|------|
| `setAgreePrivacy(…, true)` | 동의 팝업 없이 오퍼월이 바로 열립니다. 오퍼월 도움말에는 '개인 정보 수집 동의 해제' 링크가 나오지 않습니다 | 앱에서 개인정보 수집 동의를 직접 받은 경우 |
| `setAgreePrivacy(…, false)` | 다음에 열 때 동의 팝업이 나옵니다(오퍼월 안에서 동의한 적이 있어도 다시 묻습니다). 이미 열려 있는 오퍼월은 바뀌지 않습니다 | 동의 철회에는 쓰지 마세요. 철회는 `revokePrivacyConsent` 를 사용합니다 |
| 호출하지 않음 | 처음 열 때 동의 팝업이 먼저 나옵니다. 동의하면 다음부터는 나오지 않고, 거부하면 안내 화면이 나옵니다(다음에 들어갈 때 다시 묻습니다) | 앱에서 동의를 받지 않는 경우(기본) |

<figure><img src="../assets/common/compare-consent-not-agreed-vs-agreed.png" alt="왼쪽은 동의 팝업이 보이는 오퍼월, 오른쪽은 팝업 없이 바로 목록이 보이는 오퍼월" width="600"><figcaption><p>왼쪽은 동의 전달을 하지 않았을 때, 오른쪽은 setAgreePrivacy(…, true) 로 전달했을 때의 첫 화면입니다. 오퍼월 화면은 Android·iOS 가 같습니다.</p></figcaption></figure>

**안 하면:** 오류가 아닙니다. 사용자가 오퍼월 안의 동의 팝업에서 직접 동의합니다.

> ⚠️ 앱에서 동의를 받은 경우 오퍼월 안에는 동의 해제 메뉴가 나오지 않으므로, 동의를 해제하는 수단은 앱에서 제공해 주세요.
> 앱에서 동의를 철회한 사용자에게는 `true` 를 다시 넘기지 마세요. 철회가 취소됩니다.
> 자세한 내용과 나머지 값은 [7. 개인정보 설정](privacy.md)을 보세요.

### 6. 오퍼월 열기

버튼 클릭 등 사용자가 오퍼월을 열 때 호출합니다. 오퍼월이 전체 화면으로 열립니다.

```kotlin
findViewById<Button>(R.id.offerwallButton).setOnClickListener {
    TnkPpiHybSdk.openOfferwall(this)
}
```

<figure><img src="../assets/android/offerwall-fullscreen.png" alt="Android 기기 전체 화면에 열린 오퍼월. 위에 상태 바, 오퍼월 헤더와 탭, 검색창이 있고 아래는 내비게이션 바" width="300"><figcaption><p>오퍼월은 기기 화면 전체를 사용하는 전체 화면으로 열립니다. 화면 배치를 보여 주는 예시이며 광고 목록은 비어 있습니다.</p></figcaption></figure>

**안 하면:** 이 호출이 있어야 오퍼월이 열립니다. 열리지 않으면 [문제 해결](troubleshooting.md)을 확인하세요.

> ⚠️ 포인트 지급은 앱이 아니라 **서버 보상 콜백**으로 처리합니다. 앱의 `setRewardListener` 는 화면 갱신용입니다(사용법은 [5. 보상 지급 수신](reward.md)). → [서버 보상 콜백 URL](../common/server-callback.md)

여기까지가 최소 연동입니다. 별도의 권한 선언이나 Activity 등록은 필요하지 않습니다. SDK 가 자동으로 추가합니다 — [2. AndroidManifest 설정](manifest.md)을 참고하세요.

### 전체 코드

위 단계를 한 화면에 모으면 다음과 같습니다.

```kotlin
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        // 3. 초기화
        TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG)
        TnkPpiHybSdk.start(applicationContext)

        // 4. 사용자 식별값 (보상 지급의 기준)
        TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")

        // 5. (선택) 앱에서 동의를 받은 경우에만
        // TnkPpiHybSdk.setAgreePrivacy(applicationContext, true)

        // 6. 오퍼월 열기
        findViewById<Button>(R.id.offerwallButton).setOnClickListener {
            TnkPpiHybSdk.openOfferwall(this)
        }
    }
}
```

---

## 다음 단계

| 문서 | 내용 |
|------|------|
| [1. 설치](install.md) | Gradle 설정, 빌드 요구사항, 난독화(ProGuard) |
| [2. AndroidManifest 설정](manifest.md) | 개발사가 선언할 것 / SDK 가 자동으로 추가하는 것 |
| [3. 초기화](initialize.md) | 초기화 시점, 사용자 식별값, 광고 ID |
| [4. 오퍼월 띄우기](offerwall.md) | 전체 화면으로 열기 / 화면 안에 넣기 |
| [5. 보상 지급 수신](reward.md) | `TnkRewardListener` 와 `RewardInfo` |
| [6. 딥링크](deeplink.md) | `tnkscheme://` 처리 |
| [7. 개인정보 설정](privacy.md) | 수집 동의, COPPA/GDPR |
| [8. 특정 광고 진입](ad-entry.md) | 배너·푸시에서 특정 광고로 바로 진입 |
| [9. 적립 가능 포인트 조회](total-point.md) | "최대 N포인트 적립 가능" 표시용 |
| [공개 API 목록](api.md) | 전체 시그니처 |
| [네이티브 SDK 에서 이관](migration.md) | 기존 네이티브 SDK(`com.tnkfactory:rwd`)를 사용 중이라면 |
| [서버 보상 콜백 URL](../common/server-callback.md) | **실제 포인트 지급 경로** (개발사 백엔드) |
| [지원 범위](../common/support-matrix.md) | 제공 기능 한눈에 보기 |
| [문제 해결](troubleshooting.md) | 자주 겪는 증상과 원인 |
| [릴리스 노트](changelog.md) | 버전별 변경 사항 |

---

문의: tech@tnkfactory.com
