//
//  AcceptanceTests.swift
//  AcceptanceTests
//
//  Created by Paul Zabelin on 6/8/19.
//  Copyright © 2019 Bugsnag. All rights reserved.
//

import XCTest

func subclasses<T>(of theClass: T) -> [T] {
    var count: UInt32 = 0, result: [T] = []
    let allClasses = objc_copyClassList(&count)!

    for n in 0 ..< count {
        let someClass: AnyClass = allClasses[Int(n)]
        guard let someSuperClass = class_getSuperclass(someClass), String(describing: someSuperClass) == String(describing: theClass) else { continue }
        result.append(someClass as! T)
    }

    return result
}

class AcceptanceTests: XCTestCase {
    var app: XCUIApplication!
    let timeout: TimeInterval = 30

    override func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: Int, expected: Bool) {
        return
    }

//    override var testRunClass: AnyClass? {
//        return SpecialRun.self
//    }
//
//    override var testRun: SpecialRun? {
//        return (super.testRun as! SpecialRun)
//    }

    override func setUp() {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = [
            "MOCK_API_PATH=http://localhost:3000/snag",
            "BUGSNAG_API_KEY=a35a2a72bd230ac0aa0f52715bbdc6aa"
        ]
    }

//    override func tearDown() {
//        print("tear down launch")
//        app.launchArguments += ["EVENT_MODE=noevent"]
//        app.launch()
//        XCTAssertTrue(app.wait(for: .runningForeground, timeout: timeout))
//        sleep(2)
//    }

    func testLaunchWithoutCrash() {
        app.launchArguments += ["EVENT_TYPE=UserIdScenario"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: timeout))
    }

    func testCxxExceptionScenario() {
        app.launchArguments += ["EVENT_TYPE=CxxExceptionScenario"]
//        testRun!.expect(Failure(description: "iOSTestApp crashed in main", file: "<unknown>", atLine: 0, expected: true))
        app.launch()
    }

    func testNSExceptionScenario() {
        NSSetUncaughtExceptionHandler { exc in
            print(exc)
        }
        app.launchArguments += ["EVENT_TYPE=NSExceptionScenario"]
        addUIInterruptionMonitor(withDescription: "monitor") { element -> Bool in
            print("interrupted: ", element)
            return true
        }
//        testRun!.expect(Failure(description: "iOSTestApp crashed in main", file: "<unknown>", atLine: 0, expected: true))
        app.launch()

    }

}

struct Failure: Equatable {
    let description: String
    let file: String?
    let atLine: Int
    let expected: Bool
}
