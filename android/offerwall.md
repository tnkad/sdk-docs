---
description: 전체화면 오퍼월 진입과 TnkOfferwallView 를 이용한 화면 내 삽입 방법. 생명주기·뒤로가기·상단 안전영역 처리를 안내합니다.
---

# 4. 오퍼월 띄우기

두 가지 방식이 있습니다.

| 방식 | 사용처 |
|------|--------|
| **전체화면** | 버튼을 눌러 오퍼월 화면으로 진입 (권장) |
| **화면 안에 삽입** | 탭 하나를 통째로 오퍼월로 채우는 등 앱 화면에 임베드 |

---

## 전체화면

```kotlin
TnkPpiHybSdk.openOfferwall(this)
```

Java

```java
TnkPpiHybSdk.openOfferwall(this);
```

SDK 가 광고 ID 수집을 포함한 준비를 마친 뒤 오퍼월 Activity 를 띄웁니다.
매니페스트에 Activity 를 등록할 필요는 없습니다.

### 추가 파라미터

```kotlin
TnkPpiHybSdk.openOfferwall(this, mapOf("hideHeader" to "1"))
```

| 파라미터 | 값 | 설명 |
|---------|-----|------|
| `hideHeader` | `"1"` | 오퍼월 상단 헤더(타이틀/닫기)를 숨깁니다. 개발사가 자체 헤더를 그리는 경우 사용 |

### URL 만 얻기

디버깅이나 로깅 목적으로 오퍼월 URL 을 확인할 수 있습니다.

```kotlin
val url = TnkPpiHybSdk.buildOfferwallUrl(context)
Log.i("TNK", url)
```

---

## 화면 안에 삽입

### 1. 레이아웃에 배치

```xml
<com.tnkfactory.ad.hrwd.webview.TnkOfferwallView
    android:id="@+id/offerwallView"
    android:layout_width="match_parent"
    android:layout_height="match_parent" />
```

### 2. 로드

```kotlin
binding.offerwallView.loadOfferwall()
```

개발사가 자체 헤더를 그린다면 헤더를 숨긴 채 로드합니다.

```kotlin
binding.offerwallView.loadOfferwall(null, mapOf("hideHeader" to "1"))
```

Java

```java
Map<String, String> params = new HashMap<>();
params.put("hideHeader", "1");
binding.offerwallView.loadOfferwall(null, params);
```

> 이미 로드된 상태에서 다시 호출해도 안전합니다. 탭 전환처럼 화면이 다시 보일 때마다
> 호출하기보다는, **최초 1회만 호출하고 이후에는 뷰의 visibility 만 토글**하는 편이
> WebView 상태(스크롤 위치, 진행 중인 참여)가 유지되어 사용자 경험이 좋습니다.

### 생명주기 · 뒤로가기

**별도 후킹이 필요 없습니다.** 뷰가 호스트 Activity/Fragment 의 생명주기를 자동으로 구독해
`onResume`/`onPause`/`onDestroy` 를 처리하고, 뒤로가기는 WebView 에 이전 페이지가 있을 때만
가로채 `goBack()` 으로 동작합니다.

### 닫기 요청 처리

오퍼월(FE)에서 닫기를 누르면 호출됩니다. 등록하지 않으면 호스트 Activity 가 `finish()` 됩니다.

```kotlin
binding.offerwallView.onCloseRequested = {
    // 예: 탭을 이전 탭으로 되돌리기
    binding.bottomNav.selectedItemId = R.id.nav_home
}
```

### 상단 안전영역 (edge-to-edge)

호스트 앱이 edge-to-edge 로 상태바 아래까지 그리는 경우, 상단 inset 을 CSS px 로 전달하면
오퍼월 콘텐츠가 상태바에 가려지지 않습니다.

```kotlin
ViewCompat.setOnApplyWindowInsetsListener(binding.root) { _, insets ->
    val topPx = insets.getInsets(WindowInsetsCompat.Type.statusBars()).top
    binding.offerwallView.setSafeAreaTopPx(topPx / resources.displayMetrics.density)
    insets
}
```

---

## 인스턴스 방식 (네이티브 SDK 호환)

네이티브 SDK 를 사용 중인 개발사가 코드 변경을 최소화할 수 있도록 인스턴스 패턴도 제공합니다.

```kotlin
val offerwall = TnkOfferwall(this)
offerwall.setUserName("개발사-사용자-식별값")
offerwall.setCOPPA(false)
offerwall.startOfferwallActivity(this)
```

### 특정 URL 로 열기

테스트 환경 등에서 오퍼월 URL 을 직접 지정해야 할 때 사용합니다.
실서비스에서는 `openOfferwall()` 을 사용하세요.

```kotlin
TnkOfferwall.show(context, "https://...")
```

---

다음: [5. 보상 지급 수신](reward.md)
