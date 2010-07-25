//
//  GithubUser.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/11/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GithubUser : NSObject {
	NSString *username;
	NSString *apiToken;
}

@property (copy) NSString *username;
@property (copy) NSString *apiToken;


+ (GithubUser *)sharedInstance;

- (BOOL)saveToDefaults;

@end
