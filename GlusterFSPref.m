//
//  GlusterFSPref.m
//  GlusterFS
//
//  Created by Scott Jann on 5/10/09.
//  Copyright (c) 2009 Scott Jann All rights reserved.
//

#import "GlusterFSPref.h"
#import "Login.h"


@implementation GlusterFSPref

- (void) mainViewDidLoad
{
	Login *l = [[Login alloc] init];
	if([l isLoginItem] == NO)
		[l setLoginItem];	
}

@end
