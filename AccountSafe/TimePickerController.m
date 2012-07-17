//
//  TimePickerController.m
//  AccountSafe
//
//  Created by Lee Ramon on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TimePickerController.h"
#import "AccountDetailController.h"

#define kDatePicker 0
#define kTimePicker 1

//date formatter
#define kDateFormatHHmm @"HH:mm"
#define kDateFormatYMD @"yyyy-MM-dd"
#define kDateFormatYMDHHmm @"yyyy-MM-dd HH:mm"
#define kBlank @" "

@interface TimePickerController ()
-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action;
-(IBAction)saveAlarm:(id)sender;
@end

@implementation TimePickerController

@synthesize tableView;
@synthesize timePicker;
@synthesize datePicker;
@synthesize alarmTimeSet;

-(void)dealloc
{
    [tableView release];
    [datePicker release];
    [timePicker release];
    [super dealloc];
}

+(NSString*)stringFromDate:(NSDate*)date string:(NSString*)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    NSString* r = [dateFormatter stringFromDate:date];
    [dateFormatter release];
    return r;
}
+(NSDate*)dateFromString:(NSString*)date string:(NSString*)format
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:format];
    NSDate* r = [dateFormatter dateFromString:date];
    [dateFormatter release];
    return r;
}

-(void)timeValueChanged:(id)sender
{
    //datepicker or timepicker
    [tableView reloadData];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setRightClick:@"" buttonName:NSLocalizedString(@"Save", "") action:@selector(saveAlarm:)];
    //_accountData = [AccountData shareInstance];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    datePicker.datePickerMode = UIDatePickerModeDate;
    datePicker.hidden = NO;
    datePicker.date = alarmTimeSet;
    [datePicker addTarget:self action:@selector(timeValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    timePicker.datePickerMode = UIDatePickerModeTime;
    timePicker.hidden = YES;
    timePicker.date = alarmTimeSet;
    [timePicker addTarget:self action:@selector(timeValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    tableView.delegate = self;
    tableView.dataSource = self;    

    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    NSLog(@"alarmTimeSet:%@",alarmTimeSet);

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableViewIn cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableViewIn dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier]autorelease];
    }
    
    cell.textLabel.textAlignment = UITextAlignmentCenter;
    if(indexPath.row == kDatePicker)
    {
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateStyle = NSDateFormatterMediumStyle;
        cell.textLabel.text = [NSString stringWithFormat:@"%@",
                          [df stringFromDate:datePicker.date]];
        [df release];
    }
    else {   
        cell.textLabel.text = [TimePickerController stringFromDate:timePicker.date string:kDateFormatHHmm];
    }
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //first row selected,show datepicker else timepicker
    if (indexPath.row==kDatePicker) {
        datePicker.hidden = NO;
        timePicker.hidden = YES;
    }
    else {
        datePicker.hidden = YES;
        timePicker.hidden = NO;
    }
}

-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:buttonName style:UIBarButtonItemStyleBordered target:self action:action];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = title;    
    [rightItem release];
}
-(IBAction)saveAlarm:(id)sender
{ 
    //TODO::save alarm ,global account data?
    NSDate* date = [datePicker date];
    NSDate* time = [timePicker date];
    NSLog(@"date:%@,time:%@",date,time);
       
    
    NSMutableString* alarmTimeString = [[NSMutableString alloc]init]; 
    [alarmTimeString appendString:[TimePickerController stringFromDate:date string:kDateFormatYMD]];
    [alarmTimeString appendString:kBlank];     
    [alarmTimeString appendString:[TimePickerController stringFromDate:time string:kDateFormatHHmm]];
  
    NSDate* alarm = [TimePickerController dateFromString:alarmTimeString string:kDateFormatYMDHHmm];
    NSLog(@"alarm:%@",alarm);
    [alarmTimeString release];
        
    NSDictionary *aUserInfo = [[NSDictionary alloc]initWithObjectsAndKeys:alarm,kAlarmTime, nil ];
    [[NSNotificationCenter defaultCenter]postNotificationName:kAlarmTimeNotification object:self userInfo:aUserInfo];
    [aUserInfo release];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
