//
//  ViewController.m
//  GlobalLabel
//
//  Created by Shannon MYang on 2018/7/2.
//  Copyright © 2018年 Shannon MYang. All rights reserved.
//

#import "ViewController.h"

#import "DIXGlobalView.h"

@interface ViewController ()

@property (nonatomic, retain) DIXGlobalView *sphereView;

@end

@implementation ViewController
@synthesize sphereView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    sphereView = [[DIXGlobalView alloc] initWithFrame:CGRectMake(0, 100, self.view.bounds.size.width, self.view.bounds.size.width)];
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
    for (NSInteger i = 0; i < 50; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setTitle:[NSString stringWithFormat:@"%zd", i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        btn.backgroundColor = [UIColor cyanColor];
        btn.layer.cornerRadius = 5.f;
        btn.titleLabel.font = [UIFont systemFontOfSize:24.];
        btn.frame = CGRectMake(0, 0, 80, 30);
        [btn addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [array addObject:btn];
        [sphereView addSubview:btn];
    }
    [sphereView setCloudTags:array];
    sphereView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:sphereView];
}

- (void)buttonPressed:(UIButton *)btn
{
    [sphereView letTimerStop];
    
    [UIView animateWithDuration:0.3 animations:^{
        btn.transform = CGAffineTransformMakeScale(2., 2.);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            btn.transform = CGAffineTransformMakeScale(1., 1.);
        } completion:^(BOOL finished) {
            [self->sphereView letTimerStart];
        }];
    }];
    NSLog(@"---=-=-=-=-=-=-");
}


@end
