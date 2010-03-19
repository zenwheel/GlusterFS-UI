//
//  AddController.m
//  test
//
//  Created by Scott Jann on 4/30/09.
//  Copyright (c) 2009 Scott Jann
//

#import "AddController.h"


@implementation AddController

- (void)controlTextDidChange:(NSNotification *)aNotification
{
	[radioGroup selectCellWithTag:0];
}

-(IBAction) cancelButton:(id) sender { 
	[NSApp endSheet:myPanel returnCode:NSCancelButton];
}

-(IBAction) saveButton:(id) sender {
	[NSApp endSheet:myPanel returnCode:NSOKButton];
}

@end
