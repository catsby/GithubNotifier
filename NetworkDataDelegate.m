//
//  NetworkDataDelegate.m
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/17/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "NetworkDataDelegate.h"
#import "GrowlManager.h"
#import "SDGithubTaskManager.h"
#import "SDGithubTask.h"


@implementation NetworkDataDelegate

@synthesize repository;

- (void) githubManager:(SDGithubTaskManager*)manager resultsReadyForTask:(SDGithubTask*)task {
	NSNumber *space					= nil;
	NSNumber *previousSpace			= nil;
	NSMutableDictionary *previousCommit	= nil;
	int pushCount		= 0;
	int commitCount = 0;
	NSNumber *timeKey = [self.repository valueForKey:@"timeKey"];
	NSLog(@"time key at start: %@", timeKey);
	if ([timeKey isNotEqualTo:[NSNumber numberWithInt:0]]) {
		NSMutableArray *networkPushes = [NSMutableArray array];
		NSLog(@"%@ commits to parse: %lx", [self.repository valueForKey:@"name"], (unsigned long)[task.results count]);
		for (NSMutableDictionary *commit  in [task.results objectForKey:@"commits"]) {
			NSNumber *key = [commit valueForKey:@"time"];
			if ([key isGreaterThan:[self.repository valueForKey:@"timeKey"]]) {
				space = [commit valueForKey:@"space"];	
				
				if (previousSpace == nil) {	//	this is the first series of commits
					previousSpace = [commit valueForKey:@"space"];	
					commitCount = 1;
					pushCount++;
				} else if ([previousSpace isNotEqualTo:space]) {
					NSLog(@"new push");
					previousSpace = [commit valueForKey:@"space"];	
					[networkPushes addObject:previousCommit];
					pushCount++;
					commitCount=1;
				} else {
					commitCount++;
				}
				previousCommit = [commit copy];
			}
		}
		/**
		 *	If timekey is not greater, than previousCommit is nil
		 */
		NSLog(@"previousCommit: \n%@", previousCommit);
		[networkPushes addObject:previousCommit];
		
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setObject:networkPushes forKey:@"payload"];
		[dict setObject:self.repository forKey:@"repository"];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_COMMITS_PUSHED
															object:self 
														  userInfo:dict];
	}
	
	NSLog(@"push count: %d", pushCount);
	
	NSDictionary *lastCommit = [[task.results objectForKey:@"commits"] lastObject];
	[self.repository setValue:[lastCommit valueForKey:@"time"] forKey:@"timeKey"];
}

- (void) githubManager:(SDGithubTaskManager*)manager failedForTask:(SDGithubTask*)task 
{	
	NSLog(@"failed in NetworkDataDelegate");
}

@end
