//
//  Login.m
//  test
//
//  Created by Scott Jann on 5/10/09.
//  Copyright (c) 2009 Scott Jann
//

#import "Login.h"


@implementation Login
- (BOOL) isLoginItem
{
	id obj;
	
	NSString *ourAppsPath = [NSString stringWithFormat:@"%@/Contents/Resources/GlusterBoot.app", [[NSBundle bundleForClass:[self class]] bundlePath]];
	NSDictionary *loginItemDict = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/Library/Preferences/loginwindow.plist", NSHomeDirectory()]];
	NSEnumerator *loginItemEnumerator = [[loginItemDict objectForKey:@"AutoLaunchedApplicationDictionary"] objectEnumerator];
	
	while (( obj = [loginItemEnumerator nextObject] ) != nil )
	{
		if ( [[obj objectForKey:@"Path"] isEqualTo:ourAppsPath] )
			return( YES );
	}
	return( NO );
}

- (void) setLoginItem
{
	NSMutableArray *loginItems;
	
	NSLog(@"Registering GlusterBoot");
	
	loginItems = (NSMutableArray *)CFPreferencesCopyValue(
														  (CFStringRef)@"AutoLaunchedApplicationDictionary" ,
														  (CFStringRef)@"loginwindow" , 
														  kCFPreferencesCurrentUser , 
														  kCFPreferencesAnyHost ); 
	loginItems = [[loginItems autorelease] mutableCopy]; 
	
	NSMutableDictionary *myDict = [[[NSMutableDictionary alloc] init] autorelease];
	[myDict setObject:[NSNumber numberWithBool:NO] forKey:@"Hide"];
	[myDict setObject:[NSString stringWithFormat:@"%@/Contents/Resources/GlusterBoot.app", [[NSBundle bundleForClass:[self class]] bundlePath]] forKey:@"Path"];
	
	[loginItems removeObject:myDict]; //make sure it's not already in there 
	[loginItems addObject:myDict]; 
	
	CFPreferencesSetValue(
						  (CFStringRef)@"AutoLaunchedApplicationDictionary" , 
						  loginItems , 
						  (CFStringRef)@"loginwindow" , 
						  kCFPreferencesCurrentUser , 
						  kCFPreferencesAnyHost ); 
	CFPreferencesSynchronize(
							 (CFStringRef)@"loginwindow" , 
							 kCFPreferencesCurrentUser , 
							 kCFPreferencesAnyHost ); 
	
	[loginItems release]; 
}
@end
