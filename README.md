---
description: TnkFactory 하이브리드 오퍼월 SDK 연동 가이드입니다. Android · iOS 설치부터 오퍼월 열기, 서버 보상 콜백까지 순서대로 안내합니다.
---

# TnkFactory SDK 연동 가이드

이 가이드에서 하는 일: 앱에 TnkFactory 하이브리드 오퍼월 SDK 를 붙여, 사용자가 광고에 참여하고 포인트를 적립하는 **오퍼월 화면**을 열 수 있게 합니다.

오퍼월 화면은 SDK 가 앱 안에 띄우는 웹 화면으로 제공됩니다. 화면 개선이나 개발사별 맞춤 설정(담당자에게 요청)은 TnkFactory 가 적용하며, 앱을 다시 배포하지 않아도 반영됩니다.
Android 와 iOS 는 같은 오퍼월 화면을 사용하므로 사용자가 보는 화면은 같습니다.

<figure><img src="assets/common/offerwall-home.png" alt="오퍼월 첫 화면. 상단에 닫기 버튼과 제목, 카테고리 탭, 검색창, 광고 목록이 보임" width="300"><figcaption><p>사용자가 보는 오퍼월 첫 화면입니다. 오퍼월 화면은 Android·iOS 가 같습니다.</p></figcaption></figure>

---

## 플랫폼별 가이드

| 플랫폼 | 최소 지원 | 배포 | 가이드 |
|--------|----------|------|--------|
| **Android** | Android 5.0 (API 21) | Maven (AAR) | [연동 가이드 (Android)](android/README.md) |
| **iOS** | iOS 15.0 | SPM · CocoaPods | [연동 가이드 (iOS)](ios/README.md) |

플랫폼과 무관한 내용은 공통 문서에 있습니다.

- [**서버 보상 콜백 URL**](common/server-callback.md) — 실제 포인트 지급 경로입니다. **반드시 구현하셔야 합니다.**
- [지원 범위](common/support-matrix.md) — 제공 기능과 플랫폼별 차이
- [AI 도구에 문서 연결하기](publisher/ai-tools.md) — Claude Code · Cursor 등에서 이 가이드를 바로 참조하기

---

## 연동에 필요한 것

시작하기 전에 [퍼블리셔 페이지](publisher/app-id.md)에서 앱을 등록하고 아래 두 가지를 발급받으셔야 합니다.

| 항목 | 설명 |
|------|------|
| **개발사 앱 ID** (`tnkad_app_id`) | 앱마다 발급되는 식별자 — [발급 방법](publisher/app-id.md) |
| **앱 키** (`app_key`) | 서버 보상 콜백 검증에 사용. 개발사 백엔드에서만 사용하며 앱에 넣지 않습니다 |

> ⚠️ TNK 는 **패키지명(Android) / 번들 ID(iOS)로 앱을 식별**합니다. 퍼블리셔 페이지에 등록한 값과 실제 앱의 값이 다르면 오퍼월이 정상적으로 표시되지 않을 수 있습니다.
> 디버그 빌드처럼 `.debug` 같은 접미사가 붙은 앱으로 테스트하려면, 그 패키지명으로 앱을 하나 더 등록하고 거기서 발급된 APP ID 를 해당 빌드에 넣어 주세요. 설정이 어려우면 담당자에게 문의해 주세요.

---

## 연동 흐름

앱과 서버 양쪽이 필요합니다.

1. **퍼블리셔 페이지** — [앱 등록 후 APP ID 발급](publisher/app-id.md)
2. **앱** — SDK 설치 → 앱 ID 설정 → 초기화 → 사용자 식별값 설정 → (앱에서 동의를 받는 경우) 동의 전달 → 오퍼월 열기
   단계별 코드는 [Android 빠른 시작](android/README.md) · [iOS 빠른 시작](ios/README.md)에 있습니다.
3. **서버** — 보상 콜백 URL 구현 → 등록 (등록·변경은 담당자에게 요청)
4. **검증** — 실제 광고에 참여해 콜백이 도착하고 포인트가 지급되는지 확인

클라이언트의 보상 콜백(`setRewardListener`)은 **UI 갱신용**입니다.
실제 지급은 **반드시 서버 콜백**으로 처리하셔야 합니다.

---

## 처음 오퍼월을 열면 사용자가 보는 것

오퍼월을 처음 열면 **개인정보 수집 동의 팝업**이 먼저 나옵니다. 동의하면 오퍼월을 이용할 수 있고, 거부하면 안내 화면이 나옵니다(다음에 들어갈 때 다시 묻습니다).

앱에서 이미 동의를 받았다면 `setAgreePrivacy(true)` 로 전달해 팝업 없이 바로 열 수 있습니다.
자세한 내용은 [Android](android/privacy.md) · [iOS](ios/privacy.md) 의 '7. 개인정보 설정'을 보세요.

<figure><img src="assets/common/consent-popup.png" alt="개인정보 수집 동의 팝업. 수집정보와 보유기간 안내, 거부와 동의 버튼이 있음" width="300"><figcaption><p>오퍼월에 처음 들어가면 이 동의 팝업이 먼저 나옵니다. 오퍼월 화면은 Android·iOS 가 같습니다.</p></figcaption></figure>

---

문의: tech@tnkfactory.com
