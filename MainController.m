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

	[[myTable dataSource] tableView:myTable addVolume:[volumeText stringValue] onServer:[serverText stringValue]];
	[[myTable dataSource] saveToFile];
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
			[glusterText appendString:[[NSString alloc] initWithUTF8String:buf]];
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
	[[myTable dataSource] tableView:myTable deleteRow:[myTable selectedRow]];
	[[myTable dataSource] saveToFile];
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
		[[myTable dataSource] tableView:myTable setStatus:i withStatus:status];
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
		NSString *status = [[[myTable dataSource] tableView:myTable objectValueForTableName:@"status" row:[myTable clickedRow]] string];
		if([status isEqualToString:NSLocalizedStringFromTable(@"Mount", @"UI", nil)])
		{
			NSString *server = [[myTable dataSource] tableView:myTable objectValueForTableName:@"server" row:[myTable clickedRow]];
			NSString *volume = [[myTable dataSource] tableView:myTable objectValueForTableName:@"volume" row:[myTable clickedRow]];
			NSString *path = [NSString stringWithFormat:@"/Volumes/GlusterFS/%@", volume];
			NSString *commandLine = [NSString stringWithFormat:@"/usr/local/sbin/glusterfs --volfile-server=%@ --volume-name=%@ --log-file=/dev/null %@", server, volume, path];
			BOOL isDirectory = NO;
			
			if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] == NO)
				isDirectory = NO;
			
			if(isDirectory == NO && [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil] == NO)
			{
				NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"MountError", @"UI", nil)
												 defaultButton:NSLocalizedStringFromTable(@"OK", @"UI", nil) alternateButton:nil otherButton:nil
									 informativeTextWithFormat:NSLocalizedStringFromTable(@"NoMountpoint", @"UI", nil)];
				[alert setAlertStyle:NSCriticalAlertStyle];
				[alert beginSheetModalForWindow:[[prefPane mainView] window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
			}				
			
			NSLog(@"Attempting to mount volume %@ on server %@...", volume, server);
			if([volume length] == 0)
				commandLine = [NSString stringWithFormat:@"/usr/local/sbin/glusterfs --volfile-server=%@ --log-file=/dev/null %@", server, path];
			int status = system([commandLine UTF8String]);
			if(status != 0)
			{
				NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"MountError", @"UI", nil)
					defaultButton:NSLocalizedStringFromTable(@"OK", @"UI", nil) alternateButton:nil otherButton:nil
					informativeTextWithFormat:NSLocalizedStringFromTable(@"MountErrorDetails", @"UI", nil)];
				[alert setAlertStyle:NSCriticalAlertStyle];
				[alert beginSheetModalForWindow:[[prefPane mainView] window] modalDelegate:self didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) contextInfo:nil];
			}
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
		NSString *val = [[myTable dataSource] tableView:myTable objectValueForTableName:[aTableColumn identifier] row:rowIndex];
		if([val isEqualToString:NSLocalizedStringFromTable(@"Automatic", @"UI", nil)])
			result = NO;
	}
	return result;
}

@end
