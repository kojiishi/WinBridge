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

- (void)convertFromUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSString* target = [self convertFromUNCCore:pboard error:error];
    if (!target)
        return;

    [pboard clearContents];
    [pboard writeObjects:@[target]];
}

- (void)copyFromUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSString* target = [self convertFromUNCCore:pboard error:error];
    if (!target)
        return;

    NSPasteboard *generalPasteboard = [NSPasteboard generalPasteboard];
    [generalPasteboard declareTypes:@[NSStringPboardType] owner:nil];
    [generalPasteboard setString:target forType:NSStringPboardType];
}

- (void)openUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    NSString* target = [self convertFromUNCCore:pboard error:error];
    if (!target)
        return;

    NSURL* url = [NSURL URLWithString:target];
    NSURL* folder = [url URLByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] openURL:folder];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[url]];
    [[NSWorkspace sharedWorkspace] openURL:url];
}

- (NSString*)convertFromUNCCore:(NSPasteboard*)pboard error:(NSString**)error
{
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        *error = @"Please select a string";
        return nil;
    }
    
    NSString* source = [pboard stringForType:NSPasteboardTypeString];
    NSString* target = [NSURL stringFromUNC:source];
    NSLog(@"convertFromUNC: source=%@, target=%@", source, target);
    return target;
}

@end
