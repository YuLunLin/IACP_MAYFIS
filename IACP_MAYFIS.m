//
//  IACP_MAYFIS.m
//  IACP_MAYFIS
//
//  Created by Grace on 12/5/10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "IACP_MAYFIS.h"
#import "IACP_AppSupport.h"

@implementation IACP_MAYFIS

-(id)init
{
	self = [super init];
	if(!self)
		return nil;
	return self;
}

-(void)dealloc
{
	[super dealloc];
}

// 輸入AOI SN(Panel SN 碼),回傳8連板 MLB SN
- (NSString *)CheckAOISNoWc:(NSString *)AOISNo stationName:(NSString *)testStation
{
    IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
    NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
    NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
	
    
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
    {
        if ([AOISNo isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The Panel SN isn't exist!"];
        }
        else if ([testStation isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The test station isn't exist!"];
        }
        else
        {    
            NSString *dummyData = [[NSString alloc] initWithString:@"0,CC400650065DCLV1,,,,,,,CC40065006CDCLV1"];
            return dummyData;
        }
    }
    else
    {
        NSString *userName = [connectionData objectForKey:@"username"];
        NSString *passWord = [connectionData objectForKey:@"password"];
        NSString *serverName = [connectionData objectForKey:@"servername"];
        NSString *dbName = [connectionData objectForKey:@"dbname"];	
	
        // 利用NSString本身提供的方法,將字串與參數串連起來成為一個新字串 
        NSMutableString *commandString = [NSMutableString stringWithFormat:@"exec uspSFCCheckAOISNoWc '%@', '%@'",AOISNo, testStation];	
	
        //NSLog(@"%@,%@,%@,%@,%@,",commandString,userName,passWord,serverName,dbName);
	
        NSArray * retArray = [tempAppSuppot queryDataRetWithSemicolon:userName 
														 password:passWord 
													   servername:serverName 
														   dbname:dbName
														 commands:commandString];
	
        [tempAppSuppot release];
	
        if ([[retArray objectAtIndex:0] isEqualToString:@"0" ])
        {
            NSString * multiMLBSNo = [[NSString alloc] initWithFormat:@"%@,%@",[retArray objectAtIndex:0],[retArray objectAtIndex:2]];
            return multiMLBSNo;
        }
        else
        {
            //NSString * MLBSNo = [NSString stringWithFormat:@"DB Connect error!"];
            //NSRunAlertPanel(@"Alert", @"DB Connect error!", @"Yes", nil, nil);
            NSString * errMessage = [[NSString alloc] initWithFormat:@"%@,%@",[retArray objectAtIndex:0],[retArray objectAtIndex:1]];
            return errMessage;
        }
    }
     
}


// check individual MLB SN
// input: MLB SN
// output: 0(check fail)/1(check success)
- (NSString *)CheckCMBSNoWc:(NSString *)CMBSNo stationName:(NSString *)testStation
{
    IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
    NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
    NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
	
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
    {
        if ([CMBSNo isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The MLB SN isn't exist!"];
        }
        else if ([testStation isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The test station isn't exist!"];
        }
        else
        {    
            NSString *dummyData = [[NSString alloc] initWithString:@"0,CC400650065DCLV1"];
            return dummyData;
        }
    }
    else
    {
        NSString *userName = [connectionData objectForKey:@"username"];
        NSString *passWord = [connectionData objectForKey:@"password"];
        NSString *serverName = [connectionData objectForKey:@"servername"];
        NSString *dbName = [connectionData objectForKey:@"dbname"];	
	
        // 利用NSString本身提供的方法,將字串與參數串連起來成為一個新字串
        NSMutableString *commandString = [NSMutableString stringWithFormat:@"exec uspSFCCheckCMBSNWcRetMLB '%@', '%@'",CMBSNo, testStation];	
	
        NSArray * retArray = [tempAppSuppot queryDataRetWithSemicolon:userName 
                                                         password:passWord 
                                                       servername:serverName 
                                                           dbname:dbName
                                                         commands:commandString];
    
        [tempAppSuppot release];
	
        if ([[retArray objectAtIndex:0] isEqualToString:@"0" ])
        {
            //NSString * MLBSNo = [retArray objectAtIndex:2];
            NSString * MLBSNo = [[NSString alloc] initWithFormat:@"%@,%@",[retArray objectAtIndex:0],[retArray objectAtIndex:2]];
            return MLBSNo;
        }
        else
        {
            //NSString * MLBSNo = [NSString stringWithFormat:@"DB Connect error!"];
            //NSRunAlertPanel(@"Alert", @"DB Connect error!", @"Yes", nil, nil);
            //NSString * errMessage = [[NSString alloc] initWithFormat:@""];
            NSString * errMessage = [[NSString alloc] initWithFormat:@"%@,%@",[retArray objectAtIndex:0],[retArray objectAtIndex:1]];
            return errMessage;
        }
    }
}
//2012.8.8  by Billy
// 用途:check CMBSNO回傳四組CMBSNo
// 輸入:CMBSNo ＆ station name
// 輸出:以String方式輸出, ";" 區分四個資訊
//     1. 0:pass   非0:Error
//     2. message:  successful or error information
//     3.CMBSNo以逗號區隔
//     4.空值

- (NSString *)CheckMLBSNWcRetPanelMLB:(NSString *)MLBSN stationName:(NSString *)testStation
{
    IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
    NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
    NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
	
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"])
    {
        if ([MLBSN isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The MLB SN isn't exist!"];
        }
        else if ([testStation isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The test station isn't exist!"];
        }
        else
        {
            NSString *dummyData = [[NSString alloc] initWithString:@"0,CC400650065DCLV1"];
            return dummyData;
        }
    }
    else
    {
        NSString *userName = [connectionData objectForKey:@"username"];
        NSString *passWord = [connectionData objectForKey:@"password"];
        NSString *serverName = [connectionData objectForKey:@"servername"];
        NSString *dbName = [connectionData objectForKey:@"dbname"];
        
        // 利用NSString本身提供的方法,將字串與參數串連起來成為一個新字串
        NSMutableString *commandString = [NSMutableString stringWithFormat:@"exec uspSFCCheckCMBSNOWcRetPanelMLB '%@', '%@'",MLBSN, testStation];
        //return commandString;
        
        NSArray * retArray = [tempAppSuppot queryDataRetWithSemicolon:userName
                                                             password:passWord
                                                           servername:serverName
                                                               dbname:dbName
                                                             commands:commandString];
        
        [tempAppSuppot release];
        NSString * Message = [[NSString alloc] initWithFormat:@"%@;%@;%@;%@",[retArray objectAtIndex:0],[retArray objectAtIndex:1],[retArray objectAtIndex:2],[retArray objectAtIndex:3]];
        return Message;    }
}

//2012.8.8  by Billy
// 用途:check FGSN回傳四組CMBSNo
// 輸入:FGSN(客戶序號) ＆ station name
// 輸出:以String方式輸出, ";" 區分四個資訊
//     1. 0:pass   非0:Error
//     2. message:  successful or error information
//     3.CMBSNo以逗號區隔
//     4.空值

- (NSString *)CheckFGSNWcRetPanelMLB:(NSString *)FGSN stationName:(NSString *)testStation
{
    IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
    NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
    NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
	
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"])
    {
        if ([FGSN isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The MLB SN isn't exist!"];
        }
        else if ([testStation isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The test station isn't exist!"];
        }
        else
        {
            NSString *dummyData = [[NSString alloc] initWithString:@"0,CC400650065DCLV1"];
            return dummyData;
        }
    }
    else
    {
        NSString *userName = [connectionData objectForKey:@"username"];
        NSString *passWord = [connectionData objectForKey:@"password"];
        NSString *serverName = [connectionData objectForKey:@"servername"];
        NSString *dbName = [connectionData objectForKey:@"dbname"];
        
        // 利用NSString本身提供的方法,將字串與參數串連起來成為一個新字串
        NSMutableString *commandString = [NSMutableString stringWithFormat:@"exec uspSFCCheckCFGSNWcRetPanelMLB '%@', '%@'",FGSN, testStation];
        
        NSArray * retArray = [tempAppSuppot queryDataRetWithSemicolon:userName
                                                             password:passWord
                                                           servername:serverName
                                                               dbname:dbName
                                                             commands:commandString];
        
        [tempAppSuppot release];
        NSString * Message = [[NSString alloc] initWithFormat:@"%@;%@;%@;%@",[retArray objectAtIndex:0],[retArray objectAtIndex:1],[retArray objectAtIndex:2],[retArray objectAtIndex:3]];
        return Message;    
    }

}


//
- (NSString *)UploadTestResultCMBSNo:(NSString *)MLBSNotestResult stationName:(NSString *)testStation
{
    IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
    NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
    NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
	
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
    {
        if ([MLBSNotestResult isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,upload result failed!"];
        }
        else if ([testStation isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The test station isn't exist!"];
        }
        else
        {    
            NSString *dummyData = [[NSString alloc] initWithString:@"0,Successful!"];
            return dummyData;
        }
    }
    else
    {
        NSString *userName = [connectionData objectForKey:@"username"];
        NSString *passWord = [connectionData objectForKey:@"password"];
        NSString *serverName = [connectionData objectForKey:@"servername"];
        NSString *dbName = [connectionData objectForKey:@"dbname"];	
	
        // 利用NSString本身提供的方法,將字串與參數串連起來成為一個新字串
        NSMutableString *commandString = [NSMutableString stringWithFormat:@"exec uspSFCUploadTestResultCMBSN '%@', '%@'",MLBSNotestResult, testStation];	
	
        NSArray * retArray = [tempAppSuppot queryDataRetWithSemicolon:userName 
														 password:passWord 
													   servername:serverName 
														   dbname:dbName
														 commands:commandString];
	
        [tempAppSuppot release];
    
        NSString * Message = [[NSString alloc] initWithFormat:@"%@,%@",[retArray objectAtIndex:0],[retArray objectAtIndex:1]];
        return Message;
    }
}

- (NSString *)UploadFailItemCMBSNo:(NSString *)MLBSNo stationName:(NSString *)testStation SWVersion:(NSString *)version linename:(NSString *)lineName testitem:(NSString *)testItem testvalue:(NSString *)testValue unit:(NSString *)Unit uplimit:(id)Up_LIM downlimit:(id)Down_LIM
{
    IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
    NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
    NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
    
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
    {
        if ([MLBSNo isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,upload result failed!"];
        }
        else if ([testStation isEqualToString:@""])
        {
            return [[NSString alloc] initWithString:@"1,The test station isn't exist!"];
        }
        else
        {    
            NSString *dummyData = [[NSString alloc] initWithString:@"0,Successful!"];
            return dummyData;
        }
    }
    else
    {
        NSString *userName = [connectionData objectForKey:@"username"];
        NSString *passWord = [connectionData objectForKey:@"password"];
        NSString *serverName = [connectionData objectForKey:@"servername"];
        NSString *dbName = [connectionData objectForKey:@"dbname"];	
	
        // 利用NSString本身提供的方法,將字串與參數串連起來成為一個新字串
        NSMutableString *commandString = [NSMutableString stringWithFormat:@"exec uspSFCTestFailCMBSN '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@'",MLBSNo,testStation,version,lineName,testItem,testValue,Unit,Up_LIM,Down_LIM,@""];	
	
        NSArray * retArray = [tempAppSuppot queryDataRetWithSemicolon:userName 
														 password:passWord 
													   servername:serverName 
														   dbname:dbName
														 commands:commandString];
	
        [tempAppSuppot release];
    
        NSString * Message = [[NSString alloc] initWithFormat:@"%@,%@",[retArray objectAtIndex:0],[retArray objectAtIndex:1]];
        return Message;
    }
}


// 用途:check FGSN(客戶序號)
// 輸入:FGSN(客戶序號) ＆ station name & Model Name(MPN BURN才需輸入)
// 輸出:以Array方式輸出, array[0]為0(成功)或1(失敗), array[1]為錯誤訊息, array[2]為MLB序號
- (NSArray *)CheckCFGSNWCRetCMBSN:(NSString *)FGSN station:(NSString *)stationName ModelName:(NSString *)modelName
{
	@try{
		// Read connection data
		IACP_AppSupport *tempDBConnect = [[IACP_AppSupport alloc] init];
		NSString *applicationSupportFolder = [tempDBConnect applicationSupportFolder];
		NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
		NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
        
		NSDictionary *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
		
        // for Top Test off line test
        if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
        {
            NSMutableArray *dummyArray = [[NSMutableArray alloc] init];
            
            if ([FGSN isEqualToString:@""])
            {
                [dummyArray addObject:@"1"];
                [dummyArray addObject:@"Custom SN error"];
                [dummyArray addObject:@""];
            }
            else if ([stationName isEqualToString:@""])
            {
                [dummyArray addObject:@"1"];
                [dummyArray addObject:@"The test station isn't exist!"];
                [dummyArray addObject:@""];
            }
            else
            {    
                [dummyArray addObject:@"0"];
                [dummyArray addObject:@"Successful"];
                [dummyArray addObject:@"CC400650065DCLV1"];
                
            }
            
            return dummyArray;
        }
        else
        {
            NSString *userName = [connectionData objectForKey:@"username"];
            NSString *passWord = [connectionData objectForKey:@"password"];
            NSString *serverName = [connectionData objectForKey:@"servername"];
            NSString *dbName = [connectionData objectForKey:@"dbname"];
        
            // 利用NSString本身提供的方法,將字串與參數串連起來成為一個新字串
            NSString *commandString = [[NSString alloc] initWithFormat:@"exec uspSFCCheckCFGSNWcRetCMBSN '%@', '%@', '%@'",FGSN,stationName,modelName];
        
            IACP_AppSupport *CFGSNDBConnect = [[IACP_AppSupport alloc] init];
            NSArray * CFGSNArray = [CFGSNDBConnect queryDataRetWithSemicolon:userName 
																password:passWord 
															  servername:serverName 
																  dbname:dbName
																commands:commandString];	
            [commandString release];
            [tempDBConnect release];
            [CFGSNDBConnect release];
        
            if ([[CFGSNArray objectAtIndex:0] isEqualToString:@"1999" ])
            {
                NSRunAlertPanel(@"Error", [NSString stringWithFormat:@"Error: Unable to connect FIS"],@"OK",nil,nil);
                return nil;
            }
            else
            {
                return CFGSNArray;
            }
        }
		
	}
	@catch (NSException *exception) {
		NSRunAlertPanel(@"Exception", [NSString stringWithFormat:@"Error: checkCFGSNWCRetCMBSN Error", [exception reason]],@"OK",nil,nil);
		return nil;
	}
	return nil;
}



- (NSString *)GetServerName
{
	IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
	NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
	NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
	NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
	
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
    {
        return @"IACServer";
    }
    else
    {
        NSString *serverName = [connectionData objectForKey:@"servername"];
	
        [tempAppSuppot release];
	
        return serverName;
    }
}

- (NSString *)GetDBName
{
	IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
	NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
	NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
	NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
	NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
	
	// for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
    {
        return @"IACDataBabe";
    }
    else
    {
        NSString *dbName = [connectionData objectForKey:@"dbname"];
	
        [tempAppSuppot release];
	
        return dbName;
    }
}


- (NSString *)GetServerDate
{
    IACP_AppSupport *tempAppSuppot = [[IACP_AppSupport alloc] init];
    NSString *applicationSupportFolder = [tempAppSuppot applicationSupportFolder];
    NSString *path = [applicationSupportFolder stringByAppendingPathComponent:@"DBConnections.plist"];
    NSMutableDictionary *identifiers = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    NSMutableDictionary	 *connectionData = [identifiers objectForKey:[identifiers objectForKey:@"Connection"]];
    
    // for Top Test off line test
    if ([[identifiers valueForKey:@"Connection"] isEqualToString:@"Simulation"]) 
    {
        return @"2012/06/15";
    }
    else
    {
	
        NSString *userName = [connectionData objectForKey:@"username"];
        NSString *passWord = [connectionData objectForKey:@"password"];
        NSString *serverName = [connectionData objectForKey:@"servername"];
        NSString *dbName = [connectionData objectForKey:@"dbname"];
	
        NSArray * getServerDate = [tempAppSuppot queryDataUseIACPBsqldb:userName 
                                                       password:passWord 
                                                     servername:serverName 
                                                         dbname:dbName
                                                       commands:@"select convert(char(20), getdate(),120)"];
        [tempAppSuppot release];
    
        return [getServerDate objectAtIndex:0];
    }
}




@end
