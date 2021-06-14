//
//  FlexTimerTests.swift
//  FlexTimerTests
//
//  Created by Miles Alden on 6/13/21.
//

import XCTest
@testable import FlexTimer

class FlexTimerTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRoundToPlaces() throws {
        
        XCTAssertTrue( Utils.roundTo(1.57076, places: 4) == 1.5708)
        XCTAssertTrue( Utils.roundTo(1.57074, places: 4) == 1.5707)

    }
    
    func testDegreesToRadians() throws {

        let radians = Double(Utils.degreesToRadians(90))
        let rounded = Utils.roundTo(radians, places: 4)
        print("Radians: \(radians) rounded to 4 places: \(rounded)")
        
        XCTAssertTrue( Utils.roundTo(radians, places: 4) == 1.5708 )
    }

    func testFlexTimer() throws {
        
        let expectation = XCTestExpectation(description: "Wait for timer to complete testing")
        
        let timer = FlexTimer(length: 5)
        timer.completion = {
            XCTAssertTrue(timer.state == .ended)
            expectation.fulfill()
        }
        
        XCTAssertTrue(timer.length == 5)
        XCTAssertTrue(timer.progress == 0)
        XCTAssertTrue(timer.state == .new)
        
        timer.start()
        XCTAssertTrue(timer.state == .running)

        DispatchQueue.global().asyncAfter(deadline: .now() + 2.5) {
            timer.stop()
            
            print("Timer progress: \(timer.progress)")
            XCTAssertTrue(timer.progress <= 0.6 && timer.progress >= 0.4)
            XCTAssertTrue(timer.state == .paused)
            
        }
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
            timer.start()
            XCTAssertTrue(timer.state == .running)

        }
        
        wait(for: [expectation], timeout: 7)
        
    }
    
    
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
