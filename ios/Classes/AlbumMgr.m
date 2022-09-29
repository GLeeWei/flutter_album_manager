//
//  AlbumMgr.m
//  album_manager
//
//  Created by LeeWei on 2022/8/8.
//

#import "AlbumMgr.h"
#import <Photos/Photos.h>
#import "AlbumAsset.h"

@implementation AlbumMgr
{
    NSMutableDictionary<NSString*, AlbumAsset*> *assetsCache;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        assetsCache = [[NSMutableDictionary alloc] init];
    }
    return self;
}
-(void) saveToAlbum:(NSString*) path title: (NSString*) title mimeType:(NSString*) mimeType albumName:(NSString*) albumName block:(nonnull AssetResult)block
{
    __block NSString* localId;
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        PHAssetCreationRequest* request = [PHAssetCreationRequest creationRequestForAsset];
        PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
        options.originalFilename = title;
        options.shouldMoveFile = TRUE;
        PHAssetResourceType rType = [self getResourceType:mimeType];
        if (PHAssetResourceTypeVideo == rType){
            NSURL *fileURL = [NSURL fileURLWithPath:path];
            [request addResourceWithType:rType fileURL:fileURL options:options];
        } else{
            NSData *data = [NSData dataWithContentsOfFile:path];
            [request addResourceWithType:rType data:data options:options];
        }
        PHObjectPlaceholder *placeholder = [request placeholderForCreatedAsset];
        localId = placeholder.localIdentifier;
        if(![albumName isEqual:[NSNull null]]){
            PHAssetCollectionChangeRequest *collectionRequest;
            PHAssetCollection *assetCollection = [self getCurrentPhotoCollectionWithTitle:albumName];
            if (assetCollection) {
                collectionRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
            } else {
                collectionRequest = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName];
            }
            [collectionRequest addAssets:@[placeholder]];
        }
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (success) {
            block(nil, [self getAsset:localId]);
        } else {
            block(error, nil);
        }
    }];
}


- (PHAssetCollection *)getCurrentPhotoCollectionWithTitle:(NSString *)collectionName {
    for (PHAssetCollection *assetCollection in [self getAlbumGroup]) {
        if ([assetCollection.localizedTitle containsString:collectionName]) {
            return assetCollection;
        }
    }
    return nil;
}

-(PHFetchResult<PHAssetCollection *> *)getAlbumGroup{
    return [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
}

-(PHAssetResourceType) getResourceType: (NSString*) mimeType
{
    if ([mimeType containsString:@"image"]) {
        return PHAssetResourceTypePhoto;
    } else if ([mimeType containsString:@"video"]) {
        return PHAssetResourceTypeVideo;
    } /* else if ([mimeType containsString:@"audio"]) {
       return PHAssetResourceTypeAudio;
       } */
    return PHAssetResourceTypePhoto;
}

- (AlbumAsset *)getAsset:(NSString *)assetId
{
    return [self getAsset:assetId withCache:true];
}

-(AlbumAsset*) getAsset:(NSString *)assetId withCache:(BOOL)withCache
{
    AlbumAsset *assetEx;
    
    if (withCache) {
        assetEx = [assetsCache objectForKey:assetId];
        if (assetEx) return assetEx;
    }
    
    PHFetchResult<PHAsset *> *assetResult =
    [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil];
    if (assetResult == nil || assetResult.count == 0) {
        return nil;
    }
    
    PHAsset *asset = [assetResult firstObject];
    assetEx = [[AlbumAsset alloc] initWithPHAsset:asset];
    [assetsCache setObject:assetEx forKey:assetId];
    return assetEx;
}

@end
