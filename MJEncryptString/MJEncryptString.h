//
//  MJEncryptString.h
//  MJCodeObfuscation
//
//  Created by MJ Lee on 2018/8/18.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#ifndef MJEncryptString_h
#define MJEncryptString_h

typedef struct {
    char factor;
    char *value;
    int length;
    char decoded;
} MJEncryptStringData;

const char *mj_CString(const MJEncryptStringData *data);

#ifdef __OBJC__
#import <Foundation/Foundation.h>
NSString *mj_OCString(const MJEncryptStringData *data);
#endif

#endif
