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


@interface CollectionDelegate : NSObject {
	NSArray *results;
	CSManagedRepository *parentRepository;
}

@property (copy) NSArray *results;
@property (nonatomic, retain) CSManagedRepository *parentRepository;
@end
