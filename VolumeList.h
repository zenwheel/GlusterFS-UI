//
//  VolumeList.h
//  test
//
//  Created by Scott Jann on 5/1/09.
//  Copyright (c) 2009 Scott Jann
//

#import <Cocoa/Cocoa.h>


@interface VolumeList : NSObject {
@private
	NSMutableArray *records;
}

- (id) init;
- (void) tableView:(NSTableView *)aTableView
		 addVolume:(NSString *)volume
		  onServer: (NSString *)server;
- (void) tableView:(NSTableView *)aTableView
	  setStatus:(int)rowIndex
		   withStatus: (NSString*)status;
- (void) tableView:(NSTableView *)aTableView
		 deleteRow:(int)rowIndex;
- (id)tableView:(NSTableView *)aTableView
objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(int)rowIndex;
- (id)tableView:(NSTableView *)aTableView
objectValueForTableName:(NSString *)columnName
			row:(int)rowIndex;

- (void) saveToFile;
   
- (void)tableView:(NSTableView *)aTableView
   setObjectValue:anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(int)rowIndex;

- (int)numberOfRowsInTableView:(NSTableView *)aTableView;

@end
