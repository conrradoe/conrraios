//
//  DataBase.h
//  Golden Moto Driver
//
//  Created by Grepix - Baij on 27/12/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
NS_ASSUME_NONNULL_BEGIN

@interface DataBase : NSObject {

    sqlite3 *database;

}

+(DataBase *) shareDataBase;

-(BOOL) createDataBase:(NSString *)DataBaseName;

-(NSString*) GetDatabasePath:(NSString *)database;

-(NSMutableArray *) getAllDataForQuery:(NSString *)sql  forDatabase:(NSString *)database;
-(void) createTable:(NSString *) insertSql forDatabase:(NSString *)database1;
-(void) inseryQuery:(NSString *) insertSql forDatabase:(NSString *)database1;
-(void) deleteQuery:(NSString *) deleteSql forDatabase:(NSString *)database1;
-(void) updateQuery:(NSString *) updateSql forDatabase:(NSString *)database1;

-(void) deleteRouteForAllTripID;
-(void) deleteRouteForTripID:(NSString *)tripID;
-(void) insertRouteLatLngForTripID:(NSString *)tripID lat:(float) lat lng:(float) lng;
-(NSMutableArray *) getRouteForTripID:(NSString *) tripID;

-(NSMutableArray *) getWatingForTripID:(NSString *) tripID;
-(NSMutableArray *) getLastWatingRowForTripID:(NSString *) tripID;

-(void) deleteWatingForAllTripID;
-(void) insertWaitingLatLngForTripID:(NSString *)tripID lat:(float) lat lng:(float) lng date:(NSDate*)date isStart:(BOOL)isStart locationAddress:(NSString *)locationAddress;
-(void) insertTripLogDataTripID:(NSString *)tripID ulat:(float) ulat ulng:(float) ulng dlat:(float) dlat dlng:(float) dlng tripStatus:(NSString*)tripStatus timeAt:(NSString*)timeAt key1:(NSString*)key1 key2:(NSString*)key2 key3:(NSString*)key3 key4:(NSString*)key4;
-(NSMutableArray *) getTripLogForTripID:(NSString *) tripID;
-(void) deleteTripLogTripID:(NSString *) tripID;

+(void) setUpRoutTrack;

@end

NS_ASSUME_NONNULL_END
