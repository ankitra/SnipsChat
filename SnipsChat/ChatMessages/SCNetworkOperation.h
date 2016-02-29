//
//  SCNetworkOperation.h
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCChatMessage.h"

@interface SCNetworkOperation : NSOperation
{
    NSURLSessionTask * task;
    SCChatMessage * message;
    NSObject * observer;
    NSString * url;
    BOOL executing;
    BOOL finished;
}

-(void) finish;
-(instancetype) initWithTask:(NSURLSessionDataTask *) dataTask Message:(SCChatMessage *) msg AndURL:(NSString *) _url;


@property (readonly) SCChatMessage * chatMessage;
@property (readonly) NSString * textURL;
@end
