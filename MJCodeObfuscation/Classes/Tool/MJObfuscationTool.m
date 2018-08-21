//
//  MJObfuscationTool.m
//  MJCodeObfuscation
//
//  Created by MJ Lee on 2018/8/17.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJObfuscationTool.h"
#import "NSString+Extension.h"
#import "NSFileManager+Extension.h"
#import "MJClangTool.h"

#define MJEncryptKeyVar @"#var#"
#define MJEncryptKeyComment @"#comment#"
#define MJEncryptKeyFactor @"#factor#"
#define MJEncryptKeyValue @"#value#"
#define MJEncryptKeyLength @"#length#"
#define MJEncryptKeyContent @"#content#"

@implementation MJObfuscationTool

+ (NSString *)_encryptStringDataHWithComment:(NSString *)comment
                                         var:(NSString *)var
{
    NSMutableString *content = [NSMutableString string];
    [content appendString:[NSString mj_stringWithFilename:@"MJEncryptStringDataHUnit" extension:@"tpl"]];
    [content replaceOccurrencesOfString:MJEncryptKeyComment
                             withString:comment
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:MJEncryptKeyVar
                             withString:var
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    return content;
}

+ (NSString *)_encryptStringDataMWithComment:(NSString *)comment
                                         var:(NSString *)var
                                      factor:(NSString *)factor
                                       value:(NSString *)value
                                      length:(NSString *)length
{
    NSMutableString *content = [NSMutableString mj_stringWithFilename:@"MJEncryptStringDataMUnit"
                                                            extension:@"tpl"];
    [content replaceOccurrencesOfString:MJEncryptKeyComment
                             withString:comment
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:MJEncryptKeyVar
                             withString:var
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:MJEncryptKeyFactor
                             withString:factor
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:MJEncryptKeyValue
                             withString:value
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    [content replaceOccurrencesOfString:MJEncryptKeyLength
                             withString:length
                                options:NSCaseInsensitiveSearch range:NSMakeRange(0, content.length)];
    return content;
}

+ (void)encryptString:(NSString *)string
                 completion:(void (^)(NSString *, NSString *))completion
{
    if (string.mj_stringByRemovingSpace.length == 0
        || !completion) return;
    
    // 拼接value
    NSMutableString *value = [NSMutableString string];
    char factor = arc4random_uniform(pow(2, sizeof(char) * 8) - 1);
    const char *cstring = string.UTF8String;
    int length = (int)strlen(cstring);
    for (int i = 0; i< length; i++) {
        [value appendFormat:@"%d,", factor ^ cstring[i]];
    }
    [value appendString:@"0"];
    
    // 变量
    NSString *var = [NSString stringWithFormat:@"_%@", string.mj_crc32];
    
    // 注释
    NSMutableString *comment = [NSMutableString string];
    [comment appendFormat:@"/* %@ */", string];
    
    // 头文件
    NSString *hStr = [self _encryptStringDataHWithComment:comment var:var];
    
    // 源文件
    NSString *mStr = [self _encryptStringDataMWithComment:comment
                                                      var:var
                                                   factor:[NSString stringWithFormat:@"%d", factor]
                                                    value:value
                                                   length:[NSString stringWithFormat:@"%d", length]];
    completion(hStr, mStr);
}

+ (void)encryptStringsAtDir:(NSString *)dir
                         progress:(void (^)(NSString *))progress
                       completion:(void (^)(NSString *, NSString *))completion
{
    if (dir.length == 0 || !completion) return;
    
    !progress ? : progress(@"正在扫描目录...");
    NSArray *subpaths = [NSFileManager mj_subpathsAtPath:dir
                                              extensions:@[@"c", @"cpp", @"m", @"mm"]];
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *subpath in subpaths) {
        !progress ? : progress([NSString stringWithFormat:@"分析：%@", subpath.lastPathComponent]);
        [set addObjectsFromArray:[MJClangTool stringsWithFile:subpath
                                                   searchPath:dir].allObjects];
    }
    
    !progress ? : progress(@"正在加密...");
    NSMutableString *hs = [NSMutableString string];
    NSMutableString *ms = [NSMutableString string];
    
    int index = 0;
    for (NSString *string in set) {
        index++;
        [self encryptString:string completion:^(NSString *h, NSString *m) {
            [hs appendFormat:@"%@", h];
            [ms appendFormat:@"%@", m];
            
            if (index != set.count) {
                [hs appendString:@"\n"];
                [ms appendString:@"\n"];
            }
        }];
    }
    
    !progress ? : progress(@"加密完毕!");
    
    NSMutableString *hFileContent = [NSMutableString mj_stringWithFilename:@"MJEncryptStringDataH" extension:@"tpl"];
    [hFileContent replaceOccurrencesOfString:MJEncryptKeyContent withString:hs options:NSCaseInsensitiveSearch range:NSMakeRange(0, hFileContent.length)];
    NSMutableString *mFileContent = [NSMutableString mj_stringWithFilename:@"MJEncryptStringDataM" extension:@"tpl"];
    [mFileContent replaceOccurrencesOfString:MJEncryptKeyContent withString:ms options:NSCaseInsensitiveSearch range:NSMakeRange(0, mFileContent.length)];
    completion(hFileContent, mFileContent);
}

+ (void)obfuscateAtDir:(NSString *)dir
                    prefixes:(NSArray *)prefixes
                    progress:(void (^)(NSString *))progress
                  completion:(void (^)(NSString *))completion
{
    if (dir.length == 0 || !completion) return;
    
    !progress ? : progress(@"正在扫描目录...");
    NSArray *subpaths = [NSFileManager mj_subpathsAtPath:dir extensions:@[@"m", @"mm"]];
    
    NSMutableSet *set = [NSMutableSet set];
    for (NSString *subpath in subpaths) {
        !progress ? : progress([NSString stringWithFormat:@"分析：%@", subpath.lastPathComponent]);
        [set addObjectsFromArray:
         [MJClangTool classesAndMethodsWithFile:subpath
                                       prefixes:prefixes
                                     searchPath:dir].allObjects];
    }
    
    !progress ? : progress(@"正在混淆...");
    NSMutableString *fileContent = [NSMutableString string];
    [fileContent appendString:@"#ifndef MJCodeObfuscation_h\n"];
    [fileContent appendString:@"#define MJCodeObfuscation_h\n"];
    NSMutableArray *obfuscations = [NSMutableArray array];
    for (NSString *token in set) {
        NSString *obfuscation = nil;
        while (!obfuscation || [obfuscations containsObject:obfuscation]) {
            obfuscation = [NSString mj_randomStringWithoutDigitalWithLength:16];
        }
        
        [fileContent appendFormat:@"#define %@ %@\n", token, obfuscation];
    }
    [fileContent appendString:@"#endif"];
    
    !progress ? : progress(@"混淆完毕!");
    completion(fileContent);
}

@end
