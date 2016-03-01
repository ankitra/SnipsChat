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
    
    assert(chatString);
    
    //We are following the Apple's definition of word-charecter viz Lower case letter, Upper case letter, Letter titlecase, Letter Other,  Numric properties and selected punctuations such as _ in Unicode. Also we are assuming that atleast one charecter is a must.
    //https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSRegularExpression_Class/#//apple_ref/c/tdef/NSMatchingOptions
    NSRegularExpression * mentionexpression = [[NSRegularExpression alloc] initWithPattern:@"(@)(\\w+)" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:nil];
    
    //emoticon
    NSRegularExpression * emoticonexpression = [[NSRegularExpression alloc] initWithPattern:@"(\\()([A-Za-z0-9]{1,15})(\\))" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:nil];
    
    //Only urls beginning with http or https. Others cannot have a title so not considering in this.
    NSRegularExpression * urlexpression = [[NSRegularExpression alloc] initWithPattern:@"https?:\\/\\/[^\\s\\/$.?#].[^\\s]*" options:NSRegularExpressionCaseInsensitive|NSRegularExpressionAnchorsMatchLines error:nil];
    
 
    NSArray<NSTextCheckingResult *> * urlmatches = [urlexpression matchesInString:chatString options:0 range:NSMakeRange(0, [chatString length])];

    for(NSTextCheckingResult * mat in urlmatches)
    {
        [msg addLink:[chatString substringWithRange:[mat rangeAtIndex:0]]];
    }
    
    
    
    NSArray<NSTextCheckingResult *> * emoticonmatches = [emoticonexpression matchesInString:chatString options:0 range:NSMakeRange(0, [chatString length])];
    
    for(NSTextCheckingResult * mat in emoticonmatches)
    {
        bool addEmoticon = YES;
        
        
        //Do no add anything emoticon that is inside a url
        for(NSTextCheckingResult * urlmat in urlmatches)
        {
            //Check for range overlap using AABB test
            if(!((mat.range.location + mat.range.length -1) < urlmat.range.location || (mat.range.location) > (urlmat.range.location + urlmat.range.length -1) ))
            {
                //They overlap? skip this
                addEmoticon = NO;
                break;
            }
        }

        if(addEmoticon)
            [msg addEmotiocon:[chatString substringWithRange:[mat rangeAtIndex:2]]];
    }
    
    
    

    NSArray<NSTextCheckingResult *> * mentionmatches = [mentionexpression matchesInString:chatString options:0 range:NSMakeRange(0, [chatString length])];
    
    for(NSTextCheckingResult * mat in mentionmatches)
    {
        bool addMention = YES;
        
        
        //Do no add anything mention that is inside a url
        for(NSTextCheckingResult * urlmat in urlmatches)
        {
            //Check for range overlap using AABB test
            if(!((mat.range.location + mat.range.length -1) < urlmat.range.location || (mat.range.location) > (urlmat.range.location + urlmat.range.length -1) ))
            {
                //They overlap? skip this
                addMention = NO;
                break;
            }
        }
        
        if(addMention)
            [msg addMention:[chatString substringWithRange:[mat rangeAtIndex:2]]];
    }
    
    return msg;
}

-(SCChatMessage *) parse:(NSString *) chatString AndCallBlockWithLink: (SCChatMessageParserBlock) block
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


