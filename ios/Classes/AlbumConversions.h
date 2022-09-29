//
//  AlbumConversions.h
//  album_manager
//
//  Created by LeeWei on 2022/8/11.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

@class AlbumAsset;

NS_ASSUME_NONNULL_BEGIN

@interface AlbumConversions : NSObject

+(NSDictionary*) convertAlbumAssetToMap:(AlbumAsset*) asset;
+(NSDictionary*) convertAssetMetaDictToMap:(NSDictionary*) meta;
@end

NS_ASSUME_NONNULL_END
