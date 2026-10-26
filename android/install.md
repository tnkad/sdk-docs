---
description: TnkFactory Maven 저장소를 등록하고 Gradle 의존성을 추가하는 방법. 확인된 빌드 요구사항(minSdk 21, compileSdk 35 이상, 빌드 JDK 17 이상)과 난독화(R8/ProGuard) 설정, 설치 확인 방법을 안내합니다.
---

# 1. 설치

이 페이지에서 하는 일: TnkFactory Maven 저장소와 SDK 의존성을 Gradle 에 추가하고, 설치가 됐는지 확인합니다.

---

## 언제 필요한가

Android 앱에 SDK 를 붙이는 모든 개발사에게 필요합니다(필수). 별도의 인증이나 계정은 필요하지 않습니다.
이미 SDK 를 설치했다면 [2. AndroidManifest 설정](manifest.md)으로 넘어가세요.

---

## 빌드 요구사항

| 항목 | 값 | 맞지 않으면 |
|------|-----|-----------|
| `minSdk` | **21** 이상 | 앱의 `minSdk` 가 21 보다 낮으면 빌드가 중단됩니다 |
| `compileSdk` | **35** 이상 | 빌드가 중단됩니다. 앱의 `compileSdk` 를 올려 주세요 |
| 빌드 JDK | **17** 이상 | Gradle 이 JDK 11 이하로 실행되면 SDK 를 읽지 못해 빌드가 실패할 수 있습니다 |
| Kotlin (Kotlin 으로 개발하는 앱) | SDK 는 **Kotlin 2** 로 빌드됨 | 앱의 Kotlin Gradle 플러그인이 많이 낮으면 빌드 오류가 날 수 있습니다. 플러그인을 올려 주세요 |
| AndroidX | 사용 (`android.useAndroidX=true`) | SDK 가 AndroidX 라이브러리를 사용하므로, 사용하지 않으면 빌드 오류가 날 수 있습니다 |
| `targetSdk` | 제한 없음 | Google Play 의 대상 API 요구사항을 따르세요 |

> 💡 SDK 는 Java 17 로 컴파일되어 있습니다. Android Gradle 플러그인 8.x 는 JDK 17 이상을 요구하므로 대부분의 프로젝트는 이미 조건을 만족합니다.
> 앱 모듈의 Java 툴체인을 11 이하로 고정해 두었다면 17 이상으로 올려 주세요.

> 💡 기기의 **Android System WebView** 가 오래된 경우, 오퍼월은 열려도 닫기·보상 알림처럼 앱과 연결되는 기능이 동작하지 않을 수 있습니다. 기기의 WebView 를 최신으로 업데이트해 주세요.

---

## 저장소 등록

TnkFactory Maven 저장소를 추가합니다. 별도 인증은 필요하지 않습니다.

### Kotlin DSL — `settings.gradle.kts`

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven("https://repository.tnkad.net:8443/repository/public/")
    }
}
```

### Groovy — `settings.gradle`

```groovy
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
        maven { url "https://repository.tnkad.net:8443/repository/public/" }
    }
}
```

> 💡 `settings.gradle(.kts)` 에 `repositoriesMode` 를 이미 지정해 두었다면 그대로 두고 `maven(...)` 한 줄만 추가하세요.
> `FAIL_ON_PROJECT_REPOS` 를 쓰는 프로젝트는 저장소를 모듈의 `build.gradle` 이 아니라 `settings.gradle(.kts)` 에 넣어야 합니다.
> 프로젝트가 아직 `allprojects { repositories { ... } }` (구형 구조)를 쓰고 있다면 그쪽에 `maven { url "..." }` 한 줄을 추가하셔도 동일하게 동작합니다.

---

## 의존성 추가

앱 모듈의 `build.gradle.kts`

```kotlin
dependencies {
    implementation("com.tnkfactory.ad:hrwd:1.0.15")
}
```

Groovy — `build.gradle`

```groovy
dependencies {
    implementation 'com.tnkfactory.ad:hrwd:1.0.15'
}
```

이 가이드는 최신 SDK 기준입니다. 버전별 변경 사항은 [릴리스 노트](changelog.md)에서 확인하세요.

### 함께 따라오는 라이브러리

아래는 SDK 가 함께 가져오므로 **개발사가 직접 선언할 필요가 없습니다.**
앱이 같은 라이브러리를 더 높은 버전으로 쓰고 있다면 Gradle 이 높은 버전을 선택합니다.
함께 들어오는 라이브러리의 정확한 버전은 `./gradlew :app:dependencies` 로 확인할 수 있습니다. 명령은 아래 '설치 확인'을 보세요.

| 라이브러리 | 용도 |
|-----------|------|
| `androidx.core:core-ktx` | AndroidX 기본 |
| `androidx.appcompat:appcompat` | AndroidX 기본 |
| `androidx.activity:activity-ktx` | AndroidX 기본 |
| `androidx.lifecycle:lifecycle-runtime-ktx` | AndroidX 기본 |
| `androidx.annotation:annotation` | AndroidX 기본 |
| `androidx.webkit:webkit` | 오퍼월 화면 표시 |
| `org.jetbrains.kotlin:kotlin-stdlib` | Kotlin 표준 라이브러리 (Java 로만 만든 앱에도 함께 들어옵니다) |
| `org.jetbrains.kotlinx:kotlinx-coroutines-android` | 비동기 처리 |
| `com.android.installreferrer:installreferrer` | 설치 경로 확인 |

> 💡 Google Play 서비스 라이브러리(`play-services-*`)를 추가할 필요는 없습니다.
> 광고 ID(ADID)는 기기에 설치된 Google Play 서비스에서 SDK 가 직접 가져옵니다. Google Play 서비스가 없는 기기에서는 광고 ID 를 가져오지 못합니다.

---

## ProGuard / R8

**추가 작업이 없습니다.** SDK 에 포함된 난독화 규칙이 앱 빌드에 자동으로 적용되므로, R8/ProGuard 를 켠 릴리스 빌드에서도 그대로 동작합니다.

기존 네이티브 SDK 용으로 넣어두셨던 아래 규칙이 남아 있어도 무해합니다.

```proguard
-keep class com.tnkfactory.** { *; }
```

---

## 설치 확인

의존성이 제대로 해석되는지 확인합니다.

```bash
./gradlew :app:dependencies --configuration releaseRuntimeClasspath | grep hrwd
```

```
+--- com.tnkfactory.ad:hrwd:1.0.15
```

`| grep hrwd` 를 빼고 실행하면 SDK 와 함께 들어온 라이브러리의 버전까지 전체 목록으로 볼 수 있습니다.

코드에서 버전을 확인할 수도 있습니다.

```kotlin
Log.i("TNK", "SDK version = ${TnkPpiHybSdk.VERSION}")   // 설치한 SDK 버전이 출력됩니다
```

---

다음: [2. AndroidManifest 설정](manifest.md)
