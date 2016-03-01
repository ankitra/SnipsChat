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

    //When finished use these as there will be no changes
    
    NSString * _jsonC;
    NSArray * _emoC;
    NSArray * _menC;
    NSArray * _urlC;
    NSNumber * _errored;
}


/**
 No more loading is pending on this message
*/
 @property (readonly) BOOL finished;

/**
 Encountered error while getting links
 */
 @property (readonly) BOOL erroredWhileGettingLinks;

/**
 Array of strings having emoticons
*/
 @property (readonly) NSArray * emoticons;

/**
 Array of strings showing mentions
*/
 @property (readonly) NSArray * mentions;

/**
 Array of dictionaries having links. keys are
 kSCLinkKey -> link
 kSCTitleKey -> NSString title or NSError if error in getting title
*/
 @property (readonly) NSArray * links;


/**
 Pretty printed JSON representation of the message
 */
-(NSString *) jsonString;


@end
