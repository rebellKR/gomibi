# GomiDay (ゴミデー)

일본 거주자를 위한 쓰레기 배출일 알림 앱 & 위젯

## 📱 기능

- 🗓️ **지역별 쓰레기 수거 일정 관리**
  - 도도부현 → 시구정촌 → 지구/정목 순으로 검색 및 등록
  - 일정 데이터가 있는 지역: 자동 등록
  - 일정 데이터가 없는 지역: 직접 설정 가능

- 📆 **다양한 수거 규칙 지원**
  - 매주 특정 요일 (예: 매주 월·목요일)
  - 第n 요일 (예: 第2·第4 수요일)
  - 격주 수거 (기준일 지정)
  - 예외 날짜 (연말연시, 공휴일 등)

- 🔔 **전날 밤 알림**
  - 로컬 알림으로 다음 날 쓰레기 배출일 알림
  - 알림 시각 커스터마이징 가능

- 📱 **위젯 지원**
  - 잠금 화면 위젯 (Circular, Rectangular, Inline)
  - 홈 화면 위젯 (Small, Medium)
  - 오늘/내일 일정 한눈에 확인

- 🎨 **모던 디자인**
  - 라이트/다크 모드 완벽 지원
  - 쓰레기 종류별 포인트 컬러
  - SF Symbols 아이콘 사용

## 🛠️ 기술 스택

- **언어**: Swift
- **UI 프레임워크**: SwiftUI
- **위젯**: WidgetKit
- **데이터 공유**: App Group
- **최소 지원**: iOS 17.0+
- **시간대**: Asia/Tokyo (일본 표준시)
- **달력**: 그레고리력, 주 시작 일요일

## 📂 프로젝트 구조

```
GomiDay/
├── Shared/                 # 앱과 위젯이 공유하는 코드
│   ├── Models/
│   │   ├── GarbageType.swift           # 쓰레기 종류 enum
│   │   ├── GarbageScheduleRule.swift   # 수거 규칙 모델
│   │   └── Area.swift                  # 지역 정보 모델
│   ├── Services/
│   │   ├── ScheduleEngine.swift        # 일정 계산 엔진
│   │   └── AppGroupStorage.swift       # 데이터 저장소
│   └── Utils/
│       ├── CalendarExtension.swift     # 날짜 유틸리티
│       └── ColorAssets.swift           # 색상 정의
├── Views/                  # 앱 화면
│   ├── TodayView.swift
│   ├── AreaSearchView.swift
│   └── SettingsView.swift
├── Resources/              # JSON 데이터
│   ├── areas.json                      # 지역별 일정 데이터
│   └── municipalities.json             # 전국 시구정촌 목록
├── GomiDayWidget/          # 위젯 익스텐션
│   ├── LockScreenWidgets.swift
│   └── HomeScreenWidgets.swift
└── GomiDayTests/           # 단위 테스트
    └── ScheduleEngineTests.swift
```

## 🚀 개발 진행 상황

### ✅ 1단계: 프로젝트 설정 (완료)
- [x] Xcode 프로젝트 생성
- [x] Widget Extension 추가
- [x] App Group 설정
- [x] 기본 모델 정의
- [x] 데이터 저장소 구현
- [x] JSON 리소스 파일 생성

### ✅ 2단계: 일정 계산 엔진 (완료)
- [x] ScheduleEngine 구현
- [x] 단위 테스트 작성
- [x] 예외 날짜 처리

### ⏳ 3단계: 잠금 화면 위젯 (다음)
- [ ] Widget Extension 기본 구조
- [ ] accessoryRectangular 구현
- [ ] accessoryCircular 구현
- [ ] accessoryInline 구현
- [ ] TimelineProvider 구현
### 🔜 4단계: 홈 화면 위젯
### 🔜 5단계: 앱 화면
### 🔜 6단계: 설정 & 알림
### 🔜 7단계: 최적화 & 커밋
### 🔜 8단계: 배포

## 📝 쓰레기 종류

- 🔥 **可燃ごみ** (Burnable): 가연 쓰레기
- 🗑️ **不燃ごみ** (Non-Burnable): 불연 쓰레기
- ♻️ **資源** (Resource): 자원 쓰레기
- 🛍️ **プラスチック** (Plastic): 플라스틱
- 📄 **古紙** (Paper): 고지(헌 종이)

## 🎨 디자인 컨셉

**모던 & 심플**
- 정보는 "오늘/내일 무엇을 버리는가"에 집중
- 넉넉한 여백으로 가독성 향상
- SF Pro 폰트로 깔끔한 타이포그래피
- 종류별 포인트 컬러로 직관적인 구분
- 라이트/다크 모드 완벽 대응

## ⚙️ 설정 항목

- 지역 선택 및 변경
- 배출 마감 시각 설정 (기본: 08:30)
- 전날 밤 알림 ON/OFF 및 시각 설정 (기본: 20:00)
- 다크/라이트 모드 선택
- 데이터 초기화

## 📱 App Group 설정

앱과 위젯이 데이터를 공유하기 위해 App Group을 사용합니다.

**설정 방법:**
1. Xcode에서 프로젝트 선택
2. 각 타깃(App, Widget)의 **Signing & Capabilities** 탭
3. **+ Capability** → **App Groups** 추가
4. 그룹 ID: `group.com.yourname.gomiday`

⚠️ **중요**: `AppGroupStorage.swift` 파일의 `appGroupID`를 본인의 ID로 변경하세요!

## 🧪 테스트

```bash
# 단위 테스트 실행
⌘ + U (Xcode)
```

## 📄 라이선스

MIT License

---

**개발자**: hyun_kim  
**시작일**: 2026년 11월 22일  
**목적**: 일본 거주자의 쓰레기 배출일 관리를 편리하게!
