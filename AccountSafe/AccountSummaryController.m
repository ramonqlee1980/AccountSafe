//
//  AccountSummaryController.m
//  AccountSafe
//
//  Created by li ming on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountSummaryController.h"
#import "AccountDetailController.h"
#import "AccountData.h"
#import "AccountInfo.h"
#import "ProtocolLogManager.h"
#import "Reachability.h"
#import "InAppRageIAPHelper.h"
#import "MBProgressHUD.h"
#import "AppDelegate.h"

#define kTitleRow 0
#define kTitleFontSize 20
#define kDetailFontSize 12
#define kTopMargin 5
#define kFreeListMaxSectionIndex 5


@interface AccountSummaryController()
-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action;
+(BOOL)isPurchased;
+(BOOL)isSectionAvailable:(NSUInteger)section;
- (NSString *)localizedPrice:(NSLocale *)priceLocale price:(NSDecimalNumber *)price;
@end


@implementation AccountSummaryController
@synthesize tableView=_tableView;
@synthesize hud = _hud;

#pragma in-app purchase
-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:buttonName style:UIBarButtonItemStyleBordered target:self action:action];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = title;    
    [rightItem release];
}

#pragma tableview datasource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_accountData numberOfSections];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger c = [_accountData numberOfRowsInSection:section];
    NSLog(@"numberOfRowsInSection:%d-%d",section,c);
    return c;//extra one for title display
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define kAccountTitleCell @"AccountTitleCell"
#define kAccountDetailCell @"AccountDetailCell"
    //#define SECONDLABEL_TAG 2
    NSString* cellIdentifier = (indexPath.row==kTitleRow)?kAccountTitleCell:kAccountDetailCell;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel* accessoryLabel = nil;
    if (cell==nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier]autorelease];        
        //Add layout code here
        if(indexPath.row==kTitleRow)
        {
            //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            accessoryLabel= [[[UILabel alloc]initWithFrame:CGRectMake(0.0, 0.0, self.tableView.rowHeight-kTopMargin, self.tableView.rowHeight-kTopMargin)]autorelease];
            //accessoryLabel.tag = SECONDLABEL_TAG;           
            cell.accessoryView = accessoryLabel;
        }
    }
    else
    {
        if (indexPath.row ==  kTitleRow) {
            accessoryLabel = [cell.accessoryView isKindOfClass:[UILabel class]]?(UILabel*)cell.accessoryView:nil;
        }
    }
    
    NSLog(@"cellForRowAtIndexPath:%d-%d",indexPath.section,indexPath.row);
    
    //for the first row,display the title for this section
    //others for row data
    if(indexPath.row == kTitleRow)
    {
        NSString* sectionName = [_accountData nameOfSection:indexPath.section];
        //id rowData = [_accountData objectOfRow:indexPath.row inSection:indexPath.section];
        //data initialization
        // Configure the data for the cell. 
        NSString* iconName = [_accountData nameOfSectionIcon:indexPath.section];     
        NSString *iconPath = [[NSBundle mainBundle] pathForResource:[iconName lowercaseString] ofType:@"png"];
        cell.imageView.image = [[[UIImage alloc]initWithContentsOfFile:iconPath]autorelease];
        cell.imageView.backgroundColor = [UIColor clearColor];
        NSLog(@"rowHeight:%f", self.tableView.rowHeight);
        
        cell.textLabel.text = sectionName;  
        cell.textLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        cell.textLabel.textColor = [UIColor blueColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        if(accessoryLabel)
        {
            accessoryLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
            accessoryLabel.textAlignment = UITextAlignmentRight;
            accessoryLabel.textColor = [UIColor greenColor];
            accessoryLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
            accessoryLabel.text = @"+ ";
            accessoryLabel.backgroundColor = [UIColor clearColor];
        }     
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else
    {
        AccountInfo* rowData = [_accountData objectOfRow:indexPath.row inSection:indexPath.section];
        //data initialization
        cell.textLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Name", ""),rowData.name];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
        cell.textLabel.textColor = [UIColor orangeColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Account", ""),rowData.account];
        cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView.backgroundColor = [UIColor clearColor];
    }
    NSLog(@"cellForRowAtIndexPath:%@",cell.textLabel.text );    
    
    //disable some sections for trial version
    UIColor* color = [AccountSummaryController isSectionAvailable:indexPath.section]?[UIColor whiteColor]:[UIColor brownColor];   
    
    UIView* backgroundView = [[UIView alloc]initWithFrame:cell.frame];
    backgroundView.backgroundColor = color;
    cell.backgroundView = backgroundView;
    [backgroundView release];
    
    
    
    return cell;
}
+(BOOL)isSectionAvailable:(NSUInteger)section
{
    return ([AccountSummaryController isPurchased]||(section < kFreeListMaxSectionIndex && (![AccountSummaryController isPurchased])));
}
+(BOOL)isPurchased
{
    BOOL r = [[InAppRageIAPHelper sharedHelper].purchasedProducts containsObject:kInAppPurchaseProductName];   
    NSLog(@"isPurchased:%d",r);
    return r;
}

#pragma tableview delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath.row != kTitleRow);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != kTitleRow && editingStyle == UITableViewCellEditingStyleDelete) {
        AccountInfo* info = [_accountData objectOfRow:indexPath.row inSection:indexPath.section]; 
        ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
        [mgr removeObject:info];
        
        [_accountData release];
        _accountData = [[AccountData alloc]init];
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if first row is selected,add a new typed acccount
    //else open review view
    NSLog(@"didSelectRowAtIndexPath:%d-%d",indexPath.section,indexPath.row);
    if([AccountSummaryController isSectionAvailable:indexPath.section])
    {
        AccountInfo* info = (indexPath.row==kTitleRow)?nil:[_accountData objectOfRow:indexPath.row inSection:indexPath.section];
        AccountDetailController* d = [[AccountDetailController alloc]initWithAccountInfo:indexPath.section accountInfo:info nibNameOrNil:@"AccountDetailView" bundle:nil];
        [self.navigationController pushViewController:d animated:YES];
        [d release];
    }
    else
    {
        [self rightItemClickInAppPurchase:nil];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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

/*
 // Implement loadView to create a view hierarchy programmatically, without using a nib.
 - (void)loadView
 {
 }
 */


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{    
    self.navigationItem.title = NSLocalizedString(@"CFBundleDisplayName", @"");    
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back",@"") style: UIBarButtonItemStyleBordered target: nil action: nil];  
    self.navigationItem.backBarButtonItem = newBackButton;
    [newBackButton release];
    
    
    
    _accountData = [[AccountData alloc]init];
    
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if(!_accountData)
    {
        _accountData = [[AccountData alloc]init];
        [_tableView reloadData];
    }
    
    //app is purchased?   
    if(![AccountSummaryController isPurchased])  
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil];
        
        
        NSString* buttonName = NSLocalizedString(@"Purchase",@"");
        [self setRightClick:NSLocalizedString(@"CFBundleDisplayName", @"") buttonName:buttonName action:@selector(rightItemClickInAppPurchase:)];
    }
    else
    {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [_accountData release];
    _accountData = nil;
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [_accountData release];
    _accountData = nil;
    [_tableView release];
    [_hud release];
    _hud = nil;
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    
    _hud.labelText = @"Timeout! Please try again later.";
    //_hud.detailsLabelText = @"Please try again later.";
    //_hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
	//_hud.mode = MBProgressHUDModeCustomView;
    [self performSelector:@selector(dismissHUD:) withObject:nil afterDelay:3.0];
    
}

#pragma request purchase
// Add new method
-(IBAction)rightItemClickInAppPurchase:(id)sender
{   
    if ([AccountSummaryController isPurchased]) {
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
    
    [self.tableView reloadData];
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
