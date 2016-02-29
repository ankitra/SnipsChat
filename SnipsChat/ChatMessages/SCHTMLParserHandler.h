//
//  SCHTMLParserHandler.h
//  SnipsChat
//
//  Created by rishab on 29/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import <Foundation/Foundation.h>
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
