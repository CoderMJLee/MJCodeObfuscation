//
//  MJEncryptString.m
//  MJCodeObfuscation
//
//  Created by MJ Lee on 2018/8/18.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJEncryptString.h"

const char *mj_CString(const MJEncryptStringData *data)
{
    if (data->decoded == 1) return data->value;
    for (int i = 0; i < data->length; i++) {
        data->value[i] ^= data->factor;
    }
    ((MJEncryptStringData *)data)->decoded = 1;
    return data->value;
}

NSString *mj_OCString(const MJEncryptStringData *data)
{
    return [NSString stringWithUTF8String:mj_CString(data)];
}
