//
//  ImageDoc.m

//
//  Created by Grepix - Baij on 07/09/20.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ImageDoc.h"
#import "WebCallConstants.h"
@implementation ImageDoc

- (instancetype)initWithFrame:(CGRect )frameOri view:(UIView *) view
 {
    self = [super init];
    if (self) {
        int width=100;
//        view.backgroundColor=[Ui]
        CGRect frame=CGRectMake(frameOri.origin.x+width, frameOri.origin.y, 45, 45);
        CGRect frameLabel=CGRectMake(frameOri.origin.x, frameOri.origin.y+45-15, width, 15);
        
        self.imageView=[[UIImageView alloc]initWithFrame:frame];
        self.imageView.clipsToBounds=YES;
        self.imageView.contentMode=UIViewContentModeScaleAspectFill;
        UIImage *imageTinit =[[UIImage imageNamed:@"google-docs"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.imageView.tintColor = [UIColor colorNamed:@"color_icon_tint"];
        self.imageView.image=imageTinit;
        [view addSubview:self.imageView];
        self.activityLoader=[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(frame.origin.x+frame.size.width/2-30/2, frame.origin.y+frame.size.height/2-30/2, 30, 30)];
        self.activityLoader.hidden=YES;
        [self.activityLoader stopAnimating];
        [view addSubview:self.activityLoader];
        self.button=[[CustomUIButton alloc] initWithFrame:frame];
//        self.button.backgroundColor=[UIColor redColor];
       
        self.label=[[UILabel alloc] initWithFrame:frameLabel];
        
        [self.label setFont:FONTS_THEME_REGULAR(12)];
        self.label.textColor=[UIColor colorNamed:@"color_app_label"];
        [view addSubview:self.label];
         [view addSubview:self.button];
    }
    return self;
}
@end
