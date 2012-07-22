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


#define TOOLBARTAG		200
#define TABLEVIEWTAG	300


#define BEGIN_FLAG @"[/"
#define END_FLAG @"]"

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
    
    //remove cell's background
    [cell setBackgroundColor:[UIColor clearColor]];
    UIView* b = [[UIView alloc]init];
    [cell setBackgroundView:b];
    [b release];
    
    if (key) {
        BOOL fromSelf = (indexPath.section%2==0);
        //TODO::reuse bubbleView later
        UIView* bubbleView = [self bubbleView:NSLocalizedString(key, "") from:fromSelf];
        [cell.contentView addSubview:bubbleView];        
    }        
    return cell;
}
/*- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#define kVIPCell @"VIPCell"
#define kTextLaybleFlag 0x100
    UILabel* msgLabel = nil;
    UITableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kVIPCell];
    if (nil==cell) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kVIPCell]autorelease];
        msgLabel = [[[UILabel alloc] init] autorelease];
        msgLabel.tag = kTextLaybleFlag;
        [cell.contentView addSubview: msgLabel];
    }
    else
    {
        msgLabel = (UILabel*)[cell.contentView viewWithTag: kTextLaybleFlag];
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
        
        msgLabel.text = NSLocalizedString(key, "");
        msgLabel.numberOfLines = kMaxNumberOfLines;
        msgLabel.textColor = [UIColor blueColor];
        msgLabel.textAlignment = UITextAlignmentLeft;
        
        msgLabel.layer.borderColor = [UIColor grayColor].CGColor;
        msgLabel.layer.borderWidth = 1.0;
        msgLabel.layer.cornerRadius = 5.0; 
        
        //sizeToContent    
        CGSize txtSz = [msgLabel.text sizeWithFont:[UIFont fontWithName: @"Helvetica" size: 16]];        
        CGRect lblFrame = CGRectMake(0,0, txtSz.width, txtSz.height);
        //expand bounding box
#define kPaddingLR 10
#define kPaddingTB 10
        lblFrame.size.width += 2*kPaddingLR;
        lblFrame.size.height += 2*kPaddingTB;
        
#define kPaddingScreen 20
        UIColor* bgrColor = [UIColor whiteColor];
        //for even ones,align them on the right of the screen
        if (indexPath.section%2==0) {
            CGRect r = [[UIScreen mainScreen]applicationFrame];
            lblFrame.origin.x = r.size.width - lblFrame.size.width -kPaddingScreen;
            bgrColor = [UIColor yellowColor];            
        }
        
        //left origin & width
        if(lblFrame.origin.x < 0)
        {
            lblFrame.origin.x = kPaddingScreen;
        }
        const NSInteger kMaxWidth = [[UIScreen mainScreen]applicationFrame].size.width - 2*kPaddingScreen;
        if (lblFrame.size.width>kMaxWidth) {
            lblFrame.size.width = kMaxWidth;
        }
        
        msgLabel.frame = lblFrame;
        [msgLabel setBackgroundColor:bgrColor];
    }    
    
    return cell;
}*/

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
        self.tabBarItem.image = [UIImage imageNamed:@"ICN_brand_ON"];
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
    // Add inside viewWillAppear
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productsLoaded:) name:kProductsLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:kProductPurchasedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector: @selector(productPurchaseFailed:) name:kProductPurchaseFailedNotification object: nil]; 
    
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
    self.navigationItem.title = NSLocalizedString(kVIPFeatureListTitle, "");
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
    [[NSNotificationCenter defaultCenter]removeObserver:self];
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
#pragma  mark inapp purchase

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

#pragma mark request purchase
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


#pragma mark bubble support

//图文混排

-(void)getImageRange:(NSString*)message : (NSMutableArray*)array {
    NSRange range=[message rangeOfString: BEGIN_FLAG];
    NSRange range1=[message rangeOfString: END_FLAG];
    //判断当前字符串是否还有表情的标志。
    if (range.length>0 && range1.length>0) {
        if (range.location > 0) {
            [array addObject:[message substringToIndex:range.location]];
            [array addObject:[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)]];
            NSString *str=[message substringFromIndex:range1.location+1];
            [self getImageRange:str :array];
        }else {
            NSString *nextstr=[message substringWithRange:NSMakeRange(range.location, range1.location+1-range.location)];
            //排除文字是“”的
            if (![nextstr isEqualToString:@""]) {
                [array addObject:nextstr];
                NSString *str=[message substringFromIndex:range1.location+1];
                [self getImageRange:str :array];
            }else {
                return;
            }
        }
        
    } else if (message != nil) {
        [array addObject:message];
    }
}

#define KFacialSizeWidth  18
#define KFacialSizeHeight 18
#define MAX_WIDTH 150
-(UIView *)assembleMessageAtIndex : (NSString *) message from:(BOOL)fromself
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    [self getImageRange:message :array];
    UIView *returnView = [[UIView alloc] initWithFrame:CGRectZero];
    NSArray *data = array;
    UIFont *fon = [UIFont systemFontOfSize:13.0f];
    CGFloat upX = 0;
    CGFloat upY = 0;
    CGFloat X = 0;
    CGFloat Y = 0;
    if (data) {
        for (int i=0;i < [data count];i++) {
            NSString *str=[data objectAtIndex:i];
            NSLog(@"str--->%@",str);
            if ([str hasPrefix: BEGIN_FLAG] && [str hasSuffix: END_FLAG])
            {
                if (upX >= MAX_WIDTH)
                {
                    upY = upY + KFacialSizeHeight;
                    upX = 0;
                    X = 150;
                    Y = upY;
                }
                NSLog(@"str(image)---->%@",str);
                NSString *imageName=[str substringWithRange:NSMakeRange(2, str.length - 3)];
                UIImageView *img=[[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
                img.frame = CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight);
                [returnView addSubview:img];
                [img release];
                upX=KFacialSizeWidth+upX;
                if (X<150) X = upX;
                
                
            } else {
                for (int j = 0; j < [str length]; j++) {
                    NSString *temp = [str substringWithRange:NSMakeRange(j, 1)];
                    if (upX >= MAX_WIDTH)
                    {
                        upY = upY + KFacialSizeHeight;
                        upX = 0;
                        X = 150;
                        Y =upY;
                    }
                    CGSize size=[temp sizeWithFont:fon constrainedToSize:CGSizeMake(150, 40)];
                    UILabel *la = [[UILabel alloc] initWithFrame:CGRectMake(upX,upY,size.width,size.height)];
                    la.font = fon;
                    la.text = temp;
                    la.backgroundColor = [UIColor clearColor];
                    [returnView addSubview:la];
                    [la release];
                    upX=upX+size.width;
                    if (X<150) {
                        X = upX;
                    }
                }
            }
        }
    }
    returnView.frame = CGRectMake(15.0f,1.0f, X, Y); //@ 需要将该view的尺寸记下，方便以后使用
    NSLog(@"%.1f %.1f", X, Y);
    return returnView;
}

/*
 生成泡泡UIView
 */
#pragma mark -
#pragma mark Table view methods
- (UIView *)bubbleView:(NSString *)text from:(BOOL)fromSelf {
	// build single chat bubble cell with given text
    UIView *returnView =  [self assembleMessageAtIndex:text from:fromSelf];
    returnView.backgroundColor = [UIColor clearColor];
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectZero];
    cellView.backgroundColor = [UIColor clearColor];
    
	UIImage *bubble = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fromSelf?@"bubbleSelf":@"bubble" ofType:@"png"]];
	UIImageView *bubbleImageView = [[UIImageView alloc] initWithImage:[bubble stretchableImageWithLeftCapWidth:20 topCapHeight:14]];
    
    UIImageView *headImageView = [[UIImageView alloc] init];
    
    if(fromSelf){
        [headImageView setImage:[UIImage imageNamed:@"face_test.png"]];
        returnView.frame= CGRectMake(9.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(0.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f );
        cellView.frame = CGRectMake(265.0f-bubbleImageView.frame.size.width, 0.0f,bubbleImageView.frame.size.width+50.0f, bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(bubbleImageView.frame.size.width, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
	else{
        [headImageView setImage:[UIImage imageNamed:@"default_head_online.png"]];
        returnView.frame= CGRectMake(65.0f, 15.0f, returnView.frame.size.width, returnView.frame.size.height);
        bubbleImageView.frame = CGRectMake(50.0f, 14.0f, returnView.frame.size.width+24.0f, returnView.frame.size.height+24.0f);
		cellView.frame = CGRectMake(0.0f, 0.0f, bubbleImageView.frame.size.width+30.0f,bubbleImageView.frame.size.height+30.0f);
        headImageView.frame = CGRectMake(0.0f, cellView.frame.size.height-50.0f, 50.0f, 50.0f);
    }
    
    
    
    [cellView addSubview:bubbleImageView];
    [cellView addSubview:headImageView];
    [cellView addSubview:returnView];
    [bubbleImageView release];
    [returnView release];
    [headImageView release];
	return [cellView autorelease];
    
}

@end
