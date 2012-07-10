//
//  VIPController.h
//  AccountSafe
//
//  Created by li ming on 7/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;

@interface VIPController : UIViewController
{
    MBProgressHUD *_hud;
}

@property (retain) MBProgressHUD *hud;

-(IBAction)rightItemClickInAppPurchase:(id)sender;
@end
