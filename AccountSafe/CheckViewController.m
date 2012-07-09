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

@implementation CheckViewController
#import "AccountSummaryController.h"


#pragma lowmemory 
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
    
	// Do any additional setup after loading the view, typically from a nib.
    
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Back",@"") style: UIBarButtonItemStyleBordered target: nil action: nil];  
    self.navigationItem.backBarButtonItem = newBackButton;
    [newBackButton release];
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
    if (!pw.length) {
        pwRight = (mPassword.text.length!=0);
    }    
    else
    {
        pwRight = [mPassword.text isEqualToString:pw];
    }
    if (pwRight)
    {
        [AccountData setOpenDoorKey:mPassword.text];
        mPassword.text = @"";
        UIViewController* accountPageController = [[AccountSummaryController alloc]initWithNibName:@"AccountSummaryView" bundle:nil];
        
        UIViewController* vipCtrl = [[VIPController alloc]initWithNibName:@"VIPController" bundle:nil];
        UINavigationController* vipNavi = [[UINavigationController alloc]initWithRootViewController:vipCtrl];        
        //add tabcontroller
        NSMutableArray* ctrls = [[NSMutableArray alloc]initWithObjects:accountPageController,vipNavi, nil];       
        
        UITabBarController* tabCtrl = [[UITabBarController alloc]init];
        tabCtrl.viewControllers = ctrls;
                
        [self.navigationController pushViewController:tabCtrl animated:YES];
        
        [vipNavi release];
        [vipCtrl release];
        [accountPageController release];
        [ctrls release];
        [tabCtrl release]; 
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
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
