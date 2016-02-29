//
//  SCChatMessage+Private.h
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import "SCChatMessage.h"

@interface SCChatMessage (Private)

-(void) addMention:(NSString *) mention;
-(void) addEmotiocon:(NSString *) emo;
-(void) addLink:(NSString *) url;

//Title could be title string or an error encountered during determining title
-(void) setTitle:(NSObject *) title ForLink:(NSString * )url;
-(void) finish;

@end
