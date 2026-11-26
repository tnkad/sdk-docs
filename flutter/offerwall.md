---
description: Flutter 에서 전체 화면 오퍼월을 여는 openOfferwall, 닫힘 알림(offerwallClosed), 보상 알림(rewards), 적립 가능 포인트 조회, 특정 광고 진입(adDetail · adJoin · adAction), 딥링크(handleScheme) 사용법을 안내합니다.
---

# 3. 전체 화면 오퍼월

이 페이지에서 하는 일: 오퍼월을 앱 화면 위에 전체 화면으로 열고, 닫힘·보상 알림을 받고, 적립 가능 포인트 조회·특정 광고 진입·딥링크를 처리합니다.

## 언제 필요한가

`openOfferwall` 은 오퍼월을 여는 모든 개발사에게 필요합니다. 나머지(닫힘·보상 알림, 포인트 조회, 특정 광고 진입, 딥링크)는 필요한 항목만 쓰는 **선택 사항**입니다.
오퍼월을 앱 화면 안(예: 하단 탭)에 넣으려면 [5. 화면 안에 오퍼월 넣기](embedded-offerwall.md)를 보세요.

호출 전에 [2. 초기화](initialize.md)의 `initialize` 와 `setUserName` 을 마쳐야 합니다.

---

## 오퍼월 열기

```dart
await TnkPpiHybSdk.openOfferwall();
```

호출하면 오퍼월이 앱 화면 위에 전체 화면으로 열립니다. 사용자는 상단의 닫기(X) 버튼으로 닫고 앱 화면으로 돌아옵니다(Android 는 기기의 뒤로가기로도 닫을 수 있습니다).

- `openOfferwall` 이 돌려주는 `Future` 는 **화면을 열도록 요청했을 때** 끝납니다. 사용자가 닫을 때가 아닙니다. 닫힘은 아래 `offerwallClosed` 로 압니다.
- 앱이 화면에 보이는 동안 호출하세요. 화면을 띄울 곳이 없으면 `PlatformException` 이 발생합니다. Android 는 `no_activity`(Flutter 엔진에 연결된 Activity 가 없음), iOS 는 `no_presenter`(보이는 창이 없거나 앱이 백그라운드). Android 에서 앱이 백그라운드일 때는 예외 없이 성공하고 시스템이 화면 시작을 막을 수도 있습니다.
- Android 에뮬레이터·가상 기기에서는 오퍼월이 열리지 않습니다. 실기기에서 확인하세요.

### 화면 설정 (`extraParams`)

화면 모양을 바꾸는 값을 `extraParams` 로 넘길 수 있습니다. 공개된 키는 `hideHeader`, `hideBack`, `theme` 세 가지입니다.

```dart
await TnkPpiHybSdk.openOfferwall(extraParams: {'theme': 'dark'}); // 항상 어둡게, 'light' = 항상 밝게
```

값의 의미와 주의사항은 Android·iOS 와 같습니다 — [Android 4. 오퍼월 띄우기](../android/offerwall.md)의 '화면 설정'·'다크 모드'

> ⚠️ 전체 화면으로 열 때는 `hideHeader`·`hideBack` 을 쓰지 마세요. 전체 화면 오퍼월을 닫는 버튼은 오퍼월 상단 바의 닫기(X) 하나뿐입니다. 표에 없는 키는 넣지 마세요.

### 닫힘 알림 (`offerwallClosed`)

사용자가 오퍼월에서 앱으로 돌아온 시점에 포인트를 다시 조회하거나 화면을 갱신하려면 `offerwallClosed` 를 구독합니다. 닫힐 때마다 한 번 알림이 옵니다.

```dart
final sub = TnkPpiHybSdk.offerwallClosed.listen((_) async {
  final info = await TnkPpiHybSdk.getTotalPoint();
  // 화면 갱신
});

// 화면이 사라질 때
await sub.cancel();
```

`openOfferwall`, `adDetail`, `adJoin`, `adAction` 으로 연 전체 화면이 닫힐 때 알림이 옵니다. Android·iOS 가 같지만, 어떤 화면까지 알리는지가 다릅니다.

| 플랫폼 | 알림이 오는 화면 |
|---|---|
| Android | SDK 의 전체 화면이면 누가 열었든 모두 알립니다 |
| iOS | 이 플러그인의 메서드로 연 화면만 알립니다. 새 화면을 여는 `handleScheme` 링크도 포함합니다. 화면이 완전히 닫힌 뒤에 알림이 옵니다 |

---

## 보상 알림 (`rewards`)

사용자가 오퍼월에서 보상을 받은 직후 앱의 포인트 표시를 바로 갱신하려면 `rewards` 를 구독합니다.

```dart
final rewardSub = TnkPpiHybSdk.rewards.listen((reward) {
  debugPrint('${reward.payPoint}${reward.pointUnit ?? ''} 적립');
  // 개발사 서버에서 잔액을 다시 조회해 화면 갱신
});

// 화면이 사라질 때
await rewardSub.cancel();
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `appId` | `int` | 광고(캠페인) 번호 |
| `appName` | `String?` | 광고 이름 |
| `payPoint` | `int` | 지급된 포인트 |
| `pointUnit` | `String?` | 포인트 단위 |
| `payType` | `int` | 지급 유형 코드 |
| `actionId` | `int` | 보상이 속한 액션 ID |

- 첫 구독 때 SDK 의 보상 리스너가 등록되고, 마지막 구독이 취소되면 해제됩니다.
- 앱 화면 안에 넣은 오퍼월(`TnkOfferwallView`)에서 받은 보상도 같은 `rewards` 로 옵니다.
- 한 프로세스에 Flutter 엔진이 여러 개인 앱(add-to-app)은 지원하지 않습니다. SDK 가 프로세스당 리스너를 하나만 유지합니다.
- 이 플러그인이 SDK 의 보상·이벤트 리스너를 가집니다. 앱의 네이티브 코드에서 직접 설정하면 `rewards` 가 더 이상 오지 않습니다.

> ⚠️ **이 알림은 UI 갱신용입니다.** 실제 포인트 지급은 **TNK 서버 → 개발사 백엔드 콜백**으로 처리하셔야 합니다. 클라이언트 알림만 믿고 지급하면 위·변조로 부정 적립이 발생합니다. [서버 보상 콜백 URL](../common/server-callback.md)을 반드시 함께 구현하세요.

### 원시 이벤트 (`events`)

`TnkPpiHybSdk.events` 는 오퍼월이 보내는 원시 이벤트(이름과 JSON)를 줍니다. **고급 사용·디버깅 전용**입니다. 이벤트 이름과 내용은 오퍼월이 정하며 예고 없이 바뀔 수 있고, 내용에 광고 주소(URL)가 들어 있을 수 있습니다. 출시 빌드에서는 로그에 쓰거나 외부 서비스로 보내지 마세요. 보상에 반응하려면 `rewards` 를 쓰세요.

---

## 적립 가능 포인트 조회

오퍼월 입구(버튼·배너 등)에 "최대 N 포인트 적립 가능" 같은 문구를 보여 줄 때 씁니다.

```dart
final info = await TnkPpiHybSdk.getTotalPoint();
if (info != null && info.isSuccess && info.adCount > 0) {
  // '최대 ${info.pointAmount}P 적립 가능 (${info.adCount}개)' 표시
} else {
  // 조회에 실패했거나 참여할 광고가 없으면 문구를 숨깁니다
}
```

| 호출 | 설명 |
|---|---|
| `getTotalPoint()` | 일반(비구매형)과 구매형 광고의 적립 가능 포인트·광고 수를 합산해 돌려줍니다 |
| `getAdvertiseTotalPoint()` | 일반(비구매형, PPI) 광고만 |
| `getProductTotalPoint()` | 구매형(CPS) 광고만 |

세 호출 모두 `Future<TotalPointInfo?>` 를 돌려주며, 조회에 실패하면 `null` 입니다.

| `TotalPointInfo` 필드 | 타입 | 설명 |
|---|---|---|
| `pointAmount` | `int` | 적립 가능 포인트 총합 |
| `adCount` | `int` | 적립 가능 광고 수 |
| `retCode` | `int` | 서버 응답 코드. `0` 이면 성공 |
| `retMessage` | `String?` | 서버 응답 메시지 |
| `isSuccess` | `bool` | `retCode` 가 `0` 이면 `true` |

`null` 과 `isSuccess` 를 모두 확인하세요. 서버가 실패로 응답한 경우에는 `null` 이 아니라 `isSuccess` 가 `false` 인 결과가 옵니다. 값별 처리와 한쪽만 실패했을 때의 동작은 [Android 9. 적립 가능 포인트 조회](../android/total-point.md)·[iOS 9. 적립 가능 포인트 조회](../ios/total-point.md)와 같습니다.

> 이 값은 **광고 참여로 받을 수 있는 포인트의 총합**입니다. 사용자가 이미 적립한 **잔액**과는 다릅니다. 잔액은 개발사 서버가 [서버 보상 콜백](../common/server-callback.md)으로 받은 값을 직접 관리합니다.

계정을 바꿨다면(`setUserName` 으로 다른 사용자로 변경) 조회하기 전에 `clearApiSession()` 을 한 번 호출하세요.

```dart
await TnkPpiHybSdk.setUserName('<새 사용자 식별값>');
await TnkPpiHybSdk.clearApiSession(); // 이전 사용자 정보로 조회가 이어지지 않도록
```

---

## 특정 광고 진입

배너·푸시·이벤트 페이지 같은 앱 화면에서 오퍼월 목록을 거치지 않고 특정 광고의 상세·참여로 바로 보냅니다.

```dart
await TnkPpiHybSdk.adDetail(123456);   // 상세 화면으로
await TnkPpiHybSdk.adJoin(123456);     // 상세 없이 바로 참여
await TnkPpiHybSdk.adAction(123456);   // 오퍼월 목록에서 누른 것과 같은 규칙
```

| 호출 | 사용자가 보는 것 |
|---|---|
| `adDetail(appId, {actionId = 0})` | 오퍼월이 열리고 해당 광고의 상세 화면이 바로 보입니다 |
| `adJoin(appId, {actionId = 0})` | 상세 없이 바로 참여가 진행되고 광고 페이지로 이동합니다 |
| `adAction(appId, {actionId = 0})` | 오퍼월 목록에서 그 광고를 누른 것과 같습니다 |

- 여기서 `appId` 는 초기화에 넣은 개발사 앱 ID 가 아니라 보낼 **광고(캠페인) 번호**입니다(`int`). 어떤 광고를 보낼지는 TnkFactory 담당자와 캠페인을 협의할 때 전달받습니다. 위 `123456` 은 예시 값입니다.
- `actionId` 는 기본값 `0` 을 그대로 쓰세요. 구매형(CPS·쇼핑) 광고만 `5` 를 지정합니다. `adDetail(123456, actionId: 5)`
- 호출 전에 `setUserName` 이 설정돼 있어야 보상이 정상 지급됩니다.
- 세 호출 모두 항상 오퍼월을 **전체 화면**으로 엽니다. 결과를 돌려주지 않으며, 광고가 종료됐거나 찾을 수 없으면 오퍼월이 직접 안내합니다. `Future` 는 화면을 열도록 요청했을 때 끝납니다.
- `openOfferwall` 과 같이 앱이 화면에 보이는 동안 호출하세요(`no_activity` · `no_presenter` 예외).
- 개인정보 수집 동의가 필요하면 오퍼월이 동의 팝업을 먼저 보여 줍니다.

사용자가 보는 화면과 동의와의 관계는 Android·iOS 와 같습니다 — [Android 8. 특정 광고 진입](../android/ad-entry.md) · [iOS 8. 특정 광고 진입](../ios/ad-entry.md)

---

## 딥링크 (`handleScheme`)

푸시 알림·배너 등으로 받은 `tnkscheme://` 링크를 SDK 에 넘기면 오퍼월이 해당 위치로 열립니다.

```dart
final consumed = await TnkPpiHybSdk.handleScheme(
  'tnkscheme://select_menu?cat_id=3&filter_id=301',
);
if (!consumed) {
  // SDK 가 처리하지 않은 링크: 앱이 직접 처리합니다
}
```

- 반환값이 `true` 이면 SDK 가 링크를 처리했고, `false` 이면 앱이 직접 처리해야 하는 링크입니다.
- 화면을 여는 다른 메서드와 달리, 앱 화면이 보이지 않아도 예외를 던지지 않습니다. 이때는 SDK 에 링크만 전달됩니다.
- 앱 화면 안에 넣은 오퍼월(`TnkOfferwallView`)이 이미 불러와진 상태라면 새 화면을 열지 않고 그 뷰로 링크를 전달합니다 — [5. 화면 안에 오퍼월 넣기](embedded-offerwall.md)

지원하는 링크 종류와 카테고리·필터·큐레이션 ID 는 [Android 6. 딥링크](../android/deeplink.md)의 '지원하는 딥링크'와 같습니다. 위 `3`·`301` 은 예시 값이며, 실제 ID 는 TnkFactory 담당자에게 받으세요.

다음: [4. 플레이스먼트](placement.md)
