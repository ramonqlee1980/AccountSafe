//
//  PatternLockAppViewController.m
//  PatternLockApp
//
//  Created by Purnama Santo on 11/4/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PatternLockAppViewController.h"
#import "DrawPatternLockViewController.h"
#import "AccountData.h"
#import "VIPController.h"
#import "AccountSummaryController.h"
#import "MoreViewController.h"

@implementation PatternLockAppViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    BOOL setPW = ([AccountData getOpenDoorKey].length==0);
    if (!setPW) {
        [self lockClicked:nil];
        return;
    }
    NSString* title = NSLocalizedString(setPW?@"Set":@"Enter",@"");
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:title style:UIBarButtonItemStyleBordered target:self action:@selector(lockClicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = NSLocalizedString(@"CFBundleDisplayName", @""); 
    
    [rightItem release];   

}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return NO;
}


- (void)lockEntered:(NSString*)key {
    NSLog(@"key: %@", key);
#if 1
    BOOL pwRight = YES;
    NSString* pw = [AccountData getOpenDoorKey];
    NSLog(@"passcode:%@",pw);
    if (!pw.length) {
        pwRight = (key.length!=0);
    }    
    else
    {
        pwRight = [key isEqualToString:pw];
    }
    if (pwRight)
    {
        [self dismissModalViewControllerAnimated:YES];
        
        self.navigationController.navigationBarHidden = YES;
        
        [AccountData setOpenDoorKey:key];
        UIViewController* accountPageController = [[AccountSummaryController alloc]initWithNibName:@"AccountSummaryView" bundle:nil];
        UINavigationController* accountPageControllerNavi = [[UINavigationController alloc]initWithRootViewController:accountPageController];
        
        UIViewController* vipCtrl = [[VIPController alloc]initWithNibName:@"VIPController" bundle:nil];
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
        NSString* err = (key.length==0)?NSLocalizedString(@"NullPassword", ""):NSLocalizedString(@"WrongPassword", "");
        //pop alertview for tip
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:err delegate:nil cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];                              
        [alert show];
    }
    
#else
    if (![key isEqualToString:@"0102030609"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Wrong pattern!"
                                                           delegate:nil
                                                  cancelButtonTitle:nil 
                                                  otherButtonTitles:@"OK", nil];
        [alertView show];
    }
    else
        [self dismissModalViewControllerAnimated:YES];
#endif
}


- (IBAction)lockClicked:(id)sender {    
    DrawPatternLockViewController *lockVC = [[DrawPatternLockViewController alloc] init];
    [lockVC setTarget:self withAction:@selector(lockEntered:)];
    [self presentModalViewController:lockVC animated:YES];}

@end
