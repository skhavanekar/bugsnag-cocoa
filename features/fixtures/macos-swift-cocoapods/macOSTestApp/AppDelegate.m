#import "AppDelegate.h"
#import <Bugsnag/Bugsnag.h>
#import "Scenario.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self loadTestScenario];
}

- (void)loadTestScenario {
    NSArray *arguments = [NSProcessInfo processInfo].arguments;
    NSTimeInterval delay = 0;
    NSString *eventType = @"none";
    NSString *eventMode = @"regular";
    NSString *bugsnagAPIKey = @"";
    NSString *mockAPIPath = @"";
    for (NSString *argument in arguments) {
        NSString *value = [[argument componentsSeparatedByString:@"="] lastObject];
        if ([argument containsString:@"EVENT_DELAY"]) {
            delay = [value integerValue];
        } else if ([argument containsString:@"EVENT_TYPE"]) {
            eventType = value;
        } else if ([argument containsString:@"EVENT_MODE"]) {
            eventMode = value;
        } else if ([argument containsString:@"BUGSNAG_API_KEY"]) {
            bugsnagAPIKey = value;
        } else if ([argument containsString:@"MOCK_API_PORT"]) {
            mockAPIPath = [@[@"http://", [NSHost currentHost].name, @":", value] componentsJoinedByString:@""];
        }
    }
    NSAssert(mockAPIPath.length > 0, @"The mock API path must be set prior to triggering events.");

    BugsnagConfiguration *config = [BugsnagConfiguration new];
    config.apiKey = bugsnagAPIKey;
    [config setEndpointsForNotify:mockAPIPath sessions:mockAPIPath];
    Scenario *scenario = [Scenario createScenarioNamed:eventType withConfig:config];
    scenario.eventMode = eventMode;
    [scenario startBugsnag];

    if (![eventMode isEqualToString:@"noevent"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [scenario run];
        });
    }
}
@end
