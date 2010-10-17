//
//  RepositoriesController.h
//  GithubNotifier
//
//  Created by Clint Shryock on 9/30/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GithubUser;
@class SDGithubTaskManager;
@class RepositoriesDelegate;


@interface RepositoriesController : NSObject {
	NSArrayController *repositoryArrayController;
	
	//	Main Github task manager
	SDGithubTaskManager *mainTaskManager;
	
	//	Delegate objects
	RepositoriesDelegate *mainRepositoriesDelegate;
	
	GithubUser *githubUser;

}

@property (nonatomic, retain) GithubUser *githubUser;
@property (nonatomic, retain) IBOutlet NSArrayController *repositoryArrayController;

@property (retain) SDGithubTaskManager *mainTaskManager;
@property (retain) RepositoriesDelegate *mainRepositoriesDelegate;

- (id)initWithGithubUser:(GithubUser *)_githubUser;

- (void)fetchUpdates;

@end
