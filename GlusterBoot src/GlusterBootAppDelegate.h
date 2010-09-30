//
//  GlusterBootAppDelegate.h
//  GlusterBoot
//
//  Created by Scott Jann on 9/29/10.
//  Copyright 2010 Scott Jann. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface GlusterBootAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
