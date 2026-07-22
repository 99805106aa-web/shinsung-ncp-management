# 모바일 언제·어디서든 접속 (GitHub Pages)

## 접속 주소

**핸드폰에서 바로 열기**

https://99805106aa-web.github.io/shinsung-ncp-management/

저장소: https://github.com/99805106aa-web/shinsung-ncp-management

## 사용 방법

1. 위 주소를 문자/카톡으로 보내거나, PC 보고서 화면의 **📱 모바일 접속** 버튼에서 QR을 스캔합니다.
2. Safari/Chrome에서 열면 Wi‑Fi·LTE 어디서든 동일 화면을 볼 수 있습니다.
3. (선택) 브라우저 메뉴 → **홈 화면에 추가** → 앱처럼 실행.

## 데이터 갱신

GitHub Pages는 **저장소에 올라간 파일**을 보여 줍니다.

| 작업 | 방법 |
|------|------|
| 엑셀 최신화 | `신성텍 부적합 현황.xlsx` (또는 `-1.xlsx`)를 저장소 `main`에 커밋·푸시 |
| 앱 화면 최신화 | `index.html`, `vendor/` 등을 `main`에 푸시 |
| 로컬에서 배포 | `scripts\publish-to-github-pages.ps1` 실행 |

푸시 후 보통 **1~2분** 안에 Pages에 반영됩니다.

## 사내 LAN 서버와의 차이

| 항목 | GitHub Pages | 로컬 서버 (`start-local-server.bat`) |
|------|--------------|--------------------------------------|
| 외부망·LTE 접속 | ✅ | ❌ (사내망만) |
| 개선대책서 공유 업로드 | ❌ (정적) | ✅ |
| 실시간 캐시 API | ❌ | ✅ |
| 언제 어디서든 열람 | ✅ | ❌ |

**권장:** 평소 열람·보고는 GitHub Pages, 사내 첨부·실시간 공유는 LAN 서버.
