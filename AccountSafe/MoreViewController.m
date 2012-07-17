//
//  MoreViewController.m
//  AccountSafe
//
//  Created by Lee Ramon on 7/17/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MoreViewController.h"
#import "AppDelegate.h"

@interface MoreViewController ()

@end

@implementation MoreViewController
@synthesize tableView;

#define kMoreFeatureCount 2
#define kMoreAbout 0
#define kMoreFeedBack 1

#define kMoreAboutKey @"kMoreAboutKey"
#define kMoreFeedBackKey @"kMoreFeedBackKey"

#pragma  mark tableview datasource 
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kMoreFeatureCount;
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
        cell = [[[UITableViewCell alloc]init]autorelease];
    }
    
    //1 category edit
    //1.1add new category count
    //1.2delete category
    NSString* key = nil;
    
    //2.alarm to change passcode    
    switch (indexPath.section) {
        case kMoreAbout:
            key = kMoreAboutKey;
            break;
        case kMoreFeedBack:
            key = kMoreFeedBackKey;
            break;        
        default:
            break;
    }
    
    if (key) {
        cell.textLabel.text = NSLocalizedString(key, "");
    }    
    
    return cell;
}
#pragma mark about
- (IBAction)modalViewAction:(id)sender
{
    UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"AboutTitle", @"") message:NSLocalizedString(@"About", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
    [alert show];
    [alert release];
}

#pragma mark tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kMoreAbout:
            [self modalViewAction:nil];
            break;
        case kMoreFeedBack:
            [self feedback:nil];
            break;        
        default:
            break;
    }
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization        
        self.title = NSLocalizedString(@"TabTitleMore", "");
        self.tabBarItem.image = [UIImage imageNamed:@"third"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = NSLocalizedString(@"CFBundleDisplayName", @"");
    tableView.delegate = self;
    tableView.dataSource = self;
    if([AppDelegate isPurchased])    
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark -
#pragma mark Workaround

- (void)mailComposeController:(MFMailComposeViewController*)controller             didFinishWithResult:(MFMailComposeResult)result                          error:(NSError*)error;
{   
    if (result == MFMailComposeResultSent) 
    {    
        UIAlertView* alert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"EmailAlertViewTitle", @"") message:NSLocalizedString(@"EmailAlertViewMsg", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK",@"") otherButtonTitles:nil];
        [alert show];
        [alert release];
    }  
    [self dismissModalViewControllerAnimated:YES]; 
} 

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice:(BOOL)feeback
{
    //    NSString *recipients = @"mailto:first@example.com?cc=second@example.com,third@example.com&subject=Hello from California!";
    //    NSString *body = @"&body=It is raining in sunny California!";
    
    NSString * email = [NSString stringWithFormat:@"mailto:&subject=%@&body=%@", NSLocalizedString(@"CFBundleDisplayName", @""), @""];
    email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}


#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet:(BOOL)feedback 
{
    MFMailComposeViewController *picker = [[[MFMailComposeViewController alloc] init]autorelease];
    picker.mailComposeDelegate = self;
    
    [picker setSubject:NSLocalizedString(@"CFBundleDisplayName", @"")];    
    [picker setMessageBody:@"" isHTML:YES];     
    
    // Set up recipients
    //    NSArray *toRecipients = [NSArray arrayWithObject:@"first@example.com"]; 
    //    NSArray *bccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil]; 
    NSArray *recipients = [NSArray arrayWithObject:@"ramonqlee1980@gmail.com"]; 
    
    //    
    //    [picker setToRecipients:toRecipients];
    [picker setToRecipients:recipients]; 
    
    [self presentModalViewController:picker animated:YES];
}
-(IBAction)feedback:(id)sender
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (mailClass != nil)
    {
        // We must always check whether the current device is configured for sending emails
        if ([mailClass canSendMail])
        {
            [self displayComposerSheet:YES];
        }
        else
        {
            [self launchMailAppOnDevice:YES];
        }
    }
    else
    {
        [self launchMailAppOnDevice:YES];
    }
}
@end
