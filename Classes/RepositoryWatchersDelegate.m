//
//  RepositoryWatchersDelegate.m
//  GithubNotifier
//
//  Created by Clint Shryock on 10/5/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "RepositoryWatchersDelegate.h"

@interface RepositoryWatchersDelegate (Private)
- (NSMutableDictionary *)mergeLocalStore:(NSArray *)local withRemoteResults:(NSArray *)_remote;
@end


@implementation RepositoryWatchersDelegate

- (void) githubManager:(SDGithubTaskManager*)manager resultsReadyForTask:(SDGithubTask*)task 
{
	NSMutableDictionary *mergedWatchers = [self mergeLocalStore:self.parentRepository.watcherList 
									   withRemoteResults:[task.results objectForKey:@"watchers"]];

	self.parentRepository.watcherList = [mergedWatchers objectForKey:@"watcherList"];
	NSArray *additions = [mergedWatchers objectForKey:@"additions"];
	
	if (0 < [additions count]) {
		[mergedWatchers setObject:task.user forKey:@"user"];
		[mergedWatchers setObject:task.repo forKey:@"repo"];
		[[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_WATCHERS_ADDED 
															object:self 
														  userInfo:mergedWatchers];	
	}
}

- (void) githubManager:(SDGithubTaskManager*)manager failedForTask:(SDGithubTask*)task 
{	
	NSLog(@"error in RepositoryWatchersDelegate>githubManager:");
}

	//	Override mergeing function, because watchersList is a transformable attribute
	//	and wont be deleted like a normal managed object
- (NSMutableDictionary *)mergeLocalStore:(NSArray *)local withRemoteResults:(NSArray *)_remote
{
	NSMutableArray *remote = [NSMutableArray arrayWithCapacity:0];
	[_remote enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop ){
		[remote addObject:[NSDictionary dictionaryWithObject:obj forKey:@"name"]];
	}];
    NSMutableSet *currentSet = [NSMutableSet setWithArray:local];
    NSMutableSet *remoteSet  = [NSMutableSet setWithArray:remote];
    
	NSMutableDictionary *changes = [NSMutableDictionary dictionaryWithCapacity:2];
	[changes setObject:remote forKey:@"watcherList"];
	
	//	Subtract the current set of repositories on disk from the list 
	//	retrieved from the server.  If there are any left over, then 
	//	we've added new repositories since last update
    [remoteSet minusSet:currentSet];
	if (0 < [remoteSet count]) {
		[changes setObject:[remoteSet allObjects] forKey:@"additions"];
	}
	return changes;
}

@end
