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
    NSString* target = [NSURL stringWithPasteboardUNC:pboard error:error];
    if (!target)
        return;

    [pboard clearContents];
    [pboard writeObjects:@[target]];
}

- (void)copyUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSString* target = [NSURL stringWithPasteboardUNC:pboard error:error];
    if (!target)
        return;

    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard declareTypes:@[NSStringPboardType] owner:nil];
    [generalPasteboard setString:target forType:NSStringPboardType];
}

- (void)openUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSString* target = [NSURL stringWithPasteboardUNC:pboard error:error];
    if (!target)
        return;

    NSURL* url = [NSURL URLWithString:target];
    NSURL* folder = [url URLByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] openURL:folder];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

@end
