//
//  SMBServicesProvider.m
//  WinBridge
//
//  Created by Koji Ishii on 9/20/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "WinBridgeServicesProvider.h"
#import "WBUNC.h"

@implementation WinBridgeServicesProvider

- (void)convertFromUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        *error = @"Please select a string";
        return;
    }
    
    NSString* source = [pboard stringForType:NSPasteboardTypeString];
    NSString* target = [WBUNC stringFromUNC:source];
    NSLog(@"convertFromUNC: source=%@, target=%@", source, target);
    if (!target)
        return;

    [pboard clearContents];
    [pboard writeObjects:@[target]];
}

@end
