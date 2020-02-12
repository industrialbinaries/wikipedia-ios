@import Foundation;

extern NSString *const WMFNetworkingErrorDomain;

extern NSString *const WMFNetworkRequestBeganNotification;
extern NSString *const WMFNetworkRequestBeganNotificationRequestKey;

typedef NS_ENUM(NSInteger, WMFNetworkingError) {
    WMFNetworkingError_APIError,
    WMFNetworkingError_InvalidParameters
};

/// @name Functions

/**
 * Take an array of strings and concatenate them with "|" as a delimiter.
 * @return A string of the concatenated elements, or an empty string if @c props is empty or @c nil.
 */
extern NSString *WMFJoinedPropertyParameters(NSArray *props);

extern NSError *WMFErrorForApiErrorObject(NSDictionary *apiError);

extern void wmf_postNetworkRequestBeganNotification(NSURLRequest *request);
