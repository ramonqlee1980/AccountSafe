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
#import "AccountInfo.h"
#import "PatternLockAppViewController.h"
#import "ASIFormDataRequest.h"
#import "JSONKit.h"
#import "AdsConfig.h"
#import "NetworkManager.h"


#define kDigitPassword


@interface AppDelegate()
-(void)startAdsConfigReceive;
-(void)transferXMLWhenInstall;
-(void)checkUpdate;
+(BOOL)CompareVersionFromOldVersion : (NSString *)oldVersion
                         newVersion : (NSString *)newVersion;
@property (nonatomic, assign, readonly ) BOOL                               isReceiving;
@property (nonatomic, retain,readwrite) NSURLConnection *                  connection;
@property (nonatomic, copy,   readwrite) NSString *                         filePath;
@property (nonatomic, retain,readwrite) NSOutputStream *                   fileStream;
@end


@implementation AppDelegate
@synthesize connection    = _connection;
@synthesize filePath      = _filePath;
@synthesize fileStream    = _fileStream;
@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize naviController;
@synthesize mTrackName;
@synthesize mTrackViewUrl;



#pragma mark app LifeCycle
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
#ifdef DEBUG_INIT
    ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
    [mgr removeAllObjects];
#endif
    [self transferXMLWhenInstall];
    
#ifdef k91Appstore
    [self checkUpdate];
    [self startAdsConfigReceive];
#endif
    
    //in-app purchase
    [[SKPaymentQueue defaultQueue] addTransactionObserver:[InAppRageIAPHelper sharedHelper]];
    
    //ui 
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
#ifdef kDigitPassword
    self.viewController = [[CheckViewController alloc] initWithNibName:@"CheckViewController_iPhone" bundle:nil];  
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window addSubview:naviController.view];
#else
    self.viewController = [[PatternLockAppViewController alloc] initWithNibName:@"PatternLockAppViewController" bundle:nil]; 
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window addSubview:naviController.view];
#endif

        
    [self.window makeKeyAndVisible];
    
    //notification 
    [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
    if(application.applicationIconBadgeNumber>0)
    {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber-1;    
    }
    
    return YES;
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {        
    if(application.applicationIconBadgeNumber>0)
    {
        application.applicationIconBadgeNumber = application.applicationIconBadgeNumber-1;    
    }   
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
    
    [naviController popToViewController:_viewController animated:NO];
    
    [_viewController release];
    _viewController = nil;
    [naviController release];
    naviController = nil;
    
    [_window release];
    _window = nil;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
#ifdef kDigitPassword
    self.viewController = [[CheckViewController alloc] initWithNibName:@"CheckViewController_iPhone" bundle:nil];  
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window addSubview:naviController.view];
#else
    self.viewController = [[PatternLockAppViewController alloc] initWithNibName:@"PatternLockAppViewController" bundle:nil]; 
    self.naviController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window addSubview:naviController.view];
#endif
    
    
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
	
    [mTrackViewUrl release];
    [mTrackName release];
    
    [managedObjectContext release];
    managedObjectContext = nil;
    [managedObjectModel release];
    managedObjectModel = nil;
    [persistentStoreCoordinator release];
    persistentStoreCoordinator = nil;
    
    [_viewController release];
    _viewController = nil;
    [naviController release];
    naviController = nil;
    
    [_window release];
    _window = nil;
    
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
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel: [self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:options error:&error]) {
        // Handle the error.
        NSLog(@"addPersistentStoreWithType error:%@",error);
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


#pragma mark localNotification
#define kTime2ModifyPasscode @"time2ModifyPasscode"

+(void)scheduleLocalNotification:(AccountInfo*)info
{
    if(info==nil)
    {
        return;
    }
        
    UILocalNotification *notification=[[UILocalNotification alloc] init]; 
    if (notification!=nil) { 
        notification.fireDate=info.alarm; 
        notification.timeZone=[NSTimeZone defaultTimeZone]; 
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;

        notification.alertBody=[NSString stringWithFormat:NSLocalizedString(kTime2ModifyPasscode,""),info.name]; 
        NSLog(@"notification alertBody:%@",notification.alertBody);
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
        NSLog(@"scheduleLocalNotification:%@",notification);
    }    
    [notification release]; 
}

+(void)cancelLocalNotification:(AccountInfo*)info
{
    if (nil==info) {
        return;
    }
    UILocalNotification *notification=[[UILocalNotification alloc] init]; 
    if (notification!=nil) { 
        notification.fireDate=info.alarm; 
        notification.timeZone=[NSTimeZone defaultTimeZone]; 
        notification.soundName = UILocalNotificationDefaultSoundName;
        notification.applicationIconBadgeNumber = notification.applicationIconBadgeNumber+1;
        notification.alertBody=[NSString stringWithFormat:NSLocalizedString(kTime2ModifyPasscode,""),info.name];
        [[UIApplication sharedApplication]   cancelLocalNotification:notification];
        NSLog(@"cancelLocalNotification::%@",notification);
    }    
    [notification release]; 
}

+ (void)cancelAllLocalNotifications
{
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    NSLog(@"cancelAllLocalNotifications");
}
+(BOOL)isPurchased
{
    if (kDebugVersion == YES) {
        return YES;
    }
#ifdef k91Appstore
    return YES;
#else
    
    BOOL r = [[InAppRageIAPHelper sharedHelper].purchasedProducts containsObject:kInAppPurchaseProductName];   
    NSLog(@"isPurchased:%d",r);
    return r;
#endif
}

#pragma mark transferXML
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

#pragma mark update
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // the user clicked one of the OK/Cancel buttons
    if (buttonIndex == 1)
    {        
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mTrackViewUrl]];
    }
}
-(void)checkUpdate
{    
    NSString *version = @"";
    NSString* updateLookupUrl = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",kAppIdOnAppstore];
    NSURL *url = [NSURL URLWithString:updateLookupUrl];
    ASIFormDataRequest* versionRequest = [ASIFormDataRequest requestWithURL:url];
    [versionRequest setRequestMethod:@"GET"];
    [versionRequest setDelegate:self];
    [versionRequest setTimeOutSeconds:150];
    [versionRequest addRequestHeader:@"Content-Type" value:@"application/json"]; 
    [versionRequest startSynchronous];
    
    //Response string of our REST call
    NSString* jsonResponseString = [versionRequest responseString];
    
    NSDictionary *loginAuthenticationResponse = [jsonResponseString objectFromJSONString];
    
    NSArray *configData = [loginAuthenticationResponse valueForKey:@"results"];
    NSString* releaseNotes;
    for (id config in configData) 
    {
        version = [config valueForKey:@"version"];
        self.mTrackViewUrl = [config valueForKey:@"trackViewUrl"];
        releaseNotes = [config valueForKey:@"releaseNotes"]; 
        self.mTrackName = [config valueForKey:@"trackName"];
        NSLog(@"%@",mTrackName);
    }
    NSString *localVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    //Check your version with the version in app store
    if ([AppDelegate CompareVersionFromOldVersion:localVersion newVersion:version]) 
    {        
        UIAlertView *createUserResponseAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NewVersion", @"") message: @"" delegate:self cancelButtonTitle:NSLocalizedString(@"Back", @"") otherButtonTitles: NSLocalizedString(@"Ok", @""), nil];
        [createUserResponseAlert show]; 
        [createUserResponseAlert release];
    }
}
// 比较oldVersion和newVersion，如果oldVersion比newVersion旧，则返回YES，否则NO
// Version format[X.X.X]
+(BOOL)CompareVersionFromOldVersion : (NSString *)oldVersion
                         newVersion : (NSString *)newVersion
{
    NSArray*oldV = [oldVersion componentsSeparatedByString:@"."];
    NSArray*newV = [newVersion componentsSeparatedByString:@"."];
    
    if (oldV.count == newV.count) {
        for (NSInteger i = 0; i < oldV.count; i++) {
            NSInteger old = [(NSString *)[oldV objectAtIndex:i] integerValue];
            NSInteger new = [(NSString *)[newV objectAtIndex:i] integerValue];
            if (old < new) {
                return YES;
            }
        }
        return NO;
    } else {
        return NO;
    }
}

#pragma mark * Core transfer code

// This is the code that actually does the networking.

- (BOOL)isReceiving
{
    return (self.connection != nil);
}

- (void)startAdsConfigReceive
// Starts a connection to download the current URL.
{
    BOOL                success;
    NSURL *             url;	
    NSURLRequest *      request;
    if(self.connection!=nil)
    {
        return;
    }
    
    assert(self.connection == nil);         // don't tap receive twice in a row!
    assert(self.fileStream == nil);         // ditto
    assert(self.filePath == nil);           // ditto
    
    // First get and check the URL.
    
    url = [[NetworkManager sharedInstance] smartURLForString:AdsUrl];
    success = (url != nil);
    
    // If the URL is bogus, let the user know.  Otherwise kick off the connection.
    
    if ((url != nil)) {
        
        // Open a stream for the file we're going to receive into.
        
        self.filePath = [[NetworkManager sharedInstance] pathForTemporaryFileWithPrefix:@"Get"];
        assert(self.filePath != nil);
        
        //remove this file first
        NSError* error;
        NSFileManager* fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:self.filePath]) {
            if (![fileMgr removeItemAtPath:self.filePath error:&error])
                NSLog(@"Unable to delete file: %@", [error localizedDescription]);
        }
        self.fileStream = [NSOutputStream outputStreamToFileAtPath:self.filePath append:NO];
        assert(self.fileStream != nil);
        
        [self.fileStream open];
        
        // Open a connection for the URL.
        
        request = [NSURLRequest requestWithURL:url];
        assert(request != nil);
        
        self.connection = [NSURLConnection connectionWithRequest:request delegate:self];
        assert(self.connection != nil);
        [[NetworkManager sharedInstance] didStartNetworkOperation];
    }
}
- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        assert(self.filePath != nil);
        //load ads config
        [AdsConfig reset];
        [self parseAdsConfig];
        
        AdsConfig* config = [AdsConfig sharedAdsConfig];      
        
        //show close ads 
        if([config wallShouldShow])
        {
            //notify observers
            [[NSNotificationCenter defaultCenter]postNotificationName:kAdsUpdateDidFinishLoading object:nil];
        }
        
    }    
    [[NetworkManager sharedInstance] didStopNetworkOperation];
}
- (void)stopReceiveWithStatus:(NSString *)statusString
// Shuts down the connection and displays the result (statusString == nil) 
// or the error status (otherwise).
{
    if (self.connection != nil) {
        [self.connection cancel];
        self.connection = nil;
    }
    if (self.fileStream != nil) {
        [self.fileStream close];
        self.fileStream = nil;
    }
    [self receiveDidStopWithStatus:statusString];
    self.filePath = nil;
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
// A delegate method called by the NSURLConnection when the request/response 
// exchange is complete.  We look at the response to check that the HTTP 
// status code is 2xx and that the Content-Type is acceptable.  If these checks 
// fail, we give up on the transfer.
{
#pragma unused(theConnection)
    NSHTTPURLResponse * httpResponse;
    NSString *          contentTypeHeader;
    
    assert(theConnection == self.connection);
    
    httpResponse = (NSHTTPURLResponse *) response;
    assert( [httpResponse isKindOfClass:[NSHTTPURLResponse class]] );
    
    if ((httpResponse.statusCode / 100) != 2) {
        [self stopReceiveWithStatus:[NSString stringWithFormat:@"HTTP error %zd", (ssize_t) httpResponse.statusCode]];
    } else {
        // -MIMEType strips any parameters, strips leading or trailer whitespace, and lower cases 
        // the string, so we can just use -isEqual: on the result.
        contentTypeHeader = [httpResponse MIMEType];
        if (contentTypeHeader == nil) {
            [self stopReceiveWithStatus:@"No Content-Type!"];
        } 
        //        else if ( ! [contentTypeHeader isEqual:@"image/jpeg"] 
        //                   && ! [contentTypeHeader isEqual:@"image/png"] 
        //                   && ! [contentTypeHeader isEqual:@"image/gif"] ) {
        //            [self stopReceiveWithStatus:[NSString stringWithFormat:@"Unsupported Content-Type (%@)", contentTypeHeader]];
        //        }
    }    
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)dataRev
// A delegate method called by the NSURLConnection as data arrives.  We just 
// write the data to the file.
{
#pragma unused(theConnection)
    NSInteger       dataLength;
    const uint8_t * dataBytes;
    NSInteger       bytesWritten;
    NSInteger       bytesWrittenSoFar;
    
    assert(theConnection == self.connection);
    
    dataLength = [dataRev length];
    dataBytes  = [dataRev bytes];
    
    bytesWrittenSoFar = 0;
    do {
        bytesWritten = [self.fileStream write:&dataBytes[bytesWrittenSoFar] maxLength:dataLength - bytesWrittenSoFar];
        assert(bytesWritten != 0);
        if (bytesWritten == -1) {
            [self stopReceiveWithStatus:@"File write error"];
            break;
        } else {
            bytesWrittenSoFar += bytesWritten;
        }
    } while (bytesWrittenSoFar != dataLength);
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
// A delegate method called by the NSURLConnection if the connection fails. 
// We shut down the connection and display the failure.  Production quality code 
// would either display or log the actual error.
{
#pragma unused(theConnection)
#pragma unused(error)
    assert(theConnection == self.connection);
    
    [self stopReceiveWithStatus:@"Connection failed"];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
// A delegate method called by the NSURLConnection when the connection has been 
// done successfully.  We shut down the connection with a nil status, which 
// causes the image to be displayed.
{
#pragma unused(theConnection)
    assert(theConnection == self.connection);   
    
    [self stopReceiveWithStatus:nil];
}
/**
 parse ads config from server 
 if failed to get configuration,just use the default config
 */
-(void)parseAdsConfig
{
    AdsConfig *config = [AdsConfig sharedAdsConfig];
    [config init:self.filePath];
}
@end
