#import "ReportingApplication.h"
#import <Bugsnag/Bugsnag.h>

@implementation ReportingApplication

- (void)reportException:(NSException *)exception {
    [Bugsnag notify:exception];
    [super reportException:exception];
}

@end
