---
description: 사용자가 오퍼월에서 보상을 받은 직후 앱이 알림을 받는 방법(TnkRewardListener)과 RewardInfo 필드, 알림이 오는 경우·오지 않는 경우를 설명합니다. 실제 포인트 지급은 서버 콜백으로 처리해야 합니다.
---

# 5. 보상 지급 수신

이 페이지에서 하는 일: 사용자가 오퍼월에서 보상을 받은 직후 앱이 알림을 받아, 앱 화면(포인트 잔액 등)을 바로 새로 고치는 방법을 설명합니다.

---

## 언제 필요한가

**선택 사항**입니다. 오퍼월에서 보상을 받은 직후 앱의 포인트 표시를 바로 갱신하고 싶은 개발사에 필요합니다.
이 알림을 등록하지 않아도 오퍼월과 포인트 지급은 정상적으로 동작합니다.

> ⚠️ **이 콜백은 UI 갱신용입니다.**
> 실제 포인트 지급은 **TNK 서버 → 개발사 백엔드 콜백**으로 처리하셔야 합니다.
> 클라이언트 콜백만 믿고 지급하면 위·변조로 부정 적립이 발생합니다.
> [서버 보상 콜백 URL](../common/server-callback.md)을 반드시 함께 구현하세요.

---

## 등록

오퍼월을 열기 전에 등록하세요. 알림은 오퍼월 화면이 열려 있는 동안에만 옵니다.

```kotlin
class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        TnkPpiHybSdk.setRewardListener { reward ->
            Toast.makeText(
                applicationContext,
                "${reward.payPoint}${reward.pointUnit ?: ""} 적립",
                Toast.LENGTH_SHORT,
            ).show()
            refreshMyPointBalance()   // 개발사 서버에서 잔액을 다시 조회해 화면 갱신
        }
    }

    override fun onDestroy() {
        TnkPpiHybSdk.setRewardListener(null)   // 화면이 사라지면 해제
        super.onDestroy()
    }
}
```

Java

```java
TnkPpiHybSdk.setRewardListener(reward -> {
    Toast.makeText(getApplicationContext(), reward.getPayPoint() + " 적립", Toast.LENGTH_SHORT).show();
    refreshMyPointBalance();
});
```

- 콜백은 **항상 메인 스레드**에서 호출되므로 곧바로 UI 를 갱신해도 됩니다.
- 리스너는 **하나만** 유지됩니다. 다시 등록하면 이전 리스너가 바뀌므로, 여러 화면에서 오퍼월을 여는 앱은 한 곳에서 등록하세요.
- SDK 는 등록한 리스너를 **해제할 때까지 계속 보관**합니다. Activity 에서 등록했다면 위 예시처럼 `onDestroy` 에서 `null` 로 해제하세요. 해제하지 않으면 Activity 가 닫힌 뒤에도 메모리에 남을 수 있습니다.
- 앱 전체에서 한 번만 등록하려면 `Application.onCreate` 에서 등록하고, 리스너 안에서는 Activity 가 아니라 `applicationContext` 를 쓰세요.

| 리스너 상태 | 동작 |
|---|---|
| 등록함 | 아래 표의 보상이 지급되면 호출됩니다 |
| 등록하지 않음 | 알림이 없습니다. 오퍼월과 서버 콜백에는 영향이 없습니다 |
| `setRewardListener(null)` | 이후 알림이 없습니다 |

---

## 알림이 오는 경우 · 오지 않는 경우

모든 보상에 알림이 오는 것은 **아닙니다.** 사용자가 오퍼월 화면 안에서 참여를 마치고 **그 자리에서 지급이 확정된 보상**에만 옵니다.

| 보상 | 앱의 리스너 | 서버 콜백 |
|---|---|---|
| 설치형 광고 — 설치를 확인한 뒤 바로 지급 | 호출됨 (지급 직후) | 호출됨 |
| 클릭형 광고 — 광고 페이지에 들어간 뒤 정해진 시간이 지나 바로 지급 | 호출됨 | 호출됨 |
| 이벤트(출석체크 등) — 포인트 받기 | 호출됨 | 호출됨 |
| 실행형 · 액션형 · 동영상 · 구매형 광고처럼 광고주 확인 뒤에 지급이 확정되는 보상 | **호출되지 않음** | 지급이 확정되면 호출됨 |
| 지급이 지연되거나 지급되지 않은 경우 | **호출되지 않음** | 지급이 확정되면 호출됨 |

위 표는 현재 오퍼월 화면 기준입니다. 리스너로 오지 않는 보상이 있으므로 **잔액은 리스너가 아니라 서버 콜백으로 적립한 값을 기준**으로 관리하세요. 앱 화면으로 돌아올 때마다(`onResume` 등) 개발사 서버에서 잔액을 다시 조회하면 리스너가 오지 않는 보상도 반영됩니다.

> 💡 이벤트(출석체크 등) 보상은 오퍼월 화면이 적립 완료 안내를 보여 줍니다. 설치형·클릭형 보상은 오퍼월 화면에 따로 안내가 나오지 않으므로, 사용자에게 알리고 싶다면 앱에서 직접 안내하세요.
> 리스너로 받은 `payPoint` 를 앱 잔액에 **직접 더하지 마세요.** `refreshMyPointBalance()` 처럼 개발사 서버에서 잔액을 다시 불러오세요.

---

## `RewardInfo`

| 필드 | 타입 | 설명 | 값이 없으면 |
|------|------|------|------|
| `appId` | `Long` | 광고 ID. 이벤트 보상이면 이벤트 ID | `0` |
| `appName` | `String?` | 광고명. 이벤트 보상에서는 `null` | `null` |
| `payPoint` | `Long` | 지급 포인트 | `0` |
| `pointUnit` | `String?` | 개발사 포인트 명칭(예: `"P"`). 이벤트 보상에서는 `null` | `null` |
| `payType` | `Int` | 지급 유형 | `-1` |
| `actionId` | `Int` | 액션 유형 | `-1` |

현재 리스너로 오는 보상의 `payType` · `actionId` 는 보통 다음과 같습니다.

| 보상 | `payType` | `actionId` |
|---|:-:|:-:|
| 설치형 광고 | `0` | `0` |
| 클릭형 광고 | `0` | `4` |
| 이벤트(출석체크 등) | `3` | `6` |

### `payType`

| 값 | 의미 |
|----|------|
| `0` | 참여 적립 |
| `1` | 쇼핑 적립 |
| `2` | 제휴몰 |
| `3` | 이벤트 |

### `actionId`

| 값 | 의미 |
|----|------|
| `0` | 설치형 |
| `1` | 실행형 |
| `2` | 액션형 |
| `3` | 동영상 |
| `4` | 클릭형 |
| `5` | 구매형 |
| `6` | 이벤트(출석체크 등) |

> 쇼핑 적립(`payType` 1) 등은 현재 리스너로 오지 않으므로 서버 콜백으로 확인하세요.
> 분기 처리를 한다면 표에 없는 값도 들어올 수 있다고 가정하세요.

---

## 범용 이벤트 수신 (권장하지 않음)

`setEventListener` 는 오퍼월 화면에서 일어난 이벤트를 이벤트 이름과 JSON 문자열 그대로 받는 리스너입니다. 고급·디버깅 용도입니다.
보상 알림도 이 리스너로 함께 전달되므로, **두 리스너를 모두 등록하면 같은 보상이 두 번 통지됩니다.** 보상 알림은 `setRewardListener` 로만 받으세요.

그 밖의 이벤트 이름과 형식은 예고 없이 바뀔 수 있습니다. 앱 동작의 근거로 쓰지 마세요. 특정 이벤트가 필요하시면 담당자에게 문의해 주세요.
Activity 에서 등록했다면 `setRewardListener` 와 마찬가지로 `onDestroy` 에서 `setEventListener(null)` 로 해제하세요.

---

> 실제 지급 구현은 [서버 보상 콜백 URL](../common/server-callback.md) 을 참고하세요.

다음: [6. 딥링크](deeplink.md)
