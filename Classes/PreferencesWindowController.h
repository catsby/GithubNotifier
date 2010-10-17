//
//  PreferencesWindowController.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 7/7/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class GithubUser;


@interface PreferencesWindowController : NSWindowController {
	NSTextField *username;
	NSSecureTextField *apiToken;
	BOOL openAtLogin;
	
	GithubUser *githubUser;
}

@property (nonatomic, retain) IBOutlet NSTextField *username; 
@property (nonatomic, retain) IBOutlet NSSecureTextField *apiToken;
@property (nonatomic, retain) GithubUser *githubUser;
@property (assign) BOOL openAtLogin;

- (IBAction)saveNewAccount:(id)sender;
- (IBAction)updateRefreshRate:(id)sender;
- (IBAction)toggleOpenAtLaunch:(id)sender;

@end
