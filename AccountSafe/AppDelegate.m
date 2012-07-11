//
//  AppDelegate.m
//  AccountSafe
//
//  Created by li ming on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "CheckViewController.h"
#import "ProtocolLogManager.h"
#import "InAppRageIAPHelper.h"
#import "constants.h"


@interface AppDelegate()
-(void)transferXMLWhenInstall;

@end


@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize naviController;

#pragma transferXML
//transfer xml to doc directory when installing
//if file exist,just return
-(void)transferXMLWhenInstall
{    
    NSString* xmlFileName = [[self applicationDocumentsDirectory]stringByAppendingPathComponent:kAccountCategoryFileNameWithSuffix];
    NSFileManager* fm = [NSFileManager defaultManager];
    if([fm fileExistsAtPath:xmlFileName])
    {
#ifdef kDelete
        NSError* error = nil;
        [fm removeItemAtPath:xmlFileName error:&error];
#endif
        return;
    }
    
    NSError* error = nil;
    NSString* bundleXmlFileName = [[NSBundle mainBundle]pathForResource:kAccountCategoryFileName ofType:kAccountCategoryFileType];
    [fm copyItemAtPath:bundleXmlFileName toPath:xmlFileName error:&error];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
#ifdef DEBUG_INIT
    ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
    [mgr removeAllObjects];
#endif
    [self transferXMLWhenInstall];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[InAppRageIAPHelper sharedHelper]];
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[CheckViewController alloc] initWithNibName:@"CheckViewController_iPhone" bundle:nil] autorelease];
   
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window addSubview:naviController.view];
        
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
    [ProtocolLogManager reset];    

    [managedObjectContext release];
    managedObjectContext = nil;
    [managedObjectModel release];
    managedObjectModel = nil;
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
    
    [_window release];
    _window = nil;
    [_viewController release];
    _viewController = nil;
    [naviController release];
    naviController = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.viewController = [[[CheckViewController alloc] initWithNibName:@"CheckViewController_iPhone" bundle:nil] autorelease];
    
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window addSubview:naviController.view];
    
    [self.window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    NSError *error;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			// Handle the error.
        } 
    }
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
	
    [managedObjectContext release];
    managedObjectContext = nil;
    [managedObjectModel release];
    managedObjectModel = nil;
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
    
    [_window release];
    _window = nil;
    [_viewController release];
    _viewController = nil;
    [naviController release];
    naviController = nil;
    [super dealloc];
}
#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [[NSManagedObjectModel mergedModelFromBundles:nil] retain];    
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"AccountDetails.sqlite"]];
	
	NSError *error;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
        // Handle the error.
    }    
	
    return persistentStoreCoordinator;
}


#pragma mark -
#pragma mark Application's documents directory

/**
 Returns the path to the application's documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}
@end
