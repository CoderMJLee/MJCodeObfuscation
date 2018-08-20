//
//  MJDividerView.m
//  MJCodeObfuscation
//
//  Created by MJ Lee on 2018/8/18.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJDividerView.h"

@implementation MJDividerView

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder]) {
        self.wantsLayer = YES;
        self.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    }
    return self;
}

@end
