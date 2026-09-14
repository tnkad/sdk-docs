---
description: 오퍼월 목록을 거치지 않고 특정 광고의 상세·참여로 바로 진입하는 adDetail · adJoin · adAction 사용 방법입니다.
---

# 8. 특정 광고 진입

개발사 화면(배너, 푸시, 이벤트 페이지 등)에서 **특정 광고로 바로 보낼 때** 사용합니다.
오퍼월 목록을 거치지 않고 해당 광고의 상세 또는 참여로 곧장 진입합니다.

네이티브 SDK 의 `adDetail` / `adJoin` / `adAction` 과 같은 이름·의미입니다.

---

## 세 가지 진입 방식

```kotlin
TnkPpiHybSdk.adDetail(context, appId)   // 상세 화면으로
TnkPpiHybSdk.adJoin(context, appId)     // 상세 없이 바로 참여
TnkPpiHybSdk.adAction(context, appId)   // 리스트 클릭과 동일 규칙
```

| 메서드 | 동작 | 닫으면 |
|--------|------|--------|
| `adDetail` | 해당 광고의 **상세 화면**을 무조건 띄웁니다 | 오퍼월도 함께 닫혀 개발사 화면으로 복귀 |
| `adJoin` | 상세 없이 **바로 참여** 후 광고주 페이지로 이동 | — |
| `adAction` | 오퍼월 리스트를 클릭한 것과 **동일 규칙** (광고 설정에 따라 상세 또는 바로 참여) | 오퍼월 홈 |

`appId` 는 진입시킬 광고의 캠페인 ID 입니다. 어떤 광고를 노출할지는
TnkFactory 담당자와 캠페인 협의 시 전달받습니다.

## `actionId`

기본값 `0` 을 그대로 쓰시면 됩니다. **구매형(CPS·쇼핑) 광고만 `5`** 를 지정합니다.

```kotlin
TnkPpiHybSdk.adDetail(context, appId, actionId = 5)   // 구매형 광고
```

---

## 오퍼월 진입과의 차이

- [`openOfferwall`](offerwall.md) — 오퍼월 **홈(목록)** 으로 진입
- `adDetail` / `adJoin` / `adAction` — **특정 광고 하나**로 진입

초기화 요건은 동일합니다 — [`setUserName`](initialize.md) 이 설정돼 있어야 보상이 정상 지급됩니다.

---

다음: [9. 적립 가능 포인트 조회](total-point.md)
