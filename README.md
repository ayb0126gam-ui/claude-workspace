# Jerome의 Claude Code 작업 공간

> 1인 창업가 Jerome이 Claude Code와 함께 일하는 메인 폴더입니다.

---

## 폴더 구조

```
claude-workspace/
│
├── CLAUDE.md              ← Claude Code 지침서 (소통 방식 · 보안 규칙 · 작업 원칙)
├── SECURITY.md            ← 비상 매뉴얼 (키 노출 시 대응 순서)
├── README.md              ← 이 파일
│
├── index.html             ← 포트폴리오 웹페이지 (브라우저에서 바로 열기)
├── get_weather.ps1        ← 날씨 · 미세먼지 자동 수집 스크립트 (매일 09:00)
│
├── docs/
│   └── sample_sales.csv   ← 샘플 데이터
│
└── tasks/
    ├── todo.md            ← 오늘 할 일 체크리스트
    └── progress.md        ← 작업 기록 (append-only)
```

> `weather.txt`, `docs/resume.pdf` 는 보안 · 자동생성 파일로 git에서 제외됩니다.

---

## 파일 설명

| 파일 | 역할 | 비고 |
|------|------|------|
| `CLAUDE.md` | Claude Code 행동 규칙 | 매 작업마다 자동으로 읽힘 |
| `SECURITY.md` | 키 노출 비상 대응 절차 | 키 노출 의심 시 즉시 열기 |
| `index.html` | 포트폴리오 웹페이지 | 더블클릭으로 브라우저 열기 |
| `get_weather.ps1` | 영등포구 날씨 · 미세먼지 수집 | Windows 작업 스케줄러 09:00 등록됨 |
| `tasks/todo.md` | 오늘 할 일 목록 | 작업 시작 시 확인 |
| `tasks/progress.md` | 완료 작업 기록 | 작업 종료 시 추가 |

---

## 날씨 스크립트 사용법

```powershell
# 수동 실행
powershell -ExecutionPolicy Bypass -File get_weather.ps1

# 결과 확인
cat weather.txt
```

API 키 불필요 — [Open-Meteo](https://open-meteo.com) 무료 API 사용

---

## 보안 원칙

- API 키 · 비밀번호는 `.env` 파일에만 보관 (코드에 직접 쓰지 않기)
- `.env`, `*.key`, `*.pem` 은 git에 올리지 않음 (`.gitignore` 적용됨)
- 키 노출 의심 시 → `SECURITY.md` 순서대로 따라하기

---

*업데이트: 2026-06-07*
