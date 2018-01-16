//
// Created by Jamie Lynch on 04/12/2017.
// Copyright (c) 2017 Bugsnag. All rights reserved.
//

#import "BugsnagApiClient.h"
#import "BugsnagConfiguration.h"
#import "Bugsnag.h"
#import "BugsnagKeys.h"
#import "BugsnagLogger.h"

@interface BugsnagApiClient()
@property (nonatomic) NSURLSession *generatedSession;
@property(readonly) NSOperationQueue *sendQueue;
@property(readonly) NSOperationQueue *syncQueue;
@property NSOperation *requestOperation;
@property(readonly) BugsnagConfiguration *config;
@end

@implementation BugsnagApiClient

- (instancetype)initWithConfig:(BugsnagConfiguration *)configuration
                     queueName:(NSString *)queueName {
    if (self = [super init]) {
        _sendQueue = [NSOperationQueue new];
        _sendQueue.maxConcurrentOperationCount = 1;
        _syncQueue = [NSOperationQueue mainQueue];
        _config = configuration;

        if ([_sendQueue respondsToSelector:@selector(qualityOfService)]) {
            _sendQueue.qualityOfService = NSQualityOfServiceUtility;
        }
        _sendQueue.name = queueName;
    }
    return self;
}

#pragma mark - Delivery

- (void)sendData:(id)data
     withPayload:(NSDictionary *)payload
           toURL:(NSURL *)url
         headers:(NSDictionary *)headers
     synchronous:(BOOL)synchronous
    onCompletion:(RequestCompletion)onCompletion {

    [self.requestOperation cancel];

    void (^block)(void) = ^{
        [self sendData:data
           withPayload:payload
                 toURL:url
               headers:headers
          onCompletion:onCompletion];
    };
    if (synchronous) {
        block();
    } else {
        self.requestOperation = [NSBlockOperation blockOperationWithBlock:block];
        [self.sendQueue cancelAllOperations];
        [self.sendQueue addOperation:self.requestOperation];
    }
}

- (void)sendData:(id)data
     withPayload:(NSDictionary *)payload
           toURL:(NSURL *)url
         headers:(NSDictionary *)headers
    onCompletion:(RequestCompletion)onCompletion {
    
    @try {
        NSError *error = nil;
        NSData *jsonData =
                [NSJSONSerialization dataWithJSONObject:payload
                                                options:NSJSONWritingPrettyPrinted
                                                  error:&error];

        if (jsonData == nil) {
            if (onCompletion) {
                onCompletion(data, NO, error);
            }
            return;
        }
        NSMutableURLRequest *request = [self prepareRequest:url headers:headers];

        if ([NSURLSession class]) {
            NSURLSession *session = [self prepareSession];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            NSURLSessionTask *task = [session
                    uploadTaskWithRequest:request
                                 fromData:jsonData
                        completionHandler:^(NSData *_Nullable responseBody,
                                NSURLResponse *_Nullable response,
                                NSError *_Nullable requestErr) {
                            if (onCompletion) {
                                onCompletion(data, requestErr == nil, requestErr);
                            }
                            dispatch_semaphore_signal(semaphore);
                        }];
            [task resume];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            NSURLResponse *response = nil;
            request.HTTPBody = jsonData;
            [NSURLConnection sendSynchronousRequest:request
                                  returningResponse:&response
                                              error:&error];
            if (onCompletion) {
                onCompletion(data, error == nil, error);
            }
#pragma clang diagnostic pop
        }
    } @catch (NSException *exception) {
        if (onCompletion) {
            onCompletion(data, NO,
                    [NSError            errorWithDomain:exception.reason
                                        code:420
                                    userInfo:@{BSGKeyException: exception}]);
        }
    }
}

- (NSURLSession *)prepareSession {
    NSURLSession *session = [Bugsnag configuration].session;
    if (session) {
        return session;
    } else {
        if (self.generatedSession) {
            _generatedSession = [NSURLSession
                    sessionWithConfiguration:[NSURLSessionConfiguration
                            defaultSessionConfiguration]];
        }
        return self.generatedSession;
    }
}

- (NSMutableURLRequest *)prepareRequest:(NSURL *)url
                                headers:(NSDictionary *)headers {
    NSMutableURLRequest *request = [NSMutableURLRequest
            requestWithURL:url
               cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
           timeoutInterval:15];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    for (NSString *key in [headers allKeys]) {
        [request setValue:headers[key] forHTTPHeaderField:key];
    }
    return request;
}

@end
