//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "NotificationViewController.h"
#import "NotificationCell.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "NotificationModel.h"
#import "Utilities.h"
#import "BasePaging.h"
#import "UIScrollView+BottomRefreshControl.h"
#import "NotificationDetailViewController.h"
@interface NotificationViewController ()
{
    //    NSMutableArray *arrLanguage;
    //    NSString *selectedLang;
    UIRefreshControl *refreshControl;
    UIRefreshControl *   bottomRefreshControl;
    
}
@property(strong ,nonatomic) BasePaging * notifications;
@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lblNoNotifications.hidden=YES;
    [self setUIFields];
    self.notifications=[[BasePaging alloc]  init];
    self.notifications.limit=20;
    [self getNotificationConstant];
    [self setUpPullToRefresh];
    [self updateMarkAsReadAllNotification];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     [self setUIFields];
}

-(void) setUIFields{
    self.lblNoNotifications.text=[LanguageHelper getStringWithKey:@"k_s4_no_notifications"];
    self.lblHeaderTitle.text = [LanguageHelper getStringWithKey:@"k_15_s4_a1_notifications"];
//    [self.btnBack setBackgroundImage:[UIImage imageNamed:@"backward-arrow"] forState:UIControlStateNormal];

    
}

-(void) setUpPullToRefresh
{
    refreshControl = [[UIRefreshControl alloc]init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView setRefreshControl:refreshControl];
    self->bottomRefreshControl = [UIRefreshControl new];
    self->bottomRefreshControl.triggerVerticalOffset = 100.;
    self->bottomRefreshControl.tintColor=[UIColor grayColor];
    [self->bottomRefreshControl addTarget:self action:@selector(refreshLoadMore:) forControlEvents:UIControlEventValueChanged];
    self.tableView.bottomRefreshControl = self->bottomRefreshControl;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
      if([segue.identifier isEqualToString:@"NotificationDetailViewController"])
      {
          NotificationDetailViewController *vc=(NotificationDetailViewController*) segue.destinationViewController;
          vc.notificationModel=(NotificationModel*)sender;
      }
 }


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.notifications.data.count;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NotificationCell";
    NotificationCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
//    if (indexPath.row % 2 == 0) {
//        cell.backgroundColor =  [UIColor colorNamed:@"color_app_noti_1"];
//    } else {
//        [cell setBackgroundColor: [UIColor colorNamed:@"color_app_noti_2"]];
//    }
    cell.backgroundColor =  [UIColor clearColor];
    NotificationModel * noti=[self.notifications.data objectAtIndex:indexPath.row];
    [cell populateData:noti indexPath:indexPath];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationModel * noti=[self.notifications.data objectAtIndex:indexPath.row];
    int height=[UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-40, 300) forText:noti.message withFont:FONTS_THEME_REGULAR_NO_SCALE(13)];
    int heightTitle=[UtilityClass gTH:CGSizeMake(SCREEN_WIDTH-40, 300) forText:noti.title withFont:FONTS_THEME_BOLD_NO_SCALE(15)];
    return 50+height+heightTitle;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NotificationModel * notificationModel=[self.notifications.data objectAtIndex:indexPath.row];
     if(notificationModel.url.length>0)
     {
         [self performSegueWithIdentifier:@"NotificationDetailViewController" sender:notificationModel];
     }
}

- (IBAction)ButtonBackPressed:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}


-(NSMutableDictionary *) applyUserIdAndDriver{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary  *dictApi=[[NSMutableDictionary alloc] init];
    BOOL is_login_as_user = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if(is_login_as_user){
        [dictApi  setObject:[dict1  objectForKey:P_API_KEY] forKey:P_API_KEY];
        [dictApi  setObject:[dict1  objectForKey:P_USER_ID] forKey:@"to_id"];
        [dictApi  setObject:@"user" forKey:@"to_type"];
    }else{
        [dictApi  setObject:[dict1  objectForKey:P_API_KEY] forKey:P_API_KEY];
        [dictApi  setObject:[dict1  objectForKey:P_DRIVER_ID] forKey:@"to_id"];
        [dictApi  setObject:@"driver" forKey:@"to_type"];
    }
    return dictApi;
}
-(void)getNotificationConstant{
    NSMutableDictionary  *dict=[self applyUserIdAndDriver];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
    [GIC mkwu:API_GET_NOTIFICATION  d:dict  isa:NO   cb:^(id results, NSError *error) {
           [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_r30_s3_loading"]];
           if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"])
           {
               self.notifications.data=[NotificationModel parseNotification:[results objectForKey:P_RESPONSE]];
               [self.tableView reloadData];
           }
        if(self.notifications.data.count==0){
            self.lblNoNotifications.hidden=NO;
        }else{
            self.lblNoNotifications.hidden=YES;
        }
       }];
    
}

//{
//    created = "2019-05-08 07:27:10";
//    "from_id" = 1;
//    "from_type" = user;
//    id = 1;
//    message = "Use promo code 'ABC' to get 10% discount on your rides.";
//    "ref_id" = "";
//    "ref_status" = active;
//    "ref_type" = promo;
//    status = unread;
//    title = "";
//    "to_id" = 1238;
//    "to_type" = user;
//    url = "";
//}

-(void)refreshTable:(UIRefreshControl*) refresh
{
    NSMutableDictionary  *dict=[self applyUserIdAndDriver];
    if(self.notifications.data.count>0)
    {
        NotificationModel * model=[self.notifications.data objectAtIndex:0];
        [dict  setObject:isEmpty(model.noitificationId) forKey:@"last_notif_id"];
    }
    [GIC mkwu:API_GET_NOTIFICATION
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           if([[[results objectForKey:P_STATUS] uppercaseString]isEqualToString:@"OK"])
           {
               [self.notifications setPaggingData:results];
               NSMutableArray *arrayNewNotification=[NotificationModel parseNotification:[results objectForKey:P_RESPONSE]];
               if(arrayNewNotification.count>0)
               {
                   
                   if(self.notifications.data==nil)
                   {
                       self.notifications.data=[[NSMutableArray alloc] init];
                   }
                   [arrayNewNotification addObjectsFromArray:self.notifications.data];
                   self.notifications.data=arrayNewNotification;
                   [self.tableView reloadData];
               }
               if(self.notifications.data.count==0){
                   self.lblNoNotifications.hidden=NO;
               }else{
                   self.lblNoNotifications.hidden=YES;
               }
           }
           [self->refreshControl  endRefreshing];
       }];
    
}
-(void)refreshLoadMore:(UIRefreshControl*) refresh
{
    if(!self.notifications.isMoreData)
    {
        [self->bottomRefreshControl endRefreshing];
        return;
    }
    NSMutableDictionary  *dict=[self applyUserIdAndDriver];
    
    NSMutableDictionary * dictPaging=[self.notifications getDictApiForPage];
    if(self.notifications.data.count>0)
    {
        [dictPaging setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.notifications.data.count] forKey:@"offset"];
    }
    [dict addEntriesFromDictionary:dictPaging];
    [GIC mkwu:API_GET_NOTIFICATION
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           if([[[results objectForKey:P_STATUS]uppercaseString]isEqualToString:@"OK"])
           {
               NSMutableArray *arrayNewNotification=[NotificationModel parseNotification:[results objectForKey:P_RESPONSE]];
               if(arrayNewNotification.count>0)
               {
                   [self.notifications setPaggingData:results];
                   [self.notifications addNewPageData:arrayNewNotification];
                   if(self.notifications.data.count==0)
                   {
                       self.notifications.last_offset=0;
                       self.notifications.next_offset=0;
                   }
                   [self.tableView reloadData];
               }
               if(self.notifications.data.count==0){
                   self.lblNoNotifications.hidden=NO;
               }else{
                   self.lblNoNotifications.hidden=YES;
               }
           }
           [self->bottomRefreshControl  endRefreshing];
       }];
    
}
-(void) updateMarkAsReadAllNotification{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT];
    NSMutableDictionary  *dict=[[NSMutableDictionary alloc] init];
    BOOL is_login_as_user = [defaults_object(P_IS_USER_LOGIN) boolValue];
    if(is_login_as_user){
        [dict  setObject:[dict1  objectForKey:P_API_KEY] forKey:P_API_KEY];
        [dict  setObject:[dict1  objectForKey:P_USER_ID] forKey:@"to_id"];
    [dict  setObject:@"user" forKey:@"to_type"];
    }else{
        [dict  setObject:[dict1  objectForKey:P_API_KEY] forKey:P_API_KEY];
        [dict  setObject:[dict1  objectForKey:P_DRIVER_ID] forKey:@"to_id"];
    [dict  setObject:@"driver" forKey:@"to_type"];
    }
        
    [GIC mkwu:API_MARK_AS_READ_NOTIFICATION    d:dict isa:NO  cb:^(id results, NSError *error) {
        if([[[results objectForKey:P_STATUS]uppercaseString]isEqualToString:@"OK"])
        {
            [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        }
    }];
}
@end

