//
//  SMBServicesProvider.m
//  WinBridge
//
//  Created by Koji Ishii on 9/20/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "WinBridgeServicesProvider.h"

@implementation WinBridgeServicesProvider

- (void)convertFromUNC:(NSPasteboard*)pboard userData:(NSString*)userData error:(NSString**)error
{
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        *error = @"Please select a string";
        return;
    }
    
    NSString* source = [pboard stringForType:NSPasteboardTypeString];
    NSLog(@"convertFromUNC: source=%@", source);
    NSString* target = [source uppercaseString];

    NSLog(@"convertFromUNC: target=%@", target);
    [pboard clearContents];
    [pboard writeObjects:@[target]];
}

@end
