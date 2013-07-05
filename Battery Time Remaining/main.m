//
//  main.m
//  Battery Time Remaining
//
//  Created by Han Lin Yap on 2012-08-01.
//  Copyright (c) 2013 Han Lin Yap. All rights reserved.
//

#import "AppDelegate.h"
#import <Cocoa/Cocoa.h>

int main(int argc, char *argv[])
{
    AppDelegate * delegate = [[AppDelegate alloc] init];
    [[NSApplication sharedApplication] setDelegate:delegate];
    [NSApp run];
    //return NSApplicationMain(argc, (const char **)argv);
}
