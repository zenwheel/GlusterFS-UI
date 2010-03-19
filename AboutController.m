//
//  AboutController.m
//  test
//
//  Created by Scott Jann on 5/9/09.
//  Copyright (c) 2009 Scott Jann
//

#import "AboutController.h"


@implementation AboutController

-(IBAction) okButton:(id) sender {
	[NSApp endSheet:myAbout returnCode:NSOKButton];
}

@end
