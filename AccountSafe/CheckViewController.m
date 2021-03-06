//
//  ViewController.m
//  AccountSafe
//
//  Created by li ming on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "CheckViewController.h"
#import "AccountData.h"
#import "VIPController.h"
#import "AccountSummaryController.h"
#import "MoreViewController.h"
#import "SoftRcmListViewController.h"
#import "constants.h"

@implementation CheckViewController

#pragma mark - Low Memory 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField)
    {
        [textField resignFirstResponder];
    }
    [self rightItemClick:self];
    return YES;
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mPassword.delegate = self;
    mPassword.returnKeyType = UIReturnKeyDone;
    mPassword.placeholder = NSLocalizedString(@"enterPasswordPlaceholder", "");
    [mPassword becomeFirstResponder];  
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    //if password set,display login,else display set  
    
}


-(IBAction)rightItemClick:(id)sender
{
    //check password & enter accountSummary view
    //no 
    BOOL pwRight = YES;
    NSString* pw = [AccountData getOpenDoorKey];
    NSLog(@"passcode:%@",pw);
    if (!pw.length) {
        pwRight = (mPassword.text.length!=0);
    }    
    else
    {
        pwRight = [mPassword.text isEqualToString:pw];
    }
    if (pwRight)
    {
        self.navigationController.navigationBarHidden = YES;
        
        [AccountData setOpenDoorKey:mPassword.text];
        mPassword.text = @"";
        UIViewController* accountPageController = [[AccountSummaryController alloc]initWithNibName:@"AccountSummaryView" bundle:nil];
        UINavigationController* accountPageControllerNavi = [[UINavigationController alloc]initWithRootViewController:accountPageController];
#ifndef k91Appstore
        UIViewController* vipCtrl = [[VIPController alloc]initWithNibName:@"VIPController" bundle:nil];
#else
        UIViewController* vipCtrl = [[SoftRcmListViewController alloc]initWithStyle:UITableViewStyleGrouped];    
#endif
        UINavigationController* vipNavi = [[UINavigationController alloc]initWithRootViewController:vipCtrl];  
        
        UIViewController* moreCtrl = [[MoreViewController alloc]initWithNibName:@"MoreViewController" bundle:nil];
        UINavigationController* moreNavi = [[UINavigationController alloc]initWithRootViewController:moreCtrl];  
        
        //add tabcontroller
        NSMutableArray* ctrls = [[NSMutableArray alloc]initWithObjects:accountPageControllerNavi,vipNavi,moreNavi, nil];       
        
        UITabBarController* tabCtrl = [[UITabBarController alloc]init];
        [tabCtrl setViewControllers:ctrls];
                
        [self.navigationController pushViewController:tabCtrl animated:YES];
        
        
        [accountPageControllerNavi release];
        [vipNavi release];
        [vipCtrl release];
        [accountPageController release];
        [ctrls release];
        [tabCtrl release];
        [moreCtrl release];
        [moreNavi release];
    }
    else
    {
        //not set password
        NSString* err = (mPassword.text.length==0)?NSLocalizedString(@"NullPassword", ""):NSLocalizedString(@"WrongPassword", "");
        //pop alertview for tip
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:err delegate:nil cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];                              
        [alert show];
    }
}
- (void)viewWillAppear:(BOOL)animated
{
    BOOL setPW = ([AccountData getOpenDoorKey].length==0);
    NSString* title = NSLocalizedString(setPW?@"Set":@"Enter",@"");
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(rightItemClick:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = NSLocalizedString(@"CFBundleDisplayName", @"");    
    [rightItem release];
    
    if (![mPassword isFirstResponder]) {
        [mPassword becomeFirstResponder];
    }
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}

@end
