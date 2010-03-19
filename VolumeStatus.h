//
//  VolumeStatus.h
//  test
//
//  Created by Scott Jann on 5/3/09.
//  Copyright (c) 2009 Scott Jann
//

#import <Cocoa/Cocoa.h>

#define SERVER_PARAM	"--volfile-server="
#define VOLUME_PARAM	"--volume-name="

@interface VolumeStatus : NSObject {
@private
    NSMutableArray *processList;
}
- (id) init;
- (int)numberOfProcesses;
- (void)refresh;
- (BOOL)isMounted:(NSString *)volume onServer:(NSString *)server;

@end
