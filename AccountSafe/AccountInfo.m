//
//  AccountInfo.m
//  AccountSafe
//
//  Created by li ming on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountInfo.h"


@implementation AccountInfo

@dynamic name;
@dynamic account;
@dynamic password;
@dynamic note;
@dynamic type;
/*
-(void)assign:(id)obj
{
    if ([obj isKindOfClass:[AccountInfo class]]) {   
        AccountInfo* info =(AccountInfo*)obj;
        self.name = info.name;
        self.account = info.account;
        self.password = info.password;
        self.note =  info.note;        
        self.type = info.type;
    }
}*/
@end
