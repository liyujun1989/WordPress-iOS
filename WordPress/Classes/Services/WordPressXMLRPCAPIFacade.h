#import <Foundation/Foundation.h>

@protocol WordPressXMLRPCAPIFacade
NS_ASSUME_NONNULL_BEGIN

- (void)guessXMLRPCURLForSite:(NSString *)url
                      success:(void (^)(NSURL *xmlrpcURL))success
                      failure:(void (^)(NSError *error))failure;

- (void)getBlogOptionsWithEndpoint:(NSURL *)xmlrpc
                         username:(NSString *)username
                         password:(NSString *)password
                          success:(void (^)(id options))success
                          failure:(void (^)(NSError *error))failure;

NS_ASSUME_NONNULL_END
@end

@interface WordPressXMLRPCAPIFacade : NSObject<WordPressXMLRPCAPIFacade>

@end
