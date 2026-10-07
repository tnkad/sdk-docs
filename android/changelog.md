---
description: 하이브리드 오퍼월 SDK(Android) 버전별 변경 사항입니다.
---

# 릴리스 노트

패키지: `com.tnkfactory.ad:hrwd` · 설치 방법은 [1. 설치](install.md)를 참고하세요.

---

## 1.0.13 — 2026-10-07

- 다크모드에서 `TnkOfferwall.show`/`openOfferwall` 로 연 오퍼월의 하단 내비게이션 바 영역(제스처 내비게이션은 흰 줄, 3버튼 내비게이션은 밝은 회색)과 가로 화면에서 옆으로 오는 내비게이션 바 영역이 밝게 남던 문제를 수정했습니다. 해당 영역은 오퍼월 배경색으로 표시되고 내비게이션 바 아이콘 명암도 화면 테마에 맞춰집니다. 라이트모드는 이전과 같으며 연동 코드 변경은 필요 없습니다 — [4. 오퍼월 띄우기](offerwall.md)
- 오퍼월이 열리는 순간 다크모드에서 흰 화면이 잠깐 보이던 현상을 개선했습니다 — [4. 오퍼월 띄우기](offerwall.md)
- `TnkOfferwallView` 를 화면에 직접 배치한 경우 하단 영역은 앱 화면에서 처리합니다 — [4. 오퍼월 띄우기 — 화면 안에 삽입](offerwall.md#화면-안에-삽입)

## 1.0.12 — 2026-10-06

- 이전 버전 SDK(레거시 SDK 포함)에서 저장된 동의는 동의로 유지되며, 오퍼월의 "개인 정보 수집 동의 해제" 메뉴로 철회할 수 있습니다 — [7. 개인정보 설정](privacy.md)
- 오퍼월이 SDK 에 저장된 동의 상태를 기준으로 동의 여부를 판정합니다. 앱 재설치·데이터 복원 후에도 SDK 의 동의 상태와 일치합니다 — [7. 개인정보 설정](privacy.md)
- `setAgreePrivacy(context, true)` 로 설정한 경우에만 오퍼월의 동의 팝업과 "동의 해제" 메뉴가 노출되지 않습니다. 앱 시작 시마다 `setUserName` 다음에 호출하는 것을 권장합니다 — [7. 개인정보 설정](privacy.md)

## 1.0.11 — 2026-10-01

- 오퍼월에서 사용자가 동의·거부한 결과가 SDK 에 저장되어 `isAgreePrivacy(context)` 에 반영됩니다 — [7. 개인정보 설정](privacy.md)
- `setUserName` 으로 사용자가 바뀌면(최초 지정 포함) 동의 상태가 초기화됩니다. `setUserName` → `setAgreePrivacy` 순서로 호출하세요 — [7. 개인정보 설정](privacy.md)

**오퍼월 업데이트 (SDK 버전과 무관)**

- 특정 광고 진입(adDetail/adJoin/adAction)도 개인정보 동의 확인 후 진행됩니다 — [8. 특정 광고 진입](ad-entry.md)

## 1.0.10 — 2026-09-09

- 네이티브 콜백으로 적립 가능 포인트 조회 기능 추가 — [9. 적립 가능 포인트 조회](total-point.md)
- 상세 랜딩 액션 adDetail/adJoin/adAction 기능 추가 — [8. 특정 광고 진입](ad-entry.md)

## 1.0.6 — 2026-08-24

공개 가이드 최초 제공 기준 버전입니다.

- 전체화면 오퍼월(`openOfferwall`) 및 화면 내 삽입(`TnkOfferwallView`)
- 보상 지급 완료 알림(`setRewardListener`) · 범용 이벤트 수신(`setEventListener`)
- `tnkscheme://` 딥링크(`handleScheme`)
- 개인정보 동의 · COPPA · GDPR 설정
- 네이티브 SDK(`TnkSession` 계열) 시그니처 호환
