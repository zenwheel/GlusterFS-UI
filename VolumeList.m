//
//  VolumeList.m
//  test
//
//  Created by Scott Jann on 5/1/09.
//  Copyright (c) 2009 Scott Jann
//

#import "VolumeList.h"
#include "GlusterFS.h"


@implementation VolumeList

- (id) init {
    self = [super init];
	
    if (self != nil)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);   
		NSString *appSupportDir = [paths objectAtIndex:0];   
		NSString *appDir = [appSupportDir stringByAppendingPathComponent:@"GlusterFS"];
		NSString *appFile = [appDir stringByAppendingPathComponent:@"volumes.plist"];
		
		records = [[NSMutableArray alloc] init];
		
		if([[NSFileManager defaultManager] fileExistsAtPath:appFile]) {
			NSString *errorStr = nil;
			NSPropertyListFormat format;
			NSData *data = [NSData dataWithContentsOfFile:appFile];
			NSArray *savedData = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&errorStr];
			if(errorStr != nil)
			{
				NSLog(@"Error reading records: %@", errorStr);
				[errorStr release];
			}
			[records addObjectsFromArray:savedData];
		}
	}

    return self;
}

- (void) saveToFile {
	NSData *data;
	NSString *errorStr = nil;

	// remove attributed status strings
	for(int i = 0; i < [records count]; i++) {
		NSMutableDictionary *theRecord = [records objectAtIndex:i];
		[theRecord setObject:@"" forKey:@"status"];
	}
	data = [NSPropertyListSerialization dataFromPropertyList:records format:NSPropertyListXMLFormat_v1_0 errorDescription:&errorStr];
	if(errorStr != nil)
	{
		NSLog(@"Error writing records: %@", errorStr);
		[errorStr release];
	}

	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);   
	NSString *appSupportDir = [paths objectAtIndex:0];   
	NSString *appDir = [appSupportDir stringByAppendingPathComponent:@"GlusterFS"];
	[[NSFileManager defaultManager] createDirectoryAtPath:appDir withIntermediateDirectories:YES attributes:nil error:nil];
	NSString *appFile = [appDir stringByAppendingPathComponent:@"volumes.plist"];   
	[data writeToFile:appFile atomically:NO];
}

- (void) tableView:(NSTableView *)aTableView
		 addVolume:(NSString *)volume
		onServer: (NSString *)server;
{
	NSMutableDictionary *theRecord = [NSMutableDictionary dictionaryWithCapacity:3];
	[theRecord setObject:volume forKey:@"volume"];
	[theRecord setObject:server forKey:@"server"];
	[theRecord setObject:@"" forKey:@"status"];
	[records insertObject:theRecord atIndex:[records count]];
	[aTableView reloadData];
}

- (void) tableView:(NSTableView *)aTableView
		 setStatus:(int)rowIndex
		withStatus: (NSString*)status
{
	NSMutableDictionary *theRecord;
	
	NSMutableDictionary *attrsDictionary = [NSMutableDictionary dictionaryWithCapacity:2];
	if([status isEqualToString:NSLocalizedStringFromTable(@"Mount", @"UI", nil)]) {
		[attrsDictionary setObject:[NSColor blueColor] forKey:NSForegroundColorAttributeName];
		[attrsDictionary setObject:[NSNumber numberWithInt:NSSingleUnderlineStyle] forKey:NSUnderlineStyleAttributeName];
	}
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:status
									attributes:attrsDictionary];
		
    NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
    theRecord = [records objectAtIndex:rowIndex];
    [theRecord setObject:attrString forKey:@"status"];
	[aTableView reloadData];
	[attrString release];
}

- (void) tableView:(NSTableView *)aTableView
		 deleteRow:(int)rowIndex {
	[records removeObjectAtIndex:rowIndex];
	[aTableView reloadData];
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex
{
    id theRecord, theValue;
	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
    theRecord = [records objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:[aTableColumn identifier]];
	if([[aTableColumn identifier] isEqualToString:@"volume"] && [theValue length] == 0)
		theValue = NSLocalizedStringFromTable(@"Automatic", @"UI", nil);
    return theValue;
}

- (id)tableView:(NSTableView *)aTableView
objectValueForTableName:(NSString *)columnName
			row:(int)rowIndex
{
    id theRecord, theValue;
	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
    theRecord = [records objectAtIndex:rowIndex];
    theValue = [theRecord objectForKey:columnName];
	if([columnName isEqualToString:@"volume"] && [theValue length] == 0)
		theValue = NSLocalizedStringFromTable(@"Automatic", @"UI", nil);
    return theValue;
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex
{
    id theRecord;
	
    NSParameterAssert(rowIndex >= 0 && rowIndex < [records count]);
    theRecord = [records objectAtIndex:rowIndex];
    [theRecord setObject:anObject forKey:[aTableColumn identifier]];
	[aTableView reloadData];
}

- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [records count];
}
@end
