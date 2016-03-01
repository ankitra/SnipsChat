//
//  SnipsChatTests.m
//  SnipsChatTests
//
//  Created by Guest Users on 27/02/16.
//  Copyright © 2016 Ankit. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SCChatMessageParser.h"

@interface SnipsChatTests : XCTestCase
{
NSString * text;
NSString * text2;
}
@end

@implementation SnipsChatTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    text = @"@john@例子@परीक्षा@ختبار@vaki_子2323232323edfsdfsdf@aaasdasd(megusta)(hello)(boo222)(megusta)http://foo.com/blah_blah http://foo.com/blah_blah/ http://foo.com/blah_blah_(wikipedia) http://foo.com/blah_blah_(wikipedia)_(again) http://www.example.com/wpstyle/?p=364 https://www.example.com/foo/?bar=baz&inga=42&quux http://✪df.ws/123 http://userid:password@example.com:8080 http://userid:password@example.com:8080/ http://userid@example.com http://userid@example.com/ http://userid@example.com:8080 http://userid@example.com:8080/ http://userid:password@example.com http://userid:password@example.com/ http://142.42.1.1/ http://142.42.1.1:8080/ http://➡.ws/ä http://⌘.ws http://⌘.ws/ https://foo.com/blah_(wikipedia)#cite-1 http://foo.com/blah_(wikipedia)_blah#cite-1 http://foo.com/unicode_(✪)_in_parens http://foo.com/(something)?after=parens http://☺.damowmow.com/ http://code.google.com/events/#&product=browser http://j.mp http://foo.bar/baz http://foo.bar/?q=Test%20URL-encoded%20stuff http://مثال.إختبار http://例子.测试 http://उदाहरण.परीक्षा http://-.~_!$&'()*+,;=:%40:80%2f::::::@example.com http://1337.net http://a.b-c.de http://223.255.255.254 askfjkfljdsfljsalfdhttp://www.google.com";
    text2 = @"@@@ @--- () (((())) (dsadasdasd2341234erwer3324234) (.)(@)https:/ http:: http://.	http://..	http://../	";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParserPositive {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    
    
    SCChatMessage * msg = [[SCChatMessageParser sharedParser] parse:text];
    XCTAssert([msg.links count] == 37);
    XCTAssert([msg.mentions count] == 6);
    XCTAssert([msg.emoticons count] == 4);

}

- (void)testParserNegatives {

    SCChatMessage * msg = [[SCChatMessageParser sharedParser] parse:text2];
    XCTAssert([msg.links count] == 0);
    XCTAssert([msg.mentions count] == 0);
    XCTAssert([msg.emoticons count] == 0);

}

-(void)testJSON {

    SCChatMessage * msg = [[SCChatMessageParser sharedParser] parse:text];
    NSString * json = msg.jsonString;
    NSError * error;
    NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
    
    XCTAssert(!error && dict && [dict[@"links"] count]==msg.links.count && [dict[@"mentions"] count] == msg.mentions.count && [dict[@"emoticons"] count] == msg.emoticons.count);
}

@end
