//
//  WinBridgeTests.m
//  WinBridgeTests
//
//  Created by Koji Ishii on 9/20/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "NSURL+SMBTests.h"
#import "NSURL+SMB.h"

@implementation NSURL_SMBTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testStringWithUNC
{
    // Normal cases
    STAssertTrue([[NSURL stringWithStringUNC:@"\\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Normal");

    // Not a UNC
    STAssertNil([NSURL stringWithStringUNC:@"\\server\\share\\dir\\file"], @"Not a UNC");
}

- (void)testStringWithUNCExtraText
{
    // Preceding spaces
    STAssertTrue([[NSURL stringWithStringUNC:@"   \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-spaces");
    STAssertTrue([[NSURL stringWithStringUNC:@"¥t¥t\\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-tabs");
    STAssertTrue([[NSURL stringWithStringUNC:@"¥t¥t   \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-spaces-tabs");

    // Post spaces
    STAssertTrue([[NSURL stringWithStringUNC:@"\\\\server\\share\\dir\\file  "] isEqualToString:@"smb://server/share/dir/file"], @"Post-spaces");
    STAssertTrue([[[NSURL URLWithStringUNC:@"\\\\server\\share\\dir\\fil e"] absoluteString] isEqualToString:@"smb://server/share/dir/fil%20e"], @"Post-spaces");
    STAssertTrue([[NSURL stringWithStringUNC:@"\\\\server\\share\\dir\\fil e"] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");
    STAssertTrue([[NSURL stringWithStringUNC:@"\\\\server\\share\\dir\\fil e  "] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");
    STAssertTrue([[NSURL stringWithStringUNC:@" \\\\server\\share\\dir\\fil e  "] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");

    // Preceding extra text
    STAssertTrue([[NSURL stringWithStringUNC:@"Hello: \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-text");
    STAssertTrue([[NSURL stringWithStringUNC:@"He\\: \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-backslash");
}

- (void)testStringWithUNCEnclosingMarks
{
    STAssertTrue([[NSURL stringWithStringUNC:@"<\\\\server\\share\\dir\\file>a"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-text");
    STAssertTrue([[NSURL stringWithStringUNC:@"a< \\\\server\\share\\dir\\file >a"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-text");
}

- (void)testStringWithUNCi18n
{
    STAssertTrue([[NSURL stringWithStringUNC:@"\\\\server\\s\u3042\\d\u3042\\f\u3042"] isEqualToString:@"smb://server/s\u3042/d\u3042/f\u3042"], @"i18n");
    STAssertTrue([[[NSURL URLWithStringUNC:@"\\\\server\\s\u3042\\d\u3042\\f\u3042"] absoluteString] isEqualToString:@"smb://server/s%E3%81%82/d%E3%81%82/f%E3%81%82"], @"i18n URL");
}

#if defined(NOT_TESTABLE)
- (void)testLocalURLAfterAutoMount
{
    STAssertNil([[NSURL URLWithString:@"smb://gluesoft/User/kojiishi/a/b/c"] localURLIfMounted], @"oh");
}
#endif


- (void)testURLByReplacingRootRoot
{
    STAssertEqualObjects([NSURL URLWithString:@"file://localhost/Volumes/User/"], [[NSURL URLWithString:@"smb://network/share/kojiishi"] URLByReplacingRootURL:[NSURL URLWithString:@"smb://network/share/kojiishi"] withURL:[NSURL URLWithString:@"file://localhost/Volumes/User"]], @"ReplacingRoot failed");
}

- (void)testURLByReplacingRootSubDirectory
{
    STAssertEqualObjects([NSURL URLWithString:@"file://localhost/Volumes/User/a/b/c"], [[NSURL URLWithString:@"smb://network/share/kojiishi/a/b/c"] URLByReplacingRootURL:[NSURL URLWithString:@"smb://network/share/kojiishi"] withURL:[NSURL URLWithString:@"file://localhost/Volumes/User"]], @"ReplacingRoot failed");

    // Trailing slash variations
    STAssertEqualObjects([NSURL URLWithString:@"file://localhost/Volumes/User/a/b/c"], [[NSURL URLWithString:@"smb://network/share/kojiishi/a/b/c"] URLByReplacingRootURL:[NSURL URLWithString:@"smb://network/share/kojiishi/"] withURL:[NSURL URLWithString:@"file://localhost/Volumes/User"]], @"ReplacingRoot failed");
    STAssertEqualObjects([NSURL URLWithString:@"file://localhost/Volumes/User/a/b/c"], [[NSURL URLWithString:@"smb://network/share/kojiishi/a/b/c"] URLByReplacingRootURL:[NSURL URLWithString:@"smb://network/share/kojiishi"] withURL:[NSURL URLWithString:@"file://localhost/Volumes/User/"]], @"ReplacingRoot failed");
    STAssertEqualObjects([NSURL URLWithString:@"file://localhost/Volumes/User/a/b/c"], [[NSURL URLWithString:@"smb://network/share/kojiishi/a/b/c"] URLByReplacingRootURL:[NSURL URLWithString:@"smb://network/share/kojiishi/"] withURL:[NSURL URLWithString:@"file://localhost/Volumes/User/"]], @"ReplacingRoot failed");
}

@end
