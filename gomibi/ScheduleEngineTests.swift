//
//  ScheduleEngineTests.swift
//  GomiDayTests
//
//  Created by hyun_kim on 2026/11/22.
//
//  ⚠️ 테스트는 나중에 활성화합니다!
//  테스트 타깃이 제대로 설정되면 아래 주석을 해제하세요.
w
/*
import XCTest
import Foundation
@testable import gomibi

/// ScheduleEngine 단위 테스트
class ScheduleEngineTests: XCTestCase {
    
    // MARK: - 테스트용 헬퍼
    
    /// 테스트용 지역 데이터 생성
    private func createTestArea() -> Area {
        Area(
            id: "test-area",
            prefecture: "東京都",
            city: "世田谷区",
            cityKana: "せたがやく",
            area: "三軒茶屋",
            rules: [
                // 매주 월·목요일 - 가연 쓰레기
                GarbageScheduleRule(
                    type: .burnable,
                    weekdays: [2, 5],  // 월=2, 목=5
                    weeks: nil
                ),
                // 제1·제3 수요일 - 불연 쓰레기
                GarbageScheduleRule(
                    type: .nonBurnable,
                    weekdays: [4],  // 수=4
                    weeks: [1, 3]
                ),
                // 제2·제4 수요일 - 자원 쓰레기
                GarbageScheduleRule(
                    type: .resource,
                    weekdays: [4],  // 수=4
                    weeks: [2, 4]
                ),
                // 매주 화요일 - 플라스틱
                GarbageScheduleRule(
                    type: .plastic,
                    weekdays: [3],  // 화=3
                    weeks: nil
                )
            ],
            exceptions: [],
            source: nil,
            updated: nil
        )
    }
    
    /// 특정 날짜 생성 (도쿄 시간대)
    private func makeDate(year: Int, month: Int, day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute
        components.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return Calendar.tokyo.date(from: components)!
    }
    
    // MARK: - 테스트: 매주 ○요일
    
    func testWeeklyMonday() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 24일 (월요일) 확인
        let monday = makeDate(year: 2026, month: 11, day: 24)
        let schedules = engine.getSchedules(for: monday)
        
        // 가연 쓰레기가 수거되어야 함
        XCTAssertEqual(schedules.count, 1)
        XCTAssertEqual(schedules.first?.garbageType, .burnable)
    }
    
    func testWeeklyThursday() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 26일 (목요일) 확인
        let thursday = makeDate(year: 2026, month: 11, day: 26)
        let schedules = engine.getSchedules(for: thursday)
        
        // 가연 쓰레기가 수거되어야 함
        XCTAssertEqual(schedules.count, 1)
        XCTAssertEqual(schedules.first?.garbageType, .burnable)
    }
    
    // MARK: - 테스트: 第n ○요일
    
    func testSecondWednesday() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 11일 (제2 수요일)
        let secondWed = makeDate(year: 2026, month: 11, day: 11)
        let schedules = engine.getSchedules(for: secondWed)
        
        // 자원 쓰레기가 수거되어야 함
        XCTAssertTrue(schedules.contains(where: { $0.garbageType == .resource }))
    }
    
    func testFirstWednesday() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 4일 (제1 수요일)
        let firstWed = makeDate(year: 2026, month: 11, day: 4)
        let schedules = engine.getSchedules(for: firstWed)
        
        // 불연 쓰레기가 수거되어야 함
        XCTAssertTrue(schedules.contains(where: { $0.garbageType == .nonBurnable }))
    }
    
    func testThirdWednesday() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 18일 (제3 수요일)
        let thirdWed = makeDate(year: 2026, month: 11, day: 18)
        let schedules = engine.getSchedules(for: thirdWed)
        
        // 불연 쓰레기가 수거되어야 함
        XCTAssertTrue(schedules.contains(where: { $0.garbageType == .nonBurnable }))
    }
    
    // MARK: - 테스트: 수거 없는 날
    
    func testNoCollectionSunday() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 22일 (일요일)
        let sunday = makeDate(year: 2026, month: 11, day: 22)
        let schedules = engine.getSchedules(for: sunday)
        
        // 수거가 없어야 함
        XCTAssertTrue(schedules.isEmpty)
    }
    
    func testNoCollectionSaturday() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 21일 (토요일)
        let saturday = makeDate(year: 2026, month: 11, day: 21)
        let schedules = engine.getSchedules(for: saturday)
        
        // 수거가 없어야 함
        XCTAssertTrue(schedules.isEmpty)
    }
    
    // MARK: - 테스트: 마감 시각
    
    func testBeforeDeadline() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 24일 (월요일) 오전 7시
        let beforeDeadline = makeDate(year: 2026, month: 11, day: 24, hour: 7, minute: 0)
        let schedules = engine.getTodaySchedule(at: beforeDeadline)
        
        // 오늘 일정이 있어야 함 (가연 쓰레기)
        XCTAssertEqual(schedules.count, 1)
        XCTAssertEqual(schedules.first?.garbageType, .burnable)
    }
    
    func testAfterDeadline() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 24일 (월요일) 오전 9시
        let afterDeadline = makeDate(year: 2026, month: 11, day: 24, hour: 9, minute: 0)
        let schedules = engine.getTodaySchedule(at: afterDeadline)
        
        // 마감 후이므로 빈 배열
        XCTAssertTrue(schedules.isEmpty)
    }
    
    func testExactDeadline() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 24일 (월요일) 오전 8시 30분 정각
        let exactDeadline = makeDate(year: 2026, month: 11, day: 24, hour: 8, minute: 30)
        let schedules = engine.getTodaySchedule(at: exactDeadline)
        
        // 마감 시각 이후이므로 빈 배열
        XCTAssertTrue(schedules.isEmpty)
    }
    
    // MARK: - 테스트: 다음 일정
    
    func testNextScheduleBeforeDeadline() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 23일 (일요일) 오전 7시
        let sunday = makeDate(year: 2026, month: 11, day: 23, hour: 7, minute: 0)
        let nextSchedule = engine.getNextSchedule(after: sunday)
        
        // 다음 일정은 11월 24일 (월요일) 가연
        XCTAssertNotNil(nextSchedule)
        XCTAssertEqual(nextSchedule?.garbageType, .burnable)
        
        let expectedDate = makeDate(year: 2026, month: 11, day: 24)
        XCTAssertTrue(Calendar.tokyo.isDate(nextSchedule!.date, inSameDayAs: expectedDate))
    }
    
    func testNextScheduleAfterDeadline() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 24일 (월요일) 오전 9시 (마감 후)
        let afterDeadline = makeDate(year: 2026, month: 11, day: 24, hour: 9, minute: 0)
        let nextSchedule = engine.getNextSchedule(after: afterDeadline)
        
        // 다음 일정은 11월 25일 (화요일) 플라스틱
        XCTAssertNotNil(nextSchedule)
        XCTAssertEqual(nextSchedule?.garbageType, .plastic)
        
        let expectedDate = makeDate(year: 2026, month: 11, day: 25)
        XCTAssertTrue(Calendar.tokyo.isDate(nextSchedule!.date, inSameDayAs: expectedDate))
    }
    
    // MARK: - 테스트: 주간 일정
    
    func testThisWeekSchedules() throws {
        let area = createTestArea()
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 2026년 11월 24일 (월요일) 기준
        let monday = makeDate(year: 2026, month: 11, day: 24)
        let weekSchedules = engine.getThisWeekSchedules(relativeTo: monday)
        
        // 7일치 일정이 있어야 함
        XCTAssertEqual(weekSchedules.count, 7)
        
        // 월요일에 가연 쓰레기가 있어야 함
        let mondaySchedule = weekSchedules.first { schedule in
            Calendar.tokyo.isDate(schedule.date, inSameDayAs: monday)
        }
        XCTAssertNotNil(mondaySchedule)
        XCTAssertTrue(mondaySchedule?.hasCollection == true)
        XCTAssertTrue(mondaySchedule?.schedules.contains(where: { $0.garbageType == .burnable }) == true)
    }
    
    // MARK: - 테스트: 예외 날짜
    
    func testExceptionNone() throws {
        let exceptionDate = makeDate(year: 2026, month: 12, day: 31)  // 목요일
        
        var area = createTestArea()
        area = Area(
            id: area.id,
            prefecture: area.prefecture,
            city: area.city,
            cityKana: area.cityKana,
            area: area.area,
            rules: area.rules,
            exceptions: [
                ScheduleException(
                    originalDate: exceptionDate,
                    action: .none
                )
            ],
            source: area.source,
            updated: area.updated
        )
        
        let engine = ScheduleEngine(
            area: area,
            collectionDeadline: TimeOfDay(hour: 8, minute: 30)
        )
        
        // 12월 31일 (목요일)은 원래 가연 쓰레기 수거일이지만 예외로 없음
        let schedules = engine.getSchedules(for: exceptionDate)
        XCTAssertTrue(schedules.isEmpty)
    }
}
*/
