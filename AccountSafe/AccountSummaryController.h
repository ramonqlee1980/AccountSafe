//
//  AccountSummaryController.h
//  AccountSafe
//
//  Created by li ming on 6/24/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouMiWall.h"
#import "AdSageRecommendDelegate.h"

@class AdSageRecommendView;

@class AccountData;
@interface AccountSummaryController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,YouMiWallDelegate,AdSageRecommendDelegate>
{
    UITableView* _tableView;
    AccountData* _accountData;
    YouMiWall *wall;
    AdSageRecommendView *_recmdView;
}
@property(nonatomic, retain) AdSageRecommendView *recmdView;

@property (nonatomic,retain) IBOutlet UITableView* tableView;

-(IBAction)addAccountCategory:(id)sender;

@end
