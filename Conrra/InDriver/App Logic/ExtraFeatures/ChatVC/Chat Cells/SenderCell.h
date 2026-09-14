//
//  SenderCell.h
//  HireMe Rider
//
//  Created by Prashant on 12/02/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SenderCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIImageView *messageBackground;
@property (weak, nonatomic) IBOutlet UITextView *message;
@property (weak, nonatomic) IBOutlet UIImageView *profilePic;

@end
