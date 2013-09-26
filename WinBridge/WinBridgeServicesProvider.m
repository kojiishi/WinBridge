//
//  SMBServicesProvider.m
//  WinBridge
//
//  Created by Koji Ishii on 9/20/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "WinBridgeServicesProvider.h"
#import "NSURL+SMB.h"

@implementation WinBridgeServicesProvider

- (void)convertUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSString* urlString = [NSURL stringWithPasteboardUNC:pboard error:error];
    NSLog(@"convertUNC: url=%@", urlString);
    if (!urlString)
        return;

    [pboard clearContents];
    [pboard writeObjects:@[urlString]];
}

- (void)copyUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSString* urlString = [NSURL stringWithPasteboardUNC:pboard error:error];
    NSLog(@"copyUNC: url=%@", urlString);
    if (!urlString)
        return;

    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard declareTypes:@[NSStringPboardType] owner:nil];
    [generalPasteboard setString:urlString forType:NSStringPboardType];
}

- (void)openUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSURL* url = [NSURL URLWithPasteboardUNC:pboard error:error];
    NSLog(@"openUNC: url=%@", url);
    if (!url)
        return;

    [url openInSharedWorkspaceSMB];
}

@end
