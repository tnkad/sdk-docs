#!/usr/bin/env bash
#
# 가이드 버전 갱신 스크립트
#
#   ./scripts/release.sh android 1.0.7
#   ./scripts/release.sh ios 0.2.0
#
# 하는 일:
#   1) 설치 문서의 SDK 버전 문자열을 새 버전으로 치환
#   2) 해당 플랫폼 릴리스 노트(changelog.md) 맨 위에 새 버전 스텁 삽입
#
# [경계 규칙] 이 스크립트는 이 저장소(sdk-docs) 안의 md 파일만 수정한다.
# 아티팩트 게시(Nexus / GitHub Releases), git 태그, 아카이브 생성은
# 각 SDK 저장소의 릴리스 절차가 담당하며, 그쪽에서 이 스크립트를
# 호출하는 방향만 허용한다. 여기에 배포 로직을 추가하지 말 것.
#
set -euo pipefail
cd "$(dirname "$0")/.."

platform="${1:-}" version="${2:-}"
usage() { echo "사용법: $0 <android|ios> <버전>  (예: $0 android 1.0.7)"; exit 1; }
[[ "$platform" == "android" || "$platform" == "ios" ]] || usage
[[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || { echo "오류: 버전은 x.y.z 형식이어야 합니다 (정식 버전만 가이드에 반영): '$version'"; usage; }

changelog="$platform/changelog.md"
[[ -f "$changelog" ]] && ! grep -q "^## $version " "$changelog" \
  || { echo "오류: $changelog 가 없거나 이미 '## $version' 항목이 있습니다."; exit 1; }

export PLATFORM="$platform" NEW="$version" TODAY="$(date +%F)"
python3 <<'PY'
import os, re, sys

platform, new, today = os.environ['PLATFORM'], os.environ['NEW'], os.environ['TODAY']

if platform == 'android':
    pat, files = re.compile(r'(com\.tnkfactory\.ad:hrwd:)\d+\.\d+\.\d+'), ['android/install.md', 'android/README.md']
else:
    pat, files = re.compile(r'(from: ")\d+\.\d+\.\d+(")'), ['ios/install.md']

total = 0
for f in files:
    s = open(f).read()
    s2, n = pat.subn(lambda m: m.group(1) + new + (m.group(2) if m.lastindex and m.lastindex >= 2 else ''), s)
    if n:
        open(f, 'w').write(s2)
    print(f'  {n}곳 치환  {f}')
    total += n
if total == 0:
    sys.exit('오류: 치환된 곳이 없습니다. 문서의 버전 표기 형식이 바뀌었는지 확인하세요.')

cl = f'{platform}/changelog.md'
s = open(cl).read()
stub = f'## {new} — {today}\n\n- (변경 사항을 적어주세요)\n\n'
s2, n = re.subn(r'(\n---\n\n)(## )', r'\1' + stub.replace('\\', '\\\\') + r'\2', s, count=1)
if n == 0:
    sys.exit(f'오류: {cl} 에서 삽입 위치(--- 다음 첫 ## 항목)를 찾지 못했습니다.')
open(cl, 'w').write(s2)
print(f'  스텁 삽입  {cl}')
PY

echo
echo "완료. 다음 순서로 마무리하세요:"
echo "  1) $changelog 의 '(변경 사항을 적어주세요)' 를 실제 내용으로 교체"
echo "  2) git diff 로 확인 후 커밋 (제목 한 줄, 예: docs: $platform SDK $version)"
echo "  3) git push → GitBook 자동 반영"
