//
//  CSManagedRepository.m
//  GithubNotifier
//
//  Created by Clint Shryock on 10/3/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "CSManagedRepository.h"
@interface CSManagedRepository (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveWatcherCount;
- (void)setPrimitiveWatcherCount:(NSNumber *)value;

@end

@implementation CSManagedRepository

@synthesize isFork;

@dynamic watcherCount;
// coalesce these into one @interface CSManagedRepository (CoreDataGeneratedPrimitiveAccessors) section


- (NSNumber *)watcherCount 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"watcherCount"];
    tmpValue = [self primitiveWatcherCount];
    [self didAccessValueForKey:@"watcherCount"];
    
    return tmpValue;
}

- (void)setWatcherCount:(NSNumber *)value 
{
	NSLog(@"isFork: %@", [self.isFork stringValue]);
	if (![[self primitiveWatcherCount] isEqualToNumber:value] && ![self.isFork boolValue]) {
		NSLog(@"watcher count has changed on an original repo");
	}
    [self willChangeValueForKey:@"watcherCount"];
    [self setPrimitiveWatcherCount:value];
    [self didChangeValueForKey:@"watcherCount"];
}

- (BOOL)validateWatcherCount:(id *)valueRef error:(NSError **)outError 
{
    // Insert custom validation logic here.
    return YES;
}

@end