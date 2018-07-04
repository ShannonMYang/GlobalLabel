//
//  DIXGlobalView.m
//  GlobalLabel
//
//  Created by Shannon MYang on 2018/7/2.
//  Copyright © 2018年 Shannon MYang. All rights reserved.
//

#import "DIXGlobalView.h"

#import "DIXMatrix.h"

@interface DIXGlobalView() <UIGestureRecognizerDelegate> {
    NSMutableArray *_tags;
    NSMutableArray *_coordinate;
    DIXPoint _normalDirection;
    CGPoint _last;
    
    CGFloat _velocity;
    
    CADisplayLink *_timer;
    CADisplayLink *_inertia;
}

@end

@implementation DIXGlobalView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:gesture];
    }
    return self;
}

#pragma mark - initial set
- (void)setCloudTags:(NSArray *)array
{
    _tags = [NSMutableArray arrayWithArray:array];
    _coordinate = [[NSMutableArray alloc] initWithCapacity:0];
    
    // 重置view的中心点，便于计算
    for (NSInteger i = 0; i < _tags.count; i ++) {
        UIView *view = [_tags objectAtIndex:i];
        view.center = CGPointMake(self.frame.size.width / 2., self.frame.size.height / 2.);
    }
    
    CGFloat p1 = M_PI * (3 - sqrt(5));
    CGFloat p2 = 2. / _tags.count;
    
    NSLog(@"p1:%f p2:%f", p1, p2);
    
    for (NSInteger i = 0; i < _tags.count; i ++) {
        
        CGFloat y = i * p2 - 1 + (p2 / 2);
        CGFloat r = sqrt(1 - y * y);
        CGFloat p3 = i * p1;
        CGFloat x = cos(p3) * r;
        CGFloat z = sin(p3) * r;
        
        
        DIXPoint point = DIXPointMake(x, y, z);
        NSValue *value = [NSValue value:&point withObjCType:@encode(DIXPoint)];
        [_coordinate addObject:value];
        
        NSLog(@"x:%f y:%f z:%f", point.x, point.y, point.z);
        
        CGFloat time = (arc4random() % 10 + 10.) / 20.;
        
        [UIView animateWithDuration:time delay:0. options:UIViewAnimationOptionCurveEaseOut animations:^{
            [self setTagOfPoint:point andIndex:i];
        } completion:^(BOOL finished) {
            
        }];
        
    }
    
    NSInteger a =  arc4random() % 10 - 5;
    NSInteger b =  arc4random() % 10 - 5;
    _normalDirection = DIXPointMake(a, b, 0);
    [self letTimerStart];
}

#pragma mark - set frame of point
- (void)updateFrameOfPoint:(NSInteger)index direction:(DIXPoint)direction andAngle:(CGFloat)angle
{
    NSValue *value = [_coordinate objectAtIndex:index];
    DIXPoint point;
    [value getValue:&point];
    
    DIXPoint rPoint = DIXPointMakeRotation(point, direction, angle);
    value = [NSValue value:&rPoint withObjCType:@encode(DIXPoint)];
    _coordinate[index] = value;
    
    [self setTagOfPoint:rPoint andIndex:index];
}

- (void)setTagOfPoint:(DIXPoint)point andIndex:(NSInteger)index
{
    UIView *view = [_tags objectAtIndex:index];
    view.center = CGPointMake((point.x + 1) * (self.frame.size.width / 2.), (point.y + 1) * self.frame.size.width / 2.);
    
    CGFloat transform = (point.z + 2) / 3;
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, transform, transform);
    view.layer.zPosition = transform;
    view.alpha = transform;
    if (point.z < 0) {
        //禁止交互
        view.userInteractionEnabled = NO;
    } else {
        //开启交互
        view.userInteractionEnabled = YES;
    }
}

#pragma mark - autoTurnRotation
// 开启时间
- (void)letTimerStart
{
    _timer = [CADisplayLink displayLinkWithTarget:self selector:@selector(autoTurnRotation)];
    // 添加到主Runloop
    [_timer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

// 停止时间
- (void)letTimerStop
{
    [_timer invalidate];
    _timer = nil;
}

- (void)autoTurnRotation
{
    for (NSInteger i = 0; i < _tags.count; i ++) {
        [self updateFrameOfPoint:i direction:_normalDirection andAngle:0.002];
    }
}

#pragma mark - inertia
- (void)inertiaStart
{
    [self letTimerStop];
    _inertia = [CADisplayLink displayLinkWithTarget:self selector:@selector(inertiaStep)];
    // 添加到主Runloop
    [_inertia addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)inertiaStop
{
    [_inertia invalidate];
    _inertia = nil;
    [self letTimerStart];
}

- (void)inertiaStep
{
    if (_velocity <= 0) {
        [self inertiaStop];
    }else {
        _velocity -= 70.;
        CGFloat angle = _velocity / self.frame.size.width * 2. * _inertia.duration;
        for (NSInteger i = 0; i < _tags.count; i ++) {
            [self updateFrameOfPoint:i direction:_normalDirection andAngle:angle];
        }
    }
}

#pragma mark - gesture selector
// 处理Touch事件
- (void)handlePanGesture:(UIPanGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        _last = [gesture locationInView:self];
        [self letTimerStop];
        [self inertiaStop];
        
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        CGPoint current = [gesture locationInView:self];
        DIXPoint direction = DIXPointMake(_last.y - current.y, current.x - _last.x, 0);
        
        CGFloat distance = sqrt(direction.x * direction.x + direction.y * direction.y);
        
        CGFloat angle = distance / (self.frame.size.width / 2.);
        
        for (NSInteger i = 0; i < _tags.count; i ++) {
            [self updateFrameOfPoint:i direction:direction andAngle:angle];
        }
        _normalDirection = direction;
        _last = current;
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocityP = [gesture velocityInView:self];
        _velocity = sqrt(velocityP.x * velocityP.x + velocityP.y * velocityP.y);
        [self inertiaStart];
        
    }
}

@end
