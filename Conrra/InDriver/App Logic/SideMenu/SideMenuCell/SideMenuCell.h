//
//  SideMenuCell.h
//  Store_project
//
//  Created by  Appicial on 22/02/17.
//  Copyright © 2023 Appicial. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SideMenuCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblMenu;
@property (strong, nonatomic) IBOutlet UIView *viewMenuBG;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *MenuBgtopConstraints;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *MenuBgHeightConstraints;
@property (strong, nonatomic) IBOutlet UIImageView *imgIcon;
@property (strong, nonatomic) IBOutlet UIView *viewSeparator;
@property (weak, nonatomic) IBOutlet UIView *viewNotification;
@property (weak, nonatomic) IBOutlet UILabel *lblNotificationCount;

@end
