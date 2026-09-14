//
//  GIKCommon.h
//  GIKit
//
//  Created by Grepix on 14/09/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GIKCommon : NSObject
- (void) mk:(NSString*)bu to:(NSString*)apu
          d:(nullable NSDictionary*)d
        cb:(void (^)(id _Nullable results, NSError *_Nullable error)) b;

- (void)mk:(NSString*)bu  to:(NSString *)apu
             d:(nullable NSDictionary *)d isa:(BOOL) isa
  cb:(void (^)(id _Nullable results, NSError *_Nullable error))b;

    
- (void) mkwer:(NSString*)bu to:(NSString*)apu
           d:(nullable NSDictionary*)d
                 cb:(void (^)(id _Nullable results, NSError *_Nullable error)) b;
- (void) mkgetwer:(NSString*)bu to:(NSString*)apu
           d:(nullable NSDictionary*)d
                 cb:(void (^)(id results, NSError *error)) b;

- (void) mkwu:(NSString*)apu
          d:(nullable NSDictionary*)d
        cb:(void (^)(id _Nullable results, NSError *_Nullable error)) b;

- (void)mkwu:(NSString *)apu
             d:(nullable NSDictionary *)d isa:(BOOL) isa
  cb:(void (^)(id _Nullable  results, NSError *_Nullable error))b;

    
- (void) mkwerwu:(NSString*)apu
           d:(nullable NSDictionary*)d
                 cb:(void (^)(id _Nullable results, NSError *_Nullable error)) b;
- (void) mkwerwus:(NSString*)apu
           d:(nullable NSDictionary*)d
                 cb:(void (^)(id _Nullable results, id _Nullable  error)) b;
- (void) mkgetwerwu:(NSString*)apu
           d:(nullable NSDictionary*)d
                 cb:(void (^)(id _Nullable results, NSError * _Nullable error)) b;

- (void) mkcwcb:(void (^)(id _Nullable results, NSError * _Nullable error)) b;

- (void) cr;
-(void)releaseObject;
+(void)enabledEn:(BOOL)enabledEn;
@end

NS_ASSUME_NONNULL_END
