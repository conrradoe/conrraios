//
//  AddMoneyInfo.h

//
//  Created by Grepix Infotech on 28/11/18.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddMoneyInfo : NSObject

@property(nonatomic,strong)  NSString *message;


@property(nonatomic,strong)  NSString *commission_Amt;
@property(nonatomic,strong)  NSString *created;
@property(nonatomic,strong)  NSString *modified;
@property(nonatomic,strong)  NSString *net_Amt;
@property(nonatomic,strong)  NSString *other_Amt;
@property(nonatomic,strong)  NSString *tax_Amt;
@property(nonatomic,strong)  NSString *total_Amt;
@property(nonatomic,strong)  NSString *tran_Date;
@property(nonatomic,strong)  NSString *tran_Desc;
@property(nonatomic,strong)  NSString *tran_Status;
@property(nonatomic,strong)  NSString *tran_Type;
@property(nonatomic,strong)  NSString *tran_ID;
@property(nonatomic,strong)  NSString *trip_ID;


-(instancetype)initAddMoneyToWalletInfoWithDict:(NSMutableDictionary *)walletInfoDict;
@end
