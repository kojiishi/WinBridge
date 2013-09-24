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
    STAssertTrue([[NSURL stringWithUNC:@"\\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Normal");

    // Not a UNC
    STAssertNil([NSURL stringWithUNC:@"\\server\\share\\dir\\file"], @"Not a UNC");
}

- (void)testStringWithUNCExtraText
{
    // Preceding spaces
    STAssertTrue([[NSURL stringWithUNC:@"   \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-spaces");
    STAssertTrue([[NSURL stringWithUNC:@"¥t¥t\\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-tabs");
    STAssertTrue([[NSURL stringWithUNC:@"¥t¥t   \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-spaces-tabs");

    // Post spaces
    STAssertTrue([[NSURL stringWithUNC:@"\\\\server\\share\\dir\\file  "] isEqualToString:@"smb://server/share/dir/file"], @"Post-spaces");
    STAssertTrue([[NSURL stringWithUNC:@"\\\\server\\share\\dir\\fil e"] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");
    STAssertTrue([[NSURL stringWithUNC:@"\\\\server\\share\\dir\\fil e  "] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");
    STAssertTrue([[NSURL stringWithUNC:@" \\\\server\\share\\dir\\fil e  "] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");

    // Preceding extra text
    STAssertTrue([[NSURL stringWithUNC:@"Hello: \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-text");
    STAssertTrue([[NSURL stringWithUNC:@"He\\: \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-backslash");
}

- (void)testStringWithUNCEnclosingMarks
{
    STAssertTrue([[NSURL stringWithUNC:@"<\\\\server\\share\\dir\\file>a"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-text");
    STAssertTrue([[NSURL stringWithUNC:@"a< \\\\server\\share\\dir\\file >a"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-text");
}

- (void)testStringWithUNCi18n
{
    STAssertTrue([[NSURL stringWithUNC:@"\\\\server\\s¥u3042\\d¥u3042\\f¥u3042"] isEqualToString:@"smb://server/s¥u3042/d¥u3042/f¥u3042"], @"Pre-text");
}

@end
