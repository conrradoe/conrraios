//
//  WalletInfo.m
//  HireMe Rider
//
//  Created by Grepix Infotech on 27/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "WalletInfo.h"

@implementation WalletInfo
-(instancetype)initWalletInfoWithArray:(NSMutableDictionary *)walletInfoDict{
    self = [super init];
    if(self){
        [self parseWalletResponse:walletInfoDict];
    }
    return self;
}

-(void) parseWalletResponse:(NSMutableDictionary *)WalletInfoDict {
    
    @try {
        NSDictionary * transDict  = [WalletInfoDict objectForKey:@"Transaction"];
        if([transDict isKindOfClass:[NSDictionary class]]){
            self.wallet_Trans_Commision_amt    = [transDict objectForKey:@"commission_amt"];
            self.wallet_Trans_Created          = [transDict objectForKey:@"created"];
            self.Wallet_Trans_Modified         = [transDict objectForKey:@"modified"];
            self.wallet_Trans_Net_Amt          = [transDict objectForKey:@"net_amt"];
            self.wallet_Trans_Other_Amt        = [transDict objectForKey:@"other_amt"];
            self.wallet_Trans_Tax_Amt          = [transDict objectForKey:@"tax_amt"];
            self.wallet_Trans_Total_Amt        = [transDict objectForKey:@"total_amt"];
            self.wallet_Trans_Date             = [transDict objectForKey:@"trans_date"];
            self.wallet_Trans_Desc             = [transDict objectForKey:@"trans_description"];
            self.wallet_Trans_Status           = [transDict objectForKey:@"trans_status"];
            self.wallet_Trans_type             = [transDict objectForKey:@"trans_type"];
            self.wallet_Trans_Id               = [transDict objectForKey:@"transaction_id"];
            self.wallet_Trans_Trip_Id          = [transDict objectForKey:@"trip_id"];
            self.wallet_Amount                 = [[WalletInfoDict objectForKey:@"amount"] floatValue];
            self.wallet_Created                = [WalletInfoDict objectForKey:@"created"];
            self.wallet_Modified               = [WalletInfoDict objectForKey:@"modified"];
            self.wallet_Remarks                = [WalletInfoDict objectForKey:@"remarks"];
            self.wallet_Trans_Add_Type         = [WalletInfoDict objectForKey:@"trans_type"];
            self.wallet_Trans_User_Id          = [WalletInfoDict objectForKey:@"trans_user_id"];
            self.wallet_Trans_Id               = [WalletInfoDict objectForKey:@"transaction_id"];
            self.wallet_User_Id                = [WalletInfoDict objectForKey:@"user_id"];
            self.card_amt=[[WalletInfoDict objectForKey:@"card_amt"] floatValue];
            self.wallet_amt=[[WalletInfoDict objectForKey:@"wallet_amt"] floatValue];
            self.current_bal=[WalletInfoDict objectForKey:@"current_bal"]; 
            self.transactionModel=[[TransactionModel alloc ] initWithDict:[WalletInfoDict objectForKey:@"Transaction"]];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",WalletInfoDict);
    } @finally {
        
    }
    
    
    
    
    
    
    
    
    
}

@end

