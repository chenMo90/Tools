//
//  ViewController.m
//  ToolDemo
//
//  Created by luogq on 2020/8/19.
//  Copyright © 2020 LGQ. All rights reserved.
//

#import "ViewController.h"

#import "DemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

#pragma mark -- life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
}

#pragma mark -- events
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DemoViewController *vc = [DemoViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
