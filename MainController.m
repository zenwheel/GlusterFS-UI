//
//  MainController.m
//  test
//
//  Created by Scott Jann on 4/30/09.
//  Copyright (c) 2009 Scott Jann
//

#import "MainController.h"
#import "VolumeList.h"
#import "VolumeStatus.h"
#include "GlusterFS.h"

@implementation MainController

- (id) init {
	authorizationRef = 0;
	timer = [NSTimer scheduledTimerWithTimeInterval: 0.5 target: self selector: @selector(handleTimer:) userInfo: nil repeats: YES];
	[myTable reloadData];
	return self;
}

-(IBAction) addButton:(id) sender { 
	[NSApp beginSheet:myPanel modalForWindow:[[prefPane mainView] window] modalDelegate:self didEndSelector:@selector(mySheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction) mySheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode
			   contextInfo:(void *)contextInfo {
	[myPanel orderOut:self];

	if(returnCode == NSCancelButton)
		return;

	[(VolumeList*)[myTable dataSource] tableView:myTable addVolume:[volumeText stringValue] onServer:[serverText stringValue]];
	[(VolumeList*)[myTable dataSource] saveToFile];
	[self refresh];
}

-(IBAction) aboutButton:(id) sender {
	NSMutableString *glusterText = [[NSMutableString alloc] init];
	
	[glusterText appendString:NSLocalizedStringFromTable(@"About Message", @"UI", nil)];
	
	char buf[255];
	FILE *f = popen("/usr/local/sbin/glusterfs --version", "r");
	if(f != NULL)
	{
		while(fgets(buf, sizeof(buf), f)) {
			[glusterText appendString:[NSString stringWithUTF8String:buf]];
		}
	}
	pclose(f);
	
	[aboutText setStringValue:glusterText];	
	[glusterText release];
	
	[NSApp beginSheet:myAbout modalForWindow:[[prefPane mainView] window] modalDelegate:self didEndSelector:@selector(myAboutSheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (IBAction) myAboutSheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode
			   contextInfo:(void *)contextInfo {
	[myAbout orderOut:self];
}

-(IBAction) deleteButton:(id) sender {
	[(VolumeList*)[myTable dataSource] tableView:myTable deleteRow:[myTable selectedRow]];
	[(VolumeList*)[myTable dataSource] saveToFile];
}

-(IBAction) refreshButton: (id) sender {
	[self refresh];
}

-(void) refresh {
	if([myTable currentEditor] != nil)
		return;
	VolumeList *v = [myTable dataSource];
	VolumeStatus *s = [[VolumeStatus alloc] init];
	for(int i = 0; i < [v numberOfRowsInTableView:myTable]; i++) {
		NSString *status = NSLocalizedStringFromTable(@"Mount", @"UI", nil);
		if([s isMounted:[v tableView:myTable objectValueForTableName:@"volume" row:i] onServer:[v tableView:myTable objectValueForTableName:@"server" row:i]])
			status = NSLocalizedStringFromTable(@"Mounted", @"UI", nil);
		[(VolumeList*)[myTable dataSource] tableView:myTable setStatus:i withStatus:status];
	}
	[s release];
}

-(void) updateForm {
	if([myTable selectedRow] == -1)
		[uxDeleteButton setEnabled:NO];
	else
		[uxDeleteButton setEnabled:YES];
}

-(void) handleTimer: (NSTimer *)timer
{
	[self refresh]; 
}

-(IBAction) clickTable: (id) sender {
	if([myTable clickedColumn] == 2) {
		NSString *status = [[(VolumeList*)[myTable dataSource] tableView:myTable objectValueForTableName:@"status" row:[myTable clickedRow]] string];
		if([status isEqualToString:NSLocalizedStringFromTable(@"Mount", @"UI", nil)])
		{
			NSString *server = [(VolumeList*)[myTable dataSource] tableView:myTable objectValueForTableName:@"server" row:[myTable clickedRow]];
			NSString *volume = [(VolumeList*)[myTable dataSource] tableView:myTable objectValueForTableName:@"volume" row:[myTable clickedRow]];
			
			NSString *ourAppsPath = [NSString stringWithFormat:@"%@/Contents/Resources/GlusterBoot.app/Contents/MacOS/GlusterBoot", [[NSBundle bundleForClass:[self class]] bundlePath]];

			OSStatus status = errAuthorizationSuccess;
			
			if(authorizationRef == 0)
				status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment, kAuthorizationFlagDefaults, &authorizationRef);
			
			char *args[] = {(char*)[server UTF8String], (char*)[volume UTF8String], NULL};
			status = AuthorizationExecuteWithPrivileges(authorizationRef, [ourAppsPath UTF8String],
														kAuthorizationFlagDefaults, args, NULL);
			
			[self refresh];
		}
	}
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo {
}

- (void)tableViewSelectionDidChange:(NSNotification *)aNotification
{
	[self updateForm];
}

- (BOOL)tableView:(NSTableView *)aTableView shouldEditTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex {
	BOOL result = YES;
	if([[aTableColumn identifier] isEqualToString:@"volume"]) {
		NSString *val = [(VolumeList*)[myTable dataSource] tableView:myTable objectValueForTableName:[aTableColumn identifier] row:rowIndex];
		if([val isEqualToString:NSLocalizedStringFromTable(@"Automatic", @"UI", nil)])
			result = NO;
	}
	return result;
}

@end
