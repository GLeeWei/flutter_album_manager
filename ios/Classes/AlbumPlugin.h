//
//  AlbumPlugin.h
//  album_manager
//
//  Created by LeeWei on 2022/8/9.
//

#import <Foundation/Foundation.h>
#import <Flutter/Flutter.h>

@class AlbumMgr;

NS_ASSUME_NONNULL_BEGIN

@interface AlbumPlugin : NSObject

@property(atomic, strong)AlbumMgr *albumMgr;

-(void) registerPlugin:(NSObject <FlutterPluginRegistrar> *)registrar;
@end

NS_ASSUME_NONNULL_END
