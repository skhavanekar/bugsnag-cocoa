import UIKit
import Bugsnag

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

extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        let scenarios = subclasses(of: Scenario.self).map {$0.description().deletingPrefix("iOSTestApp.")}
//        print(scenarios)

        loadTestScenario()
        return true
    }

    internal func loadTestScenario() {
        let arguments = ProcessInfo.processInfo.arguments
        var delay: TimeInterval = 0
        var eventType = "none"
        var eventMode = "regular"
        var bugsnagAPIKey = ""
        var mockAPIPath = ""

        for argument in arguments {
            if argument.contains("EVENT_DELAY") {
                let components = argument.split(separator: "=")
                if let interval = TimeInterval(components.last!) {
                    delay = interval
                }
            } else if argument.contains("EVENT_TYPE") {
                eventType = String(argument.split(separator: "=").last!)
            } else if argument.contains("MOCK_API_PATH") {
                mockAPIPath = String(argument.split(separator: "=").last!)
            } else if argument.contains("BUGSNAG_API_KEY") {
                bugsnagAPIKey = String(argument.split(separator: "=").last!)
            } else if argument.contains("EVENT_MODE") {
                eventMode = String(argument.split(separator: "=").last!)
            }
        }
        assert(mockAPIPath.count > 0, "The mock API path must be set prior to triggering events. Event Type: '" + eventType + "'")
        if eventType == "preheat" {
          assert(false)
        }

        let config = prepareConfig(apiKey: bugsnagAPIKey, mockAPIPath: mockAPIPath)
        let scenario = Scenario.createScenarioNamed(eventType, withConfig: config)
        scenario.eventMode = eventMode
        triggerEvent(scenario: scenario, delay: delay, mode: eventMode)
    }

    internal func prepareConfig(apiKey: String, mockAPIPath: String) -> BugsnagConfiguration {
        let config = BugsnagConfiguration()
        config.apiKey = apiKey
        config.setEndpoints(notify: mockAPIPath, sessions: mockAPIPath)
        return config
    }

    func triggerEvent(scenario: Scenario, delay: TimeInterval, mode: String) {
        let when = DispatchTime.now() + delay
        scenario.startBugsnag()
        if mode != "noevent" {
            DispatchQueue.main.asyncAfter(deadline: when) {
                scenario.run()
            }
        }
    }
}
