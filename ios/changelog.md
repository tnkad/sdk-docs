---
description: 하이브리드 오퍼월 SDK(iOS) 버전별 변경 사항입니다.
---

# 릴리스 노트

패키지: `TnkPpiHyb` (SPM · CocoaPods) · 설치 방법은 [1. 설치](install.md)를 참고하세요.

- 배포 저장소 · 버전별 바이너리: [tnkad/ios-ppi-hyb-sdk — Releases](https://github.com/tnkad/ios-ppi-hyb-sdk/releases)
- 연동 샘플 (SPM · CocoaPods 예제 각 1개): [tnkad/ios-ppi-hyb-sample](https://github.com/tnkad/ios-ppi-hyb-sample)

---

## 0.1.0 — 2026-08-19

공개 가이드 최초 제공 기준 버전입니다.

- 전체화면 오퍼월(`openOfferwall(from:)`) 및 화면 내 삽입(`TnkOfferwallView`)
- 보상 지급 완료 알림(`setRewardListener`) · 범용 이벤트 수신(`setEventListener`)
- ATT 동의 요청(`requestTrackingAuthorization`)
- `tnkscheme://` 딥링크(`handleScheme`)
- 개인정보 동의 · COPPA · GDPR 설정
