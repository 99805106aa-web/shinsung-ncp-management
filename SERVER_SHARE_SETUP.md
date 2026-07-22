> **외부·모바일 상시 접속:** [GitHub Pages](https://99805106aa-web.github.io/shinsung-ncp-management/)  
> 저장소: https://github.com/99805106aa-web/shinsung-ncp-management · 안내: `MOBILE_GITHUB_PAGES.md`

# 신성텍 부적합보고서 — 다중기기 공유 서버 설정

> 최종 업데이트: 2026-07-22 (GitHub Pages 모바일 접속 추가)

---

## 서버 루트 경로

```
Z:\QC\qc문서\부적합보고서\shinsung-ncp-management-main
```

---

## 빠른 시작 (권장)

### 더블클릭으로 실행

```
start-local-server.bat
```

실행하면 자동으로:
1. Windows 방화벽에 포트 8787 인바운드 허용 규칙 추가
2. Python 서버 시작 (`0.0.0.0:8787` — 사내 전체 인터페이스)
3. 사내망 IP 자동 감지 및 출력
4. 스마트폰 접속용 QR코드 터미널 출력 (`pip install qrcode` 필요)
5. 기본 접근 정책 적용 (사설망/LAN/로컬 IP만 허용)

### 서버 시작 후 콘솔 출력 예시

```
[방화벽] 포트 8787 허용 규칙이 이미 존재합니다.

서버를 시작합니다 (포트 8787)...

============================================================
  신성텍 부적합보고서 서버
============================================================
  폴더  : Z:\QC\qc문서\부적합보고서\shinsung-ncp-management-main
  로컬  : http://127.0.0.1:8787/index.html
  사내망 : http://192.168.0.228:8787/index.html  ← 타 PC·모바일에서 이 주소로 접속
------------------------------------------------------------
  API: /api/sw-attachments/manifest  (첨부 목록)
  API: /api/sw-attachments/upload    (첨부 업로드)
  API: /api/sw-attachments/delete    (첨부 삭제)
  API: /api/data/cache               (데이터 캐시 읽기/쓰기)
------------------------------------------------------------
  종료: Ctrl+C
============================================================

  [QR코드] 스마트폰 카메라로 스캔하면 바로 접속됩니다:
  █▀▀▀▀▀▀▀██▀▀▀...
```

---

## 접속 방법

| 기기 | 접속 주소 |
|------|----------|
| 서버 PC (이 PC) | `http://127.0.0.1:8787/index.html` |
| 사내 타 PC | `http://192.168.0.228:8787/index.html` ← 사내망 IP |
| 스마트폰 (사내 WiFi) | 콘솔의 QR코드 스캔 또는 위 사내망 주소 입력 |

> **사내망 IP는 PC마다 다를 수 있습니다.** 서버 시작 후 콘솔에 출력되는 `사내망 :` 줄의 주소를 사용하세요.

---

## 접근 정책 (보안 기본값)

- 기본값: **사설망/LAN/로컬 IP만 허용**
- 공인 IP(외부망) 접속까지 허용하려면 서버 실행 시 옵션 추가:

```powershell
python .\scripts\start-local-server.py --host 0.0.0.0 --port 8787 --root . --allow-public-clients
```

> 운영 권장: 사내망 공유 목적이면 기본값(사설망만 허용)을 유지하세요.

---

## file:// 모드와 http:// 모드 차이

| 항목 | `file://` 모드 | `http://` 모드 (서버 실행) |
|------|---------------|--------------------------|
| 개선대책서 공유 저장 | ❌ 불가 (이 PC만 저장) | ✅ 가능 |
| 데이터 캐시 공유 | ❌ 불가 | ✅ 가능 |
| 타 PC·모바일 접속 | ❌ 불가 | ✅ 가능 |
| 자동갱신 토글 | ❌ 비활성 | ✅ 활성 |

---

## 공유 저장소 구조

서버가 관리하는 파일들:

```
cloud/
├── sw_attachments_manifest.json   ← 개선대책서 첨부 목록
├── sw_attachments/                ← 개선대책서 파일 저장 디렉터리
│   └── sw_7C...__{파일명}.pdf
└── uploaded_report_cache.json     ← 엑셀 데이터 공유 캐시
```

- 한 PC에서 개선대책서를 업로드하면 `sw_attachments/`에 저장됨
- 다른 PC·모바일에서 새로고침하면 즉시 확인 가능
- 엑셀 업로드 데이터도 `uploaded_report_cache.json`을 통해 공유됨

---

## API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| `GET` | `/api/sw-attachments/manifest` | 첨부 목록 JSON 조회 |
| `POST` | `/api/sw-attachments/upload` | 개선대책서 파일 업로드 (Base64, 최대 30MB) |
| `POST` | `/api/sw-attachments/delete` | 개선대책서 파일 삭제 |
| `GET` | `/api/data/cache` | 엑셀 데이터 캐시 조회 |
| `POST` | `/api/data/cache` | 엑셀 데이터 캐시 저장 (최대 20MB) |

---

## 개선대책서 뷰어 (Phase 2)

| 파일 형식 | 동작 |
|-----------|------|
| `.pdf` | 브라우저 내 **모달 iframe 뷰어** |
| `.jpg / .png / .gif` 등 | 브라우저 내 **이미지 미리보기** |
| `.hwp / .docx` 등 | 새 탭에서 열기 |

버튼 구성 (첨부 완료 시):

```
[보기]  [다운로드]  [교체]  [삭제]
```

---

## 30초 자동갱신 토글 (Phase 3)

보고서 화면 상단 버튼바의 **`⏱ 자동갱신 30s`** 버튼:

- **OFF (기본)**: 수동 새로고침
- **ON**: 30초마다 첨부파일 목록·데이터 캐시 자동 갱신, 카운트다운 표시

타 PC·모바일에서 실시간으로 최신 첨부파일을 확인할 때 유용합니다.

---

## QR코드 라이브러리 설치

서버 PC에서 한 번만 실행:

```
pip install qrcode
```

설치 후 서버 시작 시 사내망 접속용 QR코드가 터미널에 자동 출력됩니다.

---

## 방화벽 수동 설정 (bat 실행 시 자동 처리됨)

`start-local-server.bat`을 관리자 권한으로 실행하면 자동으로 방화벽 규칙이 추가됩니다.
수동으로 설정하려면:

1. 제어판 → Windows Defender 방화벽 → 고급 설정
2. 인바운드 규칙 → 새 규칙
3. 포트 → TCP → 특정 로컬 포트: `8787`
4. 연결 허용 → 도메인·개인·공용 모두 체크
5. 이름: `ShinsungQC_Port8787`

또는 관리자 권한 명령 프롬프트:

```bat
netsh advfirewall firewall add rule name="ShinsungQC_Port8787" dir=in action=allow protocol=TCP localport=8787
```

---

## HTML 파일 동기화 (선택)

두 HTML 파일(`신성텍_부적합보고서.html` ↔ `index.html`) 수동 동기화:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-html-files.ps1
```

서버측 자동 동기화 작업 등록 (1분마다):

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-server-html-sync-task.ps1 -Minutes 1
```

제거:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\remove-server-html-sync-task.ps1
```

---

## 클라이언트 PC 동기화 (선택)

다른 PC에 로컬 사본 유지 시:

```powershell
# 작업 등록 (3분마다)
powershell -ExecutionPolicy Bypass -File .\scripts\install-client-sync-task.ps1 -ServerPath "Z:\QC\qc문서\부적합보고서\shinsung-ncp-management-main" -Minutes 3

# 수동 동기화
powershell -ExecutionPolicy Bypass -File .\scripts\sync-now.ps1 -ServerPath "Z:\QC\qc문서\부적합보고서\shinsung-ncp-management-main"

# 작업 제거
powershell -ExecutionPolicy Bypass -File .\scripts\remove-client-sync-task.ps1
```

---

## 문제 해결

| 증상 | 원인 | 해결 |
|------|------|------|
| 타 PC에서 접속 안 됨 | 방화벽 차단 | bat 파일을 관리자 권한으로 재실행, 또는 방화벽 수동 허용 |
| 첨부파일이 타 기기에 안 보임 | `file://` 모드로 접속 중 | `http://192.168.0.228:8787/index.html` 로 접속 |
| 데이터가 오래된 것 같음 | 캐시 | `Ctrl+F5` 또는 `⏱ 자동갱신 30s` 버튼 ON |
| QR코드 안 나옴 | qrcode 미설치 | `pip install qrcode` 실행 후 서버 재시작 |
| 서버 IP가 바뀜 | DHCP 재할당 | 서버 시작 후 콘솔의 `사내망 :` 줄 주소 재확인 |
