//
//  main.m
//  AccountSafe
//
//  Created by li ming on 6/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YouMiWall.h"
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
        //disable youmi wall gps
        [YouMiWall setShouldGetLocation:NO];
        [YouMiWall setShouldCacheImage:YES];
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
