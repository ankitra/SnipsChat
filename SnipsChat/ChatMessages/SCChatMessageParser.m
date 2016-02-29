//
//  SCChatMessageParser.m
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCChatMessageParser.h"
#import "SCChatMessageParserSessionHandler.h"
#import "SCChatMessage+Private.h"




@implementation SCChatMessageParser

+(instancetype) sharedParser
{
    static id sharedI = NULL;
    
    static dispatch_once_t token;
    dispatch_once(&token, ^(void)
                  {
                      sharedI = [[self alloc] init];
                  }
                  );
    
    return sharedI;
}

-(instancetype) init
{
    self = [super init];
    
    if(self)
    {
        fetchingQueue = [[NSOperationQueue alloc] init];

        
        //Run 4 connections at a time! YeeHaw for a hardcoded number!
        fetchingQueue.maxConcurrentOperationCount = 4;
        
        //The parsing queue
        parsingQueue = [[NSOperationQueue alloc] init];
        
        parserSessionDelegate = [[SCChatMessageParserSessionHandler alloc] init];
        
        pageFetchingSession = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:parserSessionDelegate delegateQueue:parsingQueue];
    }
    
    return self;
}


-(SCChatMessage *) parse:(NSString *) chatString
{
    SCChatMessage * msg = [[SCChatMessage alloc] init];
    

    //TODO implement the actual parsing logic
    [msg addLink:@"http://www.cse.iitd.ac.in/"];
    [msg addLink:@"http://www.iitd.ac.in/"];
    [msg addLink:@"http://www.google.com/"];
    [msg addLink:@"http://www.iiita.ac.in/"];
    [msg addLink:@"http://www.gmail.com/"];
    [msg addLink:@"http://www.barclays.co.uk/"];

    return msg;
}

-(SCChatMessage *) parse:(NSString *) chatString AndCallBlock: (SCChatMessageParserBlock) block
{
    SCChatMessage * msg = [self parse:chatString];
    NSArray * links =msg.links;
    
    NSBlockOperation * finalOp = [NSBlockOperation blockOperationWithBlock:^(void) {
        
        [msg finish];
        //Call the final notification block on the main queue
        [[NSOperationQueue mainQueue] addOperation: [NSBlockOperation
                                                   blockOperationWithBlock:^(void)
                                                   {
                                                       block(msg,YES);
                                                   }]];
    }];
    
    finalOp.queuePriority = NSOperationQueuePriorityVeryHigh;
    
    if([links count])
    {

        for(NSDictionary * dict in links)
        {
            NSURL * url = [NSURL URLWithString:dict[kSCURLKey]];
            if(url)
            {
                NSURLSessionDataTask * task = [pageFetchingSession dataTaskWithURL:url];
                SCNetworkOperation * op = [[SCNetworkOperation alloc] initWithTask:task Message:msg AndURL:dict[kSCURLKey]];
                op.queuePriority = NSOperationQueuePriorityNormal;
                
                NSBlockOperation * penultimateOp = [NSBlockOperation blockOperationWithBlock:^(void) {
                    
                    //Call the notification block on the main queue
                    [[NSOperationQueue mainQueue] addOperation: [NSBlockOperation
                                                                 blockOperationWithBlock:^(void)
                                                                 {
                                                                     block(msg,NO);
                                                                 }]];
                }];

                [penultimateOp addDependency:op];
                penultimateOp.queuePriority = NSOperationQueuePriorityVeryHigh;
                [finalOp addDependency:penultimateOp];
                
                [(SCChatMessageParserSessionHandler *)parserSessionDelegate registerTask:task ToOperation:op];
                
                [fetchingQueue addOperation:op];
                [fetchingQueue addOperation:penultimateOp];
            }
        }
        [fetchingQueue addOperation:finalOp];
    }
    else
    {
        [msg finish];
    }
    
    return msg;
}

@end


