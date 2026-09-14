//
//  NIDropDown.m
//  NIDropDown
//
//  Created by Bijesh N on 12/28/12.
//  Copyright (c) 2012 Nitor Infotech. All rights reserved.
//

#import "NIDropDown.h"
#import "QuartzCore/QuartzCore.h"
#import "WebCallConstants.h"
#import "NIDropDownCell.h"
@interface NIDropDown ()
@property(nonatomic, strong) UITableView *table;
@property(nonatomic, strong) UIButton *btnSender;
@property(nonatomic, retain) NSArray *list;
@property(nonatomic, assign) CGRect frameTemp;
@property(nonatomic, assign) BOOL isDown;

@end

@implementation NIDropDown
@synthesize table;
@synthesize btnSender;
@synthesize list;
@synthesize delegate;
@synthesize animationDirection;

- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction {
    btnSender = b;
    animationDirection = direction;
    self.table = (UITableView *)[super init];
    if (self) {
    
        // Initialization code
        CGRect btn = b.frame;
        self.list = [NSArray arrayWithArray:arr];
//        self.imageList = [NSArray arrayWithArray:imgArr];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, btn.size.width, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
        table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        table.backgroundColor = [UIColor colorNamed:@"color_app_bg"];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [UIColor grayColor];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.15];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y-*height, btn.size.width, *height);
        } else if([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, *height);
        }
        table.frame = CGRectMake(0, 0, btn.size.width, *height);
        [table setClipsToBounds:YES];
        [UIView commitAnimations];
        [b.superview addSubview:self];
        [self addSubview:table];
         [table registerNib:[UINib nibWithNibName:@"NIDropDownCell" bundle:nil] forCellReuseIdentifier:@"NIDropDownCell"];
    }
    return self;
}


- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction view:(UIView *) view frame:(CGRect) frame up:(BOOL) isDown isLeftAligin:(BOOL) isLeftAligin {
    
    return [self showDropDown:b :height :arr :imgArr :direction view:view frame:frame up:isDown isLeftAligin:isLeftAligin isShowCountryCode:NO];
}

- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction view:(UIView *) view frame:(CGRect) frame up:(BOOL) isDown isLeftAligin:(BOOL) isLeftAligin isShowCountryCode:(BOOL) isShowCountryCode
{
    
    btnSender = b;
    animationDirection = direction;
    self.isShowCountryCode=isShowCountryCode;
    self.table = (UITableView *)[super init];
    if (self) {
        self.frameTemp=frame;
        self.isLeftAligin=isLeftAligin;
        self.isDown=isDown;
        CGRect btn = b.frame;
        self.list = [NSArray arrayWithArray:arr];
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, 250, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }else if ([direction isEqualToString:@"full"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
            isFullScreen = YES;
        }
        
        self.frame=frame;
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
//        table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        table.backgroundColor = [UIColor colorNamed:@"color_app_bg"];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [UIColor grayColor];
        
        if(isFullScreen==NO){
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.15];
            [table setClipsToBounds:YES];
            table.frame = CGRectMake(0, 0, frame.size.width, *height);
            [UIView commitAnimations];
        }else{
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0];
            [table setClipsToBounds:YES];
            table.frame = CGRectMake(0, 0, frame.size.width, *height);
            [UIView commitAnimations];
        }
        [view addSubview:self];
        [self addSubview:table];
        [table registerNib:[UINib nibWithNibName:@"NIDropDownCell" bundle:nil] forCellReuseIdentifier:@"NIDropDownCell"];
    }
    return self;
}

- (id)showDropDown:(UIButton *)b :(CGFloat *)height :(NSArray *)arr :(NSArray *)imgArr :(NSString *)direction view:(UIView *) view frame:(CGRect) frame  up:(BOOL)isDown{
    btnSender = b;
    animationDirection = direction;
    self.table = (UITableView *)[super init];
    if (self) {
        self.frameTemp=frame;
        self.isDown=isDown;
        // Initialization code
        CGRect btn = b.frame;
        self.list = [NSArray arrayWithArray:arr];
//        self.imageList = [NSArray arrayWithArray:imgArr];
        
        if ([direction isEqualToString:@"up"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y, 150, 0);
            self.layer.shadowOffset = CGSizeMake(-5, -5);
        }else if ([direction isEqualToString:@"down"]) {
            self.frame = CGRectMake(btn.origin.x, btn.origin.y+btn.size.height, btn.size.width, 0);
            self.layer.shadowOffset = CGSizeMake(-5, 5);
        }
        
        self.frame=frame;
        self.layer.masksToBounds = NO;
        self.layer.cornerRadius = 8;
        self.layer.shadowRadius = 5;
        self.layer.shadowOpacity = 0.5;
        
        table = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 0)];
        table.delegate = self;
        table.dataSource = self;
        table.layer.cornerRadius = 5;
//        table.backgroundColor = [UIColor colorWithRed:0.239 green:0.239 blue:0.239 alpha:1];
        table.backgroundColor = [UIColor colorNamed:@"color_app_bg"];
        table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        table.separatorColor = [UIColor grayColor];
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.15];
         if(isDown)
         {
         self.frame=frame;
         }else{
             self.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, *height);
 
         }
        table.frame = CGRectMake(0, 0, frame.size.width, *height);
        [UIView commitAnimations];
        [view addSubview:self];
        [self addSubview:table];
         [table registerNib:[UINib nibWithNibName:@"NIDropDownCell" bundle:nil] forCellReuseIdentifier:@"NIDropDownCell"];
    }
    return self;
}


-(void)hideDropDown:(UIButton *)b {
    if(isFullScreen==NO){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.15];
        if(_isDown)   {
            self.frame = CGRectMake(self.frameTemp.origin.x, self.frameTemp.origin.y, self.frameTemp.size.width, 0);
        }  else{
            self.frame = CGRectMake(self.frameTemp.origin.x, self.frameTemp.origin.y+self.frameTemp.size.height, self.frameTemp.size.width, 0);
        }
        table.frame = CGRectMake(0, 0, self.frameTemp.size.width, 0);
        [UIView commitAnimations];
    }else{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0];
        self.frame = CGRectMake(self.frameTemp.origin.x, self.frameTemp.origin.y+self.frameTemp.size.height, self.frameTemp.size.width, 0);
        table.frame = CGRectMake(0, 0, self.frameTemp.size.width, 0);
        [UIView commitAnimations];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.list count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
     if(self.isShowCountryCode)
     {
         NIDropDownCell *cell=[tableView dequeueReusableCellWithIdentifier:@"NIDropDownCell"];
           CityModel * cityModel=[list objectAtIndex:indexPath.row];
         cell.lbCountryCode.text=isEmpty(cityModel.country_code);
          cell.lbCountryName.text =[NSString stringWithFormat:@"%@",cityModel.city_name];
         return cell;
     }
    static NSString *CellIdentifier = @"Cell";
     
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
         if(self.isLeftAligin)
         {
             cell.textLabel.textAlignment = NSTextAlignmentLeft;
        
         }else{
             cell.textLabel.textAlignment = NSTextAlignmentCenter;
         }
    }
//    if ([self.imageList count] == [self.list count]) {
    CityModel * cityModel=[list objectAtIndex:indexPath.row];
    if(self.isShowCountryCode)
    {
        NSString *string=@"";
        for (int i=0; i<(8-cityModel.country_code.length); i++) {
            string=[NSString stringWithFormat:@"%@ ",string];
        }
        cell.textLabel.text =[NSString stringWithFormat:@"%@%@| %@",cityModel.country_code,string,cityModel.city_name];
    }else
    {
        cell.textLabel.text =cityModel.city_name;
    }

//        cell.imageView.image = [imageList objectAtIndex:indexPath.row];
//    } else if ([self.imageList count] > [self.list count]) {
//        cell.textLabel.text =[list objectAtIndex:indexPath.row];
//        if (indexPath.row < [imageList count]) {
//            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
//        }
//    } else if ([self.imageList count] < [self.list count]) {
//        cell.textLabel.text =[list objectAtIndex:indexPath.row];
//        if (indexPath.row < [imageList count]) {
//            cell.imageView.image = [imageList objectAtIndex:indexPath.row];
//        }
//    }
    cell.textLabel.font=FONTS_THEME_REGULAR(13);
//    cell.textLabel.textColor = RGB(33, 33, 33);
    
    UIView * v = [[UIView alloc] init];
    v.backgroundColor = [UIColor grayColor];
    v.backgroundColor = [UIColor colorNamed:@"color_app_bg"];
    cell.selectedBackgroundView = v;
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);  //UIEdgeInsetsZero;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self hideDropDown:btnSender];
    
    UITableViewCell *c = [tableView cellForRowAtIndexPath:indexPath];
//    [btnSender setTitle:c.textLabel.text forState:UIControlStateNormal];
    
    for (UIView *subview in btnSender.subviews) {
        if ([subview isKindOfClass:[UIImageView class]]) {
            [subview removeFromSuperview];
        }
    }
    imgView.image = c.imageView.image;
    imgView = [[UIImageView alloc] initWithImage:c.imageView.image];
    imgView.frame = CGRectMake(5, 5, 25, 25);
    [btnSender addSubview:imgView];
    [self.delegate niDropDownDelegateMethod:self index:(int)indexPath.row result:[self.list objectAtIndex:indexPath.row]];
//    [self myDelegate];
    
}

- (void) myDelegate {
//    [self.delegate niDropDownDelegateMethod:self];
}

-(void)dealloc {
//    [super dealloc];
//    [table release];
//    [self release];
}
-(void) updateFarame:(CGRect) rect
{
    CGRect rect2=table.frame;
    rect2.origin.y=rect.origin.y;
    table.frame=rect2;
}
@end
