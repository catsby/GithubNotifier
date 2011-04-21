//
//  AppController.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/11/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RepositoriesController;
@class GithubUser;
@class GrowlManager;

@interface AppController : NSObject {
	GrowlManager *growlManager;
	NSArrayController *repositoryArrayController;
	
	NSTimer *repeatingTimer;
	
	RepositoriesController *repositoriesController;
}

@property (nonatomic, retain) IBOutlet GrowlManager *growlManager;
@property (nonatomic, retain) IBOutlet NSArrayController *repositoryArrayController;


@property (nonatomic, retain) RepositoriesController *repositoriesController;

@property (assign) NSTimer *repeatingTimer;


- (void)run:(NSTimer *)timer;
- (IBAction)showAbout:(id)sender;

@end
