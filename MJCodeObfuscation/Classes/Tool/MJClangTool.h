//
//  MJClangTool.h
//  MJCodeObfuscation
//
//  Created by MJ Lee on 2018/8/17.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJClangTool : NSObject

/** 获得file中的所有字符串 */
+ (NSSet *)stringsWithFile:(NSString *)file
                searchPath:(NSString *)searchPath;

/** 获得file中的所有类名、方法名） */
+ (NSSet *)classesAndMethodsWithFile:(NSString *)file
                            prefixes:(NSArray *)prefixes
                          searchPath:(NSString *)searchPath;

@end
