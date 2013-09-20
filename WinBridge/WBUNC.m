//
//  WBUNC.m
//  WinBridge
//
//  Created by Koji Ishii on 9/21/13.
//  Copyright (c) 2013 Koji Ishii. All rights reserved.
//

#import "WBUNC.h"

@implementation WBUNC

+ (NSString*)stringFromUNC:(NSString*)source
{
    if (!source)
        return nil;

    const unichar* szSrc = (const unichar*)[source cStringUsingEncoding:NSUTF16StringEncoding];
    NSUInteger cchSrcMax = [source maximumLengthOfBytesUsingEncoding:NSUTF16StringEncoding];
    unichar* pchDst = (unichar*)alloca(cchSrcMax + 4 * sizeof(unichar));
    unichar* pchDstMin = NULL;
    unichar* pchDstLim = NULL;
    while (true) {
        unichar ch = *szSrc++;
        if (!ch)
            break;
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
        if (pchDstMin) {
            if (!isspace(ch))
                pchDstLim = NULL;
            else if (!pchDstLim)
                pchDstLim = pchDst;
        }
        *pchDst++ = ch;
    }

    if (!pchDstMin)
        return nil;
    if (!pchDstLim)
        pchDstLim = pchDst;
    return [NSString stringWithCharacters:pchDstMin length:pchDstLim - pchDstMin];
}

@end
