---
description: 오퍼월을 열기 전에 앱 화면에 "최대 적립 가능 포인트" 를 보여 주기 위한 getAdvertiseTotalPoint · getProductTotalPoint 사용 방법과, 결과 값별(null · 실패 응답 · 정상) 처리 방법을 설명합니다.
---

# 9. 적립 가능 포인트 조회

이 페이지에서 하는 일: 오퍼월에 들어가기 전에 앱 화면에 **"지금 최대 N 포인트 적립 가능"** 같은 문구를 보여 주기 위해, 현재 참여할 수 있는 광고의 적립 포인트 합계와 광고 수를 조회합니다.

---

## 언제 필요한가

**선택 사항**입니다. 앱의 오퍼월 입구(버튼·배너 등)에 적립 가능 포인트를 보여 주고 싶은 개발사에 필요합니다. Android SDK 1.0.10 이상에서 사용할 수 있습니다.

- 앱 ID 설정과 `setUserName` 호출을 마친 뒤에 조회하세요. ([3. 초기화](initialize.md) 참고)
- 문구가 보이는 화면이 나타날 때마다(`onResume` 등) 조회하면 최신 값을 보여 줄 수 있습니다. 호출할 때마다 서버에 조회하며, 참여할 수 있는 광고가 줄어들면 값도 바뀝니다.

---

## 호출하는 방법

광고 종류에 따라 함수가 둘로 나뉩니다.

| 함수 | 조회하는 광고 |
|---|---|
| `getAdvertiseTotalPoint` | 일반 광고(비구매형, PPI) — 설치·실행·액션형 등 구매형이 아닌 광고 |
| `getProductTotalPoint` | 구매형 광고(CPS) — 쇼핑 적립 광고 |

```kotlin
// 일반 광고(비구매형)
TnkPpiHybSdk.getAdvertiseTotalPoint(context) { info ->
    if (info != null && info.isSuccess && info.adCount > 0) {
        button.text = "최대 ${info.pointAmount}P 적립 가능 (${info.adCount}개)"
        button.visibility = View.VISIBLE
    } else {
        button.visibility = View.GONE   // 조회에 실패했거나 참여할 광고가 없으면 문구를 숨깁니다
    }
}

// 구매형 광고
TnkPpiHybSdk.getProductTotalPoint(context) { info ->
    // 위와 같은 방식으로 info 를 확인합니다
}
```

Java

```java
import android.view.View;
import com.tnkfactory.ad.hrwd.TnkPpiHybSdk;
import kotlin.Unit;

TnkPpiHybSdk.getAdvertiseTotalPoint(context, info -> {
    if (info != null && info.isSuccess() && info.getAdCount() > 0) {
        button.setText("최대 " + info.getPointAmount() + "P 적립 가능 (" + info.getAdCount() + "개)");
        button.setVisibility(View.VISIBLE);
    } else {
        button.setVisibility(View.GONE);
    }
    return Unit.INSTANCE;   // Kotlin 함수 타입 콜백은 Unit 을 돌려줘야 합니다
});
```

- 콜백은 **항상 메인 스레드**에서 호출됩니다. 곧바로 UI 를 갱신해도 됩니다.
- 조회에 실패해도 콜백이 호출됩니다. 이때 `info` 가 `null` 이거나 `isSuccess` 가 `false` 입니다.
- 앱에 보여 줄 포인트 단위(예: `P`)는 앱에서 붙입니다.

---

## 결과 값별 동작

콜백으로 받은 값에 따라 처리하세요.

| 콜백으로 받은 값 | 의미 | 앱이 할 일 |
|---|---|---|
| `null` | 통신 오류, 인증 실패, 응답을 읽지 못한 경우입니다 | 문구를 숨깁니다. 사유는 개발 빌드에서 켠 로그에서 확인합니다 |
| `isSuccess` 가 `false` 인 결과 | 서버가 실패로 응답했습니다. 사유는 `retMessage`, 응답 코드는 `retCode` 에 있습니다 | 문구를 숨깁니다 |
| `isSuccess` 가 `true` 인 결과 | 정상입니다 | `pointAmount` · `adCount` 를 보여 줍니다. 둘이 `0` 이면 적립 가능한 광고가 없는 것이므로 문구를 숨기는 것을 권장합니다 |

서버가 실패로 응답한 경우에는 `null` 이 아니라 `isSuccess` 가 `false` 인 결과가 옵니다. 그래서 위 예제처럼 **`null` 과 `isSuccess` 를 모두 확인**해야 합니다.
`enableLogging` 사용법은 [3. 초기화](initialize.md)를 참고하세요.

## `TotalPointInfo`

| 필드 | 타입 | 설명 |
|------|------|------|
| `pointAmount` | `Long` | 적립 가능 포인트 총합. 없으면 `0` |
| `adCount` | `Int` | 적립 가능 광고 수. 없으면 `0` |
| `isSuccess` | `Boolean` | 서버가 성공으로 응답했는지. `retCode` 가 `0` 이면 `true` |
| `retCode` | `Int` | 응답 코드. `0` 이면 성공, 응답 코드가 없으면 `-1` |
| `retMessage` | `String?` | 실패 메시지. 없으면 `null` |

> 이 값은 **광고 참여로 받을 수 있는 포인트의 총합**입니다.
> 사용자가 이미 적립한 **잔액**과는 다른 개념입니다. 잔액은 개발사 포인트 시스템이
> [서버 보상 콜백](../common/server-callback.md)으로 적립한 값을 직접 관리합니다.

---

## 기존 네이티브 SDK 와 다른 점

| 기존 네이티브 SDK (`com.tnkfactory:rwd`) | 하이브리드 SDK |
|---|---|
| `getEarnPoint` — 일반 광고와 구매형 광고의 합계를 **한 숫자**로 돌려줌 | `getAdvertiseTotalPoint`(일반 광고)와 `getProductTotalPoint`(구매형 광고)를 **각각 호출**합니다. 한 숫자로 보여 주려면 두 결과의 `pointAmount` 를 더하세요 |
| `getEarnPointByFilter` — 필터별 합계 | 현재 하이브리드 SDK 에서는 제공하지 않습니다. 필요하신 경우 담당자에게 문의해 주세요 |
| `queryPoint` — 사용자 보유 포인트(잔액) 조회 | 현재 하이브리드 SDK 에서는 제공하지 않습니다. 잔액은 서버 보상 콜백으로 받은 값을 개발사에서 관리해 주세요. TNK 서버에서 포인트를 관리하던 앱은 담당자에게 문의해 주세요 |

기존 `getEarnPoint` 코드를 옮기는 방법은 [네이티브 SDK 에서 이관](migration.md)을 참고하세요.

---

## 계정을 바꿀 때

로그아웃 후 다른 계정으로 로그인해 `setUserName` 으로 사용자를 바꿨다면, 조회하기 전에 `clearApiSession()` 을 한 번 호출하세요.

```kotlin
TnkPpiHybSdk.setUserName(context, "새-사용자-식별값")
TnkPpiHybSdk.clearApiSession()   // 이전 사용자 정보로 조회가 이어지지 않도록
```

호출하지 않으면 이전 사용자 정보로 조회가 이어질 수 있습니다. 계정을 바꾸지 않는 앱은 호출하지 않아도 됩니다.

---

지원 기능은 순차적으로 확대하고 있습니다.

다음: [공개 API 목록](api.md)
