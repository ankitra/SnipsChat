//
//  SCChatMessage.h
//  SnipsChat
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kSCURLKey @"url"
#define kSCTitleKey @"title"


@interface SCChatMessage : NSObject
{
    NSMutableSet * __mentions;
    NSMutableDictionary * __links;
    NSMutableArray * __emoticons;
    BOOL __finished;
}


//No more loading is pending on this message
@property (readonly) BOOL finished;

//Array of strings having emoticons
@property (readonly) NSArray * emoticons;

//Array of strings showing mentions
@property (readonly) NSArray * mentions;

//Array of dictionaries having links. keys are
//kSCLinkKey -> link
//kSCTitleKey -> NSString title or NSError if error in getting title
@property (readonly) NSArray * links;

-(NSString *) jsonString;

@end
