//
//  UITextFieldActionSheet.m
//  AccountSafe
//
//  Created by li ming on 7/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "UITextFieldActionSheet.h"

@implementation UITextFieldActionSheet
@synthesize textField;

#pragma custom 
-(id) initWithImage:(NSString *)title
           delegate:(id <UIActionSheetDelegate>)delegate 
  cancelButtonTitle:(NSString *)cancelButtonTitle 
destructiveButtonTitle:(NSString *)destructiveButtonTitle 
  otherButtonTitles:(NSString *)otherButtonTitles{
    
    self = [super initWithTitle:title delegate:delegate 
              cancelButtonTitle:cancelButtonTitle 
         destructiveButtonTitle:destructiveButtonTitle 
              otherButtonTitles:otherButtonTitles,nil];
    
    if (self) {
        CGRect rc = [[UIScreen mainScreen]applicationFrame];
        rc.size.height = 50;
        textField=[[UITextField alloc]initWithFrame:rc];
        textField.textAlignment = UITextAlignmentCenter;
        
        for (UIView *subView in self.subviews){
            if (![subView isKindOfClass:[UILabel class]]) {
                [self insertSubview:textField aboveSubview:subView];
                break;
            }
        }
        
        [textField release];
    }
    return self;
}


- (CGFloat) maxLabelYCoordinate {
    // Determine maximum y-coordinate of labels
    CGFloat maxY = 0;
    for( UIView *view in self.subviews ){
        if([view isKindOfClass:[UILabel class]]) {
            CGRect viewFrame = [view frame];
            CGFloat lowerY = viewFrame.origin.y + viewFrame.size.height;
            if(lowerY > maxY)
                maxY = lowerY;
        }
    }
    return maxY;
}

-(void) layoutSubviews{
    [super layoutSubviews];
    CGRect frame = [self frame];
    CGFloat labelMaxY = [self maxLabelYCoordinate];
    
    for(UIView *view in self.subviews){
        if (![view isKindOfClass:[UILabel class]]) {    
            if([view isKindOfClass:[UITextField class]]){
                CGRect viewFrame = CGRectMake((320 - textField.frame.size.width)/2, labelMaxY + 10,
                                              textField.frame.size.width, textField.frame.size.height);
                [view setFrame:viewFrame];
            } 
            else 
                if(![view isKindOfClass:[UITextField class]]) {
                CGRect viewFrame = [view frame];
                viewFrame.origin.y += textField.frame.size.height+10;
                [view setFrame:viewFrame];
            }
        }
    }
    
    frame.origin.y -= textField.frame.size.height + 2.0;
    frame.size.height += textField.frame.size.height + 2.0;
    [self setFrame:frame];
    
}
/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code.
 }
 */

- (void)dealloc {
    [super dealloc];    
}
@end
