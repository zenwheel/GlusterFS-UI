//
//  MainController.h
//  test
//
//  Created by Scott Jann on 4/30/09.
//  Copyright (c) 2009 Scott Jann
//

#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>
#import "VolumeList.h"

@interface MainController : NSObject {
	IBOutlet NSTableView * myTable;
	IBOutlet NSPanel *myPanel;
	IBOutlet NSPanel *myAbout;
	IBOutlet NSTextField *serverText;
	IBOutlet NSTextField *volumeText;
	IBOutlet NSButton *uxDeleteButton;
	IBOutlet NSTextField *aboutText;
	IBOutlet NSPreferencePane *prefPane;
	
@private
	VolumeList *volumes;
	NSTimer *timer;
}

-(id) init;
-(IBAction) addButton: (id) sender;
-(IBAction) deleteButton: (id) sender;
-(IBAction) refreshButton: (id) sender;
-(IBAction) aboutButton: (id) sender;
-(IBAction) clickTable: (id) sender;
-(IBAction) mySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode
			  contextInfo:(void *)contextInfo;
-(void) refresh;
-(void) updateForm;
-(void) handleTimer: (NSTimer *)timer;
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification;
- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex;

@end
