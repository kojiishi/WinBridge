//
//  WBUNC.h
//  WinBridge
//
//  Created by Koji Ishii on 9/21/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (SMB)

+ (NSString*)stringWithStringUNC:(NSString*)source;
+ (NSString*)stringWithPasteboardUNC:(NSPasteboard*)pboard error:(NSString**)error;

@end
