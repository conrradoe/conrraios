//
//  ReceiverCell.h
//  HireMe Rider
//
//  Created by Prashant on 12/02/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReceiverCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *messageBackground;
@property (weak, nonatomic) IBOutlet UITextView *message;

@end
