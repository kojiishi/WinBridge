//
//  WBUNC.m
//  WinBridge
//
//  Created by Koji Ishii on 9/21/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "NSURL+SMB.h"

@implementation NSURL (SMB)

+ (NSString*)stringWithStringUNC:(NSString*)source
{
    if (!source)
        return nil;

    const unichar* szSrc = (const unichar*)[source cStringUsingEncoding:NSUTF16StringEncoding];
    NSUInteger cchSrcMax = [source maximumLengthOfBytesUsingEncoding:NSUTF16StringEncoding];
    const size_t cbDst = cchSrcMax + 4 * sizeof(unichar);
    unichar* pchDst = (unichar*)alloca(cbDst);
    unichar* pchDst0 = pchDst;
    unichar* pchDstMin = NULL;
    unichar* pchDstLim = NULL;
    bool hasStartChar = false;
    while (true) {
        unichar ch = *szSrc++;
        if (!ch)
            break;

        // Find "\\" as the beginning of UNC, or transform to "/" if in the middle.
        if (ch == '\\') {
            if (!pchDstMin) {
                if (*szSrc != '\\')
                    continue;
                pchDstMin = pchDst;
                *pchDst++ = 's';
                *pchDst++ = 'm';
                *pchDst++ = 'b';
                *pchDst++ = ':';
            }
            *pchDst++ = '/';
            continue;
        }

        if (!pchDstMin) {
            if (ch == '<')
                hasStartChar = true;
            else if (!isspace(ch))
                hasStartChar = false;
            continue;
        }

        // Check termination character
        if (hasStartChar && ch == '>')
            break;

        // Keep track of the last non-spacing position.
        if (!isspace(ch))
            pchDstLim = NULL;
        else if (!pchDstLim)
            pchDstLim = pchDst;

        *pchDst++ = ch;
    }
    assert((void*)pchDst - (void*)pchDst0 <= cbDst);

    if (!pchDstMin)
        return nil;
    if (!pchDstLim)
        pchDstLim = pchDst;
    return [NSString stringWithCharacters:pchDstMin length:pchDstLim - pchDstMin];
}

+ (NSString*)stringWithPasteboardUNC:(NSPasteboard*)pboard error:(NSString**)error
{
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        *error = @"Please select a string";
        return nil;
    }

    NSString* source = [pboard stringForType:NSPasteboardTypeString];
    NSString* target = [NSURL stringWithStringUNC:source];
    NSLog(@"convertFromUNC: source=%@, target=%@", source, target);
    return target;
}

- (NSURL*)URLByReplacingRootURL:(NSURL*)root withURL:(NSURL*)newRoot
{
    if (![[root scheme] isEqualToString:[self scheme]] || ![[root host] isEqualToString:[self host]])
        return nil;
    NSString* myPath = [self path];
    NSString* rootPath = [root path];
    if (![myPath hasPrefix:rootPath])
        return nil;
    NSString* relativePath = [myPath substringFromIndex:[rootPath length]];
    NSString* newPath = [[newRoot path] stringByAppendingPathComponent:relativePath];
    NSURL* result = [NSURL fileURLWithPath:newPath];
    NSLog(@"%@ mapped to %@", self, result);
    return result;
}

- (NSURL*)localURLIfMounted
{
    NSArray* list = [[NSFileManager defaultManager]
        mountedVolumeURLsIncludingResourceValuesForKeys:@[NSURLTypeIdentifierKey]
        options:NSVolumeEnumerationSkipHiddenVolumes];
    for (NSURL* local in list) {
        NSURL* remote;
        if (![local getResourceValue:&remote forKey:NSURLVolumeURLForRemountingKey error:nil] ||
            !remote)
            continue;
        NSLog(@"Network volume: %@ -> %@", local, remote);
        NSURL* localMapped = [self URLByReplacingRootURL:remote withURL:local];
        if (localMapped)
            return localMapped;
    }
    return nil;
}

- (void)openInSharedWorkspaceSMB
{
    // Simply calling NSWorkspace's openURL or activateFileViewerSelectingURLs
    // will mount another instance if it's already mounted,
    // so we check mounted volumes.
    NSURL* local = [self localURLIfMounted];
    if (!local) {
//        NSURL* folder = [self URLByDeletingLastPathComponent];
//        [[NSWorkspace sharedWorkspace] openURL:folder];
        [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[self]];
        local = [self localURLIfMounted];
        if (!local) {
            NSAssert(NO, @"localURLIfMounted failed after AutoMount");
            local = self;
        }
    }
    NSLog(@"openURL: %@", local);
    [[NSWorkspace sharedWorkspace] openURL:local];
}

@end
