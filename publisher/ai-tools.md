---
description: Claude Code · Cursor 등 AI 개발 도구에 이 가이드를 연결해 연동 중 궁금한 점을 바로 묻는 방법과, 네이티브 SDK 이관 코드를 AI 도구에 맡길 때 쓰는 프롬프트를 안내합니다.
---

# AI 도구에 문서 연결하기

이 페이지에서 하는 일: AI 개발 도구(Claude Code, Cursor 등)가 이 가이드를 직접 읽도록 연결합니다. 연결해 두면 SDK 연동 중 막혔을 때 이 가이드를 근거로 답을 받을 수 있습니다.

## 언제 필요한가

선택 사항입니다. AI 도구로 연동 코드를 작성하거나, 기존 네이티브 SDK 에서 이관하는 작업을 AI 도구에 맡기려는 개발사에게 유용합니다.

이 문서는 **AI 개발 도구가 직접 읽을 수 있는 형태**로도 제공됩니다. 별도 신청이나 비용이 없고, 공개 문서라 인증도 필요하지 않습니다.

---

## 1. MCP 서버로 연결 (권장)

MCP(Model Context Protocol)를 지원하는 도구에 아래 주소를 등록합니다.

```
https://tnkfactory.gitbook.io/sdk-docs/~gitbook/mcp
```

### Claude Code

```sh
claude mcp add --transport http tnk-docs https://tnkfactory.gitbook.io/sdk-docs/~gitbook/mcp
```

### Cursor · VS Code · 그 외

각 도구의 MCP 설정에서 **HTTP 방식 서버**로 위 주소를 추가합니다.
설정 파일을 직접 쓰는 도구라면 아래와 비슷한 형태입니다. 도구마다 키 이름이 다를 수 있습니다.

```json
{
  "mcpServers": {
    "tnk-docs": {
      "url": "https://tnkfactory.gitbook.io/sdk-docs/~gitbook/mcp"
    }
  }
}
```

정확한 설정 방법은 사용하시는 도구의 문서를 확인해 주세요.

### 연결하면 쓸 수 있는 도구

연결하면 AI 도구가 아래 세 가지 도구를 쓸 수 있습니다.

| 도구 | 하는 일 |
|------|------|
| `searchDocumentation` | 가이드 전체에서 관련 내용을 찾아, 내용 일부와 해당 페이지 링크를 돌려줍니다 |
| `getPage` | 페이지 주소로 그 페이지의 전체 원문(마크다운)을 읽어 옵니다 |
| `sendFeedback` | 문서에서 발견한 잘못되거나 오래된 내용을 문서 관리자에게 제보합니다 |

연결한 AI 도구는 위 도구로 가이드를 찾아 읽은 뒤, 출처 페이지 링크와 함께 답합니다.

### 사용 예

> "TNK 오퍼월 보상이 지급되지 않는데 뭘 확인해야 해?"
>
> "안드로이드에서 오퍼월을 탭 안에 넣으려면 어떻게 해?"

AI 가 이 가이드를 근거로 답하고, 확인할 페이지를 링크로 알려줍니다.

---

## 네이티브 SDK 이관에 쓰기

기존 네이티브 오퍼월 SDK 에서 이관하신다면, [Android 이관](../android/migration.md) · [iOS 이관](../ios/migration.md)에 **패턴별 전/후 코드**와 **전체 API 대조표**가 있습니다. AI 도구가 이 문서를 기준으로 코드 치환을 도울 수 있습니다.

다만 일부 호출은 대체할 API 가 없거나 동작이 달라집니다. 대조표의 '현재 미제공(문의)' 항목과 주의 문구가 붙은 항목은 AI 가 마음대로 바꾸지 않고 보고하게 하는 것이 안전합니다. 이런 호출은 하이브리드 SDK 에 없으므로 담당자에게 문의하기 전까지는 빌드 오류로 남습니다. 아래 프롬프트는 AI 가 그 오류를 임의로 지우지 않고 보고하도록 쓴 예시입니다.

MCP 를 연결한 뒤 프로젝트 루트에서 아래 프롬프트를 붙여넣으세요.

```text
TNK 네이티브 오퍼월 SDK 를 하이브리드 SDK 로 마이그레이션하려고 해.
tnk-docs MCP 에서 "네이티브 SDK 에서 이관" 문서(android 또는 ios migration.md)를 읽고,
그 안의 '패턴별 전/후' 와 '전체 API 대조표'를 기준으로 다음을 수행해줘.

1. 이 코드베이스에서 TNK 네이티브 SDK 호출을 모두 찾는다.
   - Android: TnkSession / TnkOfferwall / TnkApi / TnkAdConfig / TnkStyle / TnkAdAnalytics / AdWallActivity
   - iOS: TnkSession / TnkAlerts / AdOfferwallViewController / AdOfferwallView / OfferwallEventListener / TnkStyles / TnkLayout / TnkPrivacyAgreementListener
2. 대조표에서 "그대로"·"치환"인 항목은 문서의 전/후 코드를 따라 수정하고, "제거"인 항목은 호출부를 삭제한다.
3. "현재 미제공(문의)" 로 분류된 호출이나 대조표에 없는 호출은 수정하지 말고 파일:라인과 함께 목록으로 보고한다.
4. 동작이 달라진다고 적힌 항목(예: 특정 광고를 닫았을 때의 화면, setUserName 과 동의 호출 순서, 적립 가능 포인트 합산)은 수정하되 따로 모아 보고한다.
5. 수정 후 빌드한다. 3번에서 남겨 둔 호출 때문에 나는 컴파일 오류는 고치지 말고 3번 목록에 추가한다. 그 밖의 컴파일 오류가 남아 있으면 원인과 함께 보고한다. 컴파일러 메시지나 Xcode 의 Fix 제안이 대조표와 다르면 대조표를 따른다.
6. 끝나면 변경 요약과, 코드만으로 확인할 수 없는 남은 할 일(매니페스트/Info.plist, 서버 콜백 등)을 정리한다.
```

MCP 없이 쓰신다면 프롬프트 둘째 줄의 `tnk-docs MCP 에서 … 문서를 읽고` 를 `아래에 붙여넣은 문서를 읽고` 로 바꾸세요. 그리고 프롬프트 아래에 `https://tnkfactory.gitbook.io/sdk-docs/android/migration.md` (또는 `ios/migration.md`) 의 원문을 붙여넣으세요.

> 💡 iOS 는 의존성을 바꾸고 빌드하면 이름이 바뀐 API 마다 컴파일 오류가 나고, 오류 메시지가 새 이름이나 새 사용법을 알려 줍니다. 이름만 바뀐 일부 호출(`TnkSession`, `sharedInstance()` 등)은 Xcode 의 Fix 버튼으로 바로 고칠 수 있지만, 나머지는 메시지나 대조표를 보고 직접 고쳐야 합니다. 없어진 호출은 `has no member` 오류가, 클래스·프로토콜이 통째로 없어진 경우(`TnkAlerts`, `AdOfferwallViewController` 등)는 `cannot find … in scope` 계열 오류가 나는데, 둘 다 새 사용법은 알려 주지 않으니 대조표를 보고 고치세요. 단 두 호출은 컴파일러의 안내를 그대로 따르지 마세요. `showMenuViewController` 에 나오는 Fix 는 마이메뉴가 아니라 오퍼월 첫 화면을 여는 호출을 제안하고, `setTrackingEnabled` 의 메시지는 ATT 요청을 안내하지만 이 호출은 ATT 와 관계가 없어 삭제해야 합니다. 대조표를 따르세요 — [iOS 이관](../ios/migration.md)

---

## 2. 파일로 넘기기

MCP 를 지원하지 않는 도구라면, 아래 주소를 그대로 열어 내용을 붙여넣으셔도 됩니다.

| 주소 | 내용 |
|------|------|
| [`/llms.txt`](https://tnkfactory.gitbook.io/sdk-docs/llms.txt) | 전체 목차와 페이지별 요약 |
| [`/llms-full.txt`](https://tnkfactory.gitbook.io/sdk-docs/llms-full.txt) | 문서 전문 (문서가 늘면 함께 커지므로, 컨텍스트가 큰 도구에서 사용하세요) |

가벼운 질문에는 `llms.txt` 로 충분하고, 문서 전체를 컨텍스트에 넣어야 할 때 `llms-full.txt` 를 쓰시면 됩니다.

---

## 3. 개별 페이지 원문

아무 페이지 주소 끝에 **`.md`** 를 붙이면 마크다운 원문이 나옵니다.

```
https://tnkfactory.gitbook.io/sdk-docs/android/install.md
https://tnkfactory.gitbook.io/sdk-docs/common/server-callback.md
```

각 페이지 우측 상단의 **복사** 버튼에서도 같은 내용을 바로 복사할 수 있습니다.

---

> ⚠️ AI 의 답변과 AI 가 바꾼 코드는 참고용입니다. 반드시 빌드해서 직접 확인해 주세요. 결제·보상 지급처럼 실제 정산에 영향을 주는 부분은
> [서버 보상 콜백 URL](../common/server-callback.md) 등 해당 문서를 직접 확인해 주세요.
