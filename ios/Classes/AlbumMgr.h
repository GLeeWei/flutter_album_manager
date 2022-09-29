//
//  AlbumMgr.h
//  album_manager
//
//  Created by LeeWei on 2022/8/8.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AlbumAsset;

typedef void (^AssetResult) (NSError* _Nullable error, AlbumAsset* _Nullable asset) ;

@interface AlbumMgr : NSObject
@property(nonatomic, assign) bool isAuth;

-(void) saveToAlbum:(NSString*) path title: (NSString*) title mimeType:(NSString*) mimeType albumName:(NSString*) albumName block:(AssetResult) block;
-(AlbumAsset*) getAsset:(NSString*) assetId;
-(AlbumAsset*) getAsset:(NSString *)assetId withCache:(BOOL) withCache;

@end

NS_ASSUME_NONNULL_END
