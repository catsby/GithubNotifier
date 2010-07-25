//
//  GrowlManager.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/15/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Growl/GrowlApplicationBridge.h>
@class AppController;
@class GithubUser;

#define GITHUB_NOTIFICATION_REPOSITORIES_ADDED   @"Repository added"
#define GITHUB_NOTIFICATION_REPOSITORIES_REMOVED @"Repository removed"
#define GITHUB_NOTIFICATION_COMMITS_PUSHED @"New Push"

typedef enum _GithubTimelineObjectType {
	GithubTimelineObjectRepoAdded,
	GithubTimelineObjectRepoRemoved,
	
    GithubTimelineObjectCommit,
    
    GithubTimelineObjectForkAdded,
    GithubTimelineObjectForkRemoved,
    
    GithubTimelineObjectIssueAdded,
    GithubTimelineObjectIssueClosed,
	
	GithubTimelineObjectNewPush
    
} GithubTimelineObjectType;

@interface GrowlManager : NSObject <GrowlApplicationBridgeDelegate> {
	AppController *appController;
}

@property (nonatomic, retain) IBOutlet AppController *appController;

@end