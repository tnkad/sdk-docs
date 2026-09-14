---
description: 개발사 화면에 "최대 적립 가능 포인트" 를 표시하기 위한 getAdvertiseTotalPoint · getProductTotalPoint 사용 방법입니다.
---

# 9. 적립 가능 포인트 조회

오퍼월에 들어가기 전, 개발사 화면에 **"지금 최대 N 포인트 적립 가능"** 같은 문구를
띄우고 싶을 때 사용합니다. 현재 참여 가능한 광고들의 적립 포인트 총합과 광고 수를 돌려줍니다.

```kotlin
// 비구매형(PPI) — 설치·실행·액션형 광고
TnkPpiHybSdk.getAdvertiseTotalPoint(context) { info ->
    if (info != null && info.isSuccess) {
        button.text = "최대 ${info.pointAmount}P 적립 가능 (${info.adCount}개)"
    }
}

// 구매형(CPS) — 쇼핑 적립 광고
TnkPpiHybSdk.getProductTotalPoint(context) { info -> /* 동일 */ }
```

- 콜백은 **항상 메인 스레드**에서 호출됩니다 — 곧바로 UI 를 갱신해도 됩니다.
- 네트워크 오류·응답 실패 시 **`null`** 이 전달됩니다. 사유는 [`enableLogging`](initialize.md) 로 확인하세요.

## `TotalPointInfo`

| 필드 | 타입 | 설명 |
|------|------|------|
| `pointAmount` | `Long` | 적립 가능 포인트 총합. 없으면 `0` |
| `adCount` | `Int` | 적립 가능 광고 수. 없으면 `0` |
| `isSuccess` | `Boolean` | 서버가 성공으로 응답했는지 |
| `retCode` | `Int` | 응답 코드. `0` 이 성공 |
| `retMessage` | `String?` | 실패 메시지. 없으면 `null` |

> 이 값은 **광고 참여로 받을 수 있는 포인트의 총합**입니다.
> 사용자가 이미 적립한 **잔액**과는 다른 개념이며, 잔액은 개발사 포인트 시스템이
> [서버 보상 콜백](../common/server-callback.md)으로 적립한 값을 직접 관리합니다.

---

다음: [공개 API 목록](api.md)
