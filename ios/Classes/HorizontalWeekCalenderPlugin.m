#import "HorizontalWeekCalenderPlugin.h"
#if __has_include(<horizontal_week_calender/horizontal_week_calender-Swift.h>)
#import <horizontal_week_calender/horizontal_week_calender-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "horizontal_week_calender-Swift.h"
#endif

@implementation HorizontalWeekCalenderPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftHorizontalWeekCalenderPlugin registerWithRegistrar:registrar];
}
@end
