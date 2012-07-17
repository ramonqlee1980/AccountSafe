//
//  TimePickerController.h
//  AccountSafe
//
//  Created by Lee Ramon on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimePickerController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* tableView;
    UIDatePicker* datePicker;
    UIDatePicker* timePicker;
    NSDate* alarmTimeSet;
}
@property (nonatomic,retain) NSDate* alarmTimeSet;
@property (nonatomic,retain) IBOutlet  UITableView* tableView;
@property (nonatomic,retain) IBOutlet UIDatePicker* datePicker;
@property (nonatomic,retain) IBOutlet UIDatePicker* timePicker;
@end
