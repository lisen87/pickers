#import "PickersPlugin.h"
#import <pickers/pickers-Swift.h>

@implementation PickersPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftPickersPlugin registerWithRegistrar:registrar];
}
@end
