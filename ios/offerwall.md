---
description: 풀스크린 오퍼월 진입과 TnkOfferwallView 를 이용한 화면 내 삽입 방법. 상태바 스타일과 정리(cleanup) 처리를 안내합니다.
---

# 4. 오퍼월 띄우기

두 가지 방식이 있습니다.

| 방식 | 사용처 |
|------|--------|
| **풀스크린** | 버튼을 눌러 오퍼월 화면으로 진입 (권장) |
| **화면 안에 삽입** | 탭 하나를 통째로 오퍼월로 채우는 등 앱 화면에 임베드 |

---

## 풀스크린

```swift
TnkPpiHybSdk.shared.openOfferwall(from: self)
```

전환 애니메이션을 끄려면:

```swift
TnkPpiHybSdk.shared.openOfferwall(from: self, animated: false)
```

### 추가 파라미터

```swift
TnkPpiHybSdk.shared.openOfferwall(from: self, extraParams: ["hideHeader": "1"])
```

| 파라미터 | 값 | 설명 |
|---------|-----|------|
| `hideHeader` | `"1"` | 오퍼월 상단 헤더(타이틀 · 닫기)를 숨깁니다. 개발사가 자체 헤더를 그리는 경우 사용 |

### URL 만 얻기

```swift
let url = TnkPpiHybSdk.shared.buildOfferwallURL()          // URL?
let url2 = TnkPpiHybSdk.shared.buildOfferwallURL(extraParams: ["hideHeader": "1"])
```

특정 URL 을 SDK 컨테이너에서 열어야 할 때:

```swift
TnkOfferwall.show(from: self, url: someURL)
```

---

## 화면 안에 삽입

`TnkOfferwallView` 는 `UIView` 라 원하는 위치에 넣을 수 있습니다.

```swift
final class CashbackViewController: UIViewController {

    private let offerwall = TnkOfferwallView(frame: .zero)

    override func viewDidLoad() {
        super.viewDidLoad()

        offerwall.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(offerwall)
        NSLayoutConstraint.activate([
            offerwall.topAnchor.constraint(equalTo: view.topAnchor),
            offerwall.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            offerwall.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            offerwall.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        // 웹에서 닫기를 누르면 호출됩니다 (탭 전환 등으로 처리)
        offerwall.onCloseRequested = { [weak self] in
            self?.tabBarController?.selectedIndex = 0
        }

        // 웹이 상태바 색을 요청하면 호스트가 반영합니다
        offerwall.onStatusBarStyleChanged = { [weak self] _ in
            self?.setNeedsStatusBarAppearanceUpdate()
        }

        offerwall.loadOfferwall(TnkPpiHybSdk.shared.buildOfferwallURL())
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        offerwall.requestedStatusBarStyle
    }

    deinit {
        offerwall.cleanup()
    }
}
```

### 헤더 숨기고 로드

```swift
offerwall.loadOfferwall(
    TnkPpiHybSdk.shared.buildOfferwallURL(extraParams: ["hideHeader": "1"])
)
```

`loadOfferwall(_:)` 은 URL 하나만 받습니다. 개발사 파라미터는 `buildOfferwallURL(extraParams:)`
쪽에 넣으세요.

### 뒤로가기

웹에 이전 페이지가 있으면 되돌아가고, 없으면 `false` 를 반환합니다.
개발사가 자체 네비게이션을 쓸 때 연결하시면 됩니다.

```swift
if !offerwall.goBackIfPossible() {
    // 더 이상 뒤로 갈 곳이 없음 — 화면을 닫는 등 개발사 처리
}
```

### 정리

> ⚠️ 화면이 사라질 때 **반드시 `cleanup()` 을 호출하세요.**
> WKWebView 와 JS 브릿지 핸들러가 해제되지 않으면 메모리에 남습니다.

```swift
deinit { offerwall.cleanup() }
```

---

> ⚠️ **삽입해도 표시되는 것은 오퍼월 전체 화면입니다.**
> 특정 카테고리만, 또는 광고 상세만 노출하는 **플레이스먼트 뷰는 제공하지 않습니다.**
> 네이티브 보상형 SDK(`TnkRwdSdk2`)의 `AdPlacementView` 를 쓰고 계시다면 문의해 주세요.

---

다음: [5. 보상 지급 수신](reward.md)
