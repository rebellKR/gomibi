# GomiDay - 커밋 가이드

## 🌱 Git 커밋 전략

이 프로젝트는 **단계별 개발 진행**에 맞춰 커밋을 나눕니다.

### 커밋 메시지 규칙

```
[단계] 제목 (한글 OK)

상세 설명 (옵션)
```

**예시:**
```
[1단계] 프로젝트 초기 설정 완료

- Xcode 프로젝트 생성
- Widget Extension 추가
- App Group 설정
- 기본 모델 정의
- 데이터 저장소 구현
```

### 단계별 커밋 계획

#### ✅ 1단계: 프로젝트 설정
```bash
git add .
git commit -m "[1단계] 프로젝트 초기 설정 완료

- Xcode 프로젝트 생성
- Widget Extension 추가  
- App Group 설정
- 기본 모델 정의 (GarbageType, Area, ScheduleRule)
- 데이터 저장소 구현 (AppGroupStorage)
- JSON 리소스 파일 추가
- 유틸리티 헬퍼 추가 (Calendar, Color)
"
```

#### 📋 2단계: 일정 계산 엔진
```bash
# 2-1: 엔진 구현
git commit -m "[2단계] ScheduleEngine 핵심 로직 구현

- 매주 ○요일 계산
- 第n ○요일 계산
- 격주 계산
- 예외 날짜 처리
- 마감 시각 고려
"

# 2-2: 테스트 추가
git commit -m "[2단계] ScheduleEngine 단위 테스트 추가

- 다양한 규칙 시나리오 테스트
- 예외 날짜 테스트
- 마감 시각 경계값 테스트
"
```

#### 🔒 3단계: 잠금 화면 위젯
```bash
git commit -m "[3단계] 잠금 화면 위젯 구현

- accessoryRectangular (메인 정보)
- accessoryCircular (종류 아이콘)
- accessoryInline (한 줄 텍스트)
- TimelineProvider 구현
- Preview 추가
"
```

#### 🏠 4단계: 홈 화면 위젯
```bash
git commit -m "[4단계] 홈 화면 위젯 구현

- systemSmall (오늘/내일 일정)
- systemMedium (이번 주 7일 일정)
- 종류별 포인트 컬러 적용
- Preview 추가
"
```

#### 📱 5단계: 앱 화면
```bash
# 5-1: 오늘 화면
git commit -m "[5단계] 오늘 화면 구현

- 이번 주 일정 카드 뷰
- 쓰레기 종류별 아이콘 & 색상
- 빈 상태 처리
"

# 5-2: 지역 검색
git commit -m "[5단계] 지역 검색 화면 구현

- 도도부현 → 시구정촌 선택
- 실시간 검색 기능
- 한자/히라가나 필터링
"

# 5-3: 직접 설정
git commit -m "[5단계] 직접 설정 화면 구현

- 쓰레기 종류별 규칙 추가
- 요일 & 주차 선택
- 예외 날짜 추가
"
```

#### ⚙️ 6단계: 설정 & 알림
```bash
git commit -m "[6단계] 설정 및 알림 기능 구현

- 다크/라이트 모드 선택
- 배출 마감 시각 설정
- 전날 밤 알림 (UNUserNotificationCenter)
- 데이터 초기화
- 위젯 자동 리로드
"
```

#### 🎨 7단계: 최적화
```bash
# 7-1: 코드 정리
git commit -m "[7단계] 코드 가독성 개선

- 주석 추가
- 함수 분리
- 네이밍 개선
- 불필요한 코드 제거
"

# 7-2: 성능 최적화
git commit -m "[7단계] 성능 최적화

- 위젯 타임라인 최적화
- JSON 로딩 개선
- 메모리 관리
"

# 7-3: 앱 아이콘
git commit -m "[7단계] 앱 아이콘 및 디자인 최종 조정

- 앱 아이콘 추가
- Launch Screen 개선
- 색상 미세 조정
"
```

#### 🚀 8단계: 배포 준비
```bash
git commit -m "[8단계] 배포 준비 완료

- README 최종 업데이트
- 스크린샷 추가
- 라이선스 추가
- 설치 가이드 작성
"
```

---

## 📅 커밋 주기

### 권장 사항:
- **하루 1~2 커밋**: 단계별로 완료될 때마다
- **기능 단위**: 큰 기능은 여러 커밋으로 나누기
- **동작하는 상태**: 커밋 시점에는 항상 빌드 성공

### GitHub 잔디 심기 전략 🌱

**목표: 꾸준한 커밋으로 잔디 채우기**

```
11월 (4주차~): 1단계 완료
12월 (1~2주): 2~3단계 (엔진 + 위젯)
12월 (3~4주): 4~5단계 (위젯 + 앱 화면)
1월 (1~2주):  6~7단계 (설정 + 최적화)
1월 (3주~):   8단계 (배포)
```

**하루에 여러 커밋도 OK!**
- 오전: 모델 작업 → 커밋
- 오후: UI 작업 → 커밋
- 저녁: 테스트 추가 → 커밋

---

## 🎯 커밋 시 체크리스트

커밋하기 전:
- [ ] 빌드 에러 없음 (⌘ + B)
- [ ] 테스트 통과 (있는 경우, ⌘ + U)
- [ ] 불필요한 주석/로그 제거
- [ ] 코드 포맷팅 정리
- [ ] README 업데이트 (필요 시)

---

## 🔧 Git 명령어 치트시트

### 첫 커밋 (로컬)
```bash
cd /path/to/gomiday
git init
git add .
git commit -m "[1단계] 프로젝트 초기 설정 완료"
```

### GitHub 연결
```bash
# GitHub에서 새 레포지토리 만든 후
git remote add origin https://github.com/본인아이디/GomiDay.git
git branch -M main
git push -u origin main
```

### 이후 커밋
```bash
git add .
git commit -m "[단계] 메시지"
git push
```

### 특정 파일만 커밋
```bash
git add 파일명
git commit -m "메시지"
git push
```

### 커밋 히스토리 보기
```bash
git log --oneline --graph
```

### 마지막 커밋 메시지 수정 (push 전)
```bash
git commit --amend -m "새 메시지"
```

---

## 🌟 Branch 전략 (선택사항)

나중에 복잡해지면 브랜치 사용:

```bash
# 새 기능 작업
git checkout -b feature/widget-timeline

# 작업 완료 후
git checkout main
git merge feature/widget-timeline
git push
```

**권장 브랜치 이름:**
- `main`: 안정 버전
- `develop`: 개발 중
- `feature/기능명`: 새 기능
- `bugfix/버그명`: 버그 수정

---

현재는 단순하게 `main` 브랜치에서 단계별로 커밋하는 것을 추천합니다!
