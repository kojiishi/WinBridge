//
//  main.m
//  WinBridge
//
//  Created by Koji Ishii on 9/20/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "WinBridgeServicesProvider.h"

int main(int argc, char *argv[])
{
    NSRegisterServicesProvider([[WinBridgeServicesProvider alloc] init], @"WinBridge");
    [[NSRunLoop currentRunLoop] run];
    return 0;
}
