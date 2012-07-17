//
//  AccountDetailController.h
//  AccountSafe
//
//  Created by li ming on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAlarmTimeNotification @"alarmtime"
#define kAlarmTime @"alarmTimeSet" 


//date formatter
#define kDateFormatHHmm @"HH:mm"
#define kDateFormatYMD @"yyyy-MM-dd"
#define kDateFormatYMDHHmm @"yyyy-MM-dd HH:mm"
#define kBlank @" "
@interface AccountDetailController : UIViewController<UITextFieldDelegate,UITextViewDelegate,UIAlertViewDelegate>
{
    id _accountInfo;
    NSInteger _accountType;
}
- (id)initWithAccountInfo:(NSInteger)accountType accountInfo:(id)data nibNameOrNil:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;

@property (nonatomic,assign) IBOutlet UILabel* nameLabel;
@property (nonatomic,assign) IBOutlet UILabel* accountLabel;
@property (nonatomic,assign) IBOutlet UILabel* passwordLabel;
@property (nonatomic,assign) IBOutlet UILabel* noteLabel;
@property (nonatomic,assign) IBOutlet UILabel* alarmLabel;

@property (nonatomic,retain) id accountInfo;
@property (nonatomic,assign) IBOutlet UITextField* name;
@property (nonatomic,assign) IBOutlet UITextField* account;
@property (nonatomic,assign) IBOutlet UITextField* password;

@property (nonatomic,assign) IBOutlet UITextView* note;
@property (nonatomic,assign) IBOutlet UIButton* alarmButton;

-(IBAction)setAlarm:(id)sender;
-(IBAction)rightItemClickDelete:(id)sender;
-(IBAction)rightItemClickSave:(id)sender;
@end
