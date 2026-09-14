//
//  Constants.h
//  FinMgt
//
//  Created by Vinay Jain on 20/05/13.
//  Copyright (c) 2013 Vinay Jain. All rights reserved.
//

#ifndef FinMgt_Constants_h
#define FinMgt_Constants_h



#define APP_DELEGATE (AppDelegate*) [[UIApplication sharedApplication] delegate]
#define DATABASE_HANDLER  (DBHandler*) [[DBHandler alloc] init]
#define APP_UTILITIES  (UtilityClass*) [[UtilityClass alloc] init]
#define GIC  (GIKCommon*) [[GIKCommon alloc] init]


#define IS_DEVICE_RUNNING_IOS_7_AND_ABOVE() ([[[UIDevice currentDevice] systemVersion] compare:@"7.0" options:NSNumericSearch] != NSOrderedAscending)
#define iPhoneVersion ([[UIScreen mainScreen] bounds].size.height == 568 ? 5 : ([[UIScreen mainScreen] bounds].size.height == 480 ? 4 : ([[UIScreen mainScreen] bounds].size.height == 667 ? 6 : ([[UIScreen mainScreen] bounds].size.height == 736 ? 61 : 999))))

#define IS_IPAD() (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

#define SCREEN_HEIGHT (int) [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH (int) [[UIScreen mainScreen] bounds].size.width
#define ABU @"app_base_url"


#define RGB(r, g, b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0]


#endif
