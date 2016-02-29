//
//  SCChatMessage+Private.m
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCChatMessage+Private.h"

@implementation SCChatMessage (Private)

-(void) addMention:(NSString *) mention
{
    assert(mention != nil);
    @synchronized(self)
    {
        if(![__mentions containsObject:mention])
            [__mentions addObject:mention];
    }
}

-(void) addEmotiocon:(NSString *) emo
{
    assert(emo != nil);
    @synchronized(self) {

        [__emoticons addObject:emo];
    }
}
-(void) addLink:(NSString *) url
{
    assert(url != nil);
    @synchronized(self) {
        [__links setObject:[NSNull null] forKey:url];
    }
}
-(void) setTitle:(NSObject *) title ForLink:(NSString * )url
{
    @synchronized(self) {

        if(__links[url] == [NSNull null])
            [__links setObject:title forKey:url];
    }
}

-(void) finish
{
    __finished = YES;
}

@end
