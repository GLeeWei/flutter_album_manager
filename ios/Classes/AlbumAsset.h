//
//  AlbumAsset.h
//  album_manager
//
//  Created by LeeWei on 2022/8/10.
//

#import <Foundation/Foundation.h>

@class PHAsset;

NS_ASSUME_NONNULL_BEGIN

@interface AlbumAsset : NSObject

@property(nonatomic, strong) PHAsset* phAsset;

@property(nonatomic, copy) NSString *id;
@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *mimeType;
@property(nonatomic, assign) long creationDate;
@property(nonatomic, assign) long modifiedDate;
@property(nonatomic, assign) double lat;
@property(nonatomic, assign) double lng;

-(instancetype)initWithPHAsset:(PHAsset*)asset;
- (void) metas:(void (^)(NSDictionary* meta)) block;

@end

NS_ASSUME_NONNULL_END
