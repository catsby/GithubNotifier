//
//  GithubUser.m
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/11/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import "GithubUser.h"
#import "EMKeychain.h"

static GithubUser *sharedInstance = nil;

@implementation GithubUser

@synthesize username;
@synthesize apiToken;

- (id) init
{
	self = [super init];
	if (self != nil) {
		self.apiToken = nil;
		self.username = nil;
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		self.username = [defaults stringForKey:@"GithubNotifierUsername"];
	}
	
	return self;
}

- (BOOL)saveToDefaults
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.username forKey:@"GithubNotifierUsername"];
	
	return YES;
}

- (void)setApiToken:(NSString *)aToken
{
	EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"com.scary-robot.GithubNotifier"
																				  withUsername:self.username];
	if(!keychainItem) {
		keychainItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"com.scary-robot.GithubNotifier" 
												   withUsername:self.username 
													   password:aToken];
	} else {
		[keychainItem setPassword:aToken];
	}
}

- (NSString *)apiToken
{
	if (!apiToken){		
	EMGenericKeychainItem *keychainItem = [EMGenericKeychainItem genericKeychainItemForService:@"com.scary-robot.GithubNotifier"
																					  withUsername:self.username];
		
		apiToken = [keychainItem password];
	}
	
	return 	apiToken;
}

#pragma mark -
#pragma mark Singleton methods

+ (GithubUser *)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
			sharedInstance = [[GithubUser alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}


- (id)retain {
    return self;
}

@end