---
description: Claude Code · Cursor 등 AI 개발 도구에 이 문서를 연결해, 연동 중 궁금한 점을 바로 물어보는 방법입니다.
---

# AI 도구에 문서 연결하기

이 문서는 **AI 개발 도구가 직접 읽을 수 있는 형태**로도 제공됩니다.
연결해두면 SDK 연동 중 막혔을 때 이 가이드를 근거로 답을 받을 수 있습니다.

별도 신청이나 비용이 없고, 공개 문서라 인증도 필요하지 않습니다.

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
설정 파일을 직접 쓰는 도구라면 대체로 아래 형태입니다.

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

### 연결하면 쓸 수 있는 기능

| 기능 | 설명 |
|------|------|
| 문서 검색 | 가이드 전체에서 관련 내용을 찾습니다 |
| 페이지 조회 | 특정 페이지의 원문을 그대로 읽습니다 |
| 질문 답변 | 자연어 질문에 **출처 페이지 링크와 함께** 답합니다 |
| 오류 제보 | 문서에서 발견한 잘못된 내용을 TnkFactory 에 전달합니다 |

### 사용 예

> "TNK 오퍼월 보상이 지급되지 않는데 뭘 확인해야 해?"
>
> "안드로이드에서 오퍼월을 탭 안에 넣으려면 어떻게 해?"

AI 가 이 가이드를 근거로 답하고, 확인할 페이지를 링크로 알려줍니다.

---

## 네이티브 SDK 마이그레이션에 쓰기

기존 네이티브 오퍼월 SDK 에서 이관하신다면, [네이티브 SDK 에서 이관](../android/migration.md)
(iOS 는 [여기](../ios/migration.md))에 **공개 API 전수 대조표**가 있습니다.
표가 "그대로 / 치환 / 제거 / 문의" 로 결정적으로 정리되어 있어, AI 도구가 이를 근거로
코드베이스 치환을 대신할 수 있습니다.

MCP 를 연결한 뒤 프로젝트 루트에서 아래 프롬프트를 붙여넣으세요.

```text
TNK 네이티브 오퍼월 SDK 를 하이브리드 SDK 로 마이그레이션하려고 해.
tnk-docs MCP 에서 "네이티브 SDK 에서 이관" 문서(android 또는 ios migration.md)를 읽고,
그 안의 전체 API 대조표를 유일한 근거로 삼아 다음을 수행해줘.

1. 이 코드베이스에서 TNK SDK 호출(TnkSession / TnkOfferwall / TnkAdConfig / TnkStyle 등)을 전수 탐색한다.
2. 대조표 기준으로 "그대로/치환" 항목은 코드를 수정하고, "제거" 항목은 호출부를 삭제한다.
   대체 동작이 필요한 것(보상 완료 통지 등)은 문서가 안내하는 새 API(setRewardListener 등)로 옮긴다.
3. 대조표에 "문의" 로 분류된 API 나 표에 없는 호출이 나오면 수정하지 말고 파일:라인과 함께 목록으로 보고한다.
4. 끝나면 변경 요약과, 문서의 "이관 체크리스트" 중 코드만으로 확인 불가한 항목
   (매니페스트/Info.plist, 서버 콜백 등)을 남은 할 일로 정리한다.
```

MCP 없이 쓰신다면 프롬프트 첫 줄의 문서 참조를
`https://tnkfactory.gitbook.io/sdk-docs/android/migration.md` (또는 `ios/migration.md`) 원문
붙여넣기로 바꾸시면 됩니다.

> iOS 는 여기에 더해, 의존성만 교체하고 빌드하면 이름이 바뀐 API 마다
> **컴파일 에러 + Xcode fix-it 으로 새 이름이 안내**됩니다 — 에러 목록이 곧 체크리스트입니다.

---

## 2. 파일로 넘기기

MCP 를 지원하지 않는 도구라면, 아래 주소를 그대로 열어 내용을 붙여넣으셔도 됩니다.

| 주소 | 내용 |
|------|------|
| [`/llms.txt`](https://tnkfactory.gitbook.io/sdk-docs/llms.txt) | 전체 목차와 페이지별 요약 (약 7KB) |
| [`/llms-full.txt`](https://tnkfactory.gitbook.io/sdk-docs/llms-full.txt) | 문서 전문 (약 100KB) |

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

> ⚠️ AI 의 답변은 참고용입니다. 결제·보상 지급처럼 실제 정산에 영향을 주는 부분은
> [서버 보상 콜백 URL](../common/server-callback.md) 등 해당 문서를 직접 확인해 주세요.
