//
//  AppController.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/11/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class SDGithubTaskManager;
@class RepositoriesDelegate;
@class GithubUser;
@class GrowlManager;

@interface AppController : NSObject {
	GrowlManager *growlManager;
	NSArrayController *repositoryArrayController;
	
	//	Main Github task manager
	SDGithubTaskManager *mainTaskManager;
	
	//	Delegate objects
	RepositoriesDelegate *mainRepositoriesDelegate;
	
	NSTimer *repeatingTimer;
}

@property (nonatomic, retain) IBOutlet GrowlManager *growlManager;
@property (nonatomic, retain) IBOutlet NSArrayController *repositoryArrayController;

@property (retain) SDGithubTaskManager *mainTaskManager;
@property (retain) RepositoriesDelegate *mainRepositoriesDelegate;

@property (assign) NSTimer *repeatingTimer;


- (void)run:(NSTimer *)timer;
- (IBAction)showAbout:(id)sender;

@end
