//
//  SCChatMessageParserSessionHandler.m
//  SnipsChat
//
//  Created by rishab on 29/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCChatMessageParserSessionHandler.h"
#import "SCHTMLParserHandler.h"
#import "SCChatMessage+Private.h"


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
