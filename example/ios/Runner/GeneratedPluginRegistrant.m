//
//  Generated file. Do not edit.
//

#import "GeneratedPluginRegistrant.h"

#if __has_include(<permission_handler/PermissionHandlerPlugin.h>)
#import <permission_handler/PermissionHandlerPlugin.h>
#else
@import permission_handler;
#endif

#if __has_include(<audio_streamer/AudioStreamerPlugin.h>)
#import <audio_streamer/AudioStreamerPlugin.h>
#else
@import audio_streamer;
#endif

@implementation GeneratedPluginRegistrant

+ (void)registerWithRegistry:(NSObject<FlutterPluginRegistry>*)registry {
  [PermissionHandlerPlugin registerWithRegistrar:[registry registrarForPlugin:@"PermissionHandlerPlugin"]];
  [AudioStreamerPlugin registerWithRegistrar:[registry registrarForPlugin:@"AudioStreamerPlugin"]];
}

@end
