//
//  SuggestedLocationDataSource.m
//  HIREME_RIDER
//
//  Created by Appicial Taxi App Soutions on 12/06/17.
//  Copyright © 2023 Appicial Taxi App Soutions. All rights reserved.
//

#import "SuggestedLocationDataSource.h"
#import "SuggestedLocationCell.h"
#import "AFHTTPRequestOperationManager.h"
#import "WebCallConstants.h"
#import <GIKit/GIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@implementation SuggestedLocationDataSource
{
    NSMutableArray *arraySuggestedLocation;
    BOOL isSearchComplete;
}

-(instancetype)initWithTableView:(UITableView *) tableView textFiled:(UITextField *) textField;
{
    self=[self init];
    self.tablview=tableView;
    [self.tablview setHidden:YES];
    self.textField=textField;
    self.tablview.delegate=self;
    self.tablview.dataSource=self;
    self.textField.delegate=self;
    isSearchComplete=NO;
    return  self;
}

#pragma  mark - UITableView Delgate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arraySuggestedLocation.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseID = @"LocationSuggestionCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseID];
    UIImageView *iconView;
    UILabel *label;

    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor whiteColor];

        // Pin icon
        iconView = [[UIImageView alloc] init];
        iconView.tag = 801;
        iconView.translatesAutoresizingMaskIntoConstraints = NO;
        iconView.contentMode = UIViewContentModeScaleAspectFit;
        iconView.tintColor = [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f];
        UIImage *pinImg = [[UIImage imageNamed:@"ic_location_pin"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        if (!pinImg) {
            // Fallback: draw a simple circle dot
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(20, 20), NO, 0);
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(ctx, [UIColor colorWithRed:0.6f green:0.6f blue:0.6f alpha:1.0f].CGColor);
            CGContextFillEllipseInRect(ctx, CGRectMake(5, 5, 10, 10));
            pinImg = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        iconView.image = pinImg;
        [cell.contentView addSubview:iconView];

        // Location label
        label = [[UILabel alloc] init];
        label.tag = 802;
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.font = [UIFont fontWithName:@"NotoSans-Regular" size:14] ?: [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithRed:0.157f green:0.157f blue:0.157f alpha:1.0f];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        [cell.contentView addSubview:label];

        [NSLayoutConstraint activateConstraints:@[
            // Icon: 20×20, left edge 16pt, vertically centered
            [iconView.widthAnchor constraintEqualToConstant:20],
            [iconView.heightAnchor constraintEqualToConstant:20],
            [iconView.leadingAnchor constraintEqualToAnchor:cell.contentView.leadingAnchor constant:16],
            [iconView.centerYAnchor constraintEqualToAnchor:cell.contentView.centerYAnchor],

            // Label: 12pt gap after icon, 16pt right margin, 12pt top/bottom
            [label.leadingAnchor constraintEqualToAnchor:iconView.trailingAnchor constant:12],
            [label.trailingAnchor constraintEqualToAnchor:cell.contentView.trailingAnchor constant:-16],
            [label.topAnchor constraintEqualToAnchor:cell.contentView.topAnchor constant:12],
            [label.bottomAnchor constraintEqualToAnchor:cell.contentView.bottomAnchor constant:-12],
        ]];
    } else {
        iconView = (UIImageView *)[cell.contentView viewWithTag:801];
        label    = (UILabel *)[cell.contentView viewWithTag:802];
    }

    NSString *locName = [[arraySuggestedLocation objectAtIndex:indexPath.row] objectForKey:@"description"];
    label.text = locName;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * locName=[[arraySuggestedLocation objectAtIndex:indexPath.row]  objectForKey:@"description"];
    // Available text width: screen - 16(left) - 20(icon) - 12(gap) - 16(right)
    CGFloat textW = SCREEN_WIDTH - 64;
    CGFloat textH = [UtilityClass gTH:CGSizeMake(textW, 400) forText:locName withFont:FONTS_THEME_REGULAR_NO_SCALE(14)];
    return MAX(56.0, textH + 24.0);
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString  *stringDestinationAddress=[[arraySuggestedLocation  objectAtIndex:indexPath.row]  objectForKey:@"description"];
    
    
    isSearchComplete=YES;
//    [self getLatlngForm:stringDestinationAddress];
    [self.textField setText:stringDestinationAddress];
    [self.textField resignFirstResponder];
    [self.tablview setHidden:YES];
  
    self.dictLocationSelected =[arraySuggestedLocation objectAtIndex:indexPath.row];
     if(self.delegate)
     {
         
        [self.delegate source:self   onSelectLocation:[arraySuggestedLocation objectAtIndex:indexPath.row]];
     }
}



#pragma mark - UITextField Deldate Method
-(void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
     if(isSearchComplete)
     {
         return;
     }
//    self.textField.text=@"";
    [self.tablview setHidden:YES];
    [self.delegate onAddressEndEditingsource:self];
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
     NSString * proposedNewString = [[textField text] stringByReplacingCharactersInRange:range withString:string];
     if(proposedNewString.length>0)
     {
    [self performSearch:proposedNewString]    ;
     }
     else{
//         [self.tablview setHidden:YES];
         [self.delegate onAddressEmptyShouldClear:self];
         [self.tablview setHidden:YES];
     }
    
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    isSearchComplete=NO;
    self.dictLocationSelected=nil;
     [self.delegate onAddressStartEditingsource:self];
     
//    [self.tablview setHidden:NO];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.textField resignFirstResponder];
    [self.tablview setHidden:YES];
    return  YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.tablview setHidden:YES];
}

-(BOOL)textFieldShouldClear:(UITextField *)textField{
    [self.tablview setHidden:YES];
    
    [self.delegate onAddressShouldClear:self];
    return YES;
}

-(void) performSearch:(NSString *) string
{
    if(string.length==0||isSearchComplete==YES)
    {
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                  @"key" : [APP_DELEGATE getGoogleKey],
                                                                                  @"input" : string,
                                                                                   @"radius" :@"5000"
                                                                                  }];
    AppDelegate * app=APP_DELEGATE;
     
    [params setObject:[NSString stringWithFormat:@"%f,%f",app.currLoc.coordinate.latitude,app.currLoc.coordinate.longitude] forKey:@"location"];
     
    AFHTTPRequestOperationManager *manager =
    [AFHTTPRequestOperationManager manager];
    [manager GET:@"https://maps.googleapis.com/maps/api/place/autocomplete/json"
      parameters:params
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             if([[[responseObject objectForKey:@"status"] uppercaseString]  isEqualToString:@"OK"])
             {
                 
                 if(self->arraySuggestedLocation==nil)
                 {
                     self->arraySuggestedLocation=[[NSMutableArray alloc]  init];
                     
                 }
                 self->arraySuggestedLocation=[responseObject objectForKey:@"predictions"];
                 [self.tablview reloadData];
                 if(self->isSearchComplete==YES)
                 {
                 [self.tablview setHidden:YES];
                 }else{
                     [self.tablview setHidden:NO];
                 }
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *errorResponse) {
         }];
}



//-(void) getLatlngForm:(NSString *) address;
//{
//    
//    CLGeocoder *geocoder = [CLGeocoder new];
//    [geocoder geocodeAddressString:address completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
//        
//        if(placemarks.count>0)
//        {
//            CLPlacemark *placemark=[placemarks firstObject];
//        }
//    }];
//}



-(void) clearDataOfSuggestion
{
    arraySuggestedLocation=nil;
    
    [self.tablview reloadData];
}


@end
