//
//  CollectionDelegate.m
//  GithubNotifier
//
//  Created by Clint Shryock on 10/5/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "CollectionDelegate.h"


@implementation CollectionDelegate

@synthesize results;
@synthesize parentRepository;

- (NSDictionary *)mergeLocalStore:(NSArray *)local withRemoteResults:(NSArray *)remote
{
	NSLog(@"merging");
    NSMutableSet *currentSet = [NSMutableSet setWithArray:local];
    NSMutableSet *remoteSet  = [NSMutableSet setWithArray:remote];
    
	NSMutableDictionary *changes = [NSMutableDictionary dictionaryWithCapacity:2];
    
	
		//	Subtract the current set of repositories on disk from the list 
		//	retrieved from the server.  If there are any left over, then 
		//	we've added new repositories since last update
    [remoteSet minusSet:currentSet];
	if (0 < [remoteSet count]) {
		[changes setObject:[NSNumber numberWithInt:[remoteSet count]] forKey:@"additions"];
	}
	
    currentSet = [NSMutableSet setWithArray:local];
    remoteSet  = [NSMutableSet setWithArray:remote];
    
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    [currentSet minusSet:remoteSet];
	if (0 < [currentSet count]) {
		[changes setObject:[NSNumber numberWithInt:[currentSet count]] forKey:@"subtractions"];
		for (NSManagedObject *orphan in currentSet) {
			[moc deleteObject:orphan];
		}
	}
		
	return changes;
}


@end
