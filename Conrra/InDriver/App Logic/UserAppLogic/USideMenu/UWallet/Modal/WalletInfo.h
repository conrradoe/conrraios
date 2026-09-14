//
//  WalletInfo.h
//  HireMe Rider
//
//  Created by Grepix Infotech on 27/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TransactionModel.h"
@interface WalletInfo : NSObject



@property(nonatomic,strong) NSString *wallet_Transaction;
@property(nonatomic,strong) NSString *wallet_Trans_Commision_amt;
@property(nonatomic,strong) NSString *wallet_Trans_Created;
@property(nonatomic,strong) NSString *Wallet_Trans_Modified;
@property(nonatomic,strong) NSString *wallet_Trans_Net_Amt;
@property(nonatomic,strong) NSString *wallet_Trans_Other_Amt;
@property(nonatomic,strong) NSString *wallet_Trans_Tax_Amt;
@property(nonatomic,strong) NSString *wallet_Trans_Total_Amt;
@property(nonatomic,strong) NSString *wallet_Trans_Date;
@property(nonatomic,strong) NSString *wallet_Trans_Desc;
@property(nonatomic,strong) NSString *wallet_Trans_Status;
@property(nonatomic,strong) NSString *wallet_Trans_type;
@property(nonatomic,strong) NSString *wallet_Trans_Id;
@property(nonatomic,strong) NSString *wallet_Trans_Trip_Id;
@property(nonatomic,strong) NSString *wallet_Created;
@property(nonatomic,strong) NSString *wallet_Modified;
@property(nonatomic,strong) NSString *wallet_Remarks;
@property(nonatomic,strong) NSString *wallet_Trans_Add_Type;
@property(nonatomic,strong) NSString *wallet_Trans_User_Id;
@property(nonatomic,strong) NSString *wallet_User_Id;
@property(nonatomic,strong) NSString *current_bal;
@property(nonatomic,assign) float wallet_Amount;
@property(nonatomic,assign) float card_amt;
@property(nonatomic,assign) float wallet_amt;
@property(nonatomic,strong) TransactionModel *transactionModel;

-(instancetype)initWalletInfoWithArray:(NSMutableDictionary *)walletInfoDict;



@end

