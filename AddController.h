//
//  AddController.h
//  test
//
//  Created by Scott Jann on 4/30/09.
//  Copyright (c) 2009 Scott Jann
//

#import <Cocoa/Cocoa.h>


@interface AddController : NSObject {
	IBOutlet NSMatrix *radioGroup;
	IBOutlet NSWindow *myPanel;
	IBOutlet NSTableView *myTable;
	IBOutlet NSTextField *serverText;
	IBOutlet NSTextField *volumeText;
}

- (void)controlTextDidChange:(NSNotification *)aNotification;
-(IBAction) cancelButton: (id) sender;
-(IBAction) saveButton: (id) sender;

@end
