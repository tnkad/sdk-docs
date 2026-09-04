---
description: TnkFactory Maven 저장소 등록과 Gradle 의존성 추가 방법. minSdk 21 / compileSdk 36 등 빌드 요구사항과 ProGuard 설정을 함께 안내합니다.
---

# 1. 설치

## 빌드 요구사항

| 항목 | 값 |
|------|-----|
| `minSdk` | **21** 이상 |
| `compileSdk` | **36** 이상 |
| `targetSdk` | 제한 없음 (Google Play 의 대상 API 요구사항을 따르세요) |
| Java / Kotlin jvmTarget | **17** |
| AndroidX | 필수 (`android.useAndroidX=true`) |

> SDK 는 Java 17 로 컴파일되어 있습니다. AGP 8.x 자체가 JDK 17 을 요구하므로 대부분의 프로젝트는
> 이미 조건을 만족하지만, `compileOptions` 가 Java 11 이하로 고정돼 있다면 17 로 올려주세요.

> `compileSdk` 가 36 보다 낮으면 AGP 가
> `Dependency ... requires libraries and applications that depend on it to compile against version 36 or later`
> 오류로 빌드를 중단합니다. 호스트 앱의 `compileSdk` 를 올려주세요.

---

## 저장소 등록

TnkFactory Maven 저장소를 추가합니다. 별도 인증은 필요하지 않습니다.

### Kotlin DSL — `settings.gradle.kts`

```kotlin
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
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

> 프로젝트가 아직 `allprojects { repositories { ... } }` (구형 구조)를 쓰고 있다면
> 그쪽에 `maven { url "..." }` 한 줄을 추가하셔도 동일하게 동작합니다.

---

## 의존성 추가

앱 모듈의 `build.gradle.kts`

```kotlin
dependencies {
    implementation("com.tnkfactory.ad:hrwd:1.0.6")
}
```

Groovy — `build.gradle`

```groovy
dependencies {
    implementation 'com.tnkfactory.ad:hrwd:1.0.6'
}
```

### 함께 따라오는 라이브러리

아래는 SDK 가 전이 의존성으로 가져오므로 **개발사가 직접 선언할 필요가 없습니다.**

- `androidx.core:core-ktx`, `androidx.appcompat:appcompat`, `androidx.activity:activity-ktx`
- `androidx.lifecycle:lifecycle-runtime-ktx`
- `androidx.webkit:webkit` — WebView JS 브릿지에 사용
- `org.jetbrains.kotlinx:kotlinx-coroutines-android`
- `com.android.installreferrer:installreferrer` — 설치 경로 수집

> Google Play Services 에 의존하지 않습니다. 광고 ID(ADID)는 SDK 가 직접 조회합니다.

---

## ProGuard / R8

**추가 작업이 없습니다.** SDK 의 `consumer-rules.pro` 가 호스트 앱 빌드에 자동 적용되어
공개 API 와 JS 브릿지 진입점을 보존합니다.

네이티브 SDK 에 넣어두셨던 아래 규칙이 남아 있어도 무해합니다.

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
+--- com.tnkfactory.ad:hrwd:1.0.6
```

코드에서 버전을 확인할 수도 있습니다.

```kotlin
Log.i("TNK", "SDK version = ${TnkPpiHybSdk.VERSION}")
```

---

다음: [2. AndroidManifest 설정](manifest.md)
