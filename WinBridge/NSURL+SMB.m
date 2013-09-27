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
    NSString* url = [NSString stringWithCharacters:pchDstMin length:pchDstLim - pchDstMin];
    NSLog(@"stringWithStringUNC: source=%@, url=%@", source, url);
    return url;
}

+ (NSURL*)URLWithStringUNC:(NSString*)source
{
    NSString* urlString = [self stringWithStringUNC:source];
    if (!urlString)
        return nil;
    NSString* escaped = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:escaped];
    NSAssert(url, @"Cannot build URL from <%@>", urlString);
    return url;
}

+ (NSString*)stringWithPasteboardUNC:(NSPasteboard*)pboard error:(NSString**)error
{
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        *error = @"Please select a string";
        return nil;
    }

    NSString* source = [pboard stringForType:NSPasteboardTypeString];
    NSString* target = [NSURL stringWithStringUNC:source];
    return target;
}

+ (NSURL*)URLWithPasteboardUNC:(NSPasteboard*)pboard error:(NSString**)error
{
    if (![pboard canReadObjectForClasses:@[[NSString class]] options:@{}]) {
        *error = @"Please select a string";
        return nil;
    }

    NSString* source = [pboard stringForType:NSPasteboardTypeString];
    NSURL* target = [NSURL URLWithStringUNC:source];
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
    NSLog(@"%@ -> %@", self, result);
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
    NSLog(@"No local URL for %@", self);
    return nil;
}

static NSMutableArray* openUrlQueue;

- (void)openInSharedWorkspaceSMB
{
    NSLog(@"openInSharedWorkspaceSMB: %@", self);

    // Simply calling NSWorkspace's openURL or activateFileViewerSelectingURLs
    // will mount another instance if it's already mounted,
    // so we check mounted volumes first.
    NSURL* local = [self localURLIfMounted];
    if (local) {
        NSLog(@"openURL: already mounted at %@", local);
        [[NSWorkspace sharedWorkspace] openURL:local];
        return;
    }

    // If not mounted, kick auto mounter to mount the desired volume.
    // Since auto mounter runs in async, we observe NSWorkspaceDidMountNotification event.
    NSLog(@"openURL: not mounted, kick %@", self);
    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:[self copy] selector:@selector(didMount:) name:NSWorkspaceDidMountNotification object:nil];

    // Because addObserer does not retain the observer, retain self.
    if (!openUrlQueue)
        openUrlQueue = [[NSMutableArray alloc] init];
    [openUrlQueue addObject:self];

    // When the target UNC is not mounted, openURL will kick auto mounter for the URL.
    // If we call openUrl for a file, auto mounter will try to mount a file, so use its folder instead.
    NSURL* folder = [self URLByDeletingLastPathComponent];
    [[NSWorkspace sharedWorkspace] openURL:folder];
}

- (void)didMount:(NSNotification*)notification
{
    NSLog(@"didMount self=%@", self);
    NSURL* local = [self localURLIfMounted];
    if (!local)
        return;

    [[NSWorkspace sharedWorkspace] openURL:local];

    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
    [openUrlQueue removeObject:self];
}

@end
