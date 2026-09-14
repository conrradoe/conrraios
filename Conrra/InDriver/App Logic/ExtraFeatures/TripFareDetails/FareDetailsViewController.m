//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "FareDetailsViewController.h"
#import "FareDetailsCell.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "CategoryModel.h"
#import "UIImageView+WebCache.h"
#import "Utilities.h"
#import "UserProfile.h"
@interface FareDetailsViewController ()
{
    NSMutableArray *arrOptions;
    CityModel * cityModel;
    
}

@end

@implementation FareDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUIFields];
    NSDictionary * dict=[[NSUserDefaults standardUserDefaults]  objectForKey:P_USER_DICT];
    cityModel=[CityModel getCityByCityId:[UserProfile shared].cityID];
    arrOptions=[[NSMutableArray alloc] init];
    [arrOptions addObject:@"Fare  "];
    [arrOptions addObject:@"Booking Fee  "];
    [arrOptions addObject:@"Government Transport Levy  "];
    [arrOptions addObject:@"CTP Fee  "];
    [arrOptions addObject:@"Promo "];
    [arrOptions addObject:@"Booking Fee  "];
    [arrOptions addObject:@"Government Transport Levy  "];
    [arrOptions addObject:@"CTP Fee  "];
//    [arrOptions addObject:@"Promo "];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    self.lblCurrency.text=isEmpty(cityModel.city_cur);
    self.lblTotalFare.text =[Utilities formatAmount:[self.trip.trip_fare floatValue]];
//    [arrOptions addObject:@"Fare Per Min"];
    [self.tableView registerNib:[UINib nibWithNibName:@"FareDetailsCell" bundle:nil] forCellReuseIdentifier:@"FareDetailsCell"];
    
   
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) setUIFields{
    self.lblHeaderTitle.text =[LanguageHelper getStringWithKey:@"Fare Details"];
    self.lblFarePolicy.text=[LanguageHelper getStringWithKey:@"k_s3_show_fare_policy"];
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
     return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
   
        return arrOptions.count;
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"FareDetailsCell";
    
    
    FareDetailsCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    cell.lblLanguage.text=[arrOptions objectAtIndex:indexPath.row];
    NSString * fare=@"";
    switch (indexPath.row) {
        case 0:
            fare=[Utilities formatAmountAndCurrency:[self.trip.trip_base_fare floatValue] currency:isEmpty(cityModel.city_cur)];
            break;
        case 1:
            fare=[Utilities formatAmountAndCurrency:0.0 currency:isEmpty(cityModel.city_cur)];
            break;
        case 2:
            fare=[Utilities formatAmountAndCurrency:[self.trip.tax_amount floatValue] currency:isEmpty(cityModel.city_cur)];
            break;
        case 3:
            fare=[Utilities formatAmountAndCurrency:0.0 currency:isEmpty(cityModel.city_cur)];
            break;
        case 4:
            fare=[NSString stringWithFormat:@"- %@",[Utilities formatAmountAndCurrency:[self.trip.trip_promo_amt floatValue]  currency:isEmpty(cityModel.city_cur)]];
            break;
        case 5:
            fare=[NSString stringWithFormat:@"- %@",[Utilities formatAmountAndCurrency:0.0 currency:isEmpty(cityModel.city_cur)]];
            break;
        case 6:
            fare=[NSString stringWithFormat:@"- %@",[Utilities formatAmountAndCurrency:[self.trip.tax_amount floatValue] currency:isEmpty(cityModel.city_cur)]];
            break;
        case 7:
            fare=[NSString stringWithFormat:@"- %@",[Utilities formatAmountAndCurrency:0.0 currency:isEmpty(cityModel.city_cur)]];
            break;
        default:
            cell.lblPrice.text=@"";
            break;
    }
    
    cell.lblPrice.text=[NSString stringWithFormat:@"  %@",fare];
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
        return 40;
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    CategoryModel * legal = [arrCategory objectAtIndex:indexPath.section] ;
   
//    [self.tableView reloadData];

}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}




- (IBAction)ButtonBackPressed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}


- (IBAction)onFarePolicyButtonTap:(id)sender {
    AboutUsViewController *viewController=(AboutUsViewController*)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.ABOUT_US ];
    viewController.isAboutUs=NO;
    viewController.isFarePolicy=YES;
    [self.navigationController pushViewController:viewController animated:YES];
}



@end
