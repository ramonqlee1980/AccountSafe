//
//  ViewController.h
//  AccountSafe
//
//  Created by li ming on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckViewController : UIViewController<UITextFieldDelegate>
{
    IBOutlet UITextField* mPassword;
}

-(IBAction)rightItemClick:(id)sender;
@end
