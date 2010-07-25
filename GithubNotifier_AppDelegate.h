//
//  GithubNotifier_AppDelegate.h
//  GithubNotifier
//
//  Created by Clinton Shryock on 6/11/10.
//  Copyright scary-robot 2010 . All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GithubUser;

@interface GithubNotifier_AppDelegate : NSObject <NSApplicationDelegate> 
{
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	NSStatusItem *appStatusItem;
	
	IBOutlet NSMenu			*appMenu;
	
	IBOutlet NSArrayController *repositoryArrayController;
}


@property (nonatomic, retain) NSArrayController *repositoryArrayController;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

@property (nonatomic, retain) IBOutlet NSMenu *appMenu;

- (IBAction)saveAction:sender;
- (IBAction)quitMenuAction:(id)sender;
- (IBAction)showPreferences:(id)sender;

@end
