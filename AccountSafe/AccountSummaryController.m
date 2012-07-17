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
#import "GDataXMLNode.h"
#import "constants.h"
#import "AppDelegate.h"


#define kTitleRow 0
#define kCategoryRowStart (kTitleRow+1)
#define kTitleFontSize 20
#define kDetailFontSize 12
#define kTopMargin 5


@implementation AccountSummaryController
@synthesize tableView=_tableView;



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
        NSLog(@"rowHeight:%f", self.tableView.rowHeight);
        
        cell.textLabel.text = sectionName;  
        cell.textLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        cell.textLabel.textColor = [UIColor blueColor];
        
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
        
        
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@%@",NSLocalizedString(@"Account", ""),rowData.account];
        cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
        cell.detailTextLabel.font = [UIFont systemFontOfSize:kDetailFontSize];
        cell.detailTextLabel.textColor = [UIColor orangeColor];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    NSLog(@"cellForRowAtIndexPath:%@",cell.textLabel.text );   
    
    
    return cell;
}


#pragma tableview delegate
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return TRUE;//(indexPath.row != kTitleRow);
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if(indexPath.row == kTitleRow)
        {
            VIP_FEATURES_TIP
            //remove from coredata starting from 1 to max row
            AccountInfo* info = nil;
            NSInteger rowCount = [_accountData numberOfRowsInSection:indexPath.section];            
            if(rowCount>kCategoryRowStart)
            {
                ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
                for (NSInteger i = kCategoryRowStart; i < rowCount; ++i) {
                    info = [_accountData objectOfRow:i inSection:indexPath.section];
                    [mgr removeObject:info];
                }
            }
            
            [_accountData removeSectionAtIndex:indexPath.section];
            [self persistentCategoryData];
            [self.tableView reloadData];
        }
        else {
            AccountInfo* info = [_accountData objectOfRow:indexPath.row inSection:indexPath.section]; 
            ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
            [mgr removeObject:info];
            
            [_accountData removeObjectAtRow:indexPath.row inSection:indexPath.section];
            
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if first row is selected,add a new typed acccount
    //else open review view
    UIBarButtonItem *back = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Back", "") style:UIBarButtonItemStyleBordered target:nil action:nil];
    self.navigationItem.backBarButtonItem = back;
    [back release];
    
    NSLog(@"didSelectRowAtIndexPath:%d-%d",indexPath.section,indexPath.row);
    AccountInfo* info = (indexPath.row==kTitleRow)?nil:[_accountData objectOfRow:indexPath.row inSection:indexPath.section];
    AccountDetailController* d = [[AccountDetailController alloc]initWithAccountInfo:indexPath.section accountInfo:info nibNameOrNil:@"AccountDetailView" bundle:nil];
    [self.navigationController pushViewController:d animated:YES];
    [d release];
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = NSLocalizedString(@"TabTitleSummary", "");
        self.tabBarItem.image = [UIImage imageNamed:@"first"];
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
-(void)persistentCategoryData
{    
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString* xmlFileName = [[delegate applicationDocumentsDirectory]stringByAppendingPathComponent:kAccountCategoryFileNameWithSuffix];
    [_accountData writeToFile:xmlFileName atomically:YES];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
#define kOK 1
    if (buttonIndex == kOK) {
        UITextField* f = nil;//[alertView textFieldAtIndex:0];
        //find textfield
        NSArray* subviews = [alertView subviews];
        for (id view in subviews) {
            if([view isKindOfClass:[UITextField class]])
            {
                f = (UITextField*)view;
                break;
            }
        }
        if (nil==f || nil == f.text || 0 == f.text.length) {
            return;
        }
        NSString* newName = f.text;
        NSString* newIcon = @"temp";
        if([_accountData addSection:newName icon:newIcon])
        {
            [self persistentCategoryData];
            
            //refresh data
            [self.tableView reloadData];
        }
        else
        {
            //conflicted name in this section 
            UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"duplicatedAccountCategory", "") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];                              
            [alert show];
        }
    }
}
-(IBAction)addAccountCategory:(id)sender
{
    VIP_FEATURES_TIP;
    // Ask for Username and password.
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"NewAccountCategory", "") message:@"\n" delegate:self cancelButtonTitle:NSLocalizedString(@"Cancel", "") otherButtonTitles:NSLocalizedString(@"OK", ""), nil];
    // Adds a username Field
    UITextField* utextfield = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
    utextfield.placeholder = NSLocalizedString(@"Name", "");
    [utextfield setBackgroundColor:[UIColor whiteColor]];
    utextfield.enablesReturnKeyAutomatically = YES;
    [utextfield setReturnKeyType:UIReturnKeyDone];    
    [utextfield performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0.05];    
    [alertView addSubview:utextfield];
    [utextfield release];
    
    // Show alert on screen.
    [alertView show];
    [alertView release];
}
-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:buttonName style:UIBarButtonItemStyleBordered target:self action:action];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = title;    
    [rightItem release];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{      
    //self.navigationItem.hidesBackButton = YES;
    [self setRightClick:@"" buttonName:NSLocalizedString(@"Add", "") action:@selector(addAccountCategory:)];
    _accountData = [AccountData shareInstance];
    
    self.tabBarController.hidesBottomBarWhenPushed = YES;
    
    if([AppDelegate isPurchased])
    {
        self.tableView.separatorColor = [UIColor orangeColor];
    }
    
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
        _accountData = [AccountData shareInstance];
        [_tableView reloadData];
    }     
    [super viewWillAppear:animated];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [_accountData release];
    _accountData = nil;
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    [_accountData release];
    _accountData = nil;
    [_tableView release];
    
    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
