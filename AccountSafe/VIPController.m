//
//  VIPController.m
//  AccountSafe
//
//  Created by li ming on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "VIPController.h"
#import "InAppRageIAPHelper.h"
#import "MBProgressHUD.h"
#import "Reachability.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>

@interface VIPController()
-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action;
- (NSString *)localizedPrice:(NSLocale *)priceLocale price:(NSDecimalNumber *)price;
@end

@implementation VIPController
@synthesize hud = _hud;
@synthesize tableView;

#define kMaxNumberOfLines 3//numberofline for tableview cell's label

#define kVIPFeatureCount 4
#define kVIPNewCategory 0
#define kVIPDeleteCategory 1
#define kVIPSetAlarm 2
#define kVIPMoreFeatures 3

#define kVIPNewCategoryKey @"kVIPNewCategoryKey"
#define kVIPDeleteCategoryKey @"kVIPDeleteCategoryKey"
#define kVIPSetAlarmKey @"kVIPSetAlarmKey"
#define kVIPMoreFeaturesKey @"kVIPMoreFeaturesKey" 

#define kVIPFeatureListTitle @"kVIPFeatureListTitle"

#pragma  mark tableview datasource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kVIPFeatureCount;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define kVIPCell @"VIPCell"
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kVIPCell];
    if (nil==cell) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVIPCell]autorelease];
    }
    
    //1 category edit
    //1.1add new category count
    //1.2delete category
    NSString* key = nil;
    
    //2.alarm to change passcode    
    switch (indexPath.section) {
        case kVIPNewCategory:
            key = kVIPNewCategoryKey;
            break;
        case kVIPDeleteCategory:
            key = kVIPDeleteCategoryKey;
            break;
        case kVIPSetAlarm:
            key = kVIPSetAlarmKey;
            break;
        case kVIPMoreFeatures:
            key = kVIPMoreFeaturesKey;
        default:
            break;
    }
    
    [cell setBackgroundColor:[UIColor clearColor]];
    UIView* b = [[UIView alloc]init];
    [cell setBackgroundView:b];
    [b release];
    
    if (key) {       
        
        cell.textLabel.text = NSLocalizedString(key, "");
        cell.textLabel.numberOfLines = kMaxNumberOfLines;
        cell.textLabel.textColor = [UIColor blueColor];
        [cell.textLabel setBackgroundColor:[UIColor whiteColor]];
        //if (indexPath.section%2==0) {
        //    cell.textLabel.textAlignment = UITextAlignmentRight;
        //}
        
        cell.textLabel.layer.borderColor = [UIColor grayColor].CGColor;
        cell.textLabel.layer.borderWidth = 1.0;
        cell.textLabel.layer.cornerRadius = 5.0; 
        
        //sizeToContent    
        //CGSize txtSz = [cell.textLabel.text sizeWithFont:[UIFont fontWithName: @"Helvetica" size: 16]];        
        //CGRect lblFrame = CGRectMake(0,0, txtSz.width, txtSz.height);        
        //cell.textLabel.frame = lblFrame;
    }    
    
    return cell;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString* r = nil;
    if (section == kVIPNewCategory) {
        r = NSLocalizedString(kVIPFeatureListTitle, "");
    }
    
    return r;
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma in-app purchase
-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:buttonName style:UIBarButtonItemStyleBordered target:self action:action];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = title;    
    [rightItem release];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"TabTitleVIP", "");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = NSLocalizedString(@"CFBundleDisplayName", @"");
    tableView.delegate = self;
    tableView.dataSource = self;   
    
    // Do any additional setup after loading the view from its nib.
    if(![AppDelegate isPurchased])
    {
        [self setRightClick:@"" buttonName:NSLocalizedString(@"Purchase", "") action:@selector(rightItemClickInAppPurchase:)];
    }
    else
    {
        tableView.separatorColor = [UIColor orangeColor];
        self.navigationItem.rightBarButtonItem = nil;
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)dealloc
{
    [_hud release];
    _hud = nil;
    self.tableView = nil;
    [super dealloc];
}


- (void)dismissHUD:(id)arg {
    
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    self.hud = nil;
    
}
- (void)updateInterfaceWithReachability: (Reachability*) curReach {   
    
}

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
#define kPurchaseConfirmIndex 1
    
    if(buttonIndex == kPurchaseConfirmIndex)
    {
        SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:0];
        
        NSLog(@"Buying %@...", product.productIdentifier);
        
        [[InAppRageIAPHelper sharedHelper] buyProduct:product];
        
        self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        _hud.labelText = NSLocalizedString(@"Purchasing","");
        [self performSelector:@selector(timeout:) withObject:nil afterDelay:60*5];
    }
}
- (NSString *)localizedPrice:(NSLocale *)priceLocale price:(NSDecimalNumber *)price
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:price];
    [numberFormatter release];
    return formattedString;
}
- (void)productsLoaded:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];   
    
    //purchase request
    SKProduct *product = [[InAppRageIAPHelper sharedHelper].products objectAtIndex:0];
    NSString* msg = [NSString stringWithFormat:@"%@(%@)",product.localizedDescription,[self localizedPrice:product.priceLocale price:product.price]];
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:product.localizedTitle message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel","") otherButtonTitles:NSLocalizedString(@"OK","") ,nil]autorelease];                              
    [alert show];     
}

- (void)timeout:(id)arg {
    
    _hud.labelText = @"Timeout,try again later.";
    //_hud.detailsLabelText = @"Please try again later.";
    //_hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	//_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

#pragma request purchase
// Add new method
-(IBAction)rightItemClickInAppPurchase:(id)sender
{   
    if ([AppDelegate isPurchased]) {
        //        NSString* ret = NSLocalizedString(@"try2delete", "");
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:@"purchased already" delegate:self cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];                              
        [alert show];    
        return;
    }     
    Reachability *reach = [Reachability reachabilityForInternetConnection];	
    NetworkStatus netStatus = [reach currentReachabilityStatus];    
    if (netStatus == NotReachable) {        
        NSLog(@"No internet connection!");        
    } else {        
        //if ([InAppRageIAPHelper sharedHelper].products == nil) 
        {
            
            [[InAppRageIAPHelper sharedHelper] requestProducts];
            self.hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
            _hud.labelText = NSLocalizedString(@"Loading","");
            [self performSelector:@selector(timeout:) withObject:nil afterDelay:30.0];            
        }        
    }
}

#pragma notification handler
- (void)productPurchased:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];    
    
    NSString *productIdentifier = (NSString *) notification.object;
    NSLog(@"Purchased: %@", productIdentifier);
    
    //hide purchase button
    self.navigationItem.rightBarButtonItem = nil;
    
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"purchased","") delegate:self cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];                              
    [alert show]; 
        
}

- (void)productPurchaseFailed:(NSNotification *)notification {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [MBProgressHUD hideHUDForView:self.navigationController.view animated:YES];
    
    SKPaymentTransaction * transaction = (SKPaymentTransaction *) notification.object;    
    if (transaction.error.code != SKErrorPaymentCancelled) {    
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Error!" 
                                                         message:transaction.error.localizedDescription 
                                                        delegate:nil 
                                               cancelButtonTitle:nil 
                                               otherButtonTitles:@"OK", nil] autorelease];
        
        [alert show];
    }
    
}


@end
