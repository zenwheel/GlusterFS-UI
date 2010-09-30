//
//  GlusterBootAppDelegate.m
//  GlusterBoot
//
//  Created by Scott Jann on 9/29/10.
//  Copyright 2010 Scott Jann. All rights reserved.
//

#import "GlusterBootAppDelegate.h"
#include <unistd.h>
#include <crt_externs.h>

@implementation GlusterBootAppDelegate

@synthesize window;


- (void)alert:(NSString*)message withVolume:(NSString*)name {
	NSRunAlertPanel(message, [NSString stringWithFormat:@"Could not mount volume '%@'", name], @"OK", nil, nil);
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	if(geteuid() != 0) {
		AuthorizationRef authorizationRef;
		OSStatus status = AuthorizationCreate(NULL, kAuthorizationEmptyEnvironment,
									 kAuthorizationFlagDefaults, &authorizationRef);
		
		char *args[] = {NULL};
		status = AuthorizationExecuteWithPrivileges(authorizationRef, [[[NSBundle mainBundle] executablePath] UTF8String],
													kAuthorizationFlagDefaults, args, NULL);
		
		if(status != errAuthorizationSuccess)
			exit(-1);
	} else {
		NSLog(@"running as root");

		// allow mounting a specific volume from the command line
		NSString *onlyVolume = nil;
		NSString *onlyServer = nil;
		char **argv = *_NSGetArgv();
		if(*_NSGetArgc() == 3) {
			onlyServer = [NSString stringWithUTF8String:argv[1]];
			onlyVolume = [NSString stringWithUTF8String:argv[2]];
			NSLog(@"mounting %@ from %@", onlyVolume, onlyServer);
		}

		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);   
		NSString *appSupportDir = [paths objectAtIndex:0];   
		NSString *appDir = [appSupportDir stringByAppendingPathComponent:@"GlusterFS"];
		NSString *appFile = [appDir stringByAppendingPathComponent:@"volumes.plist"];
		
		NSMutableArray *records = [[NSMutableArray alloc] init];
		
		//NSLog(@"Loading settings from %@", appFile);
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
		} else
			NSLog(@"no volumes.plist");
		
		NSLog(@"Mounting %d volumes...", [records count]);
		for(int i = 0; i < [records count]; i++) {
			NSMutableDictionary *theRecord = [records objectAtIndex:i];
			NSString *server = [theRecord objectForKey:@"server"];
			NSString *volume = [theRecord objectForKey:@"volume"];
			
			if(onlyServer && onlyVolume) {
				if([server isEqualToString:onlyServer] == NO || [volume isEqualToString:onlyVolume] == NO)
					break;
			}
			NSString *path = [NSString stringWithFormat:@"/Volumes/GlusterFS/%@", volume];
			NSString *commandLine = [NSString stringWithFormat:@"/usr/local/sbin/glusterfs --volfile-server=%@ --volume-name=%@ --log-file=/dev/null %@", server, volume, path];
			BOOL isDirectory = NO;
			
			if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] == NO)
				isDirectory = NO;
			
			if(isDirectory == NO && [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil] == NO) {
				[self alert:@"Error creating mount point" withVolume:volume];
				NSLog(@"Error creating mount point");
			}
			
			//NSLog(@"Attempting to mount volume %@ on server %@...", volume, server);
			if([volume length] == 0)
				commandLine = [NSString stringWithFormat:@"/usr/local/sbin/glusterfs --volfile-server=%@ --log-file=/dev/null %@", server, path];
			int status = system([commandLine UTF8String]);
			if(status != 0) {
				[self alert:@"Error mounting volume" withVolume:volume];
				NSLog(@"Error mounting volume");
			}
		}	
	}	
	NSLog(@"exiting");
	exit(0);
}

@end
