//
//  TransactionModel.h

//
//  Created by Grepix - Baij on 04/12/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransactionModel : NSObject

@property(nonatomic,strong) NSString *transaction_id;
@property(nonatomic,assign) int trip_id;
@property(nonatomic,strong) NSString *trans_status;
@property(nonatomic,strong) NSString *trans_pay_mode;
@property(nonatomic,strong) NSString *trans_description;
@property(nonatomic,strong) NSString *trans_date;
@property(nonatomic,strong) NSString *total_amt;
@property(nonatomic,strong) NSString *tax_amt;
@property(nonatomic,strong) NSString *other_amt;
@property(nonatomic,strong) NSString *net_amt;
@property(nonatomic,strong) NSString *commission_amt;
@property(nonatomic,strong) NSString *exc_dt;
@property(nonatomic,strong) NSString *currency; 



-(instancetype) initWithDict:(NSDictionary *) dict;
@end

NS_ASSUME_NONNULL_END
