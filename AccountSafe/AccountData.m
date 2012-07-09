//
//  AccountData.m
//  AccountSafe
//
//  Created by li ming on 6/27/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AccountData.h"
#import "AccountInfo.h"
#import "AppDelegate.h"
#import "ProtocolLogManager.h"

#define TYPE_ACCOUNT_KEY @"AccountTypeCount"
#define TYPE_NAME_PREFIX @"TypeName"
#define TYPE_ICON_PREFIX @"TypeIcon"

@interface AccountData()

-(void)initWithCoreData;

@end

@implementation AccountData
//init
-(id)init
{
    if (self = [super init]) {
        _managedObjectContext = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) managedObjectContext];
        
        _mData = [[NSMutableArray alloc]init];
        
        NSMutableArray* sections = [[NSMutableArray alloc]init];
        
        NSString* typeCount = NSLocalizedString(TYPE_ACCOUNT_KEY, "");
        NSLog(@"%@",typeCount);
        for (NSInteger i = 0; i < [typeCount intValue]; ++i) {
            NSString* nameKey = [NSString stringWithFormat:@"%@%d",TYPE_NAME_PREFIX,i];
            [sections addObject:NSLocalizedString(nameKey, "")];
        }         
        _mSectionName = [[NSArray alloc]initWithArray:sections];
        [sections release];
        
        sections = [[NSMutableArray alloc]init];
        for (NSInteger i = 0; i < [typeCount intValue]; ++i) {
            NSString* nameKey = [NSString stringWithFormat:@"%@%d",TYPE_ICON_PREFIX,i];
            [sections addObject:NSLocalizedString(nameKey, "")];
        }
        _mSectionNameIcons = [[NSArray alloc]initWithArray:sections];
        [sections release];
        
        //placeholder for section's data
        //first one for section name,section's data follow
        for (NSInteger i = 0; i < [_mSectionName count]; ++i) {
            [_mData addObject:[[NSMutableArray alloc]initWithObjects:[_mSectionName objectAtIndex:i], nil]];
        }
        
        //init data from core data
        [self initWithCoreData];
    }
    return self;
}

-(void)initWithCoreData
{
    ProtocolLogManager* mgr = [ProtocolLogManager sharedProtocolLogManager];
    
    //TODO::category according to type
    AccountInfo* info = nil;
    NSLog(@"account count::%d", [mgr count]);
    for (NSInteger i = 0; i < [mgr count]; ++i) {
       info = [mgr objectAtIndex:i];
        if (info) {
            [self setRowInSection:info inSection:[info.type intValue]];
        }
    }
    
}
-(void)dealloc
{
    for (NSInteger i = 0; i < [_mData count]; ++i) {
        [[_mData objectAtIndex:i]release];
    }
    [_mData release];
    [_mSectionName release];
    [super dealloc];
}
//section number
-(NSUInteger)numberOfSections
{
    return [_mSectionName count];
}
-(NSString*)nameOfSectionIcon:(NSUInteger)sectionIndex
{
    if(sectionIndex < [_mSectionName count])
    {
        return [_mSectionNameIcons objectAtIndex:sectionIndex];
    }
    return @"";
}
//section name
-(NSString*)nameOfSection:(NSUInteger)sectionIndex
{
    if(sectionIndex < [_mSectionName count])
    {
        return [_mSectionName objectAtIndex:sectionIndex];
    }
    return @"";
}

//row number in section
-(NSUInteger)numberOfRowsInSection:(NSUInteger)sectionIndex
{
    if (sectionIndex<[_mData count]) {
        return [[_mData objectAtIndex:sectionIndex]count];
    }
    return 0;
}
-(void)setRowInSection:(id)info inSection:(NSInteger)section
{
    if(section < [self numberOfSections])
    {
        [[_mData objectAtIndex:section]addObject:info];
    }
}
//row data in section
-(id)objectOfRow:(NSUInteger)rowIndex inSection:(NSUInteger)sectionIndex
{
    if ([self numberOfRowsInSection:sectionIndex]>rowIndex) {
        return [[_mData objectAtIndex:sectionIndex]objectAtIndex:rowIndex];
    }
    return nil;
}

#define kOpenDoorKey @"opendoor"

+(NSString*)getOpenDoorKey
{
    NSUserDefaults* defaultSetting = [NSUserDefaults standardUserDefaults];   
    return [defaultSetting valueForKey:kOpenDoorKey];
}
+(void)setOpenDoorKey:(NSString*)key
{
    NSUserDefaults* defaultSetting = [NSUserDefaults standardUserDefaults];   
    [defaultSetting setValue:key forKey:kOpenDoorKey];
}
@end
