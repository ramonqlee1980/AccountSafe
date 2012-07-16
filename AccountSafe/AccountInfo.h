//
//  AccountInfo.h
//  AccountSafe
//
//  Created by li ming on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

//coredata definition
#define kAccountInfo @"AccountInfo"
#define kType @"type"

@interface AccountInfo : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * account;
@property (nonatomic, retain) NSString * password;
@property (nonatomic, retain) NSString * tag;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSDate   * alarm;

@end
