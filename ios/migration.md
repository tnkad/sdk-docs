---
description: 기존 네이티브 오퍼월 SDK(TnkRwdSdk2)에서 하이브리드 SDK(TnkPpiHyb)로 옮기는 방법을 의존성·초기화·화면 안에 넣기·포인트 조회·개인정보 동의·특정 광고 진입·ATT 요청 패턴별 전/후 코드와 전체 API 대조표로 안내합니다.
---

# 네이티브 SDK 에서 이관

이 페이지에서 하는 일: 기존 네이티브 SDK(`TnkRwdSdk2`)를 쓰는 앱을 하이브리드 SDK(`TnkPpiHyb`)로 옮깁니다. 바꿀 코드를 전/후 비교로 보여 드립니다.

## 언제 필요한가

기존 네이티브 SDK 를 이미 쓰고 있는 개발사에게만 필요합니다. 신규 연동이라면 이 페이지는 건너뛰고 [연동 가이드](README.md)부터 시작하세요.

Android 앱도 함께 옮긴다면 [Android 이관](../android/migration.md)을 같이 보세요. 오퍼월 화면은 Android·iOS 가 같습니다.

---

## 한눈에 보기

| 구분 | 내용 |
|---|---|
| **그대로** | 앱 ID(`tnkad_app_id`) 선언, `Info.plist` 의 추적 허용(ATT)·사진·카메라 문구, 서버 보상 콜백 URL 과 그 구현, `setUserName` 에 넘기는 값, 오퍼월을 전체 화면으로 여는 흐름 (호출 대상만 `TnkPpiHybSdk.shared` 로 바뀝니다) |
| **바뀜** | 패키지와 import(`TnkRwdSdk2` → `TnkPpiHyb`), 최소 iOS 버전(12.0 → 15.0), 호출 대상(`TnkSession.sharedInstance()` → `TnkPpiHybSdk.shared`), 초기화(`initInstance` → `configure`), 오퍼월 열기(`AdOfferwallViewController` → `openOfferwall(from:)`), 화면 안에 넣기(`AdOfferwallView` → `TnkOfferwallView`), 적립 가능 포인트 조회, 개인정보 동의 호출, 특정 광고 진입(결과 콜백 없음), `setCOPPA`·`setGDPR` 인자 타입, ATT 요청 |
| **빠짐** | 오퍼월 디자인 설정(`TnkStyles`·`TnkLayout`), 광고 목록 데이터 직접 조회, 사용자 포인트 잔액 조회·구매·인출, 플레이스먼트 뷰(추후 제공 예정), 이벤트·Plus·커스텀 탭 화면 등 |

> ⚠️ **TNK 서버에 사용자 포인트 관리를 맡긴 앱**(`queryPoint`·`purchaseItem`·`withdrawPoints` 사용)은 이관 전에 담당자에게 문의해 주세요. 하이브리드 오퍼월에는 잔액 조회·구매·인출 화면이 없어 현재 미제공입니다. 하이브리드 SDK 에서는 [서버 보상 콜백](../common/server-callback.md)으로 받은 포인트를 개발사 서버에서 관리합니다.

> ⚠️ **Objective-C 앱**은 먼저 아래 'Objective-C 앱이라면'을 보세요. 하이브리드 SDK 는 Swift 에서 호출하는 API 만 제공합니다.

> ⚠️ 기존 네이티브 SDK 와 하이브리드 SDK 를 한 앱에 함께 두는 구성은 확인되지 않았습니다. 일부 화면(예: `AdPlacementView`)을 기존 SDK 로 유지해야 한다면 이관 전에 담당자에게 문의해 주세요. 함께 두는 동안에는 한 Swift 파일에서 `import TnkRwdSdk2` 와 `import TnkPpiHyb` 를 같이 쓰지 마세요. 기존 SDK 에서 받은 개인정보 동의는 하이브리드 SDK 를 처음 쓸 때 한 번만 이어지며, 그 뒤의 변경은 서로 반영되지 않습니다.

### 이관 순서

- [ ] 1. 앱의 최소 지원 버전(Deployment Target)이 iOS 15.0 이상인지 확인하고, 의존성을 `TnkPpiHyb` 로 교체합니다 (아래 패턴 1)
- [ ] 2. `Info.plist` 는 **그대로 둡니다** (패턴 2)
- [ ] 3. `import TnkRwdSdk2` 를 `import TnkPpiHyb` 로 바꾸고, 초기화·사용자 식별값·오퍼월 열기를 바꿉니다 (패턴 3)
- [ ] 4. 오퍼월 디자인 설정(`TnkStyles.*`·`TnkLayout.*`) 줄을 삭제합니다 (아래 '디자인 설정' 표)
- [ ] 5. 앱 화면 안에 넣던 `AdOfferwallView` 는 `TnkOfferwallView` 로 바꿉니다 (패턴 4)
- [ ] 6. 적립 가능 포인트 조회 코드를 바꿉니다 (패턴 5)
- [ ] 7. 개인정보 동의 호출을 바꾸고, `setUserName` 을 `setAgreePrivacy` 보다 먼저 호출합니다 (패턴 6)
- [ ] 8. 앱에서 직접 동의를 받는 앱(`setAgreePrivacy(true)` 를 호출하는 앱)은 앱 화면에 '동의 철회' 수단을 두고 `revokePrivacyConsent()` 를 연결합니다. 이 경우 오퍼월에는 '개인 정보 수집 동의 해제' 메뉴가 나오지 않습니다 (패턴 6)
- [ ] 9. 특정 광고 진입 코드를 바꿉니다 (패턴 7)
- [ ] 10. 시작 카테고리·필터를 지정하던 코드는 딥링크로 바꿉니다 (패턴 8)
- [ ] 11. ATT 요청을 `requestTrackingAuthorization` 으로 바꾸고, 초기화와 따로 호출합니다 (패턴 9)
- [ ] 12. 빌드해서 컴파일 오류 목록을 확인하고, 아래 '전체 API 대조표'에서 남은 호출을 찾아 치환·삭제합니다. '현재 미제공(문의)' 항목은 담당자에게 문의합니다
- [ ] 13. 서버 콜백 URL 구현과 `tnkad_app_id` 선언은 **그대로 둡니다** (변경 없음)

치환 작업을 AI 도구에 맡길 수도 있습니다. 방법은 [AI 도구에 문서 연결하기](../publisher/ai-tools.md)를 보세요. 결과는 반드시 직접 확인하세요.

---

## 패턴별 전/후

각 패턴은 "무엇이 바뀌나" 한 줄과 전/후 코드로 되어 있습니다. `-` 줄은 기존 네이티브 SDK 코드, `+` 줄은 하이브리드 SDK 코드입니다.

### 패턴 1. 의존성·빌드 설정

**무엇이 바뀌나:** 패키지 이름이 `TnkRwdSdk2` 에서 `TnkPpiHyb` 로 바뀌고, 최소 지원 iOS 버전이 12.0 에서 15.0 으로 올라갑니다. iOS 15 미만 기기까지 지원해야 하는 앱은 담당자에게 문의해 주세요. 그 밖의 빌드 요구사항은 [1. 설치](install.md)를 확인하세요.

Swift Package Manager 로 설치하는 경우입니다. Xcode 에서는 **File → Add Package Dependencies** 로 새 패키지를 추가하고, 기존 패키지는 목록에서 삭제합니다.

```diff
 // Package.swift 를 직접 쓰는 경우
 dependencies: [
-    .package(url: "https://github.com/tnkfactory/tnk-rwd2-spm.git", from: "5.94.0")
+    .package(url: "https://github.com/tnkad/ios-ppi-hyb-sdk", from: "1.0.5")
 ],
 targets: [
     .target(
         name: "YourApp",
         dependencies: [
-            .product(name: "TnkRwdSdk2", package: "tnk-rwd2-spm")
+            .product(name: "TnkPpiHyb", package: "ios-ppi-hyb-sdk")
         ]
     )
 ]
```

CocoaPods 를 쓰는 앱은 `Podfile` 에 `TnkPpiHyb` 를 추가합니다. 이 SDK 를 SPM 과 CocoaPods 양쪽으로 함께 추가하지 마세요.

```diff
-platform :ios, '12.0'
+platform :ios, '15.0'

 target 'YourApp' do
   use_frameworks!
+  pod 'TnkPpiHyb', '~> 1.0'
 end
```

`TnkRwdSdk2.xcframework` 를 프로젝트에 직접 끌어다 넣었던 앱은 다음을 정리합니다.

1. Xcode → Target → General → **Frameworks, Libraries, and Embedded Content** 에서 `TnkRwdSdk2.xcframework` 를 삭제합니다.
2. static 라이브러리를 썼다면 프로젝트에 추가했던 `TnkRwdSdk2.bundle` 도 삭제합니다.
3. 그다음 위의 SPM 또는 CocoaPods 방법으로 `TnkPpiHyb` 를 추가합니다.

Xcode → Target → General → **Minimum Deployments** 도 iOS 15.0 이상으로 맞춥니다.

- `-` 줄의 버전 숫자는 예시입니다. 쓰고 계신 값과 달라도 같은 줄을 지우면 됩니다. `+` 줄의 `from:` 에는 최신 버전을 쓰세요. 최신 버전은 [릴리스 노트](changelog.md)에서 확인할 수 있습니다. CocoaPods 의 `'~> 1.0'` 은 1.x 의 최신 버전을 받습니다.

### 패턴 2. Info.plist

**무엇이 바뀌나:** 바꿀 것이 없습니다. 기존 네이티브 SDK 를 위해 넣어 둔 항목을 **그대로 두세요.**

| 키 | 이관할 때 |
|---|---|
| `tnkad_app_id` | 그대로 둡니다. 코드로 `configure(appId:)` 를 함께 쓰는 경우의 우선순위는 [2. Info.plist 설정](plist.md)의 '앱 ID' 를 보세요 |
| `NSUserTrackingUsageDescription` | 그대로 둡니다 (ATT 팝업 문구) |
| `NSPhotoLibraryUsageDescription` | 그대로 둡니다 |
| `NSCameraUsageDescription` | 그대로 둡니다 |

### 패턴 3. 초기화 + 사용자 + 오퍼월 열기

**무엇이 바뀌나:** 가장 흔한 코드입니다. `TnkSession.initInstance` 와 `sharedInstance()` 가 `TnkPpiHybSdk.shared` 로 바뀌고, 오퍼월을 여는 코드가 한 줄로 줄어듭니다.

```diff
 import UIKit
-import TnkRwdSdk2
+import TnkPpiHyb

 final class AppDelegate: UIResponder, UIApplicationDelegate {

     func application(_ application: UIApplication,
                      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
-        TnkSession.initInstance(appId: "발급받은-앱-아이디")
-        TnkSession.sharedInstance()?.setUserName("개발사-사용자-식별값")
-        TnkSession.sharedInstance()?.applicationStarted()
+        let sdk = TnkPpiHybSdk.shared
+        sdk.configure(appId: "발급받은-앱-아이디")
+        sdk.setUserName("개발사-사용자-식별값")
+        sdk.applicationStarted()
         return true
     }
 }

 final class MainViewController: UIViewController {

     @objc private func offerwallButtonTapped() {
-        let vc = AdOfferwallViewController()
-        vc.title = "오퍼월"
-        let navController = UINavigationController(rootViewController: vc)
-        navController.modalPresentationStyle = .fullScreen
-        present(navController, animated: true)
+        TnkPpiHybSdk.shared.openOfferwall(from: self)
     }
 }
```

**사용자가 보는 것:** 버튼을 누르면 오퍼월이 전체 화면으로 열립니다. 처음 여는 사용자에게는 개인정보 수집 동의 팝업이 먼저 나옵니다. 오퍼월 화면은 Android·iOS 가 같습니다.

<figure><img src="../assets/ios/ios-fullscreen-device.png" alt="iOS 기기 전체 화면에 열린 오퍼월. 위에 상태 바, 오퍼월 헤더와 탭, 검색창, 광고 목록이 보임" width="300"><figcaption><p>버튼을 누르면 오퍼월이 앱 화면 전체를 덮는 전체 화면으로 열립니다.</p></figcaption></figure>

<figure><img src="../assets/common/consent-popup.png" alt="개인정보 수집 동의 팝업. 수집정보와 보유기간 안내, 거부와 동의 버튼이 있음" width="300"><figcaption><p>처음 여는 사용자에게는 동의 팝업이 먼저 나옵니다.</p></figcaption></figure>

- 오퍼월의 제목과 닫기(X)는 오퍼월이 직접 그립니다. `UINavigationController` 로 감싸서 present 하던 코드는 필요 없습니다.
- `Info.plist` 의 `tnkad_app_id` 만 쓰던 앱은 `configure` 호출을 생략해도 됩니다. 코드와 `Info.plist` 를 함께 쓴다면 `configure(appId:)` 를 다른 SDK 호출보다 먼저 호출하세요 — [3. 초기화](initialize.md)
- `applicationStarted` 는 호출해도 되고 생략해도 됩니다. 현재 버전에서는 오퍼월 동작에 영향이 없습니다.
- 사용자 식별값 설정은 필수입니다. 로그인 후처럼 사용자를 알 수 있는 시점에 호출하세요.
- `TnkStyles.*`·`TnkLayout.*` 같은 오퍼월 디자인 설정 줄은 지웁니다. 오퍼월 안의 포인트 표시(아이콘·단위)는 앱 코드로 정하지 않고 오퍼월 화면이 표시합니다. 기존과 같은 표시가 필요하면 담당자에게 요청해 주세요 — 아래 '디자인 설정' 표.

**이어 붙여 쓰던 호출은 나눠 주세요.** 기존 `setUserName` 과 `setCOPPA` 는 자기 자신을 돌려줘서 `.` 으로 이어 붙일 수 있었습니다. 하이브리드 SDK 의 `setUserName` 은 반환값이 없어서 이어 붙이면 컴파일되지 않습니다.

```diff
-TnkSession.sharedInstance()?.setUserName("개발사-사용자-식별값").setCOPPA(false)
+let sdk = TnkPpiHybSdk.shared
+sdk.setUserName("개발사-사용자-식별값")
+sdk.setCOPPA(0)
```

### 패턴 4. 화면 안에 넣기

**무엇이 바뀌나:** `AdOfferwallView` 를 만들어 `loadData()` 를 부르던 코드가, `TnkOfferwallView` 를 만들어 `loadOfferwall(_:)` 를 부르는 코드로 바뀝니다. 닫기 처리(`onCloseRequested`)와 정리(`cleanup()`)가 새로 생깁니다.

```diff
 import UIKit
-import TnkRwdSdk2
+import TnkPpiHyb

 final class OfferwallTabViewController: UIViewController {

+    private let offerwallView = TnkOfferwallView(frame: .zero)
+
     override func viewDidLoad() {
         super.viewDidLoad()
-        let offerwallView = AdOfferwallView(frame: view.frame, viewController: self)
-        offerwallView.offerwallListener = self   // 이벤트 리스너를 쓰던 경우
         view.addSubview(offerwallView)
         offerwallView.translatesAutoresizingMaskIntoConstraints = false
         NSLayoutConstraint.activate([
             offerwallView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
             offerwallView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
-            offerwallView.topAnchor.constraint(equalTo: view.topAnchor),
-            offerwallView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
+            offerwallView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
+            offerwallView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
         ])
-        offerwallView.loadData()
+        offerwallView.onCloseRequested = { [weak self] in
+            self?.tabBarController?.selectedIndex = 0   // 예: 첫 번째 탭으로 이동
+        }
+        if let url = TnkPpiHybSdk.shared.buildOfferwallURL() {
+            offerwallView.loadOfferwall(url)
+        }
+    }
+
+    deinit {
+        offerwallView.cleanup()   // 이 화면을 더 이상 쓰지 않을 때 한 번
     }
 }
```

**사용자가 보는 것:** 앱 화면의 일부(예: 탭 하나)가 오퍼월로 채워집니다. 탭 바 같은 앱 화면은 그대로 보입니다. 광고 목록은 오퍼월 화면이 직접 불러오므로 `loadData()` 같은 사전 로드 호출은 필요 없습니다. 탭 바·내비게이션 바에 가리지 않도록 오퍼월을 안전 영역에 맞춥니다.

<figure><img src="../assets/ios/ios-embedded-device.png" alt="앱 화면 안에 들어간 오퍼월. 위에는 앱의 상단 바, 아래에는 앱의 탭 바가 있고 그 사이에 오퍼월이 보임" width="300"><figcaption><p>앱 화면 안에 넣으면 앱의 상단 바와 탭 바 사이에 오퍼월이 표시됩니다. 이 화면은 hideHeader 를 지정해 오퍼월 헤더가 없습니다.</p></figcaption></figure>

오퍼월의 닫기(X) 버튼을 눌렀을 때 할 일은 `onCloseRequested` 로 연결합니다. 탭 안에 넣었다면 반드시 등록하세요.

| `onCloseRequested` | 사용자가 보는 것 | 언제 쓰나 |
|---|---|---|
| 등록 | 등록한 동작이 실행됩니다. 오퍼월은 앱 화면 안에 그대로 남습니다. | 앱 화면 안에 넣을 때 (반드시 등록) |
| 등록하지 않음 | 닫기(X)를 눌러도 아무 일도 일어나지 않습니다. | 전체 화면으로 열 때는 등록할 일이 없습니다. SDK 가 알아서 닫습니다. |

> 💡 Android 는 등록하지 않으면 오퍼월을 담은 화면(Activity)이 종료되지만, iOS 는 아무 일도 일어나지 않습니다.

앱이 자체 상단 바를 그린다면 주소를 만들 때 `extraParams` 로 오퍼월의 상단 헤더를 숨길 수 있습니다.

```swift
if let url = TnkPpiHybSdk.shared.buildOfferwallURL(extraParams: ["hideHeader": "1"]) {
    offerwallView.loadOfferwall(url)
}
```

> ⚠️ 전체 화면으로 열 때(`openOfferwall`)는 `hideHeader` 를 쓰지 마세요. iOS 의 전체 화면 오퍼월은 오퍼월 상단의 닫기(X)로만 닫을 수 있어서, 숨기면 사용자가 닫을 방법이 없습니다. 값별 화면 변화와 화면 예시는 [4. 오퍼월 띄우기](offerwall.md)의 '화면 설정' 항목을 보세요.

- `loadOfferwall(_:)` 에는 `buildOfferwallURL(extraParams:)` 로 만든 주소를 넘기세요. 직접 만든 주소나 `nil` 을 넘기지 마세요.
- 탭에 넣었다면 탭을 오갈 때마다 `loadOfferwall(_:)` 을 다시 부르지 마세요. 동의 팝업에서 [거부] 뒤 닫은 경우의 처리를 포함해 [4. 오퍼월 띄우기](offerwall.md)의 '탭에 넣을 때 주의' 항목을 보세요.
- 상태바 글자색 연결(`onStatusBarStyleChanged`)과 뒤로가기(`goBackIfPossible()`)는 [4. 오퍼월 띄우기](offerwall.md)를 보세요.

특정 광고·카테고리만 앱 화면 일부에 노출하는 플레이스먼트 뷰는 추후 제공될 예정입니다. 기존 네이티브 SDK 의 `AdPlacementView` 를 사용 중이시면 담당자에게 알려 주세요.

**SwiftUI 앱:** `AdOfferwallViewController` 를 `UIViewControllerRepresentable` 로 감싸던 코드는 `TnkOfferwallView` 를 `UIViewRepresentable` 로 감싸는 코드로 바꿉니다.

```diff
 import SwiftUI
-import TnkRwdSdk2
+import TnkPpiHyb

-struct OfferwallViewController: UIViewControllerRepresentable {
-    func makeUIViewController(context: Context) -> AdOfferwallViewController {
-        AdOfferwallViewController()
-    }
-
-    func updateUIViewController(_ uiViewController: AdOfferwallViewController, context: Context) {
-        uiViewController.loadOfferwall()
-    }
-}
+struct OfferwallView: UIViewRepresentable {
+    var onClose: () -> Void = {}   // 닫기(X)를 눌렀을 때 할 일
+
+    func makeUIView(context: Context) -> TnkOfferwallView {
+        let view = TnkOfferwallView(frame: .zero)
+        view.onCloseRequested = onClose
+        if let url = TnkPpiHybSdk.shared.buildOfferwallURL() {
+            view.loadOfferwall(url)
+        }
+        return view
+    }
+
+    func updateUIView(_ uiView: TnkOfferwallView, context: Context) {}
+
+    static func dismantleUIView(_ uiView: TnkOfferwallView, coordinator: Void) {
+        uiView.cleanup()
+    }
+}
```

SwiftUI 에서 전체 화면으로 열려면 `openOfferwall(from:)` 에 오퍼월을 띄울 `UIViewController` 가 필요합니다.

### 패턴 5. 포인트 조회

**무엇이 바뀌나:** 적립 가능한 포인트를 조회하는 호출이 `getAdvertiseTotalPoint`(일반 광고)와 `getProductTotalPoint`(구매형 광고)로 나뉩니다. 기존 `queryAdvertiseCount` 는 두 합계를 한 번에 돌려줬으므로, 하이브리드에서는 두 결과를 더합니다.

```diff
-TnkSession.sharedInstance()?.queryAdvertiseCount { count, point in
-    label.text = "\(count)개 \(point)P"
-}
+TnkPpiHybSdk.shared.getAdvertiseTotalPoint { ppi in
+    TnkPpiHybSdk.shared.getProductTotalPoint { shopping in
+        let ok = [ppi, shopping].compactMap { $0 }.filter { $0.isSuccess }
+        let count = ok.reduce(0) { $0 + $1.adCount }
+        let point = ok.reduce(Int64(0)) { $0 + $1.pointAmount }
+        label.text = "\(count)개 \(point)P"
+    }
+}
```

콜백은 항상 메인 스레드에서 호출되므로 바로 화면을 갱신해도 됩니다. 위 코드는 조회에 실패했거나(`nil`) 서버가 실패로 응답한(`isSuccess` 가 `false`) 쪽을 더하지 않습니다. 콜백에 오는 `TotalPointInfo` 는 이렇게 처리하세요.

| 콜백으로 오는 값 | 의미 | 처리 |
|---|---|---|
| `nil` | 네트워크 오류 등으로 조회에 실패했습니다. | 합계에 더하지 않습니다. 하나만 조회하는 화면이라면 표시하지 않거나 이전 값을 유지합니다. |
| `isSuccess` 가 `false` | 서버가 실패로 응답했습니다. `retCode`·`retMessage` 로 사유를 볼 수 있습니다. 이때의 `pointAmount` 는 쓰지 마세요. | `nil` 과 같이 처리합니다. |
| `isSuccess` 가 `true` | `pointAmount`(포인트 합계, `Int64`)와 `adCount`(광고 수)가 들어 있습니다. | 합계에 더하고 화면에 표시합니다. |

- 호출 방법과 결과 값별 동작은 [9. 적립 가능 포인트 조회](total-point.md)에 정리되어 있습니다.
- 합계 계산 방식은 SDK 마다 다를 수 있으니, 이관 후 화면에 표시된 값을 한 번 확인해 주세요.
- 로그아웃 후 다른 계정으로 로그인하는 앱은 `setUserName` 다음에 `clearApiSession()` 을 호출하세요 — [3. 초기화](initialize.md)
- 사용자가 이미 적립한 **잔액** 조회(`queryPoint`)·아이템 구매(`purchaseItem`)·전체 인출(`withdrawPoints`)은 현재 하이브리드 SDK 에서 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요.

```diff
-TnkSession.sharedInstance()?.queryPoint { point in
-    // TNK 서버에 맡긴 사용자 포인트 잔액
-}
+// 현재 미제공 — 담당자에게 문의해 주세요. 서버 보상 콜백으로 받은 포인트는 개발사 서버에서 관리합니다.
```

### 패턴 6. 개인정보 동의

**무엇이 바뀌나:** 동의 팝업을 앱에서 띄우던 호출은 필요 없어집니다. 오퍼월(특정 광고 진입 포함)에 들어갈 때 동의 팝업이 자동으로 나옵니다. 앱에서 직접 동의를 받은 경우의 알림과 철회 호출은 이름이 바뀝니다.

```diff
+let sdk = TnkPpiHybSdk.shared

-TnkSession.sharedInstance()?.openPrivacyTermAlert(parentViewController: self) { ok in
-    guard ok else { return }
-    // 동의 후 진행할 일
-}
+// 삭제 — 오퍼월(특정 광고 진입 포함)에 들어갈 때 동의 팝업이 자동으로 나옵니다

-TnkSession.sharedInstance()?.setAgreePrivacyPolicy()
+sdk.setUserName("개발사-사용자-식별값")   // 반드시 먼저
+sdk.setAgreePrivacy(true)                  // 앱에서 직접 동의를 받은 경우에만

-TnkSession.sharedInstance()?.setAgreePrivacyPolicy(false)   // 사용자가 동의를 철회했을 때
+sdk.revokePrivacyConsent()   // 사용자가 앱에서 '동의 철회' 를 눌렀을 때만 호출

-TnkSession.sharedInstance()?.setCOPPA(false).setGDPRConsent(true)
+sdk.setCOPPA(0)   // false → 0, true → 1
+sdk.setGDPR(1)    // true → 1, false → 0
```

기존에는 `setAgreePrivacyPolicy(false)` 로 철회까지 처리했지만, 하이브리드에서는 열려 있는 오퍼월까지 갱신하는 `revokePrivacyConsent()` 를 씁니다. 동의 여부를 읽는 `isAgreePrivacy()` 가 새로 생겼습니다.

기존 앱이 `setAgreePrivacyPolicy(동의여부변수)` 처럼 변수를 넘겼다면, Xcode 의 Fix 를 적용한 `setAgreePrivacy(변수)` 를 그대로 두지 말고 `if 앱에서동의함 { sdk.setAgreePrivacy(true) }` 로 바꾸세요. `false` 를 앱 시작마다 넘기면 사용자가 오퍼월에서 한 동의도 지워져 동의 팝업이 매번 나옵니다.

값별 동작(`setAgreePrivacy` 의 `true`·`false`·호출하지 않음, `revokePrivacyConsent()` 호출 전·후, `setUserName` 과 동의 상태)과 화면 예시는 [7. 개인정보 설정](privacy.md)의 '값별 동작' 항목에 있습니다. 이관할 때는 아래 두 가지를 지켜 주세요.

- **철회에는 `setAgreePrivacy(false)` 를 쓰지 마세요.** 저장된 값만 바뀌고 이미 열려 있는 오퍼월은 그대로입니다. 열려 있는 오퍼월까지 첫 화면부터 다시 열어 동의 팝업을 보여 주는 것은 `revokePrivacyConsent()` 입니다.
- **`revokePrivacyConsent()` 는 사용자의 철회 동작에서만 호출하세요.** 화면 표시(`viewDidAppear`)나 앱 활성화(`sceneDidBecomeActive`)에서 호출하면 오퍼월이 그때마다 첫 화면으로 돌아갑니다. 철회한 뒤 `setAgreePrivacy(true)` 를 다시 호출하면 철회가 취소됩니다.

**`setUserName` 과 동의 상태 — 네이티브 SDK 와 달라진 점입니다.**

`setUserName` 에 이전과 다른 값(최초 지정 포함)을 넘기면 동의 상태가 초기화되고, 이전과 같은 값이면 그대로 유지됩니다.

> ⚠️ 기존 네이티브 SDK 의 iOS 에서는 `setUserName` 이 동의 상태를 바꾸지 않았습니다. 그래서 `setAgreePrivacyPolicy` 를 `setUserName` 보다 먼저 호출해도 됐습니다. 같은 순서로 옮기면 동의가 지워져 동의 팝업이 다시 나옵니다. 항상 `setUserName` → `setAgreePrivacy` 순서로 호출하세요.

**기존 네이티브 SDK 에서 받은 동의** (iOS SDK 1.0.5 이상)

| 하이브리드 SDK 의 `setUserName` 에 넘긴 값 | 기존 동의 | 사용자가 보는 것 |
|---|---|---|
| 기존 SDK 에서 쓰던 **같은 사용자 식별값** | 유지 | 동의 팝업이 다시 나오지 않습니다 |
| 다른 값, 또는 기존 SDK 에서 식별값을 지정하지 않았던 경우 | 첫 `setUserName` 에서 초기화 | 다음에 오퍼월에 들어갈 때 동의 팝업이 나옵니다 |

> ⚠️ 기존 SDK 에서 앱이 직접 동의를 받아 `setAgreePrivacyPolicy` 를 썼다면, 하이브리드 SDK 에서도 `setUserName` 다음에 `setAgreePrivacy(true)` 를 호출하세요. 호출하지 않으면 동의는 유지되지만 오퍼월에 "개인 정보 수집 동의 해제" 메뉴가 나타납니다.

**COPPA·GDPR 값 대응**

| 기존 네이티브 SDK | 하이브리드 SDK |
|---|---|
| `setCOPPA(true)` / `setCOPPA(false)` | `setCOPPA(1)` / `setCOPPA(0)` — 인자 타입이 `Bool` 에서 `Int` 로 바뀝니다 |
| `setGDPRConsent(true)` / `setGDPRConsent(false)` | `setGDPR(1)` / `setGDPR(0)` |

COPPA·GDPR 값의 의미는 [7. 개인정보 설정](privacy.md)을 보세요.

### 패턴 7. 특정 광고 진입

**무엇이 바뀌나:** 상세 진입 이름이 `presentAdDetailView` 에서 `adDetail` 로 바뀝니다. 호출 대상이 `TnkPpiHybSdk.shared` 로 바뀌고, 첫 인자에 `from:` 레이블이 붙으며, 결과 콜백이 없어집니다. 광고 번호(`appId`)는 `Int` 가 아니라 `Int64` 입니다.

```diff
 let adAppID = 12345        // 푸시로 받은 광고 번호
 let isCPS = false
 let actionId = isCPS ? 5 : 0   // 구매형(CPS) 광고만 5

-TnkSession.sharedInstance()?.openPrivacyTermAlert(parentViewController: self) { result in
-    guard result else { return }
-    TnkSession.sharedInstance()?.presentAdDetailView(self,
-                                                     appId: adAppID,
-                                                     fullscreen: false,
-                                                     actionId: actionId) { result, error in }
-}
+TnkPpiHybSdk.shared.adDetail(from: self, appId: Int64(adAppID), actionId: actionId)   // 동의 확인도 SDK 가 처리합니다
```

`adJoin`·`adAction` 도 같은 방식으로 바꿉니다. `from:` 레이블이 붙고, `appId` 는 `Int64` 이며, `completion` 과 `subAppId`·`navigationPush`·`fullscreen` 같은 화면 옵션은 받지 않습니다. `pageAnimated` 는 `animated` 로 바뀌었습니다.

```diff
-TnkSession.sharedInstance()?.adJoin(self, appId: adAppID, actionId: actionId) { success, error in }
+TnkPpiHybSdk.shared.adJoin(from: self, appId: Int64(adAppID), actionId: actionId)

-TnkSession.sharedInstance()?.adAction(self, appId: adAppID, actionId: actionId) { success, error in }
+TnkPpiHybSdk.shared.adAction(from: self, appId: Int64(adAppID), actionId: actionId)
```

세 호출 모두 오퍼월을 전체 화면으로 엽니다. 동의 전이면 동의 팝업이 먼저 나오고, 동의하면 해당 광고로 진입합니다(거부하면 진입하지 않습니다). 닫았을 때 사용자가 보는 화면이 다릅니다.

| 메서드 | 기존 네이티브 SDK 에서 닫으면 | 하이브리드 SDK 에서 닫으면 |
|---|---|---|
| `adDetail` | 개발사 화면으로 돌아옵니다. | 개발사 화면으로 돌아옵니다 (같음) |
| `adJoin` | 광고 페이지에서 돌아오면 개발사 화면이 보입니다. | 광고 페이지에서 돌아오면 **오퍼월 첫 화면**이 보입니다 (달라짐) |
| `adAction` | 개발사 화면으로 돌아옵니다. | **오퍼월 첫 화면**이 보입니다 (달라짐) |

닫았을 때 개발사 화면으로 바로 돌아가야 한다면 `adDetail` 을 쓰세요. 자세한 내용은 [8. 특정 광고 진입](ad-entry.md)을 보세요.

### 패턴 8. 시작 카테고리·필터 지정

**무엇이 바뀌나:** 오퍼월 객체에 `landingData` 를 지정하고 화면을 띄우는 두 단계가, 딥링크 한 번의 호출로 바뀝니다.

```diff
 let categoryId = "4"      // 관리자 화면에서 확인한 카테고리 ID
 let filterID = "509"      // 필터 ID

-let vc = AdOfferwallViewController()
-vc.title = "오퍼월"
-vc.landingData = "\(categoryId)//\(filterID)"
-let navController = UINavigationController(rootViewController: vc)
-navController.modalPresentationStyle = .fullScreen
-present(navController, animated: true)
+TnkPpiHybSdk.shared.handleScheme("tnkscheme://select_menu?cat_id=\(categoryId)&filter_id=\(filterID)", from: self)
```

오퍼월이 닫혀 있으면 SDK 가 오퍼월을 열고 해당 탭으로 이동합니다. 이미 열려 있으면 그 화면에서 이동합니다. 앱 화면 안에 넣은 오퍼월을 다른 탭에 로드해 두었다면 그 오퍼월에서 이동하므로, 오퍼월 탭으로 전환해 주세요.

| 파라미터 | 사용자가 보는 것 |
|---|---|
| `cat_id` | 오퍼월이 열리며 해당 카테고리 탭이 선택됩니다. **꼭 넣어야 합니다.** 기존 `landingData` 의 앞부분(카테고리 ID)을 씁니다. |
| `filter_id` | 그 탭에서 해당 필터까지 선택됩니다. 기존 `landingData` 의 뒷부분(필터 ID)을 씁니다. 생략하거나 그 탭에 없는 값이면 "전체"가 선택됩니다. |

- 오퍼월에 없는 `cat_id` 를 넣으면 오퍼월은 열리지만 해당 탭으로 이동하지 않습니다. 오퍼월의 화면 구성에 따라서도 이동하지 않을 수 있으니, ID 값이 확실하지 않으면 담당자에게 문의해 주세요.
- 딥링크를 받는 방법은 [6. 딥링크](deeplink.md)를 보세요.

<figure><img src="../assets/common/tab-selected-game.png" alt="게임 탭이 선택된 오퍼월 화면. 게임 탭에 밑줄이 있고 아래에 필터 칩과 광고 목록이 보임" width="300"><figcaption><p>handleScheme 로 열면 cat_id 로 지정한 탭(여기서는 게임)이 선택된 채 오퍼월이 열립니다.</p></figcaption></figure>

### 패턴 9. 앱 추적 동의(ATT) 요청

**무엇이 바뀌나:** `TnkAlerts.showATTPopup` 이 `requestTrackingAuthorization` 으로 바뀝니다. 초기화와 ATT 요청은 따로 호출합니다.

```diff
-TnkAlerts.showATTPopup(viewController,
-                       agreeAction: { /* 사용자 동의함 */ },
-                       denyAction: { /* 동의하지 않음 */ })
+TnkPpiHybSdk.shared.requestTrackingAuthorization { granted in
+    // granted == true : 사용자가 허용함, false : 허용하지 않음
+}
```

앱이 활성 상태가 된 뒤(`sceneDidBecomeActive`)에 한 번만 호출하는 것을 권장합니다. 앱이 활성 상태가 아닐 때 호출해도 SDK 가 활성 상태가 될 때까지 기다렸다가 요청합니다.

네이티브 가이드의 예시처럼 `showATTPopup` 의 콜백 안에서 초기화(`initInstance`)를 하셨다면, 하이브리드 SDK 에서는 초기화(`configure`)를 앱 시작 시점으로 옮기고 ATT 는 따로 요청하세요. ATT 결과를 기다리지 않아도 오퍼월은 열립니다. 사용자가 허용하지 않으면 참여할 수 있는 광고가 줄어들 수 있습니다.

값별 동작과 `NSUserTrackingUsageDescription` 문구는 [3. 초기화](initialize.md)의 'ATT 동의 요청' 과 [2. Info.plist 설정](plist.md)을 보세요.

---

## 컴파일러가 이관을 안내합니다

의존성을 바꾸고 빌드하면 기존 이름을 쓴 곳마다 컴파일 오류가 납니다. 이름이 바뀐 API 는 오류 메시지가 새 이름이나 새 사용법을 알려 주므로, 오류 목록을 이관 체크리스트로 쓸 수 있습니다. 이 안내는 빌드할 때만 보이며 앱 동작에는 영향이 없습니다.

아래는 Xcode 27.1 에서 확인한 표시입니다. Xcode 버전에 따라 문구가 다를 수 있습니다.

| 기존 호출 | 컴파일 오류 | Xcode 의 Fix 버튼 |
|---|---|---|
| `TnkSession` | `'TnkSession' has been renamed to 'TnkPpiHybSdk'` | 있음 |
| `sharedInstance()` | `has been renamed to 'shared'` | 있음. `shared` 는 옵셔널이 아니므로 `?.` 의 `?` 도 지워야 합니다 |
| `getApplicationId()` · `getIdForAdvertising()` | `has been renamed to 'getAppId()'` · `'getAdid()'` | 있음 |
| `setAgreePrivacyPolicy(_:)` | `has been renamed to 'setAgreePrivacy(_:)'` | 있음. 인자를 생략한 `setAgreePrivacyPolicy()` 는 `missing argument` 오류가 나므로 `setAgreePrivacy(true)` 로 직접 고칩니다. 인자로 변수를 넘기던 코드는 Fix 뒤 `if 앱에서동의함 { sdk.setAgreePrivacy(true) }` 로 바꾸세요. `false` 를 앱 시작마다 넘기면 사용자가 오퍼월에서 한 동의도 지워져 팝업이 매번 나옵니다 |
| `initInstance(appId:)` · `presentAdDetailView` · `adJoin` · `adAction` · `setCOPPA` · `setGDPRConsent` · `sdkVersion` | `is unavailable:` 뒤에 새 사용법이 적힌 메시지 | 없음. 메시지를 보고 이 페이지의 패턴대로 직접 고칩니다 |
| `setTrackingEnabled` | `is unavailable:` 뒤에 ATT 요청(`requestTrackingAuthorization`)을 안내하는 메시지 | 없음. 메시지를 따르지 마세요. 이 호출은 ATT 와 관계가 없으므로 호출을 삭제합니다 ('전체 API 대조표' 참고) |
| `setPhoneNumber` | `is unavailable:` 뒤에 하이브리드 SDK 가 제공하지 않는다는 메시지 | 없음. 현재 미제공이므로 사용 중이면 담당자에게 문의해 주세요 |
| `queryAdvertiseCount` · `queryPoint` · `appStartedOnceAMonth` · `actionCompleted` · `openPrivacyTermAlert` 처럼 없어진 호출 | `has no member '…'` | 없음. 아래 '전체 API 대조표'의 '제거'·'치환'·'현재 미제공(문의)' 행을 보세요 |
| `showMenuViewController(from:)` | `has been renamed to 'openOfferwall(from:)'` | 있음. Fix 를 적용하면 마이메뉴가 아니라 오퍼월 첫 화면이 열립니다. 그대로 쓸지는 '전체 API 대조표'의 `showMenuViewController` 행을 보고 정하세요. 실제 호출처럼 `menuType:` 을 넘기면 `extra argument 'menuType'` 오류가 납니다 |
| `AdOfferwallViewController` · `AdOfferwallView` · `TnkAlerts` · `TnkStyles` · `TnkLayout` · `AdPlacementView` · `OfferwallEventListener` | `cannot find … in scope` 계열 (클래스·프로토콜이 통째로 없어진 경우) | 없음. 패턴 3·4·9 와 '전체 API 대조표'의 해당 행을 보세요 |

---

## 전체 API 대조표

기존 네이티브 SDK 의 공개 API(`TnkSession` · `TnkAlerts` · `AdOfferwallView` 등)를 하나씩 대조한 표입니다. **구분** 열의 뜻은 다음과 같습니다.

| 구분 | 뜻 |
|---|---|
| **그대로** | 이름과 인자가 같습니다. 호출 대상과 import 만 바꾸면 됩니다. |
| **치환** | 대응하는 호출이 있습니다. 이름·인자·결과 형태가 다르니 표의 설명대로 바꿉니다. |
| **제거** | 하이브리드 SDK 에서는 필요 없는 호출입니다. 호출을 삭제하세요. |
| **현재 미제공(문의)** | 현재 하이브리드 SDK 에서는 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요. |

### 초기화 · 앱 실행

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `TnkSession.initInstance(appId:)` | `TnkPpiHybSdk.shared.configure(appId:)` — `Info.plist` 에 `tnkad_app_id` 만 넣었다면 호출을 생략해도 됩니다. | **치환** |
| `TnkSession.sharedInstance()` (옵셔널) | `TnkPpiHybSdk.shared` — 옵셔널이 아니므로 `?.` 가 필요 없습니다. | **치환** |
| `applicationStarted()` | `applicationStarted()` — 호출은 그대로 두거나 생략해도 오퍼월 표시와 보상 지급에 영향이 없습니다. 이 앱을 TNK 에 광고로 등록해 실행 보상 확인이나 분석 리포트를 쓰셨다면, 현재 하이브리드 SDK 는 그 요청을 보내지 않으니 담당자에게 문의해 주세요. | **그대로** |
| `appStartedOnceAMonth()` · `actionCompleted()` · `actionCompleted(actionName:)` | 이 앱을 TNK 에 광고로 등록해 실행·액션 완료를 알리던 호출입니다. 현재 미제공 — 담당자 문의. 오퍼월만 쓰신다면 오퍼월 동작과 관계가 없으니 호출을 삭제하세요. | **현재 미제공(문의)** |

### 사용자 · 기기 식별

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `setUserName(_:)` (자기 자신을 돌려줘서 이어 붙일 수 있음) | `setUserName(_:)` — 반환값이 없으므로 한 줄씩 나눕니다. 사용자 식별값이 바뀌면(처음 지정 포함) 동의가 초기화되므로 `setAgreePrivacy` 보다 먼저 호출합니다. | **치환** |
| `getUserName()` | `getUserName()` | **그대로** |
| `getApplicationId()` | `getAppId()` — 반환 형식이 `String?` 이고, 하이픈이 없는 값입니다. | **치환** |
| `getIdForAdvertising()` | `getAdid()` — 추적 허용(ATT) 전이거나 허용하지 않으면 32자리 0 입니다. | **치환** |
| `sdkVersion()` | `TnkPpiHybSdk.version` (`shared` 가 아니라 `TnkPpiHybSdk` 에서 읽습니다) | **치환** |
| `setPhoneNumber(_:)` | 현재 미제공 — 담당자 문의. | **현재 미제공(문의)** |

### 개인정보 동의 · 추적

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `setAgreePrivacyPolicy()` · `setAgreePrivacyPolicy(true)` | `setAgreePrivacy(true)` — 인자를 생략할 수 없습니다. 앱에서 직접 동의를 받은 경우에만, `setUserName` 다음에 호출합니다. | **치환** |
| `setAgreePrivacyPolicy(false)` (사용자 철회) | `revokePrivacyConsent()` — 사용자가 앱에서 '동의 철회' 를 눌렀을 때만 호출합니다. | **치환** |
| `openPrivacyTermAlert(parentViewController:onReturn:)` | 필요 없습니다. 오퍼월(특정 광고 진입 포함)에 들어갈 때 동의 팝업이 자동으로 나옵니다. 동의 여부는 `isAgreePrivacy()` 로 읽습니다. | **제거** |
| `setPrivacyAgreementListener(_:)` · `TnkPrivacyAgreementListener` | 사용자가 오퍼월에서 동의·철회했을 때 앱에 알려 주는 기능은 현재 미제공 — 담당자 문의. 동의 상태는 필요할 때 `isAgreePrivacy()` 로 확인할 수 있습니다. | **현재 미제공(문의)** |
| `setCOPPA(_ coppa: Bool)` | `setCOPPA(_ coppa: Int)` — `false` → `0`, `true` → `1` | **치환** |
| `setGDPRConsent(_ gdpr: Bool)` | `setGDPR(_ gdpr: Int)` — `true` → `1`, `false` → `0` | **치환** |
| `setTrackingEnabled(_:)` | 앱 추적 동의(ATT)와는 관계없는 설정이며, 하이브리드 SDK 는 사용하지 않습니다. 호출을 삭제하세요. | **제거** |
| `TnkAlerts.showATTPopup(_:agreeAction:denyAction:)` | `requestTrackingAuthorization { granted in }` (패턴 9) | **치환** |

### 오퍼월 열기 · 화면 안에 넣기

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `AdOfferwallViewController` 를 `UINavigationController` 에 담아 present | `openOfferwall(from:)` (패턴 3) | **치환** |
| `AdOfferwallView(frame:viewController:)` + `loadData()` | `TnkOfferwallView(frame:)` + `loadOfferwall(TnkPpiHybSdk.shared.buildOfferwallURL())`. 닫기는 `onCloseRequested` 로 처리하고, 화면을 없앨 때 `cleanup()` 을 호출합니다. (패턴 4) | **치환** |
| `UIViewControllerRepresentable` 로 감싼 `AdOfferwallViewController` (SwiftUI) | `UIViewRepresentable` 로 감싼 `TnkOfferwallView` (패턴 4) | **치환** |
| `landingData = "카테고리ID//필터ID"` (`AdOfferwallViewController` · `AdOfferwallView`) | `handleScheme("tnkscheme://select_menu?cat_id=..&filter_id=..", from:)` (패턴 8) | **치환** |
| `AdPlacementView` | 특정 광고·카테고리만 앱 화면 일부에 노출하는 플레이스먼트 뷰는 추후 제공될 예정입니다. 기존 네이티브 SDK 의 `AdPlacementView` 를 사용 중이시면 담당자에게 알려 주세요. | **현재 미제공(문의)** |
| `showMenuViewController(from:navigationPush:pageAnimated:fullscreen:menuType:)` (마이메뉴: 참여·적립 내역, 도움말, 문의) | 마이메뉴 화면을 바로 여는 기능은 현재 하이브리드 SDK 에서 제공하지 않습니다. 버튼을 그대로 두려면 `openOfferwall(from:)` 으로 오퍼월을 여세요. 오퍼월 첫 화면이 열리고, 참여·적립 내역과 도움말·문의는 상단 "문의/내역"에서 볼 수 있습니다. 마이메뉴로 바로 보내야 한다면 담당자에게 문의해 주세요. | **현재 미제공(문의)** |
| `getFaqPageUrl()` · `getHelpDeskUrl()` · `getRewardHistoryUrl()` · `getUseHistoryUrl()` · `getContactUsUrl()` · `getCpsMyPageUrl()` | 같은 내용이 오퍼월의 "문의/내역" 메뉴에 있습니다. 주소를 앱에서 얻는 기능은 현재 미제공 — 담당자 문의. | **현재 미제공(문의)** |
| `showCustomTapViewController(...)` | 현재 미제공 — 담당자 문의. | **현재 미제공(문의)** |
| `plusInstance()` · `getEventWebView` · `openEventWebView` · `getEventLink` (이벤트·Plus 계열) | 현재 미제공 — 담당자 문의. | **현재 미제공(문의)** |

<figure><img src="../assets/common/revoke-2-mypage.png" alt="문의/내역 화면. 적립내역, 도움말, 문의하기 탭이 있고 적립내역이 비어 있음" width="300"><figcaption><p>참여·적립 내역과 도움말·문의는 오퍼월 안의 "문의/내역" 메뉴에서 볼 수 있습니다.</p></figcaption></figure>

### 특정 광고 진입

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `presentAdDetailView(_:appId:subAppId:navigationPush:pageAnimated:fullscreen:actionId:completion:…)` | `adDetail(from:appId:actionId:animated:)` — `from:` 레이블이 붙고, `appId` 는 `Int64`, 결과 콜백과 화면 옵션이 없어집니다. | **치환** |
| `adJoin(_:appId:…:actionId:completion:…)` | `adJoin(from:appId:actionId:animated:)` | **치환** |
| `adAction(_:appId:…:actionId:completion:…)` | `adAction(from:appId:actionId:animated:)` — 닫으면 오퍼월 첫 화면이 보입니다. | **치환** |

### 포인트 · 광고 데이터

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `queryAdvertiseCount(completion:)` · `queryAdvertiseCount(target:action:)` | `getAdvertiseTotalPoint` 와 `getProductTotalPoint` 결과의 `adCount`·`pointAmount` 를 더합니다. (패턴 5) | **치환** |
| `queryAdvertiseCount(adType:completion:)` | 한 종류만 조회하던 호출은 `getAdvertiseTotalPoint`(일반 광고) 또는 `getProductTotalPoint`(구매형 광고) 하나만 호출합니다. | **치환** |
| `queryPublishState(completion:)` · `queryPublishState(target:action:)` · `PublisherState` | 게시 상태 조회는 현재 미제공 — 담당자 문의. 게시 상태에 따라 오퍼월 진입 버튼을 숨기던 앱은 문의해 주세요. | **현재 미제공(문의)** |
| `queryPoint(completion:)` · `queryPoint(target:action:)` | 사용자 포인트 잔액 조회는 현재 미제공 — 담당자 문의. TNK 서버에 포인트 관리를 맡기신 앱은 이관 전에 꼭 문의해 주세요. | **현재 미제공(문의)** |
| `purchaseItem(_:cost:…)` · `withdrawPoints(_:…)` (각 2종) | 아이템 구매·전체 인출은 현재 미제공 — 담당자 문의. 위와 같이 이관 전에 문의해 주세요. | **현재 미제공(문의)** |
| `addAdItemList(data:)` · `getAdItem(appId:)` · `getAdItemToJson(appId:)` | 광고 목록·상세는 오퍼월 화면이 직접 보여 주며, 광고 데이터를 앱으로 넘기는 기능은 현재 미제공 — 담당자 문의. | **현재 미제공(문의)** |

### 오퍼월 이벤트

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `OfferwallEventListener` (`didAdDataLoaded` · `didOfferwallTitleChanged` · `didMenuSelected` · `didAdItemClicked` · `didOfferwallRemoved` · `didDetailViewShow` · `didActionButtonClicked`) | 네이티브와 같은 종류의 이벤트는 현재 미제공 — 담당자 문의. 오퍼월이 닫혔는지는 전체 화면이면 오퍼월을 연 화면이 다시 나타날 때(`viewWillAppear`), 앱 화면 안에 넣었다면 `onCloseRequested` 로 알 수 있습니다. 적립 가능 포인트는 `getAdvertiseTotalPoint` 로 조회하고, 보상 지급 완료는 `setRewardListener` 로 받습니다. 오퍼월에서 일어난 이벤트를 이름과 JSON 문자열 그대로 받는 `setEventListener` 가 있지만 이벤트 종류가 달라 1:1 로 대응하지 않습니다 ([5. 보상 지급 수신](reward.md)). | **현재 미제공(문의)** |

### 디자인 설정

오퍼월 화면의 구성(탭·필터 등)은 TnkFactory 가 개발사별로 설정합니다. 앱 코드에서 바꾸는 방식이 아니므로, 바꾸고 싶은 부분은 담당자에게 요청해 주세요.

| 네이티브 | 하이브리드 | 구분 |
|---|---|---|
| `TnkStyles.shared.*` (색·폰트·포인트 아이콘 등) | 앱 코드에서 설정하지 않습니다. 호출을 삭제하세요. 바꾸고 싶은 화면 구성은 담당자에게 요청해 주세요. | **제거** |
| `TnkLayout.shared.registerItemViewLayout` · `registerMenuViewLayout` (목록·큐레이션·메뉴 레이아웃) | 앱 코드에서 설정하지 않습니다. 호출을 삭제하세요. | **제거** |
| `TnkLayout.shared.alertControl` · `loadingIndicatorFactory` (안내창·로딩 표시 사용자 정의) | 앱 코드에서 설정하지 않습니다. 호출을 삭제하세요. | **제거** |
| `TnkStyles.offerwallTheme = .dark` · `.light` | `extraParams` 의 `theme` (`"dark"` · `"light"`) — 아래 '다크 모드 고정' 과 [4. 오퍼월 띄우기](offerwall.md)의 '다크 모드' 항목 | **치환** |
| `TnkStyles.offerwallTheme = .system` · `.unspecified` | `theme` 를 넣지 않으면 기기(앱)의 다크 모드 설정을 따릅니다. 호출을 삭제하세요. | **제거** |

**다크 모드 고정:** 네이티브에서 `TnkStyles.offerwallTheme` 으로 고정했다면 오퍼월을 열 때 `theme` 를 넘깁니다. 넘기지 않으면 오퍼월은 기기(앱)의 다크 모드 설정을 따릅니다. 라이트로 고정했던 앱이 `theme` 를 빠뜨리면 다크 모드 기기에서 오퍼월이 어둡게 보입니다.

```diff
-TnkStyles.offerwallTheme = .dark
-// ... 오퍼월 열기
+TnkPpiHybSdk.shared.openOfferwall(from: self, extraParams: ["theme": "dark"])
```

<figure><img src="../assets/common/compare-light-dark.png" alt="왼쪽은 라이트 테마, 오른쪽은 다크 테마의 오퍼월 첫 화면" width="600"><figcaption><p>기기 설정(또는 theme 값)에 따라 오퍼월이 라이트·다크로 보입니다.</p></figcaption></figure>

지원 기능은 순차적으로 확대하고 있습니다.

---

## Objective-C 앱이라면

기존 네이티브 SDK 는 Objective-C 에서도 호출할 수 있었지만, 하이브리드 SDK 는 Swift 에서 호출하는 API 만 제공합니다. Objective-C 파일에서 `TnkPpiHybSdk` 를 바로 부를 수 없습니다.

Swift 파일 하나에 SDK 호출을 모아 두고, Objective-C 에서는 그 파일을 호출하는 방식으로 연동해 주세요. 직접 호출이 꼭 필요하시면 담당자에게 문의해 주세요.

```swift
// OfferwallHelper.swift — Objective-C 에서 부를 수 있도록 SDK 호출을 감싼 Swift 파일
import UIKit
import TnkPpiHyb

@objc(OfferwallHelper)
final class OfferwallHelper: NSObject {

    @objc static func setUp(appId: String, userName: String) {
        let sdk = TnkPpiHybSdk.shared
        sdk.configure(appId: appId)
        sdk.setUserName(userName)
    }

    @objc static func openOfferwall(from viewController: UIViewController) {
        TnkPpiHybSdk.shared.openOfferwall(from: viewController)
    }
}
```

```objective-c
// Objective-C 화면에서 — 프로젝트의 "<타깃 이름>-Swift.h" 를 import 합니다
#import "YourApp-Swift.h"

[OfferwallHelper setUpWithAppId:@"발급받은-앱-아이디" userName:@"개발사-사용자-식별값"];
[OfferwallHelper openOfferwallFrom:self];
```

---

## 이관 뒤 확인할 것

- [ ] 오퍼월이 열립니다. 시뮬레이터에서도 열리지만, 광고 참여 확인은 실기기에서 해 주세요.
- [ ] 처음 여는 사용자에게 동의 팝업이 나오고, 동의하면 광고 목록이 보입니다. 앱을 삭제한 뒤 다시 설치하면 처음 상태로 확인할 수 있습니다.
- [ ] 추적 허용(ATT) 팝업이 나옵니다. 나오지 않으면 `Info.plist` 의 `NSUserTrackingUsageDescription` 을 확인하세요.
- [ ] 광고 참여 뒤 서버 보상 콜백이 이전처럼 호출됩니다.
- [ ] 적립 가능 포인트를 표시하는 앱은 표시 값이 이전과 비슷한지 확인합니다.
- [ ] 대조표에서 '현재 미제공(문의)' 로 표시된 호출이 코드에 남아 있지 않은지 확인합니다.

---

다음: [문제 해결](troubleshooting.md)
