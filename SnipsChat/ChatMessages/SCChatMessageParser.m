//
//  SCChatMessageParser.m
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCChatMessageParser.h"
#import "SCNetworkOperation.h"
#import "AXHTMLParser.h"


@interface SCChatHTMLParserHandler: NSObject <AXHTMLParserDelegate>
{
    NSString * _title;
    NSError * _error;
    int depth;
    BOOL captureTitle,wasCapturing;
    BOOL _completed;
 }

@property (readonly) NSString * title;
@property (readonly) BOOL completed;
@property (readonly) NSError * error;
@property (weak)    AXHTMLParser * parser;


@end

@implementation SCChatHTMLParserHandler

-(NSString *) title
{
    return _title;
}

-(NSError *) error
{
    return _error;
}

-(BOOL) completed
{
    return _completed;
}

-(instancetype) init
{
    self = [super init];
    
    if(self)
    {
        _completed = NO;
        captureTitle = NO;
        _error = nil;
        _title = nil;
    }
    
    return self;
}

- (void)parser:(AXHTMLParser *)parser didStartElement:(NSString *)elementName attributes:(NSDictionary *)attributeDict
{
    depth ++;
    
    if(depth == 3 && [elementName compare:@"title" options:NSCaseInsensitiveSearch] == NSOrderedSame)
        captureTitle = YES;
}

- (void)parser:(AXHTMLParser *)parser didEndElement:(NSString *)elementName
{
    depth --;
    
    if(depth == 2 && [elementName compare:@"title" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        _completed = YES;
        captureTitle = NO;
    }
    
}


- (void)parser:(AXHTMLParser *)parser foundCharacters:(NSString *)string
{
    if(!captureTitle || _completed)
        return;
    
    if(!_title)
        _title = string;
    else
        _title = [NSString stringWithFormat:@"%@%@",_title,string];
    
}


- (void)parser:(AXHTMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    _error = parseError;
    NSLog(@"[SCChatHTMLParserHandler parseErrorOccured] : Parser encountred an error %@", parseError);
}


@end


@interface SCChatMessageParserSessionHandler: NSObject<NSURLSessionDataDelegate>

{
    NSMutableDictionary * dict;
    NSMutableDictionary * parserDict;
}

-(void) registerTask:(NSURLSessionTask *) task ToOperation:(SCNetworkOperation *) op;


@end

@implementation SCChatMessageParserSessionHandler

-(instancetype) init
{
    self = [super init];
    
    if(self)
    {
        dict = [[NSMutableDictionary alloc] init];
        parserDict = [[NSMutableDictionary alloc] init];

    }
    return self;
}

-(void) registerTask:(NSURLSessionTask *) task ToOperation:(SCNetworkOperation *) op
{
    [dict setObject:op forKey:[NSString stringWithFormat:@"%lu",(unsigned long)[task taskIdentifier]]];
}

-(SCNetworkOperation *) operationFor:(NSURLSessionTask *) task
{
    return [dict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)[task taskIdentifier]]];
}

-(void) removeOperationFor:(NSURLSessionTask *) task
{
    [dict removeObjectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)[task taskIdentifier]]];
}



-(void) registerParser:(AXHTMLParser * ) parser ForTask:(NSURLSessionTask *)task
{
    [parserDict setObject:parser forKey:[NSString stringWithFormat:@"%lu",(unsigned long)[task taskIdentifier]]];
}

-(AXHTMLParser *) parserFor:(NSURLSessionTask *) task
{
    return [parserDict objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)[task taskIdentifier]]];
}

-(void) removeParserFor:(NSURLSessionTask *) task
{
    [parserDict removeObjectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)[task taskIdentifier]]];
}


- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(nullable NSError *)error
{    
    [[self operationFor:task] finish];
    [self removeOperationFor:task];
}


- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;
{
    SCNetworkOperation * op = [self operationFor:dataTask];
    AXHTMLParser * parser = [self parserFor:dataTask];

    if(!parser)
    {
        
   
    
    //Check Successful response
    // Check the mime-type and encoding
    //Either no mime type or known html mime types
    //http://www.sitepoint.com/web-foundations/mime-types-complete-list/

        if([(NSHTTPURLResponse *)dataTask.response statusCode] >= 200
           && [(NSHTTPURLResponse *)dataTask.response statusCode] < 300 &&
           
           (!dataTask.response.MIMEType ||
           [dataTask.response.MIMEType compare:@"text/html" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
           [dataTask.response.MIMEType compare:@"text/webviewhtml" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
           [dataTask.response.MIMEType compare:@"text/x-server-parsed-html" options:NSCaseInsensitiveSearch] == NSOrderedSame)
           
           )
           
            {
            //TODO add better encoding detection
            //Assume that encoding is UTF8, we can do better but for the time being this is it
            
                parser = [[AXHTMLParser alloc] initWithEncoding:XML_CHAR_ENCODING_UTF8];
            
                parser.delegate = [[SCChatHTMLParserHandler alloc] init];
                [(SCChatHTMLParserHandler * )(parser.delegate) setParser:parser];
                [self registerParser:parser ForTask:dataTask];
            }
            else
            {
                //else, unknown mime type. boom
                [op.chatMessage setTitle:[NSError errorWithDomain:@"ParserDomain" code:0x1 userInfo:[NSDictionary   dictionaryWithObject:@"Unknown MIME Type" forKey:NSLocalizedDescriptionKey]] ForLink:op.textURL];
                [dataTask cancel];
                return;
            }
        }
    
    
    assert(parser);
    
    [parser parse:data];
    if(((SCChatHTMLParserHandler * )(parser.delegate)).completed)
    {
        [op.chatMessage setTitle:
         ((SCChatHTMLParserHandler * )(parser.delegate)).title?
         ((SCChatHTMLParserHandler * )(parser.delegate)).title:
         [NSError errorWithDomain:@"ParserDomain" code:0x2 userInfo:[NSDictionary dictionaryWithObject:@"Title not parsed" forKey:NSLocalizedDescriptionKey]]
                         ForLink:op.textURL];
        
        //No need to continue downloading more data
        [dataTask cancel];
    }

}

@end


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


