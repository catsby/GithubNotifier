//
//  RepositoriesDelegate.m
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/13/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "RepositoriesDelegate.h"
#import "SDGithubTaskManager.h"
#import "SDGithubTask.h"
#import "CSManagedRepository.h"

#import "GrowlManager.h"

@interface RepositoriesDelegate (Private)

- (NSArray *)fetchRepositories;
- (void)mergeLocalRepositories:(NSArray *)local withRemoteRepositories:(NSArray *)remote forUser:(NSString *)username;
- (NSMutableArray *)repositoriesForResults:(NSArray *)remoteResults;
- (NSFetchRequest *)repositoryFetchRequestWithManangedObjectContext:(NSManagedObjectContext *)moc;
- (NSManagedObject *)createRepositoryForData:(NSDictionary *)data;
- (CSManagedRepository *)fetchRepositoryObjectByName:(NSString *)name;
- (CSManagedRepository *)updateRepository:(CSManagedRepository *)repository withDictionary:(NSDictionary *)data;

@end

@implementation RepositoriesDelegate

@synthesize results;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.results  = nil;
	}
	return self;
}


- (void) githubManager:(SDGithubTaskManager*)manager resultsReadyForTask:(SDGithubTask*)task {
	self.results = [task.results valueForKey:@"repositories"];

	NSArray *localRepositories = [self fetchRepositories];
    [self mergeLocalRepositories:localRepositories 
          withRemoteRepositories:[self repositoriesForResults:self.results]
						 forUser:task.user];
}

- (void) githubManager:(SDGithubTaskManager*)manager failedForTask:(SDGithubTask*)task {
	self.results = nil;
	
	NSLog(@"failed to fetch repositories");
}

#pragma mark -
#pragma mark Private methods


- (void)mergeLocalRepositories:(NSArray *)local withRemoteRepositories:(NSArray *)remote forUser:(NSString *)username
{
	NSLog(@"merging");
    NSMutableSet *currentSet = [NSMutableSet setWithArray:local];
    NSMutableSet *remoteSet  = [NSMutableSet setWithArray:remote];
    
	NSMutableDictionary *repositoryChanges = [NSMutableDictionary dictionaryWithCapacity:2];
	[repositoryChanges setObject:username forKey:@"username"];
    

	//	Subtract the current set of repositories on disk from the list 
	//	retrieved from the server.  If there are any left over, then 
	//	we've added new repositories since last update
    [remoteSet minusSet:currentSet];
	if (0 < [remoteSet count]) {
		[repositoryChanges setObject:[NSNumber numberWithInt:[remoteSet count]] forKey:@"additions"];
		[[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_REPOSITORIES_ADDED 
															object:self 
														  userInfo:repositoryChanges];
	}
	
    currentSet = [NSMutableSet setWithArray:local];
    remoteSet  = [NSMutableSet setWithArray:remote];
    
	NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    [currentSet minusSet:remoteSet];
    for (NSManagedObject *orphan in currentSet) {
        [moc deleteObject:orphan];
    }
	
	if (0 < [currentSet count]) {
		[repositoryChanges setObject:[NSNumber numberWithInt:[currentSet count]] forKey:@"subtractions"];
		[[NSNotificationCenter defaultCenter] postNotificationName:GITHUB_NOTIFICATION_REPOSITORIES_REMOVED 
															object:self 
														  userInfo:repositoryChanges];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RepositoriesMerged" 
														object:self 
													  userInfo:nil];
}

- (NSMutableArray *)repositoriesForResults:(NSArray *)remoteResults
{
    NSMutableArray *repositories = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *dict in remoteResults) {
        CSManagedRepository *repo = [self fetchRepositoryObjectByName:[dict valueForKey:@"name"]];
        if (repo) {
            [repositories addObject:[self updateRepository:repo withDictionary:dict]];
        } else {
            [repositories addObject:[self createRepositoryForData:dict]];
        }
    }
    
    return repositories;
}

- (CSManagedRepository *)updateRepository:(CSManagedRepository *)repository withDictionary:(NSDictionary *)data
{
	[repository setValue:[data valueForKey:@"name"] forKey:@"name"];
    [repository setValue:[data valueForKey:@"description"] forKey:@"desc"];
    [repository setValue:[data valueForKey:@"owner"] forKey:@"owner"];
    [repository setValue:[data valueForKey:@"url"] forKey:@"url"];
    [repository setValue:[data valueForKey:@"parent"] forKey:@"parent"];
    [repository setValue:[data valueForKey:@"source"] forKey:@"source"];
    [repository setValue:[data valueForKey:@"forks"] forKey:@"forks"];
    //[repository setValue:[data valueForKey:@"watchers"] forKey:@"watchers"];    
	repository.watcherCount = [data valueForKey:@"watchers"];
    [repository setValue:[data valueForKey:@"homepage"] forKey:@"homepage"];    
	NSNumber *isFork = [NSNumber numberWithUnsignedInt:[[data valueForKey:@"fork"] intValue]];
    [repository setValue:isFork forKey:@"isFork"];
    return repository;
}

- (NSManagedObject *)createRepositoryForData:(NSDictionary *)data
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSManagedObject *newRepo = [NSEntityDescription insertNewObjectForEntityForName:@"Repository" 
                                                             inManagedObjectContext:moc];
    [newRepo setValue:[data valueForKey:@"name"] forKey:@"name"];
    [newRepo setValue:[data valueForKey:@"description"] forKey:@"desc"];
    [newRepo setValue:[data valueForKey:@"owner"] forKey:@"owner"];
    [newRepo setValue:[data valueForKey:@"url"] forKey:@"url"];
    [newRepo setValue:[data valueForKey:@"parent"] forKey:@"parent"];
    [newRepo setValue:[data valueForKey:@"source"] forKey:@"source"];
    [newRepo setValue:[data valueForKey:@"forks"] forKey:@"forks"];
    [newRepo setValue:[data valueForKey:@"watchers"] forKey:@"watchers"];    
    [newRepo setValue:[data valueForKey:@"homepage"] forKey:@"homepage"];    
	NSNumber *isFork = [NSNumber numberWithUnsignedInt:[[data valueForKey:@"fork"] intValue]];
    [newRepo setValue:isFork forKey:@"isFork"];
    return newRepo;
}

- (NSArray *)fetchRepositories
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSFetchRequest *request = [self repositoryFetchRequestWithManangedObjectContext:moc];
    
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc]
										initWithKey:@"name" ascending:YES];
    
	[request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError *error = nil;
    NSArray *resultArray = [moc executeFetchRequest:request error:&error];
    
    if(nil == resultArray) {
        return nil;
    }
    
    return resultArray;
}

- (CSManagedRepository *)fetchRepositoryObjectByName:(NSString *)name
{
    NSManagedObjectContext *moc = [[NSApp delegate] managedObjectContext];
    NSFetchRequest *request = [self repositoryFetchRequestWithManangedObjectContext:moc];
	
    //  setup predicate
	NSPredicate *predicate = [NSPredicate predicateWithFormat:
							  @"name == %@", name];
	[request setPredicate:predicate];
	
	NSError *error = nil;
	NSArray *resultArray = [moc executeFetchRequest:request error:&error];	
    
    if (0 < [resultArray count]) {
        return [resultArray objectAtIndex:0];    
    } 
    
	return nil;
}

- (NSFetchRequest *)repositoryFetchRequestWithManangedObjectContext:(NSManagedObjectContext *)moc
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Repository" 
                                                         inManagedObjectContext:moc];
    
    NSFetchRequest *request = [[[NSFetchRequest alloc] init] autorelease];
    
    [request setEntity:entityDescription];
    return request;
}

@end
