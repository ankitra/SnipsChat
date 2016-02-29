//
//  SCChatMessage.m
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCChatMessage.h"

#define kSCMentionKey @"mentions"
#define kSCEmoticonsKey @"emoticons"
#define kSCLinkKey @"links"


@implementation SCChatMessage

-(instancetype) init
{
    self = [super init];
    
    if(self)
    {
        __mentions = [[NSMutableSet alloc] init];
        __emoticons = [[NSMutableArray alloc] init];
        __links = [[NSMutableDictionary alloc] init];
        __finished = NO;
    }
    
    return self;
}

-(BOOL) finished
{
    return __finished;
}

-(NSArray *) mentions
{
    NSArray * rval;
    
    @synchronized(self) {
        rval = [__mentions allObjects];
    }
    
    return rval;
}

-(NSArray *) emoticons
{
    NSArray * rval;
    
    @synchronized(self) {
        rval = [NSArray arrayWithArray: __emoticons];

    }
    return rval;

}

-(NSArray *) links
{
    NSMutableArray * rval = [[NSMutableArray alloc] init];
    
    @synchronized(self) {
        
        for(id key in [__links allKeys])
            [rval addObject:[NSDictionary dictionaryWithObjectsAndKeys:__links[key], kSCLinkKey, key, kSCURLKey, nil]];
    }

    return [NSArray arrayWithArray:rval];

}

-(NSString *) jsonString
{
    NSMutableDictionary * _localDict = [[NSMutableDictionary alloc] init];
    
    //Perform Shallow-Deep copy, mentions and emoticons shallow and links deep as they may be changed during serialization
    
    @synchronized(self) {
       
        if (__mentions.count)
            _localDict[kSCMentionKey] =  [__mentions allObjects];
        
        if(__emoticons.count)
            _localDict[kSCEmoticonsKey] = [NSArray arrayWithArray:  __emoticons];
       
        NSMutableArray * linksArray = [[NSMutableArray alloc]init];
     
        
        for(id key in [__links allKeys])
        {
            //If we have a valid title then put it in json
            if([[__links[key] class] isSubclassOfClass:[NSString class]])
            {
                [linksArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:__links[key], kSCTitleKey, key, kSCURLKey, nil]];
            }
            else
            {
                //Else just put the URL and leave the title
                NSDictionary * urlDict = [NSDictionary dictionaryWithObject:key forKey:kSCURLKey];
                [linksArray addObject:urlDict];
            }
        }
        
        if(linksArray.count)
            _localDict[kSCLinkKey] =linksArray;

    }
    
    NSData * json;
    NSError * error;
    
    json = [NSJSONSerialization dataWithJSONObject:_localDict options:NSJSONWritingPrettyPrinted error:&error];
    
    if(error != nil)
    {
        NSLog(@"[SCChatMessage jsonString] Failed to generate json with error : %@",[error description]);
        
    }

    return json != nil? [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding] : @"{}";
    
}

@end
