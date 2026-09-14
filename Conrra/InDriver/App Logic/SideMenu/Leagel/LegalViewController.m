//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "LegalViewController.h"
#import "LegalCell.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "Legal.h"
#import "SettingsModel.h"
@interface LegalViewController ()
{
    NSMutableArray *arrLegal;
}

@end

@implementation LegalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setUIFields];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"LegalCell" bundle:nil] forCellReuseIdentifier:@"LegalCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) setUIFields{
    self.lblHeaderTitle.text =[LanguageHelper getStringWithKey:@"k_2_s10_legal"];
//    arrLegal=[Legal parseArray:@[]];
    NSArray * array=defaults_object( @"settingResponse");
      SettingsModel * setting=[[SettingsModel alloc] initItemWithDict:array];
      arrLegal=[Legal parseArray:setting.legal];
      [self.tableView reloadData];
    [self.tableView reloadData];
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
    
   
        return arrLegal.count;
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"LegalCell";
    
    
    LegalCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    
    
   
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    Legal * legal=[arrLegal objectAtIndex:indexPath.row];
    cell.lblLanguage.text=legal.title;
    
    return cell;
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
        return 50;
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   Legal * legal = [arrLegal objectAtIndex:indexPath.row] ;
    AboutUsViewController *viewController=(AboutUsViewController *)[StoryBoardUtiles viewContollerInMainWithIdentifier:StoryBoardUtiles.ABOUT_US];
    viewController.isCustomUrl=YES;
    viewController.customUrl=legal.url;
    viewController.customTitle=legal.title;
    [self.navigationController pushViewController:viewController animated:YES];

}

- (IBAction)ButtonBackPressed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}





@end
