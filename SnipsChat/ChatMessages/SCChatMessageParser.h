//
//  SCChatMessageParser.h
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCChatMessage+Private.h"


//Will be called again and again for each update from the network
typedef void (^SCChatMessageParserBlock)(SCChatMessage * message,BOOL finished);

@interface SCChatMessageParser : NSObject
{
    NSURLSession * pageFetchingSession;
    NSOperationQueue * fetchingQueue;
    NSOperationQueue * parsingQueue;
    NSObject<NSURLSessionDataDelegate> * parserSessionDelegate;
}

+(instancetype) sharedParser;


//Parse locally only and do not fetch any items from the network. Will return parsed and unpopulated message.
-(SCChatMessage *) parse:(NSString *) chatString;


//Parse chat message and populate titles from the network, call block when there is a update. Will return parsed and unpopulated message.
-(SCChatMessage *) parse:(NSString *) chatString AndCallBlock: (SCChatMessageParserBlock) block;

@end
