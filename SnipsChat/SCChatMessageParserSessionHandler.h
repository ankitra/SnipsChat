//
//  SCChatMessageParserSessionHandler.h
//  SnipsChat
//
//  Created by rishab on 29/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCNetworkOperation.h"

@interface SCChatMessageParserSessionHandler: NSObject<NSURLSessionDataDelegate>

{
    NSMutableDictionary * dict;
    NSMutableDictionary * parserDict;
}

-(void) registerTask:(NSURLSessionTask *) task ToOperation:(SCNetworkOperation *) op;


@end
