//
//  AccountDetailController.m
//  AccountSafe
//
//  Created by li ming on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountDetailController.h"
#import "AccountInfo.h"
#import "AppDelegate.h"
#import <QuartzCore/QuartzCore.h>
#import "ProtocolLogManager.h"


@interface AccountDetailController()

-(NSString*)validValues;
-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action;
-(void)accountInfoChanged;
-(void)addAccountinfoChangedNotification;

@end

@implementation AccountDetailController
@synthesize name;
@synthesize account;
@synthesize password;

@synthesize nameLabel;
@synthesize accountLabel;
@synthesize passwordLabel;
@synthesize noteLabel;

@synthesize note;
@synthesize alarmEnable;
@synthesize date;
@synthesize time;
@synthesize accountInfo;

- (id)initWithAccountInfo:(NSInteger)accountType accountInfo:(id)data nibNameOrNil:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    _accountType = accountType;
    self.accountInfo = data;
    return [self initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)dealloc
{
    self.accountInfo = nil;
    [super dealloc];
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
// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField)
    {
        [textField resignFirstResponder];
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if([text isEqualToString:@"\n"])
    {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}
-(void)accountInfoChanged
{
    if(self.accountInfo!=nil)
    {
        [self setRightClick:NSLocalizedString(@"CFBundleDisplayName", @"") buttonName:NSLocalizedString(@"Save",@"") action:(@selector(rightItemClickSave:))];
    }
}
-(void)addAccountinfoChangedNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(accountInfoChanged) name:UITextFieldTextDidChangeNotification object:name];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(accountInfoChanged) name:UITextFieldTextDidChangeNotification object:account];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(accountInfoChanged) name:UITextFieldTextDidChangeNotification object:password];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(accountInfoChanged) name:UITextViewTextDidChangeNotification object:note];
}
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addAccountinfoChangedNotification];
    
    //init
    if(self.accountInfo && [self.accountInfo isKindOfClass:[AccountInfo class]])
    {
        AccountInfo* info = (AccountInfo*)self.accountInfo;
        name.text = info.name;
        account.text = info.account;
        password.text = info.password;
        note.text = info.tag;
    }
    
    self.nameLabel.text = NSLocalizedString(@"Name", "");    
    name.delegate = self;
    name.returnKeyType = UIReturnKeyDone;
    name.placeholder = NSLocalizedString(@"requiredPlaceholder", "");
    
    self.accountLabel.text = NSLocalizedString(@"Account", "");   
    account.delegate = self;
    account.placeholder = NSLocalizedString(@"requiredPlaceholder", "");
    account.returnKeyType = UIReturnKeyDone;
    
    self.passwordLabel.text = NSLocalizedString(@"Password", "");   
    password.delegate = self;
    password.placeholder = NSLocalizedString(@"optional", "");
    password.returnKeyType = UIReturnKeyDone;
    
    self.noteLabel.text = NSLocalizedString(@"Note", "");   
    note.delegate = self;
    note.layer.borderColor = [UIColor grayColor].CGColor;
    note.layer.borderWidth = 1.0;
    note.layer.cornerRadius = 5.0;
    
    BOOL modify = (self.accountInfo!=nil);    
    SEL action = modify?@selector(rightItemClickDelete:):@selector(rightItemClickSave:);
    NSString* buttonName = NSLocalizedString(modify?@"Delete":@"Save",@"");
    [self setRightClick:NSLocalizedString(@"CFBundleDisplayName", @"") buttonName:buttonName action:action];
}

-(void)setRightClick:(NSString*)title buttonName:(NSString*)buttonName action:(SEL)action
{
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:buttonName style:UIBarButtonItemStyleBordered target:self action:action];
    self.navigationItem.rightBarButtonItem = rightItem;
    self.navigationItem.title = title;    
    [rightItem release];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    
}
// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{   
#define kDeleteIndex 0
    
    if(buttonIndex == kDeleteIndex)
    {
        ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
        [mgr removeObject:self.accountInfo];
        [self.navigationController popViewControllerAnimated:YES];
    }
}
-(IBAction)rightItemClickDelete:(id)sender
{
    //pop alertview for tip
    NSString* ret = NSLocalizedString(@"try2delete", "");
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"" message:ret delegate:self cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:NSLocalizedString(@"Cancel",""),nil]autorelease];                              
    [alert show];    
    
}
-(IBAction)rightItemClickSave:(id)sender
{
    //get info and validate them            
    NSString* ret = [self validValues];
    if(ret.length == 0)
    {
        //save to core datas  
        BOOL update = (self.accountInfo!=nil);
        AccountInfo* info = nil;
        if (update) {
            info = self.accountInfo;
        }
        else
        {
            NSManagedObjectContext* managedObjectContext = MANAGED_CONTEXT;
            info = (AccountInfo*)[NSEntityDescription insertNewObjectForEntityForName:kAccountInfo inManagedObjectContext:managedObjectContext];   
        }
        
        info.name = name.text;
        info.account = account.text;
        info.password = password.text;
        info.tag = note.text; 
        info.type = [NSNumber numberWithInt:_accountType];
        info.alarm = [NSDate date];
        
        ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
        if (update) {
            [mgr replaceObject:info];
        }
        else
        {
            [mgr addObject:info];   
        }    
        
        
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //pop alertview for tip
        UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_data_title", "") message:ret delegate:nil cancelButtonTitle:NSLocalizedString(@"OK","") otherButtonTitles:nil]autorelease];                              
        [alert show];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 return:@"" for success,else return tip string for user
 */
-(NSString*)validValues
{
    //validate values
    NSMutableString* errString = [[[NSMutableString alloc]init]autorelease];
    if (name.text.length==0) {
        [errString appendString:NSLocalizedString(@"NullName","")];
        [errString appendString:@"\n"];
    }
    
    if (account.text.length==0) {
        [errString appendString:NSLocalizedString(@"NullAccount","")];
        [errString appendString:@"\n"];        
    }
    
    /*if (password.text.length==0) {
        [errString appendString:NSLocalizedString(@"NullPassword","")];
        [errString appendString:@"\n"];        
    }*/
    
    return errString;
}

@end
