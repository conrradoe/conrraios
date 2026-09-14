//
//  HomeViewController.h
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
@interface ImageFullViewController : BaseViewController
@property(strong,nonatomic) NSString * urlString;
@property(strong,nonatomic) UIImage * image;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewPre;
+(ImageFullViewController *) openMessageViewController:(NSString *) urlString viewController:(UIViewController *)viewController;
+(ImageFullViewController *) openMessageWithImage:(UIImage *) image viewController:(UIViewController *)viewController;
@end
