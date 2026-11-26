---
description: 오퍼월 전체를 Flutter 앱 화면 안(예를 들어 하단 탭)에 넣는 TnkOfferwallView 위젯의 사용법. 닫기 요청, Android 뒤로가기, 딥링크, 크기·제스처·SafeArea 주의사항을 안내합니다.
---

# 5. 화면 안에 오퍼월 넣기

이 페이지에서 하는 일: 오퍼월 전체를 앱 화면의 일부(예: 하단 탭 하나)로 넣는 `TnkOfferwallView` 위젯을 사용합니다.

## 언제 필요한가

**선택 사항**입니다. 오퍼월을 전체 화면으로 여는 것이 아니라 앱 레이아웃의 일부로 보여 주고 싶은 개발사에 필요합니다. `openOfferwall` 은 이 위젯을 쓰는 앱에서도 그대로 전체 화면으로 엽니다.

- 오퍼월 전체가 아니라 지면 하나의 광고 묶음만 넣으려면 [4. 플레이스먼트](placement.md)를 쓰세요.
- `initialize` 와 `setUserName` 을 위젯이 만들어지기 **전에** 마치세요. 위젯은 가능한 한 빨리 오퍼월을 불러옵니다 — [2. 초기화](initialize.md)
- Android 와 iOS 만 지원합니다. 다른 플랫폼에서는 위젯이 비어 있습니다.

---

## 사용 방법

```dart
final controller = TnkOfferwallController();

// 앱의 한 탭. 화면 맨 위가 상태바이므로 SafeArea 안에 넣습니다.
SafeArea(
  bottom: false,
  child: TnkOfferwallView(
    extraParams: const {'hideHeader': '1'}, // 선택: 오퍼월 자체 헤더 숨기기
    handleBackButton: tabIsSelected,         // 아래 '뒤로가기(Android)' 참고
    onCloseRequested: () {
      // 오퍼월이 닫기를 요청했습니다. 무엇을 할지는 앱이 정합니다.
    },
    controller: controller,                  // 선택
  ),
)
```

| 인자 | 설명 |
|---|---|
| `extraParams` | 오퍼월 주소에 덧붙이는 값(예: `hideHeader`, `theme`). 기본 `null` 은 아무것도 넣지 않습니다. 표에 없는 키는 넣지 마세요 — [Android 4. 오퍼월 띄우기](../android/offerwall.md)의 '화면 설정'. 내용이 바뀌면 오퍼월을 다시 불러오고, 같은 내용의 새 맵으로는 다시 불러오지 않습니다 |
| `onCloseRequested` | 오퍼월이 닫기를 요청했을 때. 아래 '닫기 요청' 참고 |
| `handleBackButton` | **Android 전용.** 기본 `true`. 아래 '뒤로가기(Android)' 참고 |
| `keepAlive` | 기본 `true`. 항목을 필요할 때 만드는 목록이나 `PageView` 에서 화면 밖으로 나가도 네이티브 뷰를 유지해 오퍼월을 다시 불러오지 않습니다([4. 플레이스먼트](placement.md)의 `keepAlive` 와 같은 뜻) |
| `controller` | `TnkOfferwallController`. `isAttached` 와, 오퍼월 안에서 한 단계 뒤로 가는 `goBack()` 을 제공합니다. `goBack()` 은 실제로 뒤로 갔는지(`bool`)를 돌려줍니다. 네이티브 뷰가 만들어지기 전과 위젯이 제거된 뒤에는 `false` |

---

## 알아둘 것

- **크기.** 위젯은 주어진 공간을 모두 채우므로 폭과 높이가 정해져 있어야 합니다(`Expanded`, `SizedBox`, 탭 본문). 크기가 정해지지 않은 `ListView` 안에 넣지 마세요.
- **한 번만 불러옵니다.** 탭을 바꿔도 오퍼월을 다시 불러오지 않습니다. iOS 는 위젯의 네이티브 뷰가 만들어질 때 불러옵니다. Android 는 위젯이 화면에 처음 그려질 때 불러오므로, 보이지 않는 탭(예: `IndexedStack` 안)에 미리 만들어 둔 위젯은 그 탭이 처음 보일 때 불러옵니다. 탭이 처음 선택될 때 위젯을 만들거나, 미리 만들어 `IndexedStack`(또는 `PageView`)에 두어 페이지와 스크롤 위치를 유지하세요.
- **닫기 요청.** 오퍼월에서 닫기 버튼이 있는 화면(상단 헤더, 거부한 동의 화면, 네트워크 오류 대화상자의 '닫기' 버튼)은 `onCloseRequested` 만 호출합니다. 플러그인은 Android·iOS 모두에서 앱 화면이나 앱을 닫지 않습니다. 콜백이 없으면 요청은 무시됩니다.
- **다시 불러오기.** 위젯은 마지막 페이지를 유지합니다. `setUserName` 으로 사용자를 바꾼 뒤, 또는 네트워크 오류 대화상자에서 '닫기'를 누른 뒤(SDK 가 웹 화면을 비운 다음 `onCloseRequested` 가 옵니다)에는 이전 사용자의 화면이 남거나 빈 화면이 될 수 있습니다. 이런 경우 오퍼월을 다시 보여 주려면 [4. 플레이스먼트](placement.md)의 위젯처럼 새 `Key` 로 위젯을 다시 만드세요. `controller.reload()` 는 아직 제공하지 않습니다.
- **제스처.** 위젯 위의 모든 터치는 네이티브 웹 화면으로 갑니다(세로 스크롤, 오퍼월 안의 가로 스와이프, iOS 의 가장자리 스와이프 뒤로가기). 위젯을 감싼 Flutter 스크롤 화면은 위젯 위의 터치로는 스크롤되지 않습니다.
- **SafeArea.** 위젯은 상태바나 노치만큼 오퍼월을 안쪽으로 밀어 주지 않습니다. `SafeArea` 안에 넣으세요.
- **보상.** 위젯 안에서 받은 보상은 전체 화면 오퍼월과 같이 `TnkPpiHybSdk.rewards` 로 옵니다 — [3. 전체 화면 오퍼월](offerwall.md)

### 뒤로가기(Android)

위젯이 보이는 상태이고 오퍼월이 되돌아갈 곳(웹 기록, 또는 오퍼월이 직접 연 상세 화면 같은 레이어)이 있으면, 기기 뒤로가기 버튼과 뒤로가기 제스처가 먼저 오퍼월로 가서 한 번에 한 단계씩 돌아갑니다. 첫 화면에서는 위젯이 관여하지 않고 앱의 뒤로가기 처리가 실행됩니다(예: 화면 나가기, 앱 종료).

- `handleBackButton: false` 이면 가로채지 않습니다.
- 위젯은 `TickerMode` 로 숨겨졌는지 판단합니다. 하지만 `IndexedStack` 에서 보이지 않는 자식도 활성 상태이므로, `IndexedStack` 을 쓸 때는 `handleBackButton: <이 탭이 선택됨>` 으로 넘기세요.
- `controller.goBack()` 은 같은 한 단계를 앱 코드에서 실행합니다.
- 오퍼월은 자신의 기록을 비동기로 알려 주므로, 페이지가 바뀐 직후의 뒤로가기는 한 번 앱으로 갈 수 있습니다.
- 위젯이 뒤로가기를 가져가면, 같은 라우트의 앱 `PopScope` 도 `didPop == false` 로 함께 호출됩니다(Flutter 가 라우트의 모든 `PopScope` 에 알립니다). "뒤로가기를 한 번 더 누르면 종료" 같은 카운터를 그 콜백에 두었다면 오퍼월이 가져간 뒤로가기도 함께 세게 됩니다.
- iOS 에는 하드웨어 뒤로가기 버튼이 없으므로 `handleBackButton` 은 아무 일도 하지 않습니다. iOS 의 `goBack()` 은 웹 기록만 거슬러 갑니다. Android 는 오퍼월이 직접 연 레이어도 닫습니다.

### 딥링크

위젯이 오퍼월을 불러온 상태라면 `TnkPpiHybSdk.handleScheme` 은 새 화면을 열지 않고 `tnkscheme://` 링크를 이 위젯으로 전달합니다. 위젯의 탭이 숨겨져 있어도 마찬가지입니다.

- iOS 는 네이티브 뷰가 만들어진 때부터 전달됩니다.
- Android 는 위젯이 처음 그려진 뒤부터 전달됩니다. 그 전(한 번도 보이지 않은 탭에 미리 만든 위젯)에는 링크가 위젯으로 가지 않고 `handleScheme` 이 전체 화면 오퍼월을 엽니다. 오퍼월 탭으로 먼저 전환한 뒤 `handleScheme` 을 호출하세요. 한 번도 보이지 않은 탭으로 막 전환한 직후에도 링크가 전체 화면 오퍼월을 열 수 있습니다(오퍼월은 그 탭이 처음 보이는 첫 프레임에 만들어집니다).

### Android 전용 참고

- **상태바 아이콘 색.** 오퍼월 페이지가 밝은/어두운 화면으로 바뀌면 Android SDK 가 앱 창의 상태바 아이콘 색을 바꿉니다. Flutter 는 이 변경을 모릅니다. Flutter 는 자신의 `SystemUiOverlayStyle`(`AppBar` 또는 `SystemChrome.setSystemUIOverlayStyle`)이 바뀌거나 앱이 포그라운드로 돌아올 때만 다시 보내므로, SDK 가 바꾼 아이콘 색이 그때까지 남을 수 있습니다. 앱 상태바 배경과 어울리지 않으면 `extraParams` 의 `theme` 를 앱 화면에 맞춰 고정하세요.
- **파일 첨부.** SDK 는 호스트 Activity 가 `ComponentActivity` 일 때만 `<input type="file">` 의 파일 선택(예: 문의에 사진 첨부)을 띄울 수 있습니다. 기본 `FlutterActivity` 는 `ComponentActivity` 가 아니라서 파일 선택이 동작하지 않습니다. 사용자가 파일을 첨부해야 한다면 `MainActivity` 의 부모 클래스를 `FlutterFragmentActivity` 로 바꾸세요. 위젯의 나머지는 둘 다 동작합니다.
- **Activity 가 다시 만들어질 때.** 엔진이 유지된 채 Activity 가 다시 만들어지거나 바뀌면(`configChanges` 없는 화면 회전, 캐시된 엔진의 새 화면) 위젯은 자리를 지키고 새 Activity 에서 오퍼월을 다시 불러옵니다(페이지와 스크롤 위치는 사라집니다). 뷰는 앱의 일시정지·재개를 따릅니다.
- **성능.** Android 의 삽입 오퍼월은 하이브리드 컴포지션(Hybrid Composition) 플랫폼 뷰입니다. 오퍼월이 화면에 있는 동안 Flutter 가 프레임을 플랫폼 스레드에서 합성하고, Android 10 미만에서는 프레임마다 메인 메모리를 거쳐 복사합니다. 같은 화면에 무거운 Flutter 애니메이션이 있으면 프레임이 떨어질 수 있습니다.

다음: [기존 플러그인에서 이관](migration.md)
