//
//  MJCodeViewController.m
//  MJCodeObfuscation
//
//  Created by MJ Lee on 2018/8/18.
//  Copyright © 2018年 MJ Lee. All rights reserved.
//

#import "MJCodeViewController.h"
#import "MJObfuscationTool.h"
#import "NSFileManager+Extension.h"
#import "NSString+Extension.h"

@interface MJCodeViewController()
@property (weak) IBOutlet NSButton *openBtn;
@property (weak) IBOutlet NSButton *chooseBtn;
@property (weak) IBOutlet NSButton *startBtn;
@property (weak) IBOutlet NSTextField *filepathLabel;
@property (copy) NSString *filepath;
@property (copy) NSString *destFilepath;
@property (weak) IBOutlet NSTextField *destFilepathLabel;
@property (weak) IBOutlet NSTextField *tipLabel;
@property (weak) IBOutlet NSTextField *prefixFiled;
@end

@implementation MJCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tipLabel.stringValue = @"";
    self.filepathLabel.stringValue = @"";
    self.destFilepathLabel.stringValue = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(prefixDidChange) name:NSControlTextDidChangeNotification object:self.prefixFiled];
}

- (void)prefixDidChange {
    NSString *text = [self.prefixFiled.stringValue mj_stringByRemovingSpace];
    self.startBtn.enabled = (text.length != 0) && self.filepath;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)chooseFile:(NSButton *)sender {
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    openPanel.prompt = @"选择";
    openPanel.canChooseDirectories = YES;
    openPanel.canChooseFiles = NO;
    [openPanel beginSheetModalForWindow:self.view.window completionHandler:^(NSModalResponse result) {
        if (result != NSModalResponseOK) return;
        
        self.filepath = openPanel.URLs.firstObject.path;
        self.filepathLabel.stringValue = [@"需要进行混淆的目录：\n" stringByAppendingString:self.filepath];
        self.destFilepath = nil;
        self.destFilepathLabel.stringValue = @"";
        self.openBtn.enabled = YES;
        [self prefixDidChange];
    }];
}

- (IBAction)openFile:(NSButton *)sender {
    NSString *file = self.destFilepath ? self.destFilepath : self.filepath;
    NSArray *fileURLs = @[[NSURL fileURLWithPath:file]];
    [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:fileURLs];
}

- (IBAction)start:(NSButton *)sender {
    self.destFilepath = nil;
    self.destFilepathLabel.stringValue = @"";
    self.startBtn.enabled = NO;
    self.chooseBtn.enabled = NO;
    self.prefixFiled.enabled = NO;
    
    // 获得前缀
    NSArray *prefixes = [self.prefixFiled.stringValue mj_componentsSeparatedBySpace];
    
    // 处理进度
    void (^progress)(NSString *) = ^(NSString *detail) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tipLabel.stringValue = detail;
        });
    };
    
    // 处理结束
    void (^completion)(NSString *) = ^(NSString *fileContent) {
        // 保存
        self.destFilepath = [self.filepath stringByAppendingPathComponent:@"MJCodeObfuscation.h"];
        self.destFilepath = [NSFileManager mj_checkPathExists:self.destFilepath];
        [fileContent writeToFile:self.destFilepath atomically:YES
                        encoding:NSUTF8StringEncoding error:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.destFilepathLabel.stringValue = [@"混淆后的文件路径：\n" stringByAppendingString:self.destFilepath];
            
            // 恢复按钮
            self.startBtn.enabled = YES;
            self.chooseBtn.enabled = YES;
            self.prefixFiled.enabled = YES;
        });
    };
    
    // 混淆
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [MJObfuscationTool obfuscateAtDir:self.filepath
                                 prefixes:prefixes
                                 progress:progress
                               completion:completion];
    });
}

@end
