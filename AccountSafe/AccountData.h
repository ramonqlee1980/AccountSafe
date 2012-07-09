//
//  AccountData.h
//  AccountSafe
//
//  Created by li ming on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountData : NSObject
{
    NSMutableArray* _mData;
    NSArray* _mSectionName;
    NSArray* _mSectionNameIcons;
    NSManagedObjectContext* _managedObjectContext;
}
+(NSString*)getOpenDoorKey;
+(void)setOpenDoorKey:(NSString*)key;
//init
-(id)init;

//section number
-(NSUInteger)numberOfSections;

//section name
-(NSString*)nameOfSection:(NSUInteger)sectionIndex;
-(NSString*)nameOfSectionIcon:(NSUInteger)sectionIndex;

//row number in section
-(NSUInteger)numberOfRowsInSection:(NSUInteger)sectionIndex;
//row data in section
-(id)objectOfRow:(NSUInteger)rowIdex inSection:(NSUInteger)sectionIndex;
-(void)setRowInSection:(id)info inSection:(NSInteger)section;
@end
