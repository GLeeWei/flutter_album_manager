//
//  FlutterResultHandler.m
//  album_manager
//
//  Created by LeeWei on 2022/8/8.
//
#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

NS_ASSUME_NONNULL_BEGIN

@interface FlutterResultHandler : NSObject

@property(nonatomic, strong) FlutterResult result;

+ (instancetype)handlerWithResult:(FlutterResult)result;

- (instancetype)initWithResult:(FlutterResult)result;

- (void)replyError:(NSString *)errorCode;

- (void)reply:(__nullable id)obj;

- (void)notImplemented;

- (BOOL)isReplied;

@end
NS_ASSUME_NONNULL_END
