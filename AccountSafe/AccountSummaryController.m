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


#define kTitleRow 0
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
    UIColor* color = [UIColor whiteColor];   
    
    UIView* backgroundView = [[UIView alloc]initWithFrame:cell.frame];
    backgroundView.backgroundColor = color;
    cell.backgroundView = backgroundView;
    [backgroundView release];
    
    
    
    return cell;
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
-(IBAction)addAccountCategory:(id)sender
{
    //TODO::parse current xml from directory and append this new one
    //save to file
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
    self.title = NSLocalizedString(@"TabTitleSummary", "");
    //self.navigationItem.hidesBackButton = YES;
    [self setRightClick:@"" buttonName:NSLocalizedString(@"Add", "") action:@selector(addAccountCategory:)];
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
