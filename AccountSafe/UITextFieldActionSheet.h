//
//  UITextFieldActionSheet.h
//  AccountSafe
//
//  Created by li ming on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextFieldActionSheet : UIActionSheet
{
    UITextField *textField;
}

@property(readonly) UITextField* textField;

-(id) initWithImage:(NSString *)title 
           delegate:(id <UIActionSheetDelegate>)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
  otherButtonTitles:(NSString *)otherButtonTitles;
@end
