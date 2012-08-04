//
//  StartAtLoginHelper.m
//  Battery Time Remaining
//
//  Created by Mathijs Kadijk on 04-08-12.
//  Copyright (c) 2012 Wrep. All rights reserved.
//

#import "StartAtLoginHelper.h"

@implementation StartAtLoginHelper

+ (BOOL)isInLoginItems
{
    BOOL isInLoginItems = NO;
    
    // Get URL to the App
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Get the current users login items
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems)
    {
        // Get a array of the loginItems
		UInt32 seedValue;
        CFArrayRef loginItemsArrayRef = LSSharedFileListCopySnapshot(loginItems, &seedValue);
        
        // Cast to NSArray for ease of use
        NSArray *loginItemsArray = (__bridge NSArray *)loginItemsArrayRef;
        
        // Loop through all loginitems
		for (int i = 0; i < [loginItemsArray count]; i++)
        {
            // Get the current loginitem
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            
            // Resolve the loginitem
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&url, NULL) == noErr)
            {
                // Get the path from the URL
				NSString *urlPath = [(__bridge NSURL *)url path];
                
                // Check if this is us
                if ([urlPath compare:appPath] == NSOrderedSame)
                {
                    isInLoginItems = YES;
				}
			}
            
            CFRelease(url);
		}
        
        CFRelease(loginItems);
	}
    
    return isInLoginItems;
}

+ (void)addToLoginItems
{
    // Get URL to the App
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
    // Get the current users login items
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
    if (loginItems)
    {
        // Insert ourself into the list of startup items
        LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItems, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
        
        // Check if the item is inserted, if so release it
        if (item)
        {
            CFRelease(item);
        }
        else
        {
            NSLog(@"Failed to insert loginitem!");
        }
        
        CFRelease(loginItems);
    }
    else
    {
        NSLog(@"No loginitems list found!");
    }
}

+ (void)removeFromLoginItems
{
    // Get URL to the App
    NSString *appPath = [[NSBundle mainBundle] bundlePath];
    CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:appPath];
    
	// Get the current users login items
    LSSharedFileListRef loginItems = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
    
	if (loginItems)
    {
        // Get a array of the loginItems
		UInt32 seedValue;
        CFArrayRef loginItemsArrayRef = LSSharedFileListCopySnapshot(loginItems, &seedValue);
        
        // Cast to NSArray for ease of use
        NSArray *loginItemsArray = (__bridge NSArray *)loginItemsArrayRef;
        
        // Loop through all loginitems
		for (int i = 0; i < [loginItemsArray count]; i++)
        {
            // Get the current loginitem
			LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)[loginItemsArray objectAtIndex:i];
            
            // Resolve the loginitem
			if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&url, NULL) == noErr)
            {
                // Get the path from the URL
				NSString *urlPath = [(__bridge NSURL *)url path];
                
                // Check if this is us
                if ([urlPath compare:appPath] == NSOrderedSame)
                {
                    // It is us, remove us from the list
					LSSharedFileListItemRemove(loginItems, itemRef);
				}
			}
            
            CFRelease(url);
		}
        
        CFRelease(loginItems);
	}
}

@end
