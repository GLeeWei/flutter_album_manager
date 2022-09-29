//
//  PHAsset+Extension.h
//  album_manager
//
//  Created by LeeWei on 2022/8/11.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

@interface PHAsset (Extension)

- (NSString*)title;
/**
 Get the MIME type for this asset from UTI (`PHAssetResource.uniformTypeIdentifier`), such as `image/jpeg`, `image/heic`, `video/quicktime`, etc.
 
 @note For Live Photos, this returns a type representing its image file.
 @return The MIME type of this asset if available, otherwise `nil`.
 */
- (nullable NSString*)mimeType;
@end

NS_ASSUME_NONNULL_END
