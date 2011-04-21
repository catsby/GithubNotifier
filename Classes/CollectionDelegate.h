//
//  CollectionDelegate.h
//  GithubNotifier
//
//  Created by Clint Shryock on 10/5/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CSManagedRepository.h"
#import "SDGithubTaskManager.h"
#import "GrowlManager.h"


@interface CollectionDelegate : NSObject {
	NSArray *results;
	CSManagedRepository *parentRepository;
}

@property (copy) NSArray *results;
@property (nonatomic, retain) CSManagedRepository *parentRepository;

//	handle mergine a remote set with our local store
- (NSDictionary *)mergeLocalStore:(NSArray *)local withRemoteResults:(NSArray *)remote;

@end
