//
//  NetworkMetaDelegate.m
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/17/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "NetworkMetaDelegate.h"
#import "SDGithubTaskManager.h"
#import "SDGithubTask.h"


@implementation NetworkMetaDelegate

@synthesize parentRepository;

- (void) githubManager:(SDGithubTaskManager*)manager resultsReadyForTask:(SDGithubTask*)task {
	NSString *nethash;
	nethash = [task.results valueForKey:@"nethash"];
    if ([nethash isNotEqualTo:[self.parentRepository valueForKey:@"nethash"]]) {
		NSLog(@"nethash update");
		[self.parentRepository setValue:nethash forKey:@"nethash"];
		
		NSLog(@"Posting nethash change for :%@", [self.parentRepository valueForKey:@"name"]);
		NSDictionary *dict = [NSDictionary dictionaryWithObject:self.parentRepository forKey:@"repository"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateNetworkForRepository" 
															object:self 
														  userInfo:dict];
		
    }
}

- (void) githubManager:(SDGithubTaskManager*)manager failedForTask:(SDGithubTask*)task 
{	
	NSLog(@"error in NetworkMetaDelegate>githubManager:");
}


@end
