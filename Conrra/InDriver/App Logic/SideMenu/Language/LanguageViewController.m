//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "LanguageViewController.h"
#import "LanguageCell.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"

@interface LanguageViewController ()
{
    NSArray *arrLanguage;
    NSString *selectedLang;
}

@end

@implementation LanguageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *lng = [[NSUserDefaults standardUserDefaults]objectForKey:@"language"];
    if (lng.length == 0) {
        NSString *deviceLanguage = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        for (NSDictionary *dict in [[LanguageHelper sharedInstance] getLanguageList]) {
            if ([[dict objectForKey:@"code"] isEqualToString:deviceLanguage]) {
                selectedLang = [dict objectForKey:@"code"];
                break;
            }
        }
    } else {
        selectedLang = lng;
    }
    [self setUIFields];
    [self setupNewDesign];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void) setUIFields{
    self.lblHeaderTitle.text = [LanguageHelper getStringWithKey:@"k_12_s4_a1_language" defaultValue:@"Idioma"];
    arrLanguage = [[NSArray alloc] initWithArray:[[LanguageHelper sharedInstance] getLanguageList]];
}

#pragma mark - New Design

- (void)setupNewDesign {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
    for (UIView *v in [self.view.subviews copy]) { v.hidden = YES; }

    self.view.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    UIColor *textMain = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];

    UIView *header = [[UIView alloc] init];
    header.translatesAutoresizingMaskIntoConstraints = NO;
    header.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:header];

    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    backBtn.tintColor = textMain;
    if (@available(iOS 13, *)) {
        UIImageSymbolConfiguration *cfg = [UIImageSymbolConfiguration configurationWithWeight:UIImageSymbolWeightMedium];
        [backBtn setImage:[[UIImage systemImageNamed:@"chevron.left" withConfiguration:cfg]
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                 forState:UIControlStateNormal];
    } else {
        [backBtn setTitle:@"‹" forState:UIControlStateNormal];
        backBtn.titleLabel.font = [UIFont systemFontOfSize:26 weight:UIFontWeightLight];
    }
    [backBtn addTarget:self action:@selector(ButtonBackPressed:) forControlEvents:UIControlEventTouchUpInside];
    [header addSubview:backBtn];

    UILabel *titleLbl = [[UILabel alloc] init];
    titleLbl.translatesAutoresizingMaskIntoConstraints = NO;
    titleLbl.text = [LanguageHelper getStringWithKey:@"k_12_s4_a1_language" defaultValue:@"Idioma"];
    titleLbl.font = FONTS_NOTO_BOLD(18);
    titleLbl.textColor = textMain;
    [header addSubview:titleLbl];

    // Reassign IBOutlet so setUIFields keeps working
    self.lblHeaderTitle = titleLbl;

    UIView *headerSep = [[UIView alloc] init];
    headerSep.translatesAutoresizingMaskIntoConstraints = NO;
    headerSep.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    [header addSubview:headerSep];

    [NSLayoutConstraint activateConstraints:@[
        [header.topAnchor constraintEqualToAnchor:safe.topAnchor],
        [header.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [header.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [header.heightAnchor constraintEqualToConstant:56],

        [backBtn.leadingAnchor constraintEqualToAnchor:header.leadingAnchor constant:16],
        [backBtn.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],
        [backBtn.widthAnchor constraintEqualToConstant:36],
        [backBtn.heightAnchor constraintEqualToConstant:36],

        [titleLbl.centerXAnchor constraintEqualToAnchor:header.centerXAnchor],
        [titleLbl.centerYAnchor constraintEqualToAnchor:header.centerYAnchor],

        [headerSep.bottomAnchor constraintEqualToAnchor:header.bottomAnchor],
        [headerSep.leadingAnchor constraintEqualToAnchor:header.leadingAnchor],
        [headerSep.trailingAnchor constraintEqualToAnchor:header.trailingAnchor],
        [headerSep.heightAnchor constraintEqualToConstant:1],
    ]];

    UITableView *table = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    table.translatesAutoresizingMaskIntoConstraints = NO;
    table.backgroundColor = [UIColor colorWithRed:0.96 green:0.96 blue:0.96 alpha:1];
    table.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    table.separatorColor = [UIColor colorWithWhite:0.92 alpha:1];
    table.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    table.rowHeight = 70;
    table.tableFooterView = [[UIView alloc] init];
    table.layer.cornerRadius = 14;
    table.layer.masksToBounds = YES;
    table.dataSource = self;
    table.delegate = self;
    [table registerNib:[UINib nibWithNibName:@"LanguageCell" bundle:nil] forCellReuseIdentifier:@"LanguageCell"];
    [self.view addSubview:table];

    // Reassign IBOutlet so existing data/delegate methods work
    self.tableView = table;

    [NSLayoutConstraint activateConstraints:@[
        [table.topAnchor constraintEqualToAnchor:header.bottomAnchor constant:12],
        [table.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:16],
        [table.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-16],
        [table.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
    ]];
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
    return arrLanguage.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"LanguageCell";
    LanguageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor whiteColor];
    cell.contentView.backgroundColor = [UIColor whiteColor];

    // Language label
    cell.lblLanguage.font = FONTS_NOTO_REGULAR(16);
    cell.lblLanguage.textColor = [UIColor colorNamed:@"color_app_label"] ?: [UIColor blackColor];
    cell.lblLanguage.text = [[arrLanguage objectAtIndex:indexPath.row] objectForKey:@"name"];

    // Radio icon
    BOOL isSelected = [[[arrLanguage objectAtIndex:indexPath.row] objectForKey:@"code"] isEqualToString:selectedLang];
    NSString *assetName = isSelected ? @"radio-selected" : @"radio-unselected";
    UIImage *image = [[UIImage imageNamed:assetName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    cell.imgSelectlanguage.tintColor = [UIColor colorNamed:@"app_theame"];
    cell.imgSelectlanguage.image = image;

    return cell;
}
    

    
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

    
    
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selectedLang = [[arrLanguage objectAtIndex:indexPath.row] objectForKey:@"code"];
    [self.tableView reloadData];
    [self updateLanguage];
}

    
    
- (IBAction)ButtonBackPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)updateLanguage{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSString * stringLng=selectedLang;
    NSMutableDictionary *dict ;
    BOOL is_user_login = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if(is_user_login){
        dict = [NSMutableDictionary dictionaryWithDictionary:@{
            P_USER_ID       :[dict1 objectForKey:P_USER_ID],
            P_U_LANGUAGE        :stringLng
        }];
    }else{
        dict = [NSMutableDictionary dictionaryWithDictionary:@{
            P_DRIVER_ID       :[dict1 objectForKey:P_DRIVER_ID],
            P_LANGUAGE        :stringLng
        }];
        NSDictionary *dictLogged = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
        [dict setObject:[dictLogged objectForKey:P_USER_ID] forKey:@"usr_ref_id"];
    }
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:is_user_login?UPDATE_USER_PROFILE:UPDATE_DRIVER_PROFILE
            d:dict
          isa:NO
           cb:^(id results, NSError *error) {
        if ([[[results objectForKey:P_STATUS] uppercaseString] isEqualToString:@"OK"]) {
            defaults_set_object(P_USER_DICT,[results objectForKey:P_RESPONSE] );
            if(is_user_login){
                defaults_set_object(P_USER_DICT_LOGGED,[results objectForKey:P_RESPONSE] );
            }
            [LanguageHelper  sharedInstance] .cunnrentLanguage=self->selectedLang;
            [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:[[LanguageHelper sharedInstance] getlcidForCode:self->selectedLang], nil] forKey:@"AppleLanguages"];
            [[NSUserDefaults standardUserDefaults] setObject:self->selectedLang forKey:@"language"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[LanguageHelper  sharedInstance] configureLanguage];
            [[NSNotificationCenter defaultCenter]
             postNotificationName:@"NotificationOnLanguageChanged"
             object:nil];
            [self setUIFields];
        }
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    }];
}



@end
