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
    assert(mention != nil&& !self.finished);
    @synchronized(self)
    {
        if(![__mentions containsObject:mention])
            [__mentions addObject:mention];
    }
}

-(void) addEmotiocon:(NSString *) emo
{
    assert(emo != nil && !self.finished);
    @synchronized(self) {

        [__emoticons addObject:emo];
    }
}
-(void) addLink:(NSString *) url
{
    assert(url != nil && !self.finished);
    @synchronized(self) {
        [__links setObject:[NSNull null] forKey:url];
    }
}
-(void) setTitle:(NSObject *) title ForLink:(NSString * )url
{
    assert(!self.finished);
    @synchronized(self) {

        if(__links[url] == [NSNull null])
            [__links setObject:title forKey:url];
    }
}

-(void) finish
{
    __finished = YES;

    _emoC = self.emoticons;
    _menC = self.mentions;
    _urlC = self.links;

    //cache json string as well no changes will be made
    _jsonC = self.jsonString;
    
    //No need to these sets, array are better now as we do not have to search anymore we just have to enumerate at max;
    __mentions = nil;
    __emoticons = nil;
    __links = nil;
}

@end
