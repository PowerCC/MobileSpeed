//
//  JSONModel+networking.h
//  JSONModel
//

#import "MSLJSONModel.h"
#import "MSLJSONHTTPClient.h"

typedef void (^JSONModelBlock)(id model, MSLJSONModelError *err) DEPRECATED_ATTRIBUTE;

@interface MSLJSONModel (Networking)

@property (assign, nonatomic) BOOL isLoading DEPRECATED_ATTRIBUTE;
- (instancetype)initFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)getModelFromURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;
+ (void)postModel:(MSLJSONModel *)post toURLWithString:(NSString *)urlString completion:(JSONModelBlock)completeBlock DEPRECATED_ATTRIBUTE;

@end
