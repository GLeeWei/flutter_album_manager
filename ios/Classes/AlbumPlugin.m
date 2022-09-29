//
//  AlbumPlugin.m
//  album_manager
//
//  Created by LeeWei on 2022/8/9.
//
#import "AlbumPlugin.h"
#import <Photos/Photos.h>
#import "FlutterResultHandler.h"
#import "AlbumMgr.h"
#import "AlbumAsset.h"
#import "AlbumConversions.h"

@implementation AlbumPlugin

-(void) registerPlugin:(NSObject<FlutterPluginRegistrar> *)registrar
{
    AlbumMgr *mgr = [[AlbumMgr alloc] init];
    [self setAlbumMgr:mgr];
    FlutterMethodChannel* channel = [FlutterMethodChannel
                                     methodChannelWithName:@"album_manager"
                                     binaryMessenger:[registrar messenger]];
    [channel setMethodCallHandler:^(FlutterMethodCall * _Nonnull call, FlutterResult  _Nonnull result) {
        [self onMethodCall:call result:result];
    }];
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
    FlutterResultHandler *handler = [FlutterResultHandler handlerWithResult:result];
    if ([call.method isEqualToString:@"getPlatformVersion"]) {
        result([@"iOS " stringByAppendingString:[[UIDevice currentDevice] systemVersion]]);
    } else {
        if ([self albumMgr].isAuth) {
            [self onHandleAuthMethod:call handler:handler];
        } else {
            [self requestPermissionStatus:2 completeHandler:^(PHAuthorizationStatus status) {
                if (PHAuthorizationStatusAuthorized == status){
                    [self albumMgr].isAuth = TRUE;
                    [self onHandleAuthMethod:call handler:handler];
                } else {
                    FlutterError *error = [FlutterError errorWithCode:@"PERMISSION_NOT_AUTHORIZED" message:@"Permission denied" details:nil];
                    [handler reply:error];
                }
            }];
        }
    }
}


-(void) onHandleAuthMethod:(FlutterMethodCall*)call handler: (FlutterResultHandler*) handler
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
        NSString* method = call.method;
        if ([method isEqualToString:@"saveToAlbum"]) {
            [self saveToAlbum:call handler:handler];
        } else if ([method isEqualToString:@"getAsset"]) {
            NSString* assetId = call.arguments[@"assetId"];
            bool withCache = call.arguments[@"withCache"];
            AlbumAsset* asset = [[self albumMgr] getAsset:assetId withCache: withCache];
            [handler reply:(asset ?[AlbumConversions convertAlbumAssetToMap:asset] : nil)];
        } else if ([method isEqualToString:@"getAssetMeta"]) {
            NSString* assetId = call.arguments[@"id"];
            AlbumAsset* asset = [[self albumMgr] getAsset:assetId];
            if (nil == asset) return [handler reply:nil];
            [asset metas:^(NSDictionary *meta) {
                [handler reply:([AlbumConversions convertAssetMetaDictToMap:meta])];
            }];
        
        }else{
            [handler notImplemented];
        }
    });
    
}

-(void) saveToAlbum:(FlutterMethodCall*)call handler: (FlutterResultHandler*) handler
{
    NSString* path = call.arguments[@"path"];
    NSString* title = call.arguments[@"title"];
    NSString* mimeType = call.arguments[@"mimeType"];
    NSString* albumName = call.arguments[@"albumName"];
    [[self albumMgr] saveToAlbum:path title:title mimeType:mimeType albumName:albumName block:^(NSError * _Nullable error, AlbumAsset* _Nullable asset) {
        if(error !=  nil){
            [handler reply:([FlutterError errorWithCode:[NSString stringWithFormat:@"%ld", (long)error.code] message:error.description details:error.localizedFailureReason])];
        } else [handler reply:@YES];
    }];
}

- (void)requestPermissionStatus:(int)requestAccessLevel
                completeHandler:(void (^)(PHAuthorizationStatus status))completeHandler {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_14_0
    if (@available(iOS 14, *)) {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:requestAccessLevel handler:^(PHAuthorizationStatus status) {
            completeHandler(status);
        }];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            completeHandler(status);
        }];
    }
#else
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        completeHandler(status);
    }];
#endif
}

@end
