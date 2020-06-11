//
//  MSLJSONModelError.h
//  JSONModel
//

#import <Foundation/Foundation.h>

/////////////////////////////////////////////////////////////////////////////////////////////
typedef NS_ENUM(int, kMSLJSONModelErrorTypes)
{
    kMSLJSONModelErrorInvalidData = 1,
    kMSLJSONModelErrorBadResponse = 2,
    kMSLJSONModelErrorBadJSON = 3,
    kMSLJSONModelErrorModelIsInvalid = 4,
    kMSLJSONModelErrorNilInput = 5
};

/////////////////////////////////////////////////////////////////////////////////////////////
/** The domain name used for the MSLJSONModelError instances */
extern NSString *const MSLJSONModelErrorDomain;

/**
 * If the model JSON input misses keys that are required, check the
 * userInfo dictionary of the MSLJSONModelError instance you get back -
 * under the kJSONModelMissingKeys key you will find a list of the
 * names of the missing keys.
 */
extern NSString *const kJSONModelMissingKeys;

/**
 * If JSON input has a different type than expected by the model, check the
 * userInfo dictionary of the MSLJSONModelError instance you get back -
 * under the kJSONModelTypeMismatch key you will find a description
 * of the mismatched types.
 */
extern NSString *const kJSONModelTypeMismatch;

/**
 * If an error occurs in a nested model, check the userInfo dictionary of
 * the MSLJSONModelError instance you get back - under the kJSONModelKeyPath
 * key you will find key-path at which the error occurred.
 */
extern NSString *const kJSONModelKeyPath;

/////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Custom NSError subclass with shortcut methods for creating
 * the common JSONModel errors
 */
@interface MSLJSONModelError : NSError

@property (strong, nonatomic) NSHTTPURLResponse *httpResponse;

@property (strong, nonatomic) NSData *responseData;

/**
 * Creates a MSLJSONModelError instance with code kMSLJSONModelErrorInvalidData = 1
 */
+ (id)errorInvalidDataWithMessage:(NSString *)message;

/**
 * Creates a MSLJSONModelError instance with code kMSLJSONModelErrorInvalidData = 1
 * @param keys a set of field names that were required, but not found in the input
 */
+ (id)errorInvalidDataWithMissingKeys:(NSSet *)keys;

/**
 * Creates a MSLJSONModelError instance with code kMSLJSONModelErrorInvalidData = 1
 * @param mismatchDescription description of the type mismatch that was encountered.
 */
+ (id)errorInvalidDataWithTypeMismatch:(NSString *)mismatchDescription;

/**
 * Creates a MSLJSONModelError instance with code kMSLJSONModelErrorBadResponse = 2
 */
+ (id)errorBadResponse;

/**
 * Creates a MSLJSONModelError instance with code kMSLJSONModelErrorBadJSON = 3
 */
+ (id)errorBadJSON;

/**
 * Creates a MSLJSONModelError instance with code kMSLJSONModelErrorModelIsInvalid = 4
 */
+ (id)errorModelIsInvalid;

/**
 * Creates a MSLJSONModelError instance with code kMSLJSONModelErrorNilInput = 5
 */
+ (id)errorInputIsNil;

/**
 * Creates a new MSLJSONModelError with the same values plus information about the key-path of the error.
 * Properties in the new error object are the same as those from the receiver,
 * except that a new key kJSONModelKeyPath is added to the userInfo dictionary.
 * This key contains the component string parameter. If the key is already present
 * then the new error object has the component string prepended to the existing value.
 */
- (instancetype)errorByPrependingKeyPathComponent:(NSString *)component;

/////////////////////////////////////////////////////////////////////////////////////////////
@end
