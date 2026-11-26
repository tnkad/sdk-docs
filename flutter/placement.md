---
description: 담당자에게 받은 지면 ID 로 광고 묶음 하나를 Flutter 앱 화면 일부에 보여 주는 TnkPlacementView 위젯과, 광고 목록을 데이터로 받아 직접 그리는 loadPlacementData 방식의 사용법을 안내합니다.
---

# 4. 플레이스먼트

이 페이지에서 하는 일: 앱 화면 중간(스크롤 화면 안 등)에 **지면(플레이스먼트) 하나의 광고 묶음**을 보여 줍니다. SDK 가 목록을 그려 주는 `TnkPlacementView` 위젯과, 목록을 데이터로 받아 앱이 직접 그리는 `loadPlacementData` 두 가지 방식이 있습니다.

## 언제 필요한가

**선택 사항**입니다. 오퍼월 전체가 아니라 지면 하나의 광고 묶음만 앱 화면 일부에 보여 주고 싶은 개발사에 필요합니다. 기존 `tnk_flutter_rwd` 의 `getPlacementJsonData`·`onItemClick` 을 쓰던 앱은 이 페이지의 방식으로 바꿀 수 있습니다 — [기존 플러그인에서 이관](migration.md)

- 지면 ID 는 TnkFactory 담당자에게 받은 값을 그대로 넣으세요. 지면은 앱 ID 마다 등록되므로 Android·iOS 앱 ID 가 다르면 앱 ID 별로 지면 ID 를 받아 주세요. 같은 앱에 등록된 기존 지면 ID 는 그대로 씁니다.
- 지면 ID 와 지면 설정(제목·더보기 문구 등)은 앱 코드로 바꿀 수 없습니다. 담당자에게 요청해 주세요.
- `initialize` 와 `setUserName` 을 마친 뒤에 불러오세요 — [2. 초기화](initialize.md)
- 레이아웃 키(`layoutKey`), 지면 유형, 머리글, 테마 같은 지면 자체의 동작은 Android·iOS 와 같습니다 — [Android 10. 플레이스먼트 뷰](../android/placement.md) · [iOS 10. 플레이스먼트 뷰](../ios/placement.md)
- Android 와 iOS 만 지원합니다. 다른 플랫폼에서는 위젯이 비어 있고 `onFailed(-1)` 이 호출됩니다.

> ⚠️ Android 에뮬레이터·가상 기기에서는 지면이 표시되지 않습니다. 동작 확인은 실기기에서 해 주세요. 지면 레이아웃도 출시 전에 실기기에서 확인하세요.

---

## 방식 1. 위젯: SDK 가 목록을 그립니다

```dart
final controller = TnkPlacementController();

ListView(children: [
  // ... 앱의 다른 위젯 ...
  TnkPlacementView(
    placementId: '<지면 ID>',
    layoutKey: 'DEFAULT',        // 또는 FEED_SWIPE, BOX, ... (선택)
    theme: 'dark',               // 'light' | 'dark' | null = 기기 설정을 따름
    filterIds: const [1, 2],     // 선택
    handleMoreClick: false,      // true: 앱이 '더보기'를 처리
    controller: controller,
    onLoaded: (info) => debugPrint('광고 수: ${info.count}'),
    onFailed: (code) => debugPrint('실패: $code'),
    onItemClicked: (appId, appName) {},
    onItemClosed: (appId) => controller.refresh(), // 참여 결과를 목록에 반영
    onMoreClicked: () {},
    onHeightChanged: (height) {},
  ),
]);
```

위 `<지면 ID>`, `[1, 2]` 는 예시 값입니다. `layoutKey` 로 쓸 수 있는 키는 [Android 10. 플레이스먼트 뷰](../android/placement.md)의 '레이아웃 키'를 보세요.

### 인자

| 인자 | 설명 |
|---|---|
| `placementId` | (필수) 담당자에게 받은 지면 ID |
| `layoutKey` | 레이아웃 키. 대소문자를 구분하지 않으며 모르는 키는 기본 레이아웃으로 그립니다. `null` 이면 기본 |
| `theme` | `light` 또는 `dark`. 그 밖의 값과 `null` 은 기기 설정을 따릅니다 |
| `filterIds` | 이 필터 ID 의 광고만 보여 줍니다. `null` 이면 필터 없음 |
| `handleMoreClick` | 사용자가 '더보기'를 눌렀을 때의 처리. 아래 '더보기' 참고. 기본 `false` |
| `keepAlive` | 항목을 필요할 때 만드는 목록(lazy list)에서 화면 밖으로 나가도 네이티브 뷰를 유지할지. 기본 `true` |
| `controller` | `TnkPlacementController`. `refresh()` · `clickItem()` 을 코드에서 호출할 때 |
| `onLoaded` | 불러오기에 성공했을 때. `info.count` 가 `0` 이면 보여 줄 광고가 없다는 뜻이며 위젯은 접힌 채로 있습니다 |
| `onFailed` | 불러오기에 실패했을 때(위젯은 접힙니다). 코드: `-2` 5초 안에 응답 없음, `-1` 네트워크·그 밖의 오류, 그 외는 서버 코드 |
| `onItemClicked` | 사용자가 광고를 눌렀을 때. 이어서 SDK 가 상세 화면을 엽니다 |
| `onItemClosed` | 광고를 눌러 열린 화면이 닫혔을 때. 참여 결과를 목록에 반영하려면 여기서 `refresh()` 를 호출합니다 |
| `onMoreClicked` | 사용자가 '더보기'를 눌렀을 때 |
| `onHeightChanged` | 위젯 높이가 바뀔 때(`0` 으로 접힐 때도). Flutter 논리 픽셀 단위 |

### 동작

- **높이.** 위젯은 폭이 정해져 있어야 합니다(`ListView` 의 자식이면 됩니다). 불러오기 전, 광고가 없을 때, 불러오기에 실패했을 때는 높이가 `0` 이고, 불러온 뒤에는 내용 높이를 따릅니다. `onHeightChanged` 는 바뀔 때마다 한 번 호출되며 `0` 으로 접힐 때도 호출됩니다. Android·iOS 가 같습니다.
- **제스처.** 세로 드래그는 Flutter 스크롤 화면이 스크롤하고, 가로 드래그는 SDK 로 갑니다(`FEED_SWIPE` 같은 스와이프 레이아웃).
- **설정 바꾸기.** `placementId`, `layoutKey`, `theme`, `filterIds` 가 바뀌면 지면을 다시 불러옵니다(위젯이 먼저 접힙니다). `handleMoreClick` 은 다시 불러오지 않고 '더보기'의 처리만 바꿉니다.
- **더보기.** SDK 는 '더보기' 처리를 네이티브에서 바로 정해야 해서 Dart 의 답을 기다릴 수 없습니다. `handleMoreClick: true` 이면 앱이 처리합니다(SDK 는 아무것도 열지 않고 `onMoreClicked` 만 호출). `false`(기본)이면 SDK 가 오퍼월 홈을 엽니다(이때도 `onMoreClicked` 는 호출됩니다).
- **컨트롤러.** `controller.refresh()` 는 접지 않고 목록을 다시 불러옵니다(SDK 는 불러오는 중에는 무시하고, 실패한 뒤에는 다시 불러옵니다). `controller.clickItem(appId)` 는 사용자가 누른 것처럼 클릭을 실행하고 `TnkPlacementClickResult`(`success`, `code`) 를 한 번 돌려줍니다. 위젯의 네이티브 뷰가 만들어지기 전이나 제거된 뒤에는 `refresh()` 는 아무 일도 하지 않고 `clickItem` 은 `success: false, code: -1` 을 돌려줍니다. 위젯 하나에 컨트롤러 하나를 쓰세요.
- **keepAlive.** 기본적으로 위젯은 항목을 필요할 때 만드는 목록(`ListView`, `ListView.builder`, `GridView`, `PageView`)에서 화면 밖으로 나가도 유지되어, 돌아왔을 때 다시 불러오지 않습니다. 대신 네이티브 뷰가 메모리에 남습니다. 화면 밖에 유지된 위젯도 `clickItem` 을 받으므로, `clickItem` 은 사용자가 보이는 목록을 눌렀을 때만 호출하세요. 지면이 많은 긴 목록에서는 `keepAlive: false` 를 주면 멀리 벗어났을 때 Flutter 가 위젯을 버리고, 돌아오면 다시 불러옵니다. 위젯을 담은 바깥 목록 항목(예: `PageView` · `TabBarView` 의 한 페이지)도 함께 유지되므로 원하지 않으면 `keepAlive: false` 를 쓰세요. 항목을 필요할 때 만드는 목록 밖이나 `addAutomaticKeepAlives: false` 로 만든 목록에서는 `keepAlive` 가 효과가 없습니다.
- **사용자 변경.** 같은 화면에서 `setUserName` 으로 사용자를 바꾸면, 유지 중인 위젯은 이전에 불러온 목록을 계속 보여 줍니다. 위젯에 새 `Key` 를 주어 다시 만드세요.
- **Activity 가 다시 만들어질 때(Android).** 엔진이 유지된 채 Activity 가 다시 만들어지거나 바뀌면(예: `configChanges` 없는 화면 회전) 위젯은 자리를 지키고 새 Activity 에서 다시 불러옵니다. `onLoaded` 가 다시 호출됩니다. 그때 상세 화면이 열려 있었다면 그 `onItemClosed` 는 오지 않습니다. 광고를 눌러 SDK 가 여는 화면은 앱의 Activity 에서 앱의 작업(task) 안에 시작됩니다.

### 코드로 클릭하기

`controller.clickItem(appId)` 는 사용자가 목록을 탭한 것과 같은 클릭을 실행하고 `onItemClicked` · `onItemClosed` 를 호출합니다. **사용자 동작에 대한 응답으로만** 호출하세요(예: 앱이 그린 목록을 사용자가 누를 때). 화면이 나타날 때나 목록이 도착한 직후처럼 자동으로 호출하면 안 됩니다. `success` 는 화면이 열리기 시작했다는 뜻일 뿐, 사용자가 참여했거나 보상을 받았다는 뜻이 아닙니다.

---

## 방식 2. 데이터: 앱이 목록을 그립니다

SDK 가 그리지 않고 광고 목록을 Dart 객체로 받아 앱이 직접 그립니다.

```dart
final data = await TnkPpiHybSdk.loadPlacementData('<지면 ID>', theme: 'light');
for (final ad in data.adList) {
  // ad.appName, ad.imageUrl, ad.point 등으로 그립니다.
  // 사용자가 이 광고를 눌렀을 때만:
  //   final result = await data.clickItem(ad.appId); // TnkPlacementClickResult: success, code
}

data.itemClosed.listen((appId) => data.refresh());  // 클릭으로 연 화면이 닫힘
data.loaded.listen((info) {
  // 목록이 다시 불러와짐: data.adList 를 다시 그립니다
});
await data.dispose();                               // 필요 없어지면
```

`loadPlacementData(placementId, {layoutKey, filterIds, theme})` 의 `layoutKey`·`filterIds`·`theme` 은 위젯의 같은 이름 인자와 같습니다.

| `TnkPlacementData` | 설명 |
|---|---|
| `adList` | 마지막으로 성공한 불러오기의 광고 목록(서버 순서, 수정 불가) |
| `count` | 광고 수. `0` 이면 보여 줄 광고가 없는 것(오류가 아님) |
| `pubInfo` | 지면 정보(`TnkPlacementPubInfo`). SDK 가 값을 주지 않았으면 `null` |
| `customData` | 서버가 지면에 보낸 값. 없으면 빈 문자열 |
| `placementId` | 불러온 지면 ID |
| `loaded` | 처음 불러온 뒤 목록을 다시 불러올 때마다 알립니다(예: `refresh()`). 알림이 올 때 이미 `adList` 는 갱신되어 있습니다 |
| `failed` | 나중의 불러오기가 실패했을 때. 데이터는 이전 값 그대로입니다 |
| `itemClosed` | 광고 클릭으로 연 화면이 닫힐 때마다 `appId` 를 알립니다. 참여 결과를 반영하려면 여기서 `refresh()` 를 호출합니다 |
| `refresh()` | 현재 데이터를 지우지 않고 목록을 다시 불러옵니다. 요청을 보냈을 때 끝나며 새 목록은 `loaded` 로 받습니다 |
| `clickItem(appId)` | 사용자가 누른 것처럼 클릭을 실행하고 `TnkPlacementClickResult`(`success`, `code`) 를 돌려줍니다. 위 '코드로 클릭하기'와 같은 주의사항이 적용됩니다 |
| `dispose()` | 숨겨 둔 SDK 뷰를 제거하고 스트림을 닫습니다. 여러 번 호출해도 안전합니다 |
| `isDisposed` | `dispose()` 를 호출했는지 |

- 불러오기에 실패하면 `TnkPlacementException` 이 발생하고 `code` 를 담습니다: `-2` 5초 안에 응답 없음(안전장치로 20초), `-1` 네트워크·그 밖의 오류(불러오는 동안 Android 화면이 완전히 사라진 경우 포함), 그 외는 서버 코드. 실패하면 남는 핸들은 없습니다. 광고가 없는 지면은 오류가 아닙니다(`count == 0`).
- 데이터를 붙일 화면이 없으면 `PlatformException` 이 발생합니다(Android `no_activity`, iOS `no_presenter`). 앱이 화면에 보이는 동안 호출하세요.
- 핸들마다 `dispose()` 를 호출할 때까지 숨겨진 SDK 뷰를 하나 유지합니다(Android: 현재 Activity 안의 `GONE` 뷰, iOS: 키 윈도우 안의 높이 0 숨김 뷰). 핸들은 서로 독립적입니다. 필요 없어지면 `dispose()` 하세요.
- Android 에서 엔진이 유지된 채 Activity 가 다시 만들어지면 핸들은 새 Activity 에 새 숨김 뷰를 만들어 같은 설정으로 다시 불러오고, 결과는 `loaded`(또는 `failed`)로 옵니다. 그때 상세 화면이 열려 있었다면 그 `itemClosed` 는 오지 않고, 그 사이의 `clickItem` 은 `success: false, code: -1` 을 돌려줍니다. Activity 가 완전히 사라지거나 엔진이 분리되면 뷰가 해제되고 핸들의 호출은 '불러오지 않음' 응답을 돌려줍니다. 이후의 Activity 가 핸들을 되살리지 않으므로 `loadPlacementData` 를 다시 호출하세요.

### 광고 항목 (`TnkPlacementAdItem`)

`pubInfo` 는 7개 필드, 광고 항목은 19개 필드입니다. 화면을 그리기 위한 값이며, 보상이나 정산 판단에 쓰지 마세요.

| 필드 | 타입 | 설명 |
|---|---|---|
| `appId` | `int` | 광고 번호. 이벤트·뉴스 행(`isLink`)은 그 행의 ID |
| `actionId` | `int` | 액션 ID |
| `appName` | `String` | 앱 또는 행의 이름 |
| `imageUrl` | `String` | 메인 이미지 주소 |
| `iconUrl` | `String` | 아이콘 주소 |
| `point` | `int` | 적립 포인트 |
| `originalPoint` | `int` | 배율 이벤트 전 포인트. 없으면 `0` |
| `pointUnit` | `String` | 포인트 단위 이름 |
| `pointText` | `String` | 포인트 수 대신 보여 줄 문구. 없으면 빈 문자열 |
| `price` | `int` | 상품 가격(구매형) |
| `originalPrice` | `int` | 할인 전 가격(구매형) |
| `discountRate` | `int` | 할인율(%) |
| `isMultiMission` | `bool` | 멀티 미션 광고인지 |
| `campaignType` | `int` | 캠페인 유형 코드 |
| `campaignTypeName` | `String` | 캠페인 유형 이름. 없으면 빈 문자열 |
| `likeYn` | `String` | 즐겨찾기 상태: `Y`, `N` 또는 빈 문자열 |
| `filterId` | `int` | 불러올 때 지정한 `filterIds` 와 맞는 필터 ID |
| `isLink` | `bool` | 광고가 아닌 링크 행(이벤트·뉴스)인지 |
| `actionDesc` | `String` | 액션 설명. 없으면 빈 문자열 |

| `TnkPlacementPubInfo` 필드 | 타입 | 설명 |
|---|---|---|
| `placementId` | `String` | 불러온 지면 ID |
| `adType` | `int` | 지면 유형: 0 일반, 1 쇼핑, 2 제휴몰, 3 뉴스, 4 이벤트, 5 퀴즈. 알 수 없으면 `-1` |
| `title` | `String` | 지면 제목. 없으면 빈 문자열 |
| `moreLabel` | `String` | '더보기' 버튼 문구. 없으면 빈 문자열 |
| `customData` | `String` | 서버가 지면에 보낸 값. 없으면 빈 문자열 |
| `pointUnit` | `String` | 매체 포인트 이름. 없으면 빈 문자열 |
| `layoutKey` | `String` | 그려진 레이아웃의 공개 키. 키 표에 없는 레이아웃이면 빈 문자열 |

---

## 현재 지원하지 않는 것: `maxHeight`, `verticalScrollEnabled`

하이브리드(V4) Android·iOS SDK 의 플레이스먼트 뷰에는 지면을 고정 높이 안에서 스크롤하게 하는 `maxHeight`, `verticalScrollEnabled` 옵션이 있습니다([Android 10. 플레이스먼트 뷰](../android/placement.md)의 '높이와 세로 스크롤'). Flutter 플러그인은 이 두 옵션을 현재 지원하지 않습니다. 위젯은 항상 내용 높이를 따릅니다.

다음: [5. 화면 안에 오퍼월 넣기](embedded-offerwall.md)
