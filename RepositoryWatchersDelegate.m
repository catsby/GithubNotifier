//
//  RepositoryWatchersDelegate.m
//  GithubNotifier
//
//  Created by Clint Shryock on 10/5/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "RepositoryWatchersDelegate.h"


@implementation RepositoryWatchersDelegate

- (void) githubManager:(SDGithubTaskManager*)manager resultsReadyForTask:(SDGithubTask*)task 
{
//	NSLog(@"found results: \n");
//	NSLog(@"class: %@\n%@", [task.results class], task.results);

	NSDictionary *mergedWatchers = [self mergeLocalStore:self.parentRepository.watcherList 
									   withRemoteResults:[task.results objectForKey:@"watchers"]];
	
		//	If this repo has no watchers at present then the watcherList will be nil, so create it
	if (!self.parentRepository.watcherList) {
		NSLog(@"not initialized, setting up");
		self.parentRepository.watcherList = [NSMutableArray arrayWithArray:[mergedWatchers objectForKey:@"additions"]];
	} else {
		NSLog(@"initialized, adding to");	
		NSArray *additions = [mergedWatchers objectForKey:@"additions"];
		NSLog(@"additions: %@", additions);
		[additions enumerateObjectsUsingBlock:^(id dict, NSUInteger index, BOOL *stop) {
			NSLog(@"added watcher: %@", [dict valueForKey:@"name"]);
		}];
		[self.parentRepository.watcherList addObjectsFromArray:additions];	
	}
}

- (void) githubManager:(SDGithubTaskManager*)manager failedForTask:(SDGithubTask*)task 
{	
	NSLog(@"error in RepositoryWatchersDelegate>githubManager:");
}

	//	Override mergeing function, because watchersList is a transformable attribute
	//	and wont be deleted like a normal managed object
- (NSDictionary *)mergeLocalStore:(NSArray *)local withRemoteResults:(NSArray *)_remote
{
	NSLog(@"merging");
	NSMutableArray *remote = [NSMutableArray arrayWithCapacity:0];
	[_remote enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop ){
		[remote addObject:[NSDictionary dictionaryWithObject:obj forKey:@"name"]];
	}];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:local];
    NSMutableSet *remoteSet  = [NSMutableSet setWithArray:remote];
    
	NSMutableDictionary *changes = [NSMutableDictionary dictionaryWithCapacity:2];
    
	
		//	Subtract the current set of repositories on disk from the list 
		//	retrieved from the server.  If there are any left over, then 
		//	we've added new repositories since last update
    [remoteSet minusSet:currentSet];
	if (0 < [remoteSet count]) {
		[changes setObject:[remoteSet allObjects] forKey:@"additions"];
	}
	
    currentSet = [NSMutableSet setWithArray:local];
    remoteSet  = [NSMutableSet setWithArray:remote];
    
    [currentSet minusSet:remoteSet];
	if (0 < [currentSet count]) {
		[changes setObject:[NSNumber numberWithInt:[currentSet count]] forKey:@"subtractions"];
//		for (NSManagedObject *orphan in currentSet) {
//			[moc deleteObject:orphan];
//		}
	}
	
	return changes;
}

@end
