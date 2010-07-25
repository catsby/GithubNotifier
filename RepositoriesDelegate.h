//
//  RepositoriesDelegate.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/13/10.
//  Copyright 2010 scary-robot. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RepositoriesDelegate : NSObject {
	NSArray *results;
}

@property (copy) NSArray *results;

@end
