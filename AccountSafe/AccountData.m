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
#import "GDataXMLNode.h"
#import "constants.h"

#define TYPE_ACCOUNT_KEY @"AccountTypeCount"
#define TYPE_NAME_PREFIX @"TypeName"
#define TYPE_ICON_PREFIX @"TypeIcon"
static AccountData * sSharedInstance;

@interface AccountData()

-(void)initWithCoreData;
-(void)parseLocalCategoryXML;
@end

@implementation AccountData
-(oneway void)release
{
    [super release];
    sSharedInstance = nil;
}
+(id)shareInstance
{
    if(!sSharedInstance)
    {
        sSharedInstance = [[AccountData alloc] init];
    }
    return sSharedInstance;   
}
//init
-(id)init
{
    if (self = [super init]) {
        _managedObjectContext = [((AppDelegate*)[[UIApplication sharedApplication]delegate]) managedObjectContext];
        
        _mData = [[NSMutableArray alloc]init];
        [self parseLocalCategoryXML];
        
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

-(void)parseLocalCategoryXML
{
    //#define kLocalStringCategory
#ifdef kLocalStringCategory
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
#else
    AppDelegate* delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSString* xmlFileName = [[delegate applicationDocumentsDirectory]stringByAppendingPathComponent:kAccountCategoryFileNameWithSuffix];
    NSFileManager* fm = [NSFileManager defaultManager];
    if(![fm fileExistsAtPath:xmlFileName])
    {
        return;
    }
    
    //parse xml in local directory
    NSData* responseXML = [NSData dataWithContentsOfFile:xmlFileName];
    NSError *error;
    GDataXMLDocument *doc = [[[GDataXMLDocument alloc] initWithData:responseXML options:0 error:&error]autorelease];
    if (doc == nil) {
        return;
    }    
    
    NSArray *members = [doc nodesForXPath:@"//channel/item" error:nil];
    
    NSMutableArray* names = [[NSMutableArray alloc]init];  
    NSMutableArray* icons = [[NSMutableArray alloc]init];  
    for (GDataXMLElement *member in members){
        NSString *title = [[member attributeForName:@"title"] stringValue];
        NSString *icon = [[member attributeForName:@"icon"] stringValue];
        NSLog(@"name:%@,icon:%@",title,icon);
        [names addObject:title];
        [icons addObject:icon];
    }
    _mSectionName = names;
    _mSectionNameIcons = icons;    
    
    //[doc release];??
#endif
}
-(BOOL)addSection:(NSString*)title icon:(NSString*)icon
{
    if([_mSectionName containsObject:title])
    {
        return NO;
    }
    if(title!=nil && icon != nil && title.length>0&& icon.length>0)
    {
        [_mSectionName addObject:title];
        [_mSectionNameIcons addObject:icon];
        [_mData addObject:[[NSMutableArray alloc]initWithObjects:title, nil]];//add to section list
    }
    return YES;
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
-(void)removeObjectAtRow:(NSUInteger)rowIndex inSection:(NSUInteger)sectionIndex
{
    if ([self numberOfRowsInSection:sectionIndex]>rowIndex) {
        [[_mData objectAtIndex:sectionIndex]removeObjectAtIndex:rowIndex];
    }
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
-(BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile;
{
    GDataXMLElement *request = [GDataXMLNode elementWithName:@"channel"];    
    for (NSInteger i =0; i < [self numberOfSections]; ++i) {
        GDataXMLElement *item = [GDataXMLNode elementWithName:@"item"];
        GDataXMLNode *titleNode = [GDataXMLNode attributeWithName:@"title" stringValue:[self nameOfSection:i]];
        GDataXMLNode *iconNode = [GDataXMLNode attributeWithName:@"icon" stringValue:[self nameOfSectionIcon:i]];
        [item addAttribute:titleNode];
        [item addAttribute:iconNode];
        [request addChild:item]; 
    }
    
    GDataXMLDocument *document = [[[GDataXMLDocument alloc] initWithRootElement:request] autorelease];
    [document setCharacterEncoding:@"utf-8"];
    NSData *xmlData = document.XMLData;    
    
    return [xmlData writeToFile:path atomically:useAuxiliaryFile];
}

@end
