////
//  HomeViewController.m
//  Store_project
//
//  Created by Appicial Taxi App Soutions on 22/05/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "ImageFullViewController.h"
#import "UIImageView+WebCache.h"
@interface ImageFullViewController ()
{
    
}

@end

@implementation ImageFullViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUIFiels];
    if(self.image){
        [self.imageViewPre setImage:self.image];
    }else{
        
        UIImage *imageTinit =[[UIImage imageNamed:@"google-docs"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageViewPre.tintColor = [UIColor colorNamed:@"color_icon_tint"];
        [self.imageViewPre sd_setImageWithURL:[NSURL URLWithString:self.urlString] placeholderImage:imageTinit];
    }
}


 




-(void) setUIFiels{
}




- (IBAction)onClodeButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}




-(void) viewWillDisappear:(BOOL)animated
{
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //  Get the new view controller using [segue destinationViewController].
    //  Pass the selected object to the new view controller.
    
    
    
}
 

+(ImageFullViewController *) openMessageWithImage:(UIImage *) image viewController:(UIViewController *)viewController{
    ImageFullViewController *vc=[[UIStoryboard storyboardWithName:@"ExtraFeature" bundle:nil] instantiateViewControllerWithIdentifier:@"ImageFullViewController"];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.image=image;
    [viewController presentViewController:vc animated:YES completion:^{
      
        
    }];
    return  vc;
}
+(ImageFullViewController *) openMessageViewController:(NSString *) urlString viewController:(UIViewController *)viewController{
    ImageFullViewController *vc=[[UIStoryboard storyboardWithName:@"ExtraFeature" bundle:nil] instantiateViewControllerWithIdentifier:@"ImageFullViewController"];
    vc.modalPresentationStyle=UIModalPresentationOverCurrentContext;
    vc.modalTransitionStyle=UIModalTransitionStyleCrossDissolve;
    vc.urlString=urlString;
    [viewController presentViewController:vc animated:YES completion:^{
      
        
    }];
    return  vc;
}


@end

