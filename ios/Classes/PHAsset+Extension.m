//
//  PHAsset+Extension.m
//  album_manager
//
//  Created by LeeWei on 2022/8/11.
//

#import "PHAsset+Extension.h"
#if TARGET_OS_IOS || TARGET_OS_WATCH || TARGET_OS_TV
#import <MobileCoreServices/MobileCoreServices.h>
#else
#import <CoreServices/CoreServices.h>
#endif

@implementation PHAsset (Extension)

-(NSString*) title
{
    @try {
        NSString* result = [self valueForKey:@"filename"];
        NSLog(@"title %@", result);
        return result;
    } @catch (NSException *exception) {
        return @"";    }
}

// UTI: https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/understanding_utis/understand_utis_intro/understand_utis_intro.html#//apple_ref/doc/uid/TP40001319
- (NSString *)mimeType {
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:self] firstObject];
    if (resource) {
        NSString *uti = resource.uniformTypeIdentifier;
        return (__bridge_transfer NSString *)UTTypeCopyPreferredTagWithClass((__bridge CFStringRef)uti, kUTTagClassMIMEType);
    }
    return nil;
}
@end
