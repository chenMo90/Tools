//
//  DemoViewController.m
//  ToolDemo
//
//  Created by luogq on 2020/8/19.
//  Copyright © 2020 LGQ. All rights reserved.
//

#import "DemoViewController.h"

#import "JimTimer.h"

#define kDemoVCTimerKey @"kDemoVCTimerKey"

@interface DemoViewController ()

@property (weak, nonatomic) IBOutlet UIButton *sendCodeBtn;

@end

@implementation DemoViewController

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.sendCodeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self addNot];
}

#pragma mark -- events
/** 发送验证码 */
- (IBAction)sendCodeAction:(UIButton *)sender {
    // 测试block形式的定时器
//    [self testBlockTimer];
    // 测试notification形式的定时器
    [self testNotificationTimer];
}

- (void)receiverNot:(NSNotification *)not {
    if ([not.name isEqualToString:kJimTimerManagerChangeNotificationKey]) { // 定时器改变
        JimTimerManagerNotificationModel *model = not.object;
        if ([model.key isEqualToString:kDemoVCTimerKey]) {
            [self changeCodeBtnWithInterval:model.interval key:model.key];
        }
    }else if ([not.name isEqualToString:kJimTimerManagerEndNotificationKey]) { // 定时器结束
        JimTimerManagerNotificationModel *model = not.object;
        if ([model.key isEqualToString:kDemoVCTimerKey]) {
            [self changeCodeBtnWithInterval:model.interval key:model.key];
        }
    }
}

#pragma mark -- private
/** 测试block形式的定时器 */
- (void)testBlockTimer {
    [JimTimerManager startTimerWithChangeBlock:^(NSString * _Nonnull key, int interval) {
        [self changeCodeBtnWithInterval:interval key:key];
    } endBlock:^(NSString * _Nonnull key) {
        [self changeCodeBtnWithInterval:0 key:key];
    }];
}

/** 测试notification形式的定时器 */
- (void)testNotificationTimer {
    [JimTimerManager startTimerWithKey:kDemoVCTimerKey];
}

/** 更新验证码按钮 */
- (void)changeCodeBtnWithInterval:(NSUInteger)interval {
    [self changeCodeBtnWithInterval:interval key:nil];
}

/** 更新验证码按钮，key只是为了打印而已 */
- (void)changeCodeBtnWithInterval:(NSUInteger)interval key:(NSString *)key {
    if (key) {
        NSLog(@"key:%@,interval:%@",key,kNumerToString(interval));
    }else {
        NSLog(@"interval:%@",kNumerToString(interval));
    }
    if (interval == 0) {
        self.sendCodeBtn.enabled = YES;
        [self.sendCodeBtn setTitle:@"重新获取验证码" forState:UIControlStateNormal];
        [self.sendCodeBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }else {
        self.sendCodeBtn.enabled = NO;
        [self.sendCodeBtn setTitle:kNumerToString(interval) forState:UIControlStateNormal];
        [self.sendCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }
}

- (void)addNot {
    [JimTimerManager addNotWithTarget:self sel:@selector(receiverNot:)];
}

@end
