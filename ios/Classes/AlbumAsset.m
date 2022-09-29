//
//  AlbumAsset.m
//  album_manager
//
//  Created by LeeWei on 2022/8/10.
//

#import "AlbumAsset.h"
#import "PHAsset+Extension.h"
#import <Photos/Photos.h>

@implementation AlbumAsset

- (instancetype)initWithPHAsset:(PHAsset *)asset{
    self = [super init];
    if (self) {
        self.phAsset = asset;
        [self assingBaseValues];
    }
    
    return self;
}

-(void) assingBaseValues
{
    self.id = self.phAsset.localIdentifier;
    self.title = [self.phAsset title];
    self.mimeType = [self.phAsset mimeType];
    NSDate *date = self.phAsset.creationDate;
    self.creationDate = (long)date.timeIntervalSince1970;
    
    NSDate *modificationDate = self.phAsset.modificationDate;
    self.modifiedDate = (long)modificationDate.timeIntervalSince1970;
    
    self.lat = self.phAsset.location.coordinate.latitude;
    self.lng = self.phAsset.location.coordinate.longitude;
}

-(void) metas:(void (^)(NSDictionary *meta))block
{
    PHAssetMediaType mediaType =[self.phAsset mediaType];
    if (PHAssetMediaTypeImage == mediaType) {
        [self.phAsset requestContentEditingInputWithOptions:nil completionHandler:^(PHContentEditingInput * _Nullable contentEditingInput, NSDictionary * _Nonnull info) {
            CIImage *fullImage = [CIImage imageWithContentsOfURL:contentEditingInput.fullSizeImageURL];
            NSLog(@"%@",fullImage.properties);
            if (block)
                block(fullImage.properties);
        }];
    } else if (PHAssetMediaTypeVideo == mediaType){
        if (block)
            block(@{});
    }
}
@end
