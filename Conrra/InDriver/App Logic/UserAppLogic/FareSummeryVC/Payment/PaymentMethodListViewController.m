//
//  LanguageViewController.m
//  JS Rider
//
//  Created by Devineer on 25/06/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "PaymentMethodListViewController.h"
#import "PaymentTableViewCell.h"
#import <GIKit/GIKit.h>
#import "WebCallConstants.h"
#import "AppDelegate.h"
#import "ConstantModel.h"
#import "HomeViewController.h"
#import "LanguageHelper.h"
@interface PaymentMethodListViewController ()
{
    NSMutableArray *arrLanguage;
    NSString *selectedPaymentMethod;
    ConstantModel *constantModel;
    BOOL isOpenedPaymentScreen;
}

@end

@implementation PaymentMethodListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     constantModel =[ConstantModel getConstantsObject];
    self.lblHeaderTitle.text =[LanguageHelper getStringWithKey:@"k_r35_s1_payment_methods" defaultValue:@"Payment Methods"];
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    selectedPaymentMethod=[dict1 objectForKey:P_USER_DEFAULT_PAY_METHOD];
    arrLanguage = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"PaymentTableViewCell" bundle:nil] forCellReuseIdentifier:@"PaymentTableViewCell"];
    [self.btnAddCard setTitle:[LanguageHelper getStringWithKey:@"k_r35_s1_add"] forState:UIControlStateNormal];
    [self.btnContinue setTitle:[LanguageHelper getStringWithKey:@"k_r35_s1_continue"] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getCutomerPaymentMethod];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    static NSString *cellIdentifier = @"PaymentTableViewCell";
    
    
    PaymentTableViewCell *cell =
    [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[PaymentTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellIdentifier];
    }

    cell.selectionStyle =UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    NSDictionary * dictPayment=[arrLanguage objectAtIndex:indexPath.row];
    NSDictionary *dictCard=[dictPayment objectForKey:@"card"];
    cell.lbCard.text =[NSString stringWithFormat:@"****%@", [dictCard  objectForKey:@"last4"]];
    cell.lbCardType.text=[NSString stringWithFormat:@"%@", [[dictCard  objectForKey:@"brand"] uppercaseString]];
    cell.lbExpiry.text=[NSString stringWithFormat:@"%@/%@",[dictCard  objectForKey:@"exp_month"],[dictCard  objectForKey:@"exp_year"]];
    if ([[dictPayment objectForKey:@"id"] isEqualToString:selectedPaymentMethod]) {
        UIImage * image=[[UIImage imageNamed:@"radio-selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        cell.lbRadio.tintColor=[UIColor colorNamed:@"app_theame"];
           [cell.lbRadio setImage:image];
       }
       else{
           UIImage * image=[[UIImage imageNamed:@"radio-unselected"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
           cell.lbRadio.tintColor=[UIColor colorNamed:@"app_theame"];
           [cell.lbRadio setImage:image];
       }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
   
        return 75;
    
    
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
  NSDictionary * dictPayment=[arrLanguage objectAtIndex:indexPath.row];
    selectedPaymentMethod= [dictPayment objectForKey:@"id"];
    [self.tableView reloadData];
    
    
   
    
    
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *delete = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title: [LanguageHelper getStringWithKey:@"k_r35_s1_detach"] handler:^(UITableViewRowAction *action, NSIndexPath *indexPath)
                                    {
        [self askForRemove:indexPath];
    }];
    
    delete.backgroundColor = UIColor.redColor; // Replace with your color
    return @[delete];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
   
//    [tableData removeObjectAtIndex:indexPath.row];
}

-(void) askForRemove:(NSIndexPath *)indexPath{
    // Remove the row from data model
    UIAlertController * alertController=[UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_r35_s1_detach_card"] message:[LanguageHelper getStringWithKey:@"k_r35_s1_detach_card_text"] preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey: @"k_22_s4_no"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey: @"k_21_s4_yes"] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary * dictPayment=[self->arrLanguage objectAtIndex:indexPath.row];
        [self detachCutomerPaymentMethod:dictPayment];
    }]];
    [self presentViewController:alertController animated:YES completion:^{
        
    }];
}


- (IBAction)ButtonBackPressed:(id)sender {

    [self.navigationController popViewControllerAnimated:YES];
}



-(void) detachCutomerPaymentMethod:(NSDictionary * ) dictPayment
{
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."] ];
    NSString * paymentMethodId=[dictPayment objectForKey:@"id"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty(constantModel.stripe_s_key)/*STRIPE_SECRET_KEY*/ password:@"" persistence:NSURLCredentialPersistenceNone];
    NSString * urlForSave=[NSString stringWithFormat:@"https://api.stripe.com/v1/payment_methods/%@/detach",paymentMethodId];
    NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"POST" URLString:urlForSave parameters:nil error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
        NSDictionary * error=[responseObject objectForKey:@"error"];
        if(error==nil)
        {
            [self->arrLanguage removeObject:dictPayment];
            [self.tableView reloadData];
            if ([[dictPayment objectForKey:@"id"] isEqualToString:self->selectedPaymentMethod]) {
                
                [self detachDefaultPaymentMethodUserProfile];
            }
        }else{
            [UtilityClass swa:@"Detach card failed!" m: isEmpty([error objectForKey:@"message"]) cbt:@"Ok" obt:nil vc:self];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure: %@", error);
        [UtilityClass swa:@"Error!" m:@"Error " cbt:@"Ok" obt:nil vc:self];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    }];
    [manager.operationQueue addOperation:operation];
}



-(void) getCutomerPaymentMethod
{
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    ConstantModel *constModel=[ConstantModel getConstantsObject];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
     NSDictionary *WalletAmtDict = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    NSURLCredential *credential = [NSURLCredential credentialWithUser:isEmpty(constantModel.stripe_s_key)/*STRIPE_SECRET_KEY*/ password:@"" persistence:NSURLCredentialPersistenceNone];
    NSString * stripeCustomerId = isEmpty(constModel.is_stripe_live?[WalletAmtDict objectForKey:P_STRIPE_CUS_ID]:[WalletAmtDict objectForKey:P_STRIPE_DEV_CUS_ID]);
    if([ConstantModel getConstantsObject].is_stripe_live==NO){
        if(stripeCustomerId){
#if TARGET_OS_SIMULATOR
            stripeCustomerId = P_STRIPE_CUS_DEV_CUS_ID;
#else

#endif
        }
        
    }
    NSDictionary *parameters = @{@"customer":stripeCustomerId,@"type":@"card",@"limit":@"100"};
    NSString * urlForSave=[NSString stringWithFormat:@"https://api.stripe.com/v1/payment_methods"];
     NSMutableURLRequest *request= [manager.requestSerializer requestWithMethod:@"GET" URLString:urlForSave parameters:parameters error:nil];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCredential:credential];
    [operation setResponseSerializer:[AFJSONResponseSerializer alloc]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success: %@", responseObject);
        self->arrLanguage=[[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"data"]];
         if(self->arrLanguage.count==0)
         {
             if(self.isFromPaymentJob)    {
                 self->selectedPaymentMethod=nil;
             }else{
                
             }
             if(self->isOpenedPaymentScreen==NO){
             self->isOpenedPaymentScreen=YES;
             [self performSegueWithIdentifier:@"AddPaymentMethodViewController" sender:nil];
             }
//             self->selectedPaymentMethod=nil;
         }else{
             
         }
        [self.tableView reloadData];
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        self->selectedPaymentMethod=nil;
        NSLog(@"Failure: %@", error);
        [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    }];
    [manager.operationQueue addOperation:operation];
}



- (IBAction)onContinueButtonTap:(id)sender {
    
    if(selectedPaymentMethod!=nil&&selectedPaymentMethod.length>0)  {
        [self updateDefaultPaymentMethod];
    }else  {
        UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_s7_alert" defaultValue:@"Alert!"] message:[LanguageHelper getStringWithKey:@"k_r35_s1_please_select_payment_method" defaultValue:@"Please select a payment method"] preferredStyle:UIAlertControllerStyleAlert];
        [actionSheet addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Ok"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
           
        }]];
          [self presentViewController:actionSheet animated:YES completion:nil];
    }
}

- (IBAction)onAddCardButtonTap:(id)sender {
    [self performSegueWithIdentifier:@"AddPaymentMethodViewController" sender:nil];
}

-(void)updateDefaultPaymentMethod{
    
   
     if(selectedPaymentMethod.length==0)
     {
         return;
     }
    if(self.isFromPaymentJob)
    {
        NSDictionary * dict;
        for (NSDictionary * dictTemp in arrLanguage) {
            if([[dictTemp objectForKey:@"id"]  isEqualToString:selectedPaymentMethod]){
                dict = dictTemp;
            }
        }
        [self.delegate onPaymentIntentSelected:isEmpty(selectedPaymentMethod) dict:dict viewControlllor:self];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
   
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID       :[dict1 objectForKey:P_USER_ID],
        P_USER_DEFAULT_PAY_METHOD        :isEmpty(selectedPaymentMethod),
        //   P_USER_DEFAULT_PAY_MODE        :@"card"
    }];

    if(self.isFormPrepaireConfirmTrip)
    {
    }else{
        [dict setObject:@"card" forKey:P_USER_DEFAULT_PAY_MODE];
    }
    
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];

    [GIC mkwu:UPDATE_USER_PROFILE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
               // success
               [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
               defaults_set_object(P_USER_DICT_LOGGED,[results objectForKey:P_RESPONSE] );
               if(self.isFormPrepaireTrip)   {
                   for (UIViewController *controller in self.navigationController.viewControllers) {
                       if ([controller isKindOfClass:[HomeViewController class]]) {
                           if(self.isFormPrepaireConfirmTrip)   {
                               [self.delegate onPaymentMethodSelected:@"card" viewControlllor:self];
                           }
                           [self.navigationController popToViewController:controller
                                                                 animated:YES];
                           return;
                       }
                   }
               }else{
                   UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:[LanguageHelper getStringWithKey:@"k_33_success" defaultValue:@"Success"] message:[LanguageHelper getStringWithKey:@"k_r35_s1_payment_method_added_success" defaultValue:@"Payment method added successfully"] preferredStyle:UIAlertControllerStyleAlert];
                   [actionSheet addAction:[UIAlertAction actionWithTitle:[LanguageHelper getStringWithKey:@"k_18_s4_Ok" defaultValue:@"Ok"] style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                       [self dismissViewControllerAnimated:YES completion:^{
                       }];
                   }]];
                   [self presentViewController:actionSheet animated:YES completion:nil];
               }
           }
       }];
}



-(void)detachDefaultPaymentMethodUserProfile{
    NSDictionary *dict1 = [[NSUserDefaults standardUserDefaults]objectForKey:P_USER_DICT_LOGGED];
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:@{
        P_USER_ID       :[dict1 objectForKey:P_USER_ID],
        P_USER_DEFAULT_PAY_METHOD        :@"",
    }];
    [UtilityClass setLH:NO wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
    [GIC mkwu:UPDATE_USER_PROFILE
                  d:dict
      isa:NO
           cb:^(id results, NSError *error) {
           if ([[results objectForKey:P_STATUS] isEqualToString:@"OK"]) {
               // success
               [UtilityClass setLH:YES wt:[LanguageHelper getStringWithKey:@"k_53_s3_please_wait" defaultValue:@"Please wait..."]];
               self->selectedPaymentMethod=nil;
               defaults_set_object(P_USER_DICT_LOGGED,[results objectForKey:P_RESPONSE] );
               [self.tableView reloadData];
           }
           
       }];
}


@end
