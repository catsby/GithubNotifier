//
//  PreferencesWindowController.m
//  GithubNotifier
//
//  Created by Clinton Shryock on 7/7/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "PreferencesWindowController.h"
#import "GithubUser.h"
#import "NSWorkspaceHelper.h"


@implementation PreferencesWindowController

@synthesize username;
@synthesize apiToken;
@synthesize githubUser;
@synthesize openAtLogin;

- (void)awakeFromNib
{
	self.githubUser = [GithubUser sharedInstance];
}

- (IBAction)saveNewAccount:(id)sender
{
	self.githubUser.username = [self.username stringValue];
	self.githubUser.apiToken = [self.apiToken stringValue];
	[[self window] close];
	
	
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"UserSet" 
														object:self 
													  userInfo:nil];
}

- (IBAction)updateRefreshRate:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshRateChanged" 
														object:self 
													  userInfo:nil];
}

- (IBAction)toggleOpenAtLaunch:(id)sender
{
	NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	NSBundle *bundle = [NSBundle mainBundle];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	BOOL shouldRegisterForLogin = [sender state];
	if (shouldRegisterForLogin) {
		[workspace registerLoginLaunchBundle:bundle];
		[defaults setBool:YES forKey:@"openAtLogin"];
	} else {
		[workspace unregisterLoginLaunchBundle:bundle];
		[defaults setBool:NO forKey:@"openAtLogin"];
	}
}


@end