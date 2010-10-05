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
	NSLog(@"found results: \n");
	NSLog(@"%@", task.results);
}

- (void) githubManager:(SDGithubTaskManager*)manager failedForTask:(SDGithubTask*)task 
{	
	NSLog(@"error in RepositoryWatchersDelegate>githubManager:");
}

@end
