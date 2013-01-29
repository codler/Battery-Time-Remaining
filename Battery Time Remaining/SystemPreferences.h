/*
 * SystemPreferences.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class SystemPreferencesApplication,SystemPreferencesPane;


/*
 * Standard Suite
 */

// An application's top level scripting object.
@interface SystemPreferencesApplication : SBApplication
@end

/*
 * System Preferences
 */

// System Preferences top level scripting object
@interface SystemPreferencesApplication (SystemPreferences)

- (SBElementArray *) panes;
@property (copy) SystemPreferencesPane *currentPane;  // the currently selected pane
@end

// a preference pane
@interface SystemPreferencesPane : SBObject
- (NSString *) id;
@end