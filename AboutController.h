//
//  AboutController.h
//  test
//
//  Created by Scott Jann on 5/9/09.
//  Copyright (c) 2009 Scott Jann
//

#import <Cocoa/Cocoa.h>


@interface AboutController : NSObject {
	IBOutlet NSWindow *myAbout;
}

-(IBAction) okButton: (id) sender;

@end
