//
//  WinBridgeTests.m
//  WinBridgeTests
//
//  Created by Koji Ishii on 9/20/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "WinBridgeTests.h"
#import "NSURL+SMB.h"

@implementation WinBridgeTests

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

- (void)testStringFromUNC
{
    // Normal cases
    STAssertTrue([[NSURL stringFromUNC:@"\\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Normal");

    // Not a UNC
    STAssertNil([NSURL stringFromUNC:@"\\server\\share\\dir\\file"], @"Not a UNC");

    // Preceding spaces
    STAssertTrue([[NSURL stringFromUNC:@"   \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-spaces");
    STAssertTrue([[NSURL stringFromUNC:@"¥t¥t\\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-tabs");
    STAssertTrue([[NSURL stringFromUNC:@"¥t¥t   \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-spaces-tabs");

    // Post spaces
    STAssertTrue([[NSURL stringFromUNC:@"\\\\server\\share\\dir\\file  "] isEqualToString:@"smb://server/share/dir/file"], @"Post-spaces");
    STAssertTrue([[NSURL stringFromUNC:@"\\\\server\\share\\dir\\fil e"] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");
    STAssertTrue([[NSURL stringFromUNC:@"\\\\server\\share\\dir\\fil e  "] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");
    STAssertTrue([[NSURL stringFromUNC:@" \\\\server\\share\\dir\\fil e  "] isEqualToString:@"smb://server/share/dir/fil e"], @"Post-spaces");

    // Preceding extra text
    STAssertTrue([[NSURL stringFromUNC:@"Hello: \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-text");
    STAssertTrue([[NSURL stringFromUNC:@"He\\: \\\\server\\share\\dir\\file"] isEqualToString:@"smb://server/share/dir/file"], @"Pre-backslash");

    // i18n
    STAssertTrue([[NSURL stringFromUNC:@"\\\\server\\s¥u3042\\d¥u3042\\f¥u3042"] isEqualToString:@"smb://server/s¥u3042/d¥u3042/f¥u3042"], @"Pre-text");
}

@end
