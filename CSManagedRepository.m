//
//  CSManagedRepository.m
//  GithubNotifier
//
//  Created by Clint Shryock on 10/3/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "CSManagedRepository.h"

#import "SDGithubTaskManager.h"
#import "RepositoryWatchersDelegate.h"
#import "GithubUser.h"

@interface CSManagedRepository (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber *)primitiveWatcherCount;
- (void)setPrimitiveWatcherCount:(NSNumber *)value;
- (NSNumber *)primitiveIsFork;
- (void)setPrimitiveIsFork:(NSNumber *)value;
- (id)primitiveWatcherList;
- (void)setPrimitiveWatcherList:(id)value;

@end

@implementation CSManagedRepository

@dynamic isFork;
@dynamic watcherCount;
@dynamic watcherList;


- (NSNumber *)isFork 
{
    NSNumber * tmpValue;
    
    [self willAccessValueForKey:@"isFork"];
    tmpValue = [self primitiveIsFork];
    [self didAccessValueForKey:@"isFork"];
    
    return tmpValue;
}

- (void)setIsFork:(NSNumber *)value 
{
    [self willChangeValueForKey:@"isFork"];
    [self setPrimitiveIsFork:value];
    [self didChangeValueForKey:@"isFork"];
}

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
	if ([value isGreaterThan:[self primitiveWatcherCount]]) {
		NSLog(@"watcher count has changed on an original repo");
		GithubUser *githubUser = [GithubUser sharedInstance];
		SDGithubTaskManager *watcherManager = [[SDGithubTaskManager manager] retain];
        RepositoryWatchersDelegate *watcherDelegate = [[RepositoryWatchersDelegate alloc] init];
		
        watcherDelegate.parentRepository = self;
        
        watcherManager.delegate = watcherDelegate;
        watcherManager.successSelector = @selector(githubManager:resultsReadyForTask:);
        watcherManager.failSelector = @selector(githubManager:failedForTask:);
        watcherManager.maxConcurrentTasks = 3;
        watcherManager.username = githubUser.username;
        watcherManager.password = githubUser.apiToken;
        
        SDGithubTask *basicTask = [SDGithubTask taskWithManager:watcherManager];
        basicTask.user = [self valueForKey:@"owner"];
        basicTask.repo = [self valueForKey:@"name"];
        basicTask.type = SDGithubTaskGetRepoWatchers;
        [basicTask run];
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

- (id)watcherList 
{
    id tmpValue;
    
    [self willAccessValueForKey:@"watcherList"];
    tmpValue = [self primitiveWatcherList];
    [self didAccessValueForKey:@"watcherList"];
    
    return tmpValue;
}

- (void)setWatcherList:(id)value 
{
    [self willChangeValueForKey:@"watcherList"];
    [self setPrimitiveWatcherList:value];
    [self didChangeValueForKey:@"watcherList"];
}

@end