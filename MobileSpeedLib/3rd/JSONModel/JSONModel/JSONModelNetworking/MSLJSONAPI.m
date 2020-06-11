//
//  MSLJSONAPI.m
//  JSONModel
//

#import "MSLJSONAPI.h"

#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
#pragma GCC diagnostic ignored "-Wdeprecated-implementations"

#pragma mark - helper error model class
@interface MSLMSLJSONAPIRPCErrorModel: MSLJSONModel
@property (assign, nonatomic) int code;
@property (strong, nonatomic) NSString* message;
@property (strong, nonatomic) id<Optional> data;
@end

#pragma mark - static variables

static MSLJSONAPI* sharedInstance = nil;

static long jsonRpcId = 0;

#pragma mark - MSLJSONAPI() private interface

@interface MSLJSONAPI ()
@property (strong, nonatomic) NSString* baseURLString;
@end

#pragma mark - MSLJSONAPI implementation

@implementation MSLJSONAPI

#pragma mark - initialize

+(void)initialize
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[MSLJSONAPI alloc] init];
    });
}

#pragma mark - api config methods

+(void)setAPIBaseURLWithString:(NSString*)base
{
    sharedInstance.baseURLString = base;
}

+(void)setContentType:(NSString*)ctype
{
    [MSLJSONHTTPClient setRequestContentType: ctype];
}

#pragma mark - GET methods
+(void)getWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];

    [MSLJSONHTTPClient getJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, MSLJSONModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - POST methods
+(void)postWithPath:(NSString*)path andParams:(NSDictionary*)params completion:(JSONObjectBlock)completeBlock
{
    NSString* fullURL = [NSString stringWithFormat:@"%@%@", sharedInstance.baseURLString, path];

    [MSLJSONHTTPClient postJSONFromURLWithString: fullURL params:params completion:^(NSDictionary *json, MSLJSONModelError *e) {
        completeBlock(json, e);
    }];
}

#pragma mark - RPC methods
+(void)__rpcRequestWithObject:(id)jsonObject completion:(JSONObjectBlock)completeBlock
{

    NSData* jsonRequestData = [NSJSONSerialization dataWithJSONObject:jsonObject
                                                              options:kNilOptions
                                                                error:nil];
    NSString* jsonRequestString = [[NSString alloc] initWithData:jsonRequestData encoding: NSUTF8StringEncoding];

    NSAssert(sharedInstance.baseURLString, @"API base URL not set");
    [MSLJSONHTTPClient postJSONFromURLWithString: sharedInstance.baseURLString
                                   bodyString: jsonRequestString
                                   completion:^(NSDictionary *json, MSLJSONModelError* e) {

                                       if (completeBlock) {
                                           //handle the rpc response
                                           NSDictionary* result = json[@"result"];

                                           if (!result) {
                                               MSLMSLJSONAPIRPCErrorModel* error = [[MSLMSLJSONAPIRPCErrorModel alloc] initWithDictionary:json[@"error"] error:nil];
                                               if (error) {
                                                   //custom server error
                                                   if (!error.message) error.message = @"Generic json rpc error";
                                                   e = [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                                                                  code:error.code
                                                                              userInfo: @{ NSLocalizedDescriptionKey : error.message}];
                                               } else {
                                                   //generic error
                                                   e = [MSLJSONModelError errorBadResponse];
                                               }
                                           }

                                           //invoke the callback
                                           completeBlock(result, e);
                                       }
                                   }];
}

+(void)rpcWithMethodName:(NSString*)method andArguments:(NSArray*)args completion:(JSONObjectBlock)completeBlock
{
    NSAssert(method, @"No method specified");
    if (!args) args = @[];

    [self __rpcRequestWithObject:@{
                                  //rpc 1.0
                                  @"id": @(++jsonRpcId),
                                  @"params": args,
                                  @"method": method
     } completion:completeBlock];
}

+(void)rpc2WithMethodName:(NSString*)method andParams:(id)params completion:(JSONObjectBlock)completeBlock
{
    NSAssert(method, @"No method specified");
    if (!params) params = @[];

    [self __rpcRequestWithObject:@{
                                  //rpc 2.0
                                  @"jsonrpc": @"2.0",
                                  @"id": @(++jsonRpcId),
                                  @"params": params,
                                  @"method": method
     } completion:completeBlock];
}

@end

#pragma mark - helper rpc error model class implementation
@implementation MSLMSLJSONAPIRPCErrorModel
@end
