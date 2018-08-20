# MJCodeObfuscation
> 一个用于代码混淆和字符串加密的Mac小Demo

- 主要是利用`libclang`解析扫描源代码的语法树，搜索出所有的类名、方法名、字符串
- 语法树解析的核心代码是：`MJCodeObfuscation/Classes/Tool/MJClangTool.m`，比较简单，不复杂
- 这仅仅是个小Demo，大家可以根据自己需要去调整代码，比如混淆协议、属性等等，可以自行添加实现
- 更多混淆相关，可以参考开源项目
  - [ios-class-guard](https://github.com/Polidea/ios-class-guard)
  - [ollvm](https://github.com/obfuscator-llvm/obfuscator)



## 代码混淆

> 将需要混淆的类名、方法名生成随机字符串的宏定义

- 假设要对MJPerson的类名、方法名进行混淆

```objective-c
@interface MJPerson : NSObject
- (void)mj_run;
- (void)mj_setupName:(NSString *)name mj_no:(int)no mj_age:(int)age;
@end
    
@implementation MJPerson
- (void)mj_run {
    NSLog(@"%s", __func__);
}

- (void)mj_setupName:(NSString *)name mj_no:(int)no mj_age:(int)age {
    NSLog(@"%s - %@ %d %d", __func__, name, no, age);
}
@end
```

- 点击【1.选择目录】
  - 选择需要扫描的代码目录
- 点击【2.开始混淆】
  - 会扫描所选择的目录以及子目录下的所有代码文件
  - 根据前缀（下图实例用的前缀是`MJ`、`mj_`）搜索出需要混淆的类名、方法名

![](https://images2018.cnblogs.com/blog/497279/201808/497279-20180820152207867-1084045147.gif)

- 最后会生成一个宏定义头文件MJCodeObfuscation.h

```objective-c
#define mj_run OmWJoTZfCqoPshvr
#define MJPerson egnjoOFDrFiQVRgr
#define mj_setupName HrZLzcgSoPhwMBwW
#define mj_age reXYcdSKKEUSMalJ
#define mj_no mHEQViTuoOvRtMuB
```

- 点击【打开目录】
  - 可以打开刚才所生成的宏定义头文件的所在目录

![](https://images2018.cnblogs.com/blog/497279/201808/497279-20180820152219450-1074617550.gif)

- 在项目的PCH文件中导入刚才的头文件

```objective-c
#ifndef PrefixHeader_pch
#define PrefixHeader_pch

#import "MJCodeObfuscation.h"

#endif /* PrefixHeader_pch */
```

- 最后的效果

```objective-c
MJPerson *person = [[MJPerson alloc] init];
[person mj_run];
[person mj_setupName:@"jack" mj_no:20 mj_age:21];

// 打印结果
-[egnjoOFDrFiQVRgr OmWJoTZfCqoPshvr]
-[egnjoOFDrFiQVRgr HrZLzcgSoPhwMBwW:mHEQViTuoOvRtMuB:reXYcdSKKEUSMalJ:] - jack 20 21
```



## 字符串加密（方式1）

> 仅仅是将字符串进行了一个简单的异或处理（开发者可以自行制定加密算法）

- 假设想对以下的C、OC字符串进行加密

```objective-c
NSString *str1 = @"小码哥mj123go";
const char *str2 = "小码哥mj123go";
NSLog(@"%@ %s", str1, str2);
```

- 点击【字符串加密】
  - 弹出字符串加密窗口
- 输入需要加密的字符串，点击【加密】

![](https://images2018.cnblogs.com/blog/497279/201808/497279-20180820162041646-620382237.gif)

- 加密后的内容如下所示，添加到项目中去（根据需要，声明和定义可以分别放.h和.m）

```objective-c
/* 小码哥mj123go */
extern const MJEncryptStringData * const _761622619;

/* 小码哥mj123go */
const MJEncryptStringData * const _761622619 = &(MJEncryptStringData){
    .factor = (char)-100,
    .value = (char []){121,44,19,123,60,29,121,15,57,-15,-10,-83,-82,-81,-5,-13,0},
    .length = 16
};
```

- 由于上面代码依赖`MJEncryptStringData`结构，所以需要将`MJEncryptString`目录的内容加入到项目中

![](https://images2018.cnblogs.com/blog/497279/201808/497279-20180820162253160-783805417.png)

- 在项目中的使用

```objective-c
#import "MJEncryptString.h"

NSString *str1 = mj_OCString(_761622619);
const char *str2 = mj_CString(_761622619);
NSLog(@"%@ %s", str1, str2);

// 打印结果如下
小码哥mj123go 小码哥mj123go
```



## 字符串加密（方式2）

- 点击【1.选择目录】
  - 选择需要扫描的代码目录
- 点击【2.开始加密】
  - 将开始自动扫描目录以及子目录下的所有字符串（C、OC字符串）

![](https://images2018.cnblogs.com/blog/497279/201808/497279-20180820162442278-1556544160.gif)

![](https://images2018.cnblogs.com/blog/497279/201808/497279-20180820162448921-927018764.gif)

- 加密完毕后，会自动生成一个`MJEncryptString`目录
  - 将这个目录添加到项目中
  - 并在PCH文件中导入头文件`MJEncryptStringData.h`（便于整个项目中共享使用加密的字符串）

```objective-c
#ifndef PrefixHeader_pch
#define PrefixHeader_pch

#import "MJEncryptStringData.h"

#endif /* PrefixHeader_pch */
```

- `MJEncryptStringData.h`文件内容如下所示
  - 它将项目里的`"%@ %s"`、`"小码哥mj123go"`字符串都进行了加密

```objective-c
#ifndef MJEncryptStringData_h
#define MJEncryptStringData_h
#include "MJEncryptString.h"
/* %@ %s */
extern const MJEncryptStringData * const _1302706645;
/* 小码哥mj123go */
extern const MJEncryptStringData * const _761622619;
#endif
```

- 在项目中的使用

```objective-c
NSString *str1 = mj_OCString(_761622619);
const char *str2 = mj_CString(_761622619);
NSLog(@"%@ %s", str1, str2);

// 打印结果如下
小码哥mj123go 小码哥mj123go
```