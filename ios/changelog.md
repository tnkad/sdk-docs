---
description: 하이브리드 오퍼월 SDK(iOS) 버전별 변경 사항입니다.
---

# 릴리스 노트

패키지: `TnkPpiHyb` (SPM · CocoaPods) · 설치 방법은 [1. 설치](install.md)를 참고하세요.

- 배포 저장소 · 버전별 바이너리: [tnkad/ios-ppi-hyb-sdk — Releases](https://github.com/tnkad/ios-ppi-hyb-sdk/releases)
- 연동 샘플 (SPM · CocoaPods 예제 각 1개): [tnkad/ios-ppi-hyb-sample](https://github.com/tnkad/ios-ppi-hyb-sample)

---

## 1.0.3 — 2026-10-06

- 이전 버전 SDK 에서 저장된 동의는 동의로 유지되며, 오퍼월의 "개인 정보 수집 동의 해제" 메뉴로 철회할 수 있습니다 — [7. 개인정보 설정](privacy.md)
- 오퍼월이 SDK 에 저장된 동의 상태를 기준으로 동의 여부를 판정합니다. 앱 재설치·데이터 복원 후에도 SDK 의 동의 상태와 일치합니다 — [7. 개인정보 설정](privacy.md)
- `setAgreePrivacy` 는 앱 시작 시마다 `setUserName` 다음에 호출하는 것을 권장합니다 — [7. 개인정보 설정](privacy.md)

## 1.0.2 — 2026-10-01

- 최소 지원 iOS 버전을 15.0 으로 상향 — [1. 설치](install.md)
- 오퍼월에서 사용자가 동의·거부한 결과가 SDK 에 저장되어 `isAgreePrivacy()` 에 반영됩니다 — [7. 개인정보 설정](privacy.md)
- `setUserName` 으로 사용자가 바뀌면(최초 지정 포함) 동의 상태가 초기화됩니다. `setUserName` → `setAgreePrivacy` 순서로 호출하세요 — [7. 개인정보 설정](privacy.md)

**오퍼월 업데이트 (SDK 버전과 무관)**

- `setAgreePrivacy(true)` 로 설정한 앱에서는 오퍼월의 동의 팝업과 "개인 정보 수집 동의 해제" 메뉴가 노출되지 않습니다. 동의 철회는 매체 앱이 `setAgreePrivacy(false)` 로 처리합니다 — [7. 개인정보 설정](privacy.md)
- 특정 광고 진입(adDetail/adJoin/adAction)도 개인정보 동의 확인 후 진행됩니다 — [8. 특정 광고 진입](ad-entry.md)

## 1.0.1 — 2026-09-10

- 포인트 조회 액션 getAdvertiseTotalPoint/getProductTotalPoint 기능 추가 — [9. 적립 가능 포인트 조회](total-point.md)

## 1.0.0 — 2026-09-09

- 상세 랜딩 액션 adDetail/adJoin/adAction 기능 추가 — [8. 특정 광고 진입](ad-entry.md)

## 0.1.0 — 2026-08-19

공개 가이드 최초 제공 기준 버전입니다.

- 전체화면 오퍼월(`openOfferwall(from:)`) 및 화면 내 삽입(`TnkOfferwallView`)
- 보상 지급 완료 알림(`setRewardListener`) · 범용 이벤트 수신(`setEventListener`)
- ATT 동의 요청(`requestTrackingAuthorization`)
- `tnkscheme://` 딥링크(`handleScheme`)
- 개인정보 동의 · COPPA · GDPR 설정
