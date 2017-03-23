//
//  NSData+Base64.h
//  
//
//  Created by Vincent Tuscano on 5/26/13.
//  Copyright (c) 2013 Vincent Tuscano. All rights reserved.
//


#import <Foundation/Foundation.h>

void *NewBase64Decode(
                      const char *inputBuffer,
                      size_t length,
                      size_t *outputLength);

char *NewBase64Encode(
                      const void *inputBuffer,
                      size_t length,
                      bool separateLines,
                      size_t *outputLength);

@interface NSData (Base64)

+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;

// added by Hiroshi Hashiguchi
- (NSString *)base64EncodedStringWithSeparateLines:(BOOL)separateLines;


@end