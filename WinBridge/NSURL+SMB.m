//
//  WBUNC.m
//  WinBridge
//
//  Created by Koji Ishii on 9/21/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "NSURL+SMB.h"

@implementation NSURL (SMB)

+ (NSString*)stringWithUNC:(NSString*)source
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

@end
