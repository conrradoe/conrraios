//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "ReferralViewController.h"
#import "ReferralCell.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "Referral.h"
#import "SettingsModel.h"
#import "ConstantModel.h"
#import "Utilities.h"
#import "UIImageView+WebCache.h"
@interface ReferralViewController ()
{
    NSMutableArray *arrLegal;
    BOOL isHasMore;
    BOOL isLoading;
    
}

@end

@implementation ReferralViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isHasMore=NO;
    isLoading=NO;
    self.lblReferals.hidden=YES;
    arrLegal=[[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    [self onEraningButTap:self.btnEraning];
    [self setUIFields];
    [self.viewReferalCode.layer setBorderWidth:1];
    self.viewReferalCode.layer.borderColor=RGB(225, 225, 225).CGColor;
    self.viewReferalCode.layer.cornerRadius=5;
    [self.tableView registerNib:[UINib nibWithNibName:@"ReferralCell" bundle:nil] forCellReuseIdentifier:@"ReferralCell"];
    
    NSDictionary * dict1=defaults_object(P_USER_DICT);
    ConstantModel * _currType =  [ConstantModel getConstantsObject];
    self.lblReferralCode.text=[NSString stringWithFormat:@"%@%@",_currType.app_prefix,[dict1 objectForKey:P_DRIVER_ID]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) setUIFields{
    self.lblHeaderTitle.text =[LanguageHelper getStringWithKey:@"k_s10_referral"];
    [self.btnEraning setTitle:[LanguageHelper getStringWithKey:@"k_9_s4_a1_earning"] forState:UIControlStateNormal];
    [self.btnReferal setTitle:[LanguageHelper getStringWithKey:@"k_9_s4_a1_referrals"] forState:UIControlStateNormal];
    [self.btnCopyCode setTitle:[LanguageHelper getStringWithKey:@"k_9_s4_copy_code"] forState:UIControlStateNormal];
    [self.btnInvite setTitle:[LanguageHelper getStringWithKey:@"k_9_s4_invite"] forState:UIControlStateNormal];
    self.lblEraningMessage.text=[LanguageHelper getStringWithKey:@"k_9_s4_earning_msg"];
    self.lblReferals.text=[LanguageHelper getStringWithKey:@"k_1_s17_rests_nt_fnd"];
    self.lblReferals.textColor = [UIColor colorNamed:@"color_app_label"];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
     if(isHasMore)
     {
         return  2;
     }
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
   
     if(section==1)
     {
         return  1;
     }
    return arrLegal.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"ReferralCell";
    if(indexPath.section==1)
    {
        ReferralCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell.lblDriverName.hidden=YES;
        cell.imageDriver.hidden=YES;
        cell.lblLanguage.hidden=YES;
        cell.viewStatusBg.hidden=YES;
        cell.lblMessage.hidden=YES;
        cell.lblActivityLoader.hidden=NO;
        [cell.lblActivityLoader startAnimating];
         if(isLoading==NO)
         {
             [self  getReferalsList:YES];
         }
        return  cell;
        
    }
    
    ReferralCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    
   
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    Referral * legal=[arrLegal objectAtIndex:indexPath.row];
    cell.lblDriverName.text=[NSString stringWithFormat:@"%@ %@",isEmpty(legal.driver.d_fname),isEmpty(legal.driver.d_lname)];
    
    if (legal.driver.d_profile_image_path.length>0) {
        [cell.imageDriver sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",url_base_images, legal.driver.d_profile_image_path]] placeholderImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    else
    {
        [cell.imageDriver setImage:[UIImage imageNamed:@"Profile Icon Crop Image"]];
    }
    
     if([legal.status isEqualToString:@"joined"])
     {
         cell.lblLanguage.text=[LanguageHelper getStringWithKey:@"k_9_s4_joined"];
         cell.lblMessage.text=[LanguageHelper getStringWithKey:@"k_9_s4_joined_msg"];
         [cell.viewStatusBg setBackgroundColor:[UIColor orangeColor]];
     }else if([legal.status isEqualToString:@"completed"])
     {
         [cell.viewStatusBg setBackgroundColor:RGB(0,150,0)];
         NSString * smStartMsg=[LanguageHelper getStringWithKey:@"k_9_s4_completed_msg"];
         NSDateFormatter * df=[[NSDateFormatter alloc] init];
         [df setDateFormat:@"yyyy-MM-dd"];
         NSDate * sdate=[df dateFromString:legal.st_dt];
         NSDate * edate=[df dateFromString:legal.et_dt];
         [df setDateFormat:@"MMM dd, yyyy"];
         NSString * sdateString=[df stringFromDate:sdate];
         NSString * edateString=[df stringFromDate:edate];
         cell.lblMessage.text=[NSString stringWithFormat:@"%@\n%@ %@ %@ %@",smStartMsg,[LanguageHelper getStringWithKey:@"k_9_s4_from"],isEmpty(sdateString),[LanguageHelper getStringWithKey:@"k_9_s4_to"],isEmpty(edateString) ];
     }else{
         [cell.viewStatusBg setBackgroundColor:[UIColor redColor]];
         cell.lblLanguage.text=legal.status;
         cell.lblMessage.text=@"";
     }
    
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==1)
    {
        return  50;
    }
    Referral * legal=[arrLegal objectAtIndex:indexPath.row];
    
    if([legal.status isEqualToString:@"completed"])
    {
        return 80;
    }
    return 65;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    Referral * legal = [arrLegal objectAtIndex:indexPath.row] ;
//    AboutUsViewController *viewController=[self.storyboard instantiateViewControllerWithIdentifier:@"AboutUsViewController"];
//    viewController.isCustomUrl=YES;
//    viewController.customUrl=legal.url;
//    viewController.customTitle=legal.title;
//    [self.navigationController pushViewController:viewController animated:YES];

}

- (IBAction)ButtonBackPressed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}
- (IBAction)onEraningButTap:(id)sender {
    UIColor * selected=[UIColor whiteColor];
    UIColor * normal=RGB(0, 197, 231);
    [self.btnEraning setTitleColor:selected forState:UIControlStateNormal];
    [self.btnReferal setTitleColor:normal forState:UIControlStateNormal];
    self.btnEraning.backgroundColor=normal;
    self.btnReferal.backgroundColor=selected;
    [self.viewEranigs setHidden:NO];
    self.viewReferalList.hidden=YES;
}


- (IBAction)onRererralButTap:(id)sender {
    UIColor * selected=[UIColor whiteColor];
    UIColor * normal=RGB(0, 197, 231);
    [self.btnEraning setTitleColor:normal forState:UIControlStateNormal];
    [self.btnReferal setTitleColor:selected forState:UIControlStateNormal];
    self.btnEraning.backgroundColor=selected;
    self.btnReferal.backgroundColor=normal;
    [self.viewEranigs setHidden:YES];
    self.viewReferalList.hidden=NO;
     if(arrLegal.count==0)
     {
    isHasMore=YES;
     }
    [self.tableView reloadData];
    [self getReferalsList:NO];
}


- (IBAction)onCopyCode:(id)sender {
    UIPasteboard *pasteboard = [UIPasteboard pasteboardWithName:@"com.grepix." create:YES];
//    [pasteboard setPersistent:YES];
    NSString *string=self.lblReferralCode.text;
    [pasteboard setString:string];
//    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//    pasteboard.string = self.lblReferralCode.text;
    
    UIAlertController * alert=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_s7_alert"] message:[LanguageHelper getStringWithKey:@"k_9_s4_copied"] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction: [UIAlertAction  actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok"] style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    
}

-(IBAction) onInviteButtonTap:(id)sender
{
  
  
    NSString *myWebsite = [NSString stringWithFormat:@"%@ %@",[LanguageHelper getStringWithKey:@"k_9_s4_invite_msg"],self.lblReferralCode.text];
    
    NSArray *objectsToShare = @[myWebsite];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}


-(void)getReferalsList:(BOOL) isLoadMore{
    if(isLoading)
    {
        return;
    }
    isLoading=YES;
     NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                                @"ref_driver_id":[dict1 objectForKey:P_DRIVER_ID],
                                                                            
                                                                                @"limit":@(SIZE),
                                                                            @"api_key":[dict1 objectForKey:P_API_KEY],
                                                                                }];
    
     if(isLoadMore)
     {
         [dict setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self->arrLegal.count] forKey:@"offset"];
     }else
     {
         [dict setObject:@"0" forKey:@"offset"];
     }
    
    
    [GIC mkwu:API_GET_REFERRAL
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
        self->isLoading=NO;
//        if(!isLoadMore)
//        {
//            [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
//        }
           if ([[[results objectForKey:P_STATUS]uppercaseString] isEqualToString:@"OK"]) {
               // success
               
               if ([[results objectForKey:P_RESPONSE] isKindOfClass:[NSArray class]]) {
                   
//                   NSArray *arrtrip = [results objectForKey:P_RESPONSE];
                   NSArray *arrtrip=[Referral parseArray:[results objectForKey:P_RESPONSE]];
                   self->isHasMore = arrtrip.count == SIZE ? YES : NO;
                   if(!isLoadMore)
                   {
                       [self->arrLegal removeAllObjects];
                   }
                 
                   [self->arrLegal addObjectsFromArray:arrtrip];
                   if(self->arrLegal.count>0)
                   {
                       self.lblReferals.hidden=YES;
                   }else{
                       self.lblReferals.hidden=NO;
                   }
                   [self.tableView reloadData];
                   
               }else {
                   self.lblReferals.hidden=NO;
                   self->isHasMore =NO;
                   [self.tableView reloadData];
                   
               }
           }else{
               [self.tableView reloadData];
               self->isHasMore=NO;
               self.lblReferals.hidden=NO;
           }
       }];
    }


@end
