//
//  AddMoneyInfo.m

//
//  Created by Grepix Infotech on 28/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "AddMoneyInfo.h"

@implementation AddMoneyInfo
-(instancetype)initAddMoneyToWalletInfoWithDict:(NSMutableDictionary *)walletInfoDict{
    
    self = [super init];
    if(self){
        [self parseAddedMoneyToWalletResponse:walletInfoDict];
    }
    return self;
}

-(void)parseAddedMoneyToWalletResponse :(NSMutableDictionary *)walletInfoDict{
   
    self.commission_Amt = [walletInfoDict objectForKey:@"commission_amt"];
    self.created = [walletInfoDict objectForKey:@"created"];
    self.modified = [walletInfoDict objectForKey:@"modified"];
    self.net_Amt = [walletInfoDict objectForKey:@"net_amt"];
    self.other_Amt = [walletInfoDict objectForKey:@"other_amt"];
    self.tax_Amt = [walletInfoDict objectForKey:@"tax_amt"];
    self.total_Amt = [walletInfoDict objectForKey:@"total_amt"];
    self.tran_Date = [walletInfoDict objectForKey:@"trans_date"];
    self.tran_Desc = [walletInfoDict objectForKey:@"trans_description"];
    self.tran_Status = [walletInfoDict objectForKey:@"trans_status"];
    self.tran_Type = [walletInfoDict objectForKey:@"trans_type"];
    self.tran_ID = [walletInfoDict objectForKey:@"transaction_id"];
    self.trip_ID = [walletInfoDict objectForKey:@"trip_id"];
    
    
    
}




@end
