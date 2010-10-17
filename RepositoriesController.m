//
//  RepositoriesController.m
//  GithubNotifier
//
//  Created by Clint Shryock on 9/30/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "RepositoriesController.h"
#import "GithubUser.h"
#import "SDGithubTaskManager.h"
#import "RepositoriesDelegate.h"

@interface RepositoriesController (private)
- (void)updateRepositories:(NSNotification *)aNotification;
@end


@implementation RepositoriesController

@synthesize repositoryArrayController;
@synthesize githubUser;
@synthesize mainTaskManager;
@synthesize mainRepositoriesDelegate;

- (id) initWithGithubUser:(GithubUser *)_githubUser
{
	self = [super init];
	if (self != nil) {
		self.githubUser = _githubUser;
		self.mainTaskManager			= [SDGithubTaskManager new];
		self.mainRepositoriesDelegate	= [RepositoriesDelegate new];
		
		self.mainTaskManager.delegate = mainRepositoriesDelegate;
		self.mainTaskManager.successSelector = @selector(githubManager:resultsReadyForTask:);
		self.mainTaskManager.failSelector = @selector(githubManager:failedForTask:);
	}
	return self;
}

- (void) fetchUpdates
{
	self.mainTaskManager.username = githubUser.username;
	self.mainTaskManager.password = githubUser.apiToken;
	SDGithubTask *basicTask = [SDGithubTask taskWithManager:self.mainTaskManager];
	basicTask.user = self.mainTaskManager.username;
	basicTask.name = self.mainTaskManager.username;
	basicTask.type = SDGithubTaskGetRepos;
	[basicTask run];	
}

@end
