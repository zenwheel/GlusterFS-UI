#import <Foundation/Foundation.h>

int main (int argc, const char * argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
	
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
	}
	
	//NSLog(@"Mounting %d volumes...", [records count]);
	for(int i = 0; i < [records count]; i++) {
		NSMutableDictionary *theRecord = [records objectAtIndex:i];
		NSString *server = [theRecord objectForKey:@"server"];
		NSString *volume = [theRecord objectForKey:@"volume"];
		NSString *path = [NSString stringWithFormat:@"/Volumes/GlusterFS/%@", volume];
		NSString *commandLine = [NSString stringWithFormat:@"/usr/local/sbin/glusterfs --volfile-server=%@ --volume-name=%@ --log-file=/dev/null %@", server, volume, path];
		BOOL isDirectory = NO;
		
		if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory] == NO)
			isDirectory = NO;
		
		if(isDirectory == NO && [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil] == NO)
			NSLog(@"Error creating mount point");
		
		//NSLog(@"Attempting to mount volume %@ on server %@...", volume, server);
		if([volume length] == 0)
			commandLine = [NSString stringWithFormat:@"/usr/local/sbin/glusterfs --volfile-server=%@ --log-file=/dev/null %@", server, path];
		int status = system([commandLine UTF8String]);
		if(status != 0)
			NSLog(@"Error mounting volume");
	}
	
    [pool drain];
    return 0;
}
