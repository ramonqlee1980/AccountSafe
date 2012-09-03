//
//  AdsConfig.h
//  HappyLife
//
//  Created by ramon lee on 5/12/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "constants.h"

#define AccountSafe

#define kAppIdOnAppstore @"541440403"//for identifying app when updating
//wall
//修改为你自己的AppID和AppSecret
#define kDefaultAppID_iOS           @"5aa5eabf0f6bef1d" // youmi default app id
#define kDefaultAppSecret_iOS       @"5e9ee87631d15545" // youmi default app secret
#define kMobiSageID_iPhone  @"e270159b22cc4c98a64e4402db48e96d"

//ads url
#define kDefaultAds @"defaultAds"
#define AdsUrl @"http://www.idreems.com/example.php?adsconfigNonAppstore_AccountSafe.xml"


//ads platform names
#define AdsPlatformWooboo @"Wooboo"
#define AdsPlatformWiyun @"Wiyun"
#define AdsPlatformMobisage @"Mobisage"
#define AdsPlatformDomob @"Domob"
#define AdsPlatformYoumi @"Youmi"//not implemented right now
#define AdsPlatformCasee @"Casee"
#define AdsPlatformAdmob @"Admob"

#define kNewContentScale 5
#define kMinNewContentCount 3

#define kWeiboMaxLength 140
#define kAdsSwitch @"AdsSwitch"
#define kPermanent @"Permanent"
#define kDateFormatter @"yyyy-MM-dd"

//for notification
#define kAdsUpdateDidFinishLoading @"AdsUpdateDidFinishLoading"
#define  kUpdateTableView @"UpdateTableView"

#define kOneDay (24*60*60)
#define kTrialDays  1

//flurry event
#define kFlurryRemoveTempConfirm @"kRemoveTempConfirm"
#define kFlurryRemoveTempCancel  @"kRemoveTempCancel"
#define kEnterMainViewList       @"kEnterMainViewList"
#define kFlurryOpenRemoveAdsList @"kOpenRemoveAdsList"

#define kFlurryDidSelectApp2RemoveAds @"kDidSelectApp2RemoveAds"
#define kFlurryRemoveAdsSuccessfully  @"kRemoveAdsSuccessfully"
#define kDidShowFeaturedAppNoCredit   @"kDidShowFeaturedAppNoCredit"

#define kShareByWeibo @"kShareByWeibo"
#define kShareByEmail @"kShareByEmail"

#define kEnterBylocalNotification @"kEnterBylocalNotification"
#define kDidShowFeaturedAppCredit @"kDidShowFeaturedAppCredit"

#define kFlurryDidSelectAppFromRecommend @"kFlurryDidSelectAppFromRecommend"
#define kFlurryDidSelectAppFromMainList  @"kFlurryDidSelectAppFromMainList"

//favorite
#define kEnterNewFavorite @"kEnterNewFavorite"
#define kOpenExistFavorite @"kOpenExistFavorite"

#define kCountPerSection 3
@interface AdsConfig : NSObject
{
    NSMutableArray *mData;
    NSInteger mCurrentIndex;
}
@property (nonatomic, retain) NSMutableArray* mData;
@property (nonatomic, assign) NSInteger mCurrentIndex;

+(AdsConfig*)sharedAdsConfig;
+(void)reset;
+(NSDate*)currentLocalDate;

+(BOOL) isAdsOn;
+(BOOL) isAdsOff;
+(void) setAdsOn:(BOOL)enable type:(NSString*)type;
+(BOOL)neverCloseAds;

-(NSString *)getAdsTestVersion:(const NSUInteger)index;
-(BOOL)wallShouldShow;
-(NSString*)wallShowString;
-(void)init:(NSString*)path;

-(NSString*)getFirstAd;

-(NSString*)getLastAd;

-(NSInteger)getAdsCount;

-(NSString*)toNextAd;

-(NSString*)getCurrentAd;

-(BOOL)isCurrentAdsValid;
-(NSInteger)getCurrentIndex;

-(BOOL)isInitialized;

-(void)dealloc;

@end
