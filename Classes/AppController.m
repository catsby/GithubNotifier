//
//  AppController.m
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/11/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "AppController.h"
#import "NetworkMetaDelegate.h"
#import "NetworkDataDelegate.h"
#import "RepositoriesController.h"
#import "GithubUser.h"
#import "SDGithubTaskManager.h"

#import "GrowlManager.h"

@interface AppController (Private)
- (void)resetTimer:(NSNotification *)aNotification;
- (NSTimeInterval)refreshRate;
@end

@implementation AppController

@synthesize growlManager;
@synthesize repositoryArrayController;
@synthesize repeatingTimer;
@synthesize repositoriesController;


- (id) init
{
	self = [super init];
	if (self != nil) {
		self.repeatingTimer = nil;
	}
	return self;
}


- (void) awakeFromNib
{
	//	Listen for when repositories have been merged, then update 
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateRepositories:)
                                                 name:@"RepositoriesMerged"
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(updateNetwork:)
                                                 name:@"UpdateNetworkForRepository"
                                               object:nil];
	
	//	Used for new account setup, when app delegate sets up the GithubUser
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(resetTimer:)
                                                 name:@"UserSet"
                                               object:nil];
	
	//	Used for new account setup, when app delegate sets up the GithubUser
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(resetTimer:)
                                                 name:@"RefreshRateChanged"
                                               object:nil];
	
}

- (IBAction)showAbout:(id)sender
{
	[NSApp activateIgnoringOtherApps:YES];
	[NSApp orderFrontStandardAboutPanel:self];
}

#pragma mark -
#pragma mark Main Run
- (void)run:(NSTimer *)timer
{
	GithubUser *githubUser = [GithubUser sharedInstance];

	if ([githubUser.username isNotEqualTo:nil]) {		
		if (!self.repositoriesController) {
			self.repositoriesController = [[RepositoriesController alloc] initWithGithubUser:githubUser];
		}
		[self.repositoriesController fetchUpdates];
	}
}

- (void)resetTimer:(NSNotification *)aNotification
{
	NSTimer *repeat;
	NSDate  *fireDate;
	NSTimeInterval interval = [self refreshRate];
	if (!self.repeatingTimer) {	
		NSDate  *fireDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
		repeat = [[NSTimer alloc] initWithFireDate:fireDate
												   interval:interval 
													 target:self 
												   selector:@selector(run:)
												   userInfo:nil
													repeats:YES];
	} else {
		[self.repeatingTimer invalidate];
		self.repeatingTimer = nil;
		fireDate = [NSDate dateWithTimeIntervalSinceNow:interval];
		repeat = [[NSTimer alloc] initWithFireDate:fireDate
										  interval:interval 
											target:self 
										  selector:@selector(run:)
										  userInfo:nil
										   repeats:YES];
	}
	
	NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
	[runLoop addTimer:repeat forMode:NSDefaultRunLoopMode];
	self.repeatingTimer = repeat;
}

- (NSTimeInterval)refreshRate
{		
	NSUserDefaults *defaults	= [NSUserDefaults standardUserDefaults];
	NSNumber *refreshRateIndex  = [defaults objectForKey:@"RefreshRateIndex"]; 
	NSTimeInterval refreshRate;
	switch ([refreshRateIndex intValue]) {
		case 1:
			refreshRate = 900;
			break;
		case 2:
			refreshRate = 1800;
			break;
		case 3:
			refreshRate = 3600;
			break;
		default:
			refreshRate = 300;

	}
	return refreshRate;
}
/**
 *	When we're done merging the collection of repositories, adding new ones and pruning old ones,
 *	we go and grab the nethash value for each
 */
- (void)updateRepositories:(NSNotification *)aNotification
{
	GithubUser *githubUser = [GithubUser sharedInstance];
	NSArray *repositories = [self.repositoryArrayController arrangedObjects];
	for (NSManagedObject *repository in repositories) {
        SDGithubTaskManager *netHashManager = [[SDGithubTaskManager manager] retain];
        NetworkMetaDelegate *nethashDelegate = [[NetworkMetaDelegate alloc] init];
		
        nethashDelegate.parentRepository = repository;
        
        netHashManager.delegate = nethashDelegate;
        netHashManager.successSelector = @selector(githubManager:resultsReadyForTask:);
        netHashManager.failSelector = @selector(githubManager:failedForTask:);
        netHashManager.maxConcurrentTasks = 3;
        netHashManager.username = githubUser.username;
        netHashManager.password = githubUser.apiToken;
        
        SDGithubTask *basicTask = [SDGithubTask taskWithManager:netHashManager];
        basicTask.user = [repository valueForKey:@"owner"];
        basicTask.repo = [repository valueForKey:@"name"];
        basicTask.type = SDGithubTaskNetworkMeta;
        [basicTask run];
    }
}

/**
 *	When we're done merging the collection of repositories, adding new ones and pruning old ones,
 *	we go and grab the nethash value for each
 */
- (void)updateNetwork:(NSNotification *)aNotification
{
	GithubUser *githubUser = [GithubUser sharedInstance];
	NSManagedObject *repository = [[aNotification userInfo] objectForKey:@"repository"];
	
	SDGithubTaskManager *networkDataTaskManager = [[SDGithubTaskManager manager] retain];
	
	NetworkDataDelegate *networkDataDelegate = [[NetworkDataDelegate alloc] init];
	
	networkDataDelegate.repository = repository;
	
	networkDataTaskManager.delegate = networkDataDelegate;
	networkDataTaskManager.successSelector = @selector(githubManager:resultsReadyForTask:);
	networkDataTaskManager.failSelector = @selector(githubManager:failedForTask:);
	networkDataTaskManager.maxConcurrentTasks = 3;
	networkDataTaskManager.username = githubUser.username;
	networkDataTaskManager.password = githubUser.apiToken;
	
	SDGithubTask *basicTask = [SDGithubTask taskWithManager:networkDataTaskManager];
	basicTask.user = [repository valueForKey:@"owner"];
	basicTask.repo = [repository valueForKey:@"name"];
	basicTask.type = SDGithubTaskNetworkData;
	[basicTask run];
}
@end
