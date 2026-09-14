//
//  LanguageCell.h
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationModel.h"
#import "LanguageHelper.h"

@interface NotificationCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *lblLanguage;
@property (strong, nonatomic) IBOutlet UIImageView *imgSelectlanguage;
@property (weak, nonatomic) IBOutlet UILabel *lbDate;
@property (weak, nonatomic) IBOutlet UILabel *lbRefId;
-(void) populateData:(NotificationModel *) notificationModel indexPath:(NSIndexPath *) indexPath;
@end
