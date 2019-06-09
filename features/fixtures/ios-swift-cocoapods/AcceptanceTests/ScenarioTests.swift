//
//  ScenarioTests.swift
//  AcceptanceTests
//
//  Created by Paul Zabelin on 6/9/19.
//  Copyright © 2019 Bugsnag. All rights reserved.
//

import XCTest

class ScenarioTests: XCTestCase {
    var app: XCUIApplication!
    let timeout: TimeInterval = 30

    var scenario: String!

    override var name: String {
        return scenario!
    }

    override class var defaultTestSuite: XCTestSuite {
        let suite = XCTestSuite(forTestCaseClass: ScenarioTests.self)

        let scenarios = ["NewSessionScenario", "StoppedSessionScenario", "SwiftAssertion", "SwiftCrash", "HandledExceptionScenario", "HandledErrorOverrideScenario", "HandledErrorScenario", "UserIdScenario", "ResumedSessionScenario", "UserDisabledScenario", "UserEnabledScenario", "UserEmailScenario", "NSExceptionScenario", "DisabledSessionTrackingScenario", "StopSessionOOMScenario", "AutoSessionScenario", "ManualSessionScenario", "PrivilegedInstructionScenario", "AutoSessionHandledEventsScenario", "ReportBackgroundOOMsEnabledScenario", "NonExistentMethodScenario", "AutoSessionUnhandledScenario", "BuiltinTrapScenario", "MinimalCrashReportScenario", "UndefinedInstructionScenario", "StackOverflowScenario", "ReadOnlyPageScenario", "OverwriteLinkRegisterScenario", "CorruptMallocScenario", "AccessNonObjectScenario", "ObjCExceptionScenario", "ReportOOMsDisabledReportBackgroundOOMsEnabledScenario", "ManualSessionWithUserScenario", "ReadGarbagePointerScenario", "AsyncSafeThreadScenario", "NullPointerScenario", "OOMScenario", "ObjCMsgSendScenario", "NSExceptionShiftScenario", "CxxExceptionScenario", "ReleasedObjectScenario", "SessionOOMScenario", "AbortScenario", "AutoSessionMixedEventsScenario", "ResumeSessionOOMScenario", "AutoSessionWithUserScenario", "ReportOOMsDisabledScenario", "AutoSessionCustomVersionScenario"]

        scenarios.forEach { name in
            let test = ScenarioTests(selector: #selector(verifyScenario))
            test.scenario = name
            suite.addTest(test)
        }

        return suite
    }

    @objc func verifyScenario() {
        guard let scenario = scenario else {
            XCTFail("no scenario")
            return
        }
        print("verifying scenario: ", scenario)
        app.launchArguments += [
            "MOCK_API_PATH=http://localhost:3000/snag/\(scenario)",
            "EVENT_TYPE=\(scenario)"
        ]
        app.launch()
    }

    override func recordFailure(withDescription description: String, inFile filePath: String, atLine lineNumber: Int, expected: Bool) {
        return
    }

    override func setUp() {
        continueAfterFailure = true
        app = XCUIApplication()
        app.launchArguments = [
            "BUGSNAG_API_KEY=a35a2a72bd230ac0aa0f52715bbdc6aa"
        ]
    }

    override func tearDown() {
        print("tear down launch")
        app.launchArguments += ["EVENT_MODE=noevent"]
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: timeout))
        sleep(2)
    }

}
