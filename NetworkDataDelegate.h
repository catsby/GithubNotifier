//
//  NetworkDataDelegate.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/17/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NetworkDataDelegate : NSObject {
	NSManagedObject *repository;
}

@property (retain) NSManagedObject *repository;

@end
