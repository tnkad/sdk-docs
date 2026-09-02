---
description: TnkFactory 하이브리드 오퍼월 SDK(Android) 연동 가이드. Gradle 설정부터 오퍼월 노출과 보상 지급까지, 최소 연동에 필요한 모든 절차를 안내합니다.
---

# TnkPpiHyb — 하이브리드 오퍼월 SDK 연동 가이드 (Android)

TnkFactory 하이브리드 오퍼월 SDK 입니다. 네이티브는 기기 컨텍스트 수집과 WebView 호스팅,
JS 브릿지를 담당하고 **오퍼월 화면과 보상 로직은 WebView 안의 웹(FE)이 처리**합니다.
그래서 오퍼월 UI 개선이나 개발사별 커스터마이징은 **앱 업데이트 없이** 반영됩니다.

- 최소 지원: **Android 5.0 (API 21)**
- `compileSdk` **36 이상**, Java/Kotlin jvmTarget **17**
- 배포 형태: AAR (TnkFactory Maven 저장소)

---

## 연동에 필요한 것

시작하기 전에 TnkFactory 담당자로부터 아래 두 가지를 받으셔야 합니다.

| 항목 | 설명 |
|------|------|
| **개발사 앱 ID** (`tnkad_app_id`) | 앱마다 발급되는 UUID 형식의 식별자 |
| **앱 키** (`app_key`) | 서버 보상 콜백 검증에 사용. 개발사 백엔드에서만 사용하며 앱에 넣지 않습니다 |

> ⚠️ TNK 어드민은 **패키지명(`applicationId`)으로 앱을 식별**합니다.
> 등록한 패키지명과 실제 앱의 `applicationId` 가 다르면 세션이 생성되지 않습니다.
> `applicationIdSuffix` 로 `.debug` 등을 붙인 빌드도 마찬가지이니 주의하세요.

---

## 빠른 시작

### 1. 저장소와 의존성 추가

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
    implementation("com.tnkfactory.ad:hrwd:1.0.6")
}
```

### 2. 앱 ID 등록

`AndroidManifest.xml`

```xml
<application ...>
    <meta-data
        android:name="tnkad_app_id"
        android:value="발급받은-앱-아이디" />
</application>
```

### 3. 초기화하고 오퍼월 띄우기

```kotlin
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)

        TnkPpiHybSdk.enableLogging(BuildConfig.DEBUG)

        // 개발사 사용자 식별값. 보상 지급의 기준이 되므로 반드시 설정합니다.
        TnkPpiHybSdk.setUserName(applicationContext, "개발사-사용자-식별값")

        // (선택) 앱 실행 신호 — 실행 카운트 / Install Referrer 수집
        TnkPpiHybSdk.start(applicationContext)

        // 보상 지급 완료 알림 (UI 갱신용)
        TnkPpiHybSdk.setRewardListener { reward ->
            Toast.makeText(
                this,
                "${reward.payPoint}${reward.pointUnit ?: ""} 적립",
                Toast.LENGTH_SHORT,
            ).show()
        }

        findViewById<Button>(R.id.offerwallButton).setOnClickListener {
            TnkPpiHybSdk.openOfferwall(this)
        }
    }
}
```

여기까지가 최소 연동입니다. 별도의 권한 선언이나 Activity 등록은 필요하지 않습니다
(SDK 가 자동으로 병합합니다 — [2. AndroidManifest 설정](manifest.md) 참고).

---

## 다음 단계

| 문서 | 내용 |
|------|------|
| [1. 설치](install.md) | Gradle 설정, 빌드 요구사항, ProGuard |
| [2. AndroidManifest 설정](manifest.md) | 개발사가 선언할 것 / SDK 가 자동 병합하는 것 |
| [3. 초기화](initialize.md) | 초기화 시점, 사용자 식별값, 광고 ID |
| [4. 오퍼월 띄우기](offerwall.md) | 전체화면 진입 / 화면 안에 삽입 |
| [5. 보상 지급 수신](reward.md) | `TnkRewardListener` 와 `RewardInfo` |
| [서버 보상 콜백 URL](../common/server-callback.md) | **실제 포인트 지급 경로** (개발사 백엔드) |
| [6. 딥링크](deeplink.md) | `tnkscheme://` 처리 |
| [7. 개인정보 · 사용자 속성](privacy.md) | 동의, COPPA/GDPR, 연령/성별 |
| [공개 API 목록](api.md) | 전체 시그니처 |
| [네이티브 SDK 에서 이관](migration.md) | `com.tnkfactory:rwd` 를 사용 중이라면 |
| [지원 범위](../common/support-matrix.md) | 제공 / 미제공 기능 |
| [문제 해결](troubleshooting.md) | 자주 겪는 증상과 원인 |

---

문의: tech@tnkfactory.com
