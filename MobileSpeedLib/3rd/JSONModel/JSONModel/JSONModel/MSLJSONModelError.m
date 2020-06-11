//
//  MSLJSONModelError.m
//  JSONModel
//

#import "MSLJSONModelError.h"

NSString* const MSLJSONModelErrorDomain = @"MSLJSONModelErrorDomain";
NSString* const kJSONModelMissingKeys = @"kJSONModelMissingKeys";
NSString* const kJSONModelTypeMismatch = @"kJSONModelTypeMismatch";
NSString* const kJSONModelKeyPath = @"kJSONModelKeyPath";

@implementation MSLJSONModelError

+(id)errorInvalidDataWithMessage:(NSString*)message
{
    message = [NSString stringWithFormat:@"Invalid JSON data: %@", message];
    return [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                      code:kMSLJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:message}];
}

+(id)errorInvalidDataWithMissingKeys:(NSSet *)keys
{
    return [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                      code:kMSLJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. Required JSON keys are missing from the input. Check the error user information.",kJSONModelMissingKeys:[keys allObjects]}];
}

+(id)errorInvalidDataWithTypeMismatch:(NSString*)mismatchDescription
{
    return [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                      code:kMSLJSONModelErrorInvalidData
                                  userInfo:@{NSLocalizedDescriptionKey:@"Invalid JSON data. The JSON type mismatches the expected type. Check the error user information.",kJSONModelTypeMismatch:mismatchDescription}];
}

+(id)errorBadResponse
{
    return [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                      code:kMSLJSONModelErrorBadResponse
                                  userInfo:@{NSLocalizedDescriptionKey:@"Bad network response. Probably the JSON URL is unreachable."}];
}

+(id)errorBadJSON
{
    return [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                      code:kMSLJSONModelErrorBadJSON
                                  userInfo:@{NSLocalizedDescriptionKey:@"Malformed JSON. Check the JSONModel data input."}];
}

+(id)errorModelIsInvalid
{
    return [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                      code:kMSLJSONModelErrorModelIsInvalid
                                  userInfo:@{NSLocalizedDescriptionKey:@"Model does not validate. The custom validation for the input data failed."}];
}

+(id)errorInputIsNil
{
    return [MSLJSONModelError errorWithDomain:MSLJSONModelErrorDomain
                                      code:kMSLJSONModelErrorNilInput
                                  userInfo:@{NSLocalizedDescriptionKey:@"Initializing model with nil input object."}];
}

- (instancetype)errorByPrependingKeyPathComponent:(NSString*)component
{
    // Create a mutable  copy of the user info so that we can add to it and update it
    NSMutableDictionary* userInfo = [self.userInfo mutableCopy];

    // Create or update the key-path
    NSString* existingPath = userInfo[kJSONModelKeyPath];
    NSString* separator = [existingPath hasPrefix:@"["] ? @"" : @".";
    NSString* updatedPath = (existingPath == nil) ? component : [component stringByAppendingFormat:@"%@%@", separator, existingPath];
    userInfo[kJSONModelKeyPath] = updatedPath;

    // Create the new error
    return [MSLJSONModelError errorWithDomain:self.domain
                                      code:self.code
                                  userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

@end
