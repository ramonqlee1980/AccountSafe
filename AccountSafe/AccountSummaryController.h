//
//  AccountSummaryController.h
//  AccountSafe
//
//  Created by li ming on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AccountData;
@interface AccountSummaryController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UITableView* _tableView;
    AccountData* _accountData;
}

@property (nonatomic,retain) IBOutlet UITableView* tableView;



@end
