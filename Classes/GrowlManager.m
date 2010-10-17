//
//  GrowlManager.m
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/15/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "GrowlManager.h"
#import "GithubUser.h"

@interface GrowlManager (Private)
- (void)notifyWithNewCommits:(NSNotification *)aNotification;
- (void)notifyWithRepositoriesAdditions:(NSNotification *)aNotification;
- (void)notifyWithRepositoriesRemovals:(NSNotification *)aNotification;
- (void)notifyWithNewPush:(NSNotification *)aNotification;
- (void)notifyWithWatchersAdded:(NSNotification *)aNotification;
@end

@implementation GrowlManager 

@synthesize appController;

- (void) awakeFromNib {
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWithRepositoriesAdditions:)
												 name:GITHUB_NOTIFICATION_REPOSITORIES_ADDED
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
											 selector:@selector(notifyWithRepositoriesRemovals:)
												 name:GITHUB_NOTIFICATION_REPOSITORIES_REMOVED
											   object:nil];
	
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notifyWithNewPush:)
                                                 name:GITHUB_NOTIFICATION_COMMITS_PUSHED
                                               object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(notifyWithWatchersAdded:)
                                                 name:GITHUB_NOTIFICATION_WATCHERS_ADDED
                                               object:nil];
	
	
	[GrowlApplicationBridge setGrowlDelegate:self];
}

- (void)notifyWithRepositoriesAdditions:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	
	NSNumber *count = [userInfo objectForKey:@"additions"];
	NSMutableDictionary *context = [NSMutableDictionary dictionary];
	[context setObject:[userInfo objectForKey:@"username"] forKey:@"username"];
	NSString *variableDesc = ([count intValue] > 1) ? @"repositories were" : @"repository was"; 
	[GrowlApplicationBridge notifyWithTitle:@"Your repositories have changed"
								description:[NSString stringWithFormat:@"%@ %@ added", count, variableDesc]
						   notificationName:@"Repositories Changed"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:context];
}


- (void)notifyWithRepositoriesRemovals:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	
	NSNumber *count = [userInfo objectForKey:@"subtractions"];
	
	NSString *variableDesc = ([count intValue] > 1) ? @"repositories were" : @"repository was"; 
	[GrowlApplicationBridge notifyWithTitle:@"Your repositories have changed"
								description:[NSString stringWithFormat:@"%@ %@ removed", count, variableDesc]
						   notificationName:@"Repositories Changed"
								   iconData:nil
								   priority:0
								   isSticky:NO
							   clickContext:nil];
}

- (void)notifyWithNewPush:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSMutableArray *pushes = [userInfo objectForKey:@"payload"];
	NSManagedObject *repository = [userInfo objectForKey:@"repository"];
	
	[GrowlApplicationBridge setGrowlDelegate:self];
	
	for (NSDictionary *commit in pushes) {
		NSString *linkTitle = ([[commit objectForKey:@"login"] isNotEqualTo:nil]) ? 
		[NSString stringWithFormat:@"%@/", [commit objectForKey:@"login"]] : @"";
		
		NSString *title = [NSString stringWithFormat:@"New pushes to %@%@", 
						   linkTitle,
						   [repository valueForKey:@"name"]];
		NSMutableDictionary *context = [NSMutableDictionary dictionary];
		[context setValue:[commit objectForKey:@"login"] forKey:@"author"];
		[context setValue:[repository valueForKey:@"name"] forKey:@"repoName"];
		[context setValue:[commit objectForKey:@"id"] forKey:@"commitId"];
		[context setValue:[NSNumber numberWithInteger:GithubTimelineObjectNewPush] forKey:@"type"];
		[GrowlApplicationBridge notifyWithTitle:title
									description:[commit objectForKey:@"message"]
							   notificationName:GITHUB_NOTIFICATION_COMMITS_PUSHED
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:context];
	}	

}

- (void) growlNotificationWasClicked:(id)clickContext
{	
	GithubUser *githubUser = [GithubUser sharedInstance];
	
	NSNumber *type = [clickContext objectForKey:@"type"];
	NSString *urlEnd;
	switch ([type integerValue]) {
		case GithubTimelineObjectNewPush:
			urlEnd = [NSString stringWithFormat:@"%@/%@/commits", 
					  ([[clickContext objectForKey:@"author"] isNotEqualTo:nil]) ? [clickContext objectForKey:@"author"] : githubUser.username,
					  [clickContext objectForKey:@"repoName"]];
			break;
		case GithubTimelineObjectWatchersAdded:
			urlEnd = [NSString stringWithFormat:@"%@", [clickContext objectForKey:@"name"]];
			break;
		default:
			urlEnd = [NSString stringWithFormat:@"%@", [clickContext objectForKey:@"username"]];
			
	}
	NSWorkspace * ws = [NSWorkspace sharedWorkspace];
	NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"http://github.com/%@", urlEnd]];
	[ws openURL: url];
	
}



- (void)notifyWithWatchersAdded:(NSNotification *)aNotification
{
	NSDictionary *userInfo = [aNotification userInfo];
	NSMutableArray *watchers = [userInfo objectForKey:@"additions"];
	
	[GrowlApplicationBridge setGrowlDelegate:self];

	if (3 < [watchers count]) {
		NSString *title = [NSString stringWithFormat:@"New watchers for %@/%@", 
						   [userInfo valueForKey:@"user"], 
						   [userInfo valueForKey:@"repo"]];
		NSMutableString *message = [NSMutableString stringWithFormat:@"%d new watchers\n", [watchers count]];
		[watchers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {
			[message appendFormat:@"%@\n", [obj valueForKey:@"name"]];
		}];
		
		[GrowlApplicationBridge notifyWithTitle:title
									description:message
							   notificationName:GITHUB_NOTIFICATION_WATCHERS_ADDED
									   iconData:nil
									   priority:0
									   isSticky:NO
								   clickContext:nil];
	} else {
		[watchers enumerateObjectsUsingBlock:^(id obj, NSUInteger index, BOOL *stop) {		
			NSMutableDictionary *context = [NSMutableDictionary dictionary];
			[context setValue:[obj objectForKey:@"name"] forKey:@"name"];
			[context setValue:[NSNumber numberWithInteger:GithubTimelineObjectWatchersAdded] forKey:@"type"];	
			NSString *title = [NSString stringWithFormat:@"New watchers for %@", 
							   [userInfo valueForKey:@"repo"]];
			[GrowlApplicationBridge notifyWithTitle:title
										description:[NSString stringWithFormat:@"%@ is now watching your fork", [obj valueForKey:@"name"]]
								   notificationName:GITHUB_NOTIFICATION_WATCHERS_ADDED
										   iconData:nil
										   priority:0
										   isSticky:NO
									   clickContext:context];
		}];
	}
	
	
}

@end
