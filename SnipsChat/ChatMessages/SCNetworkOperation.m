//
//  SCNetworkOperation.m
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCNetworkOperation.h"

@interface SCNetworkOperation()

-(void) cancelTask;

@end


@interface SCNetworkOperationObserver : NSObject

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,
                                id> *)change
                       context:(void *)context;


@end

@implementation SCNetworkOperationObserver

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString *,
                                id> *)change
                       context:(void *)context
{

    if([keyPath isEqualToString:@"isCancelled"])
    {
        if((BOOL)[change objectForKey:NSKeyValueChangeNewKey] == YES)
            [(SCNetworkOperation *)object cancelTask];
    }
}

@end

@implementation SCNetworkOperation

-(instancetype) initWithTask:(NSURLSessionDataTask *) dataTask Message:(SCChatMessage *) msg AndURL:(NSString *) _url
{
    self = [super init];
    if(self)
    {
        executing = NO;
        finished = NO;
        task = dataTask;
        url = _url;
        message = msg;
        observer = [[SCNetworkOperationObserver alloc] init];
        [self addObserver:observer forKeyPath:@"isCancelled" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    return self;
}

-(NSString *) textURL
{
    return url;
}

-(SCChatMessage * ) chatMessage
{
    return message;
}

-(void) cancelTask
{
    @synchronized(task) {
        //If task needs to be cancelled, do it
        if(!([task state] == NSURLSessionTaskStateCompleted || [task state] == NSURLSessionTaskStateCanceling))
            [task cancel];
    }

}


-(void) finish
{
    //Conforming to KVO
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    executing = NO;
    finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

-(void) start
{
    if([self isCancelled])
    {
        [self finish];
        return;
    }
    

    @synchronized(task) {
        
        //If task can be started, do it
        if([task state] == NSURLSessionTaskStateSuspended)
        {
            [self willChangeValueForKey:@"isExecuting"];
            [task resume];
            executing = YES;
            [self didChangeValueForKey:@"isExecuting"];

        }
        else
        {
            NSLog(@"[SCNetworkOperation Start] : Unexpected state of the download task %@",task.originalRequest.URL);
            if(!([task state] == NSURLSessionTaskStateCompleted || [task state] == NSURLSessionTaskStateCanceling))
                [task cancel];
            [self finish];
        }
    }
}

-(BOOL) isAsynchronous
{
    return YES;
}

-(BOOL) isExecuting
{
    return executing;
}

-(BOOL) isFinished
{
    return finished;
}

@end
