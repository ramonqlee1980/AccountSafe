//
//  AppDelegate.h
//  AccountSafe
//
//  Created by li ming on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckViewController;
@class AccountInfo;

#define kDebugVersion NO//for test only

#define kInAppPurchaseProductName @"com.idreems.AccountSafe.VIP"

#define MANAGED_CONTEXT [((AppDelegate*)[[UIApplication sharedApplication]delegate]) managedObjectContext]
#define APPDELEGATE    [[UIApplication sharedApplication]delegate]

#define VIP_FEATURES_TIP if (![AppDelegate isPurchased])\
                            {\
                            NSString* ret = NSLocalizedString(@"vipFeatures", "");\
                            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:ret delegate:nil cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil, nil]autorelease];\
                            [alert show];\
                            return;\
                            }


@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSString* mTrackViewUrl;
    NSString* mTrackName;
    
    UINavigationController* naviController;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;	
}
@property (nonatomic, retain) NSString* mTrackViewUrl;
@property (nonatomic, retain) NSString* mTrackName;

@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, readonly) NSString *applicationDocumentsDirectory;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UIViewController *viewController;
@property (strong, nonatomic) UINavigationController *naviController;

+(void)scheduleLocalNotification:(AccountInfo*)info;
+(void)cancelLocalNotification:(AccountInfo*)info;
+(void)cancelAllLocalNotifications;


+(BOOL)isPurchased;

@end
