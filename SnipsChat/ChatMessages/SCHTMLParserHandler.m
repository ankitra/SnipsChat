//
//  SCHTMLParserHandler.m
//  SnipsChat
//
//  Created by rishab on 29/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCHTMLParserHandler.h"


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
