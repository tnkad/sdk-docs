---
description: ATT 동의 문구와 사진·카메라 권한 문구 등 TnkPpiHyb SDK 연동에 필요한 Info.plist 키를 안내합니다.
---

# 2. Info.plist 설정

## 필요한 키

| 키 | 필수 | 용도 |
|---|:-:|---|
| `NSUserTrackingUsageDescription` | ✅ | ATT 동의 팝업 문구. IDFA 수집에 필요 |
| `NSPhotoLibraryUsageDescription` | ✅ | 광고 참여 시 이미지 첨부 |
| `NSCameraUsageDescription` | ✅ | 광고 참여 시 사진 촬영 |
| `NSMicrophoneUsageDescription` | ○ | 동영상 촬영형 광고 |
| `tnkad_app_id` | ○ | 개발사 앱 ID. 코드로 `configure(appId:)` 하면 생략 가능 |

> ⚠️ **ATT 동의를 받지 않으면 참여 가능한 광고가 크게 줄어듭니다.**
> IDFA 없이도 오퍼월은 동작하지만 매칭되는 광고 수가 떨어집니다.

---

## 작성 예시

```xml
<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 광고 제공을 위해 기기 광고 식별자(IDFA)를 사용합니다.</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>광고 참여 인증을 위해 사진을 첨부합니다.</string>

<key>NSCameraUsageDescription</key>
<string>광고 참여 인증을 위해 사진을 촬영합니다.</string>

<key>tnkad_app_id</key>
<string>발급받은-앱-아이디</string>
```

권한 문구는 **심사 반려 사유가 되기 쉬운 항목**입니다. "왜 필요한지"가 드러나게 쓰세요.

---

## 딥링크를 쓰는 경우

`tnkscheme://` 딥링크를 받을 때만 필요합니다. 자세한 내용은 [6. 딥링크](deeplink.md)를 참고하세요.

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>com.example.app.tnk</string>
    <key>CFBundleURLSchemes</key>
    <array><string>tnkscheme</string></array>
  </dict>
</array>
```

---

다음: [3. 초기화](initialize.md)
