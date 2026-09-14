//
//  DataBase.m
//  Golden Moto Driver
//
//  Created by Grepix - Baij on 27/12/19.
//  Copyright © 2023 Grepixit. All rights reserved.
//

#import "DataBase.h"
#import "Keys.h"
#import "Utilities.h"
@implementation DataBase

static DataBase *SampleDataBase =nil;


+(DataBase*) shareDataBase{

    if(!SampleDataBase){
        SampleDataBase = [[DataBase alloc] init];
    }

    return SampleDataBase;

}


-(NSString *) GetDatabasePath:(NSString *)database1{


    [self createDataBase:database1];

    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:database1];
}


-(BOOL) createDataBase:(NSString *)DataBaseName{
    BOOL success;

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DataBaseName];

    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return success;
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DataBaseName];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];

    if (!success) {
       

    }else{
          
    }
    
    
    return success;
}



-(NSMutableArray *) getAllDataForQuery:(NSString *)sql  forDatabase:(NSString *)database1{

    sqlite3_stmt *statement = nil ;

    NSString *path = [self GetDatabasePath:database1];

    NSMutableArray *alldata;
    alldata = [[NSMutableArray alloc] init];

    if(sqlite3_open([path UTF8String],&database) == SQLITE_OK )
    {
        NSString *query = sql;

        if((sqlite3_prepare_v2(database,[query UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            while(sqlite3_step(statement) == SQLITE_ROW)
            {

                NSMutableDictionary *currentRow = [[NSMutableDictionary alloc] init];

                int count = sqlite3_column_count(statement);

                for (int i=0; i < count; i++) {

                    char *name = (char*) sqlite3_column_name(statement, i);
                    char *data = (char*) sqlite3_column_text(statement, i);

                    NSString *columnData;
                    NSString *columnName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];


                    if(data != nil)
                        columnData = [NSString stringWithCString:data encoding:NSUTF8StringEncoding];
                    else {
                        columnData = @"";
                    }

                    [currentRow setObject:columnData forKey:columnName];
                }

                [alldata addObject:currentRow];
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);

    return alldata;

}

-(void) inseryQuery:(NSString *) insertSql forDatabase:(NSString *)database1{

    sqlite3_stmt *statement = nil ;

    NSString *path = [self GetDatabasePath:database1];

    if(sqlite3_open([path UTF8String],&database) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(database,[insertSql UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_OK){
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);

}

-(void) createTable:(NSString *) insertSql forDatabase:(NSString *)database1{

  

    NSString *path = [self GetDatabasePath:database1];

    if(sqlite3_open([path UTF8String],&database) == SQLITE_OK )
    {
         
        if(sqlite3_exec(database, [insertSql UTF8String], NULL,NULL, NULL) == SQLITE_OK)
        {
            NSLog(@"User table created successfully..");
        }
//        sqlite3_finalize(statement);
    }
    sqlite3_close(database);

}


-(void) updateQuery:(NSString *) updateSql forDatabase:(NSString *)database1{

    sqlite3_stmt *statement = nil ;

    NSString *path = [self GetDatabasePath:database1];

    if(sqlite3_open([path UTF8String],&database) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(database,[updateSql UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_OK){
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);

}

-(void) deleteQuery:(NSString *) deleteSql forDatabase:(NSString *)database1{

    sqlite3_stmt *statement = nil ;

    NSString *path = [self GetDatabasePath:database1];

    if(sqlite3_open([path UTF8String],&database) == SQLITE_OK )
    {
        if((sqlite3_prepare_v2(database,[deleteSql UTF8String],-1, &statement, NULL)) == SQLITE_OK)
        {
            if(sqlite3_step(statement) == SQLITE_OK){
            }
        }
        sqlite3_finalize(statement);
    }
    sqlite3_close(database);

}

-(void) insertRouteLatLngForTripID:(NSString *)tripID lat:(float) lat lng:(float) lng
{
    NSString * insertQuery =[NSString stringWithFormat:@"insert into DRIVER_ROUTE (TRIP_ID,LAT,LNG) values('%@','%f','%f')",tripID,lat,lng];
        [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
}

-(void) insertWaitingLatLngForTripID:(NSString *)tripID lat:(float) lat lng:(float) lng date:(NSDate*)date isStart:(BOOL)isStart locationAddress:(NSString *)locationAddress
{
    
//    CREATE TABLE IF NOT EXISTS WAITING_DATA (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, WAITING_DATE TEXT, IS_START INTEGER, LOCATION TEXT,LAT TEXT, LNG TEXT,EXTRA TEXT
    
    if(isStart==NO)
    {
        NSArray *array=[self getLastWatingRowForTripID:tripID];
        if(array.count>0)
        {
            NSDictionary * dict=[array firstObject];
            if([[dict objectForKey:@"IS_START"] boolValue])
            {
                NSDateFormatter *df= [[NSDateFormatter alloc] init];
                [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                
                NSString * dateFormated=[Utilities getStringFromDate:date];
                NSDate *dateStart = [df dateFromString:[dict objectForKey:@"WAITING_DATE_START"]];
                NSDate * dateNow=[df dateFromString:dateFormated];
                long diff=([dateNow timeIntervalSince1970]-[dateStart timeIntervalSince1970])/60;
                
                NSString * queryUpdate=[NSString stringWithFormat:@"UPDATE WAITING_DATA SET WAITING_DATE_END='%@' , IS_START='0', END_LAT ='%f',END_LNG ='%f', WAIT_DURATION = '%ld' WHERE TRIP_ID = %@",dateFormated,lat,lng,diff,tripID];
                [[DataBase shareDataBase] updateQuery:queryUpdate forDatabase:Data_BASE_NAME];
                
            }
        }
    }else
    {
        NSString * dateFormated=[Utilities getStringFromDate:date];
        NSString * insertQuery =[NSString stringWithFormat:@"insert into WAITING_DATA (TRIP_ID,START_LAT,START_LNG,START_LOCATION,IS_START,WAITING_DATE_START) values('%@','%f','%f','%@','%d','%@')",tripID,lat,lng,locationAddress,isStart?1:0,dateFormated];
        [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
    }
}



-(void) deleteRouteForTripID:(NSString *)tripID
{
    NSString * insertQuery =[NSString stringWithFormat:@"delete from DRIVER_ROUTE WHERE TRIP_ID = '%@'",tripID];
    [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
       
}

-(void) deleteRouteForAllTripID
{
    NSString * insertQuery =[NSString stringWithFormat:@"delete from DRIVER_ROUTE WHERE 1"];
      [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
}

-(void) deleteWatingForAllTripID
{
    NSString * insertQuery =[NSString stringWithFormat:@"delete from WAITING_DATA WHERE 1"];
      [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
}

-(NSMutableArray *) getWatingForTripID:(NSString *) tripID
{
    NSString * query=[NSString stringWithFormat:@"select * from WAITING_DATA WHERE  TRIP_ID = '%@' ",tripID];
    NSMutableArray * arra=[[DataBase shareDataBase] getAllDataForQuery:query forDatabase:Data_BASE_NAME];
   
    return arra;
}
-(NSMutableArray *) getLastWatingRowForTripID:(NSString *) tripID
{
    NSString * query=[NSString stringWithFormat:@"select * from WAITING_DATA WHERE  TRIP_ID = '%@' ORDER BY ID DESC LIMIT 1 ",tripID];
    NSMutableArray * arra=[[DataBase shareDataBase] getAllDataForQuery:query forDatabase:Data_BASE_NAME];

    return arra;
}
//SELECT * FROM tablename ;


-(NSMutableArray *) getRouteForTripID:(NSString *) tripID
{
    NSString * query=[NSString stringWithFormat:@"select * from DRIVER_ROUTE WHERE  TRIP_ID = '%@' ",tripID];
    NSMutableArray * arra=[[DataBase shareDataBase] getAllDataForQuery:query forDatabase:Data_BASE_NAME];
    return arra;
}




+(void) setUpRoutTrack
{
    NSString * path=[[DataBase shareDataBase] GetDatabasePath:Data_BASE_NAME];
       if(path==nil)
       {
           BOOL isCreated= [[DataBase shareDataBase] createDataBase:Data_BASE_NAME];
           if(isCreated)
           {
               NSString * quuery=@"CREATE TABLE IF NOT EXISTS DRIVER_ROUTE (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, LAT TEXT, LNG TEXT)";
               [[DataBase shareDataBase] createTable:quuery forDatabase:Data_BASE_NAME ];
                    // create table for waiting data
               //           yyyy-MM-DD HH:MM:SS.SSS
                NSString * queryWaitingInfo=@"CREATE TABLE IF NOT EXISTS WAITING_DATA (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, WAITING_DATE_START TEXT, IS_START TEXT, START_LOCATION TEXT,START_LAT TEXT, START_LNG TEXT,START_EXTRA TEXT, WAITING_DATE_END TEXT, END_LOCATION TEXT,END_LAT TEXT, END_LNG TEXT,END_EXTRA TEXT,WAIT_DURATION TEXT)";
               [[DataBase shareDataBase] createTable:queryWaitingInfo forDatabase:Data_BASE_NAME ];
               NSString * quueryLog=@"CREATE TABLE IF NOT EXISTS DRIVER_TRIP_LOG (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, U_LAT TEXT, U_LNG TEXT, D_LAT TEXT, D_LNG TEXT, TRIP_STATUS TEXT, TIME_AT TEXT, KEY_1 TEXT, KEY_2 TEXT, KEY_3 TEXT, KEY_4 TEXT)";
               [[DataBase shareDataBase] createTable:quueryLog forDatabase:Data_BASE_NAME ];
           }
       }else
       {
           // create table for route
           NSString * quuery=@"CREATE TABLE IF NOT EXISTS DRIVER_ROUTE (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, LAT TEXT, LNG TEXT)";
           [[DataBase shareDataBase] createTable:quuery forDatabase:Data_BASE_NAME ];
            // create table for waiting data
//           yyyy-MM-DD HH:MM:SS.SSS
           NSString * queryWaitingInfo=@"CREATE TABLE IF NOT EXISTS WAITING_DATA (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, WAITING_DATE_START TEXT, IS_START TEXT, START_LOCATION TEXT,START_LAT TEXT, START_LNG TEXT,START_EXTRA TEXT, WAITING_DATE_END TEXT, END_LOCATION TEXT,END_LAT TEXT, END_LNG TEXT,END_EXTRA TEXT,WAIT_DURATION TEXT)";
           [[DataBase shareDataBase] createTable:queryWaitingInfo forDatabase:Data_BASE_NAME ];
           
           NSString * quueryLog=@"CREATE TABLE IF NOT EXISTS DRIVER_TRIP_LOG (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, U_LAT TEXT, U_LNG TEXT, D_LAT TEXT, D_LNG TEXT, TRIP_STATUS TEXT, TIME_AT TEXT, KEY_1 TEXT, KEY_2 TEXT, KEY_3 TEXT, KEY_4 TEXT)";
           [[DataBase shareDataBase] createTable:quueryLog forDatabase:Data_BASE_NAME ];
       }
}


-(void) insertTripLogDataTripID:(NSString *)tripID ulat:(float) ulat ulng:(float) ulng dlat:(float) dlat dlng:(float) dlng tripStatus:(NSString*)tripStatus timeAt:(NSString*)timeAt key1:(NSString*)key1 key2:(NSString*)key2 key3:(NSString*)key3 key4:(NSString*)key4
{
    
//    NSString * quueryLog=@"CREATE TABLE IF NOT EXISTS DRIVER_TRIP_LOG (ID INTEGER PRIMARY KEY AUTOINCREMENT, TRIP_ID TEXT, U_LAT TEXT, U_LNG TEXT, D_LAT TEXT, D_LNG TEXT, TRIP_STATUS TEXT, TIME_AT TEXT, KEY_1 TEXT, KEY_2 TEXT, KEY_3 TEXT, KEY_4 TEXT)";
    BOOL isExit= [self isStatusUpdatedTripLogForTripID:tripID tripStatus:tripID];
    if(isExit){
        [self deleteTripIDAndOldTripStatusLogTripID:tripID tripStatus:tripID];
    }
    NSString * insertQuery =[NSString stringWithFormat:@"insert into DRIVER_TRIP_LOG (TRIP_ID,U_LAT,U_LNG,D_LAT,D_LNG,TRIP_STATUS,TIME_AT,KEY_1,KEY_2,KEY_3,KEY_4) values('%@','%f','%f','%f','%f','%@','%@','%@','%@','%@','%@')",tripID,ulat,ulng,dlat,dlng,tripStatus,timeAt,key1,key2,key3,key4];
    [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
}

-(void) deleteTripIDAndOldTripStatusLogTripID:(NSString *) tripID tripStatus:(NSString*)tripStatus
{
    NSString * insertQuery =[NSString stringWithFormat:@"delete from DRIVER_TRIP_LOG  WHERE TRIP_ID = '%@'  and TRIP_STATUS = '%@' ",tripID,tripStatus];
      [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
}

-(BOOL ) isStatusUpdatedTripLogForTripID:(NSString *) tripID tripStatus:(NSString*)tripStatus{
    NSString * query=[NSString stringWithFormat:@"select * from DRIVER_TRIP_LOG WHERE  TRIP_ID = '%@' and TRIP_STATUS = '%@' ORDER BY ID DESC LIMIT 1 ",tripID,tripStatus];
    NSMutableArray * arra=[[DataBase shareDataBase] getAllDataForQuery:query forDatabase:Data_BASE_NAME];
    if(arra.count>0){
        return YES;
    }
    return NO;
}


-(NSMutableArray *) getTripLogForTripID:(NSString *) tripID
{
    NSString * query=[NSString stringWithFormat:@"select * from DRIVER_TRIP_LOG WHERE  TRIP_ID = '%@' ",tripID];
    NSMutableArray * arra=[[DataBase shareDataBase] getAllDataForQuery:query forDatabase:Data_BASE_NAME];
   
    return arra;
}
-(void) deleteTripLogTripID:(NSString *) tripID
{
    NSString * insertQuery =[NSString stringWithFormat:@"delete from DRIVER_TRIP_LOG WHERE TRIP_ID = '%@' ",tripID];
      [[DataBase shareDataBase]  inseryQuery:insertQuery forDatabase:Data_BASE_NAME];
}
@end
