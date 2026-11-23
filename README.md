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

### ✅ 3단계: 잠금 화면 위젯 (완료)
- [x] Widget Extension 기본 구조
- [x] accessoryRectangular 구현
- [x] accessoryCircular 구현
- [x] accessoryInline 구현
- [x] TimelineProvider 구현

### ✅ 5단계: 앱 화면 (완료)
- [x] MainTabView 구현
- [x] TodayView 구현
- [x] AreaSearchView 구현
- [x] SettingsView 구현

### ✅ 6단계: 알림 & 개선 (완료)
- [x] 전날 밤 알림 구현
- [x] NotificationManager 구현
- [x] 알림 권한 요청
- [x] 설정에서 알림 ON/OFF

### ✅ 7-8단계: 최종 완성 (완료)
- [x] 코드 주석 정리
- [x] 도쿄 + 근기 지역 데이터 (10개 도시)
- [x] README 문서화
- [x] 실제 iPhone 테스트
- [x] 프로젝트 완성 🎉

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

---

## 🚀 사용 방법

### 1️⃣ 앱 설치 및 실행
```
1. Xcode에서 프로젝트 열기
2. 본인의 iPhone 연결
3. App Group ID 변경:
   - AppGroupStorage.swift의 appGroupID를 본인 ID로 변경
4. ⌘ + R로 실행
```

### 2️⃣ 지역 등록
```
1. 하단 탭에서 "地域" 선택
2. 검색창에 본인 지역 입력 (예: "大阪市")
3. 목록에서 지역 선택
4. 자동으로 등록 완료!
```

### 3️⃣ 위젯 추가
```
[잠금 화면]
1. 잠금 화면 길게 누르기
2. [커스터마이즈] 탭
3. 위젯 영역 탭
4. "ゴミ収集日" 검색
5. 원하는 위젯 추가

[홈 화면]
1. 홈 화면 빈 공간 길게 누르기
2. 왼쪽 상단 [+] 버튼
3. "ゴミ収集日" 검색
4. 위젯 추가
```

### 4️⃣ 알림 설정
```
1. 하단 탭에서 "設定" 선택
2. "前日夜に通知" 토글 ON
3. 권한 요청 → 허용
4. 통知時刻 선택 (18~22시)
5. 완료!
```

---

## 📊 프로젝트 완성도

```
✅ 100% 완성!

- 핵심 기능: 100%
- UI/UX: 100%
- 위젯: 100%
- 알림: 100%
- 데이터: 10개 도시
- 문서화: 100%
```

---

## 🎓 배운 것들

이 프로젝트를 통해 습득한 iOS 개발 기술:

### SwiftUI
- TabView, NavigationStack
- List, Form, Picker
- @State, @Binding, @StateObject
- Task, async/await
- .searchable 모디파이어

### WidgetKit
- TimelineProvider
- Widget Configuration
- App Group 데이터 공유
- accessoryRectangular, Circular, Inline
- containerBackground

### Foundation
- Calendar (Asia/Tokyo)
- DateComponents
- JSON Codable
- FileManager

### UserNotifications
- UNUserNotificationCenter
- 권한 요청
- 로컬 알림 스케줄링
- UNCalendarNotificationTrigger

### 아키텍처
- MVVM 패턴
- Shared 코드 구조
- App Group 데이터 공유
- 단위 테스트 (XCTest)

---

## 📄 라이선스

MIT License

---

## 🗾 지역 데이터 추가 방법

현재 **도쿄 23구** 데이터가 포함되어 있습니다. 다른 지역을 추가하려면:

### 방법 1: 직접 설정 기능 사용
앱에서 "地域を選択" → 본인 지역 선택 → "直接設定" 버튼으로 일정 입력

### 방법 2: areas.json에 데이터 추가
GitHub에서 Pull Request를 통해 데이터 기여:

```json
{
  "id": "지역코드-이름",
  "prefecture": "都道府県",
  "city": "市区町村",
  "cityKana": "ひらがな",
  "area": null,
  "rules": [
    {
      "id": "유니크ID",
      "type": "burnable",  // burnable, nonBurnable, resource, plastic, paper
      "weekdays": [2, 5],  // 1=일요일, 2=월요일, ... 7=토요일
      "weeks": null,       // null=매주, [1,3]=제1·제3주
      "biweeklyStartDate": null
    }
  ],
  "exceptions": [],
  "source": "자치체 URL",
  "updated": "YYYY-MM-DD"
}
```

### 데이터 출처
각 지역의 쓰레기 수거 일정은 해당 자치체 홈페이지에서 확인하세요:
- 도쿄 23구: https://www.tokyo23city.or.jp/
- 전국 자치체 검색: https://www.soumu.go.jp/

---

## 🌐 커뮤니티 기여

다음 지역의 데이터를 추가해주세요!

**우선순위:**
1. 정령지정도시 (20개)
   - 요코하마시, 오사카시, 나고야시, 삿포로시, 후쿠오카시 등
2. 도도부현청 소재지 (47개)
3. 인구 10만 이상 도시

**기여 방법:**
1. `areas.json` 파일 수정
2. Pull Request 제출
3. 출처 URL 반드시 포함

---

**개발자**: hyun_kim  
**시작일**: 2026년 11월 22일  
**목적**: 일본 거주자의 쓰레기 배출일 관리를 편리하게!
