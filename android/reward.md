---
description: TnkRewardListener 로 보상 지급 완료를 수신하는 방법과 RewardInfo 필드 정의. 실제 포인트 지급은 서버 콜백으로 처리해야 합니다.
---

# 5. 보상 지급 수신

> ⚠️ **이 콜백은 UI 갱신용입니다.**
> 실제 포인트 지급은 **TNK 서버 → 개발사 백엔드 콜백**으로 처리하셔야 합니다.
> 클라이언트 콜백만 믿고 지급하면 위·변조로 부정 적립이 발생합니다.
> [서버 보상 콜백 URL](../common/server-callback.md)을 반드시 함께 구현하세요.

---

## 등록

```kotlin
TnkPpiHybSdk.setRewardListener { reward ->
    Toast.makeText(
        this,
        "${reward.payPoint}${reward.pointUnit ?: ""} 적립",
        Toast.LENGTH_SHORT,
    ).show()
    refreshMyPointBalance()   // 개발사 자체 잔액 UI 갱신
}
```

Java

```java
TnkPpiHybSdk.setRewardListener(reward -> {
    Toast.makeText(this, reward.getPayPoint() + " 적립", Toast.LENGTH_SHORT).show();
    refreshMyPointBalance();
});
```

콜백은 **항상 메인 스레드**에서 호출되므로 곧바로 UI 를 갱신해도 됩니다.
해제할 때는 `null` 을 넘깁니다.

```kotlin
TnkPpiHybSdk.setRewardListener(null)
```

---

## `RewardInfo`

| 필드 | 타입 | 설명 |
|------|------|------|
| `appId` | `Long` | 광고 ID. 파싱 실패 시 `0` |
| `appName` | `String?` | 광고명. 없으면 `null` |
| `payPoint` | `Long` | 지급 포인트. 파싱 실패 시 `0` |
| `pointUnit` | `String?` | 개발사 포인트 명칭(예: `"P"`). 없으면 `null` |
| `payType` | `Int` | 지급 유형. 없으면 `-1` |
| `actionId` | `Int` | 액션 유형. 없으면 `-1` |

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

---

## 범용 이벤트 수신 (선택)

오퍼월(FE)이 보내는 모든 이벤트를 원본 JSON 그대로 받을 수 있습니다.
SDK 버전을 올리지 않고도 새로운 이벤트 종류를 받아야 할 때 사용하세요.

```kotlin
TnkPpiHybSdk.setEventListener { type, rawJson ->
    Log.i("TNK", "event type=$type payload=$rawJson")
}
```

`type` 이 `"rewardCompleted"` 인 이벤트는 `TnkRewardListener` 로도 함께 전달됩니다.
두 리스너를 모두 등록했다면 **같은 보상이 두 번 통지된다는 점**에 유의하세요.

---

다음: [6. 딥링크](deeplink.md)

> 실제 지급 구현은 [서버 보상 콜백 URL](../common/server-callback.md) 을 참고하세요.
