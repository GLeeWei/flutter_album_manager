//
//  AlbumConversions.h
//  album_manager
//
//  Created by LeeWei on 2022/8/11.
//

#import "AlbumConversions.h"
#import "AlbumAsset.h"

@implementation AlbumConversions

+(NSDictionary*) convertAlbumAssetToMap:(AlbumAsset *)asset
{
    return @{
        @"id" : asset.id,
        @"title" : asset.title,
        @"mimeType" : asset.mimeType,
        @"creationDate" : @(asset.creationDate),
        @"modifiedDate" : @(asset.modifiedDate),
        @"lng" : @(asset.lng),
        @"lat" : @(asset.lat),
    };
}

+(NSDictionary*) convertAssetMetaDictToMap:(NSDictionary *)meta {
    return @{
        @"ColorModel": [NSString stringWithFormat:@"%@", [meta valueForKey:@"ColorModel"]],
        @"DPIHeight": @([[NSString stringWithFormat:@"%@", [meta valueForKey:@"DPIHeight"]]  doubleValue]),
        @"DPIWidth": @([[NSString stringWithFormat:@"%@", [meta valueForKey:@"DPIWidth"] ] doubleValue]),
        @"Depth": @([[NSString stringWithFormat:@"%@", [meta valueForKey:@"Depth"] ] intValue]),
        @"PixelHeight": @([[NSString stringWithFormat:@"%@", [meta valueForKey:@"PixelHeight"] ] intValue]),
        @"PixelWidth": @([[NSString stringWithFormat:@"%@", [meta valueForKey:@"PixelWidth"] ] intValue]),
        @"ProfileName": [NSString stringWithFormat:@"%@", [meta valueForKey:@"ColorModel"]],
//        @"Exif" : [meta objectForKey:@"{Exif}"],
//        @"TIFF" : [meta objectForKey:@"{TIFF}"],
//        @"GPS" : [meta objectForKey:@"{GPS}"],
    };
}

-(NSString*) strinVauleForKey: id
{
    return [NSString stringWithFormat:@"%@", id];
}

-(NSInteger) intVauleForKey: id
{
    return [[NSString stringWithFormat:@"%@", id] integerValue];
}
@end
