//
//  VolumeStatus.m
//  test
//
//  Created by Scott Jann on 5/3/09.
//  Copyright (c) 2009 Scott Jann
//

#import "VolumeStatus.h"
#include <stdio.h>
#include <string.h>

@implementation VolumeStatus
- (id) init {
	processList = nil;
	[self refresh];
	return self;
}

- (int)numberOfProcesses {
	if(processList == nil)
		return 0;
	else
		return [processList count];
}

- (void)refresh {
	if(processList != nil)
		[processList release];
	processList = [NSMutableArray arrayWithCapacity:8];
	char buf[255], server[255], volume[255];
	char *p;
	FILE *f = popen("ps -ef", "r");
	if(f == NULL)
		return;
	while(fgets(buf, sizeof(buf), f)) {
		server[0] = volume[0] = 0;
		if(strstr(buf, "glusterfs") == 0)
			continue;
		p = strstr(buf, SERVER_PARAM);
		if(p != 0)
		{
			strcpy(server, p + strlen(SERVER_PARAM));
			p = strchr(server, ' ');
			if(p != 0)
				*p = 0;
		}
		p = strstr(buf, VOLUME_PARAM);
		if(p != 0)
		{
			strcpy(volume, p + strlen(VOLUME_PARAM));
			p = strchr(volume, ' ');
			if(p != 0)
				*p = 0;
		}
		
		if(server[0] != 0)
		{
			NSMutableDictionary *item = [NSMutableDictionary dictionaryWithCapacity:2];
			[item setObject:[[NSString alloc] initWithUTF8String:volume] forKey:@"volume"];
			[item setObject:[[NSString alloc]  initWithUTF8String:server] forKey:@"server"];
			[processList insertObject:item atIndex:[processList count]];
		}
	}
	pclose(f);
}

- (BOOL)isMounted:(NSString *)volume onServer:(NSString *)server {
	for(int i = 0; i < [processList count]; i++) {
		NSMutableDictionary *item = [processList objectAtIndex:i];
		if([[item objectForKey:@"volume"] isEqualToString:volume] && [[item objectForKey:@"server"] isEqualToString:server])
			return YES;
	}
	return NO;
}

@end
