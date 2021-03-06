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
+ (NSURL*)URLWithStringUNC:(NSString*)source;

+ (NSString*)stringWithPasteboardUNC:(NSPasteboard*)pboard error:(NSString**)error;
+ (NSURL*)URLWithPasteboardUNC:(NSPasteboard*)pboard error:(NSString**)error;

- (void)openInSharedWorkspaceSMB;
- (NSURL*)localURLIfMounted;
- (NSURL*)URLByReplacingRootURL:(NSURL*)root withURL:(NSURL*)newRoot;

@end
