#import "AlbumManagerPlugin.h"
#import <Photos/Photos.h>
#import "AlbumPlugin.h"

@implementation AlbumManagerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    AlbumPlugin* instance = [[AlbumPlugin alloc] init];
    [instance registerPlugin:registrar];
}
@end
