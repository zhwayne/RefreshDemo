//
//  RefreshHeader.m
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "RefreshHeader.h"


@interface RefreshHeader ()

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) CGPoint deceleratingOffset;

@property (nonatomic, strong) CADisplayLink *displayLink;

@property (nonatomic, assign) CGFloat displacement;

@property (nonatomic, assign) CFTimeInterval startTimeInterval;

@property (nonatomic, assign, readonly) RefreshState lastState;

@end


@implementation RefreshHeader

static char *observer_context = "RefreshHeader";

/*******************************************************************************
 * Header 添加到其父视图上时监听 frame 和 contentOffset.
 *******************************************************************************/
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    
    NSCAssert([self.superview isKindOfClass:[UIScrollView class]], @"RefreshHeader must add into a scroll view.");
    [self.superview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:observer_context];
    [self.superview addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:observer_context];
    
    _scrollView = (UIScrollView *)self.superview;
    self.scrollView.alwaysBounceVertical = YES;
    self.frame = CGRectMake(0, -(64 + self.scrollView.contentInset.top), self.scrollView.bounds.size.width, 64);
    if (self.state != RefreshStateRefreshing) {
        self.state = RefreshStatePossible;
    }
}


- (void)removeFromSuperview
{
    [self.displayLink invalidate];
    self.displayLink = nil;
    [self.superview removeObserver:self forKeyPath:@"frame" context:observer_context];
    [self.superview removeObserver:self forKeyPath:@"contentOffset" context:observer_context];
    [super removeFromSuperview];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if (context == observer_context){
        if (self.userInteractionEnabled == NO || self.hidden == YES)
            return;
        
        if ([keyPath isEqualToString:@"frame"]) {
            [self selfFrameDidChange:change];
        } else if ([keyPath isEqualToString:@"contentOffset"]) {
            [self scrollViewContentOffsetDidChange:change];
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


- (void)selfFrameDidChange:(NSDictionary *)change
{
    CGRect frame = [change[NSKeyValueChangeNewKey] CGRectValue];
    
    if (CGRectEqualToRect(frame, self.frame) == NO) {
        self.frame = CGRectMake(0, -self.bounds.size.height, frame.size.width, self.bounds.size.height);
    }
}


- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    /* 拖拽阈值偏移量是判定触发刷新操作的参照 */
    CGFloat dragStartOffset = -self.scrollView.contentInset.top;
    CGFloat dragThresholdOffset = dragStartOffset - self.bounds.size.height;
    
    /***************************************************************************
     * 下拉刷新操作分为两个阶段，第一阶段为手指拖动 scroll view，第二阶段为手指放开。在
     * 第一阶段，我们需要矫正 scroll view 的原始 content offset 并根据滑动偏移量设置
     * 刷新控件当前所处的状态。
     ***************************************************************************/
    if (self.scrollView.isDragging) {
        self.deceleratingOffset = self.scrollView.contentOffset;
        if (_state == RefreshStateRefreshing) {
            return;
        }
        /***********************************************************************
         * 刷新状态默认处于 possible，需要处理何时进入 preparing、ready 及 refreshing。
         * 一般来讲，当 state 处于 preparing 状态，并且下拉偏移量高于一个阈值时，才会进入
         * ready 状态。
         ***********************************************************************/
        if (_state == RefreshStatePossible) {
            if (self.scrollView.contentOffset.y < dragStartOffset) {
                self.state = RefreshStatePreparing;
            }
        } else if (_state == RefreshStatePreparing) {
            if (self.scrollView.contentOffset.y >= dragStartOffset) {
                self.state = RefreshStatePossible;
            } else if (self.scrollView.contentOffset.y < dragThresholdOffset) {
                self.state = RefreshStateReady;
            }
        } else if (_state == RefreshStateReady) {
            if (self.scrollView.contentOffset.y > dragThresholdOffset) {
                self.state = RefreshStatePreparing;
            }
        }
        
    } else {
        /***********************************************************************
         * 如果放开手指时正处于 ready 状态，则开始刷新。
         * 如果当前状态处于 preparing，则需判断上一个状态是否为 refreshing，因为状态转变为
         * refreshing 是会改变 scrollView 的 contentInset 属性，进而影响 contentOff-
         * set的判断。
         ***********************************************************************/
        if (_state == RefreshStateReady) {
            self.state = RefreshStateRefreshing;
        } else if (_state == RefreshStatePreparing) {
            if (_lastState != RefreshStateRefreshing) {
                if (self.scrollView.contentOffset.y >= dragStartOffset ) {
                    self.state = RefreshStatePossible;
                }
            } else {
                if (self.scrollView.contentOffset.y <= dragStartOffset ) {
                    self.state = RefreshStatePossible;
                }
            }
        } else if (_state == RefreshStateRefreshing) {
            if (self.scrollView.contentOffset.y > dragStartOffset) {
                self.state = RefreshStatePreparing;
            }
        }
    }
    
    [self notifyDelegateChangeState];
}


- (void)notifyDelegateChangeState
{
//    if (self.delegate == nil || [self.delegate respondsToSelector:@selector(refreshHeader:changeToState:progress:)] == NO)
//        return;
    
    if (_state == RefreshStateRefreshing) {
        [self.delegate refreshHeader:self changeToState:RefreshStateRefreshing progress:1];
    } else if (_state == RefreshStateReady) {
        [self.delegate refreshHeader:self changeToState:RefreshStateReady progress:1];
    } else if (_state == RefreshStatePossible) {
        [self.delegate refreshHeader:self changeToState:RefreshStatePossible progress:1];
    } else {
        [self layoutIfNeeded];
        CGFloat totolOffsetY = self.scrollView.contentInset.top + self.bounds.size.height;
        CGFloat contentOffsetY = MIN(self.scrollView.contentOffset.y, 0);
        contentOffsetY = MAX(self.bounds.size.height, contentOffsetY);
        NSLog(@"%.2f, %.2f", totolOffsetY, contentOffsetY);
        // TODO: 
    }
}


- (void)setState:(RefreshState)state
{
    _lastState = _state;
    _state = state;
    switch (_state) {
        case RefreshStatePossible: {
            [UIView animateWithDuration:0.2 animations:^{
                self.backgroundColor = [UIColor purpleColor];
            }];
        } break;
            
        case RefreshStatePreparing: {
            [UIView animateWithDuration:0.2 animations:^{
                self.backgroundColor = [UIColor orangeColor];
            }];
        } break;
        
        case RefreshStateReady: {
            [UIView animateWithDuration:0.2 animations:^{
                self.backgroundColor = [UIColor redColor];
            }];
        } break;
            
        default: {
            [self beginAction];
            [UIView animateWithDuration:0.2 animations:^{
                self.backgroundColor = [UIColor greenColor];
            }];
        }
    }
}


- (void)beginAction
{
    if (self.state == RefreshStateRefreshing) {
        UIEdgeInsets edgeInset = self.scrollView.contentInset;
        edgeInset.top += self.bounds.size.height;
        
        self.scrollView.contentOffset = self.deceleratingOffset;
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollView.contentInset = edgeInset;
        }];
        
        [super beginAction];
        
    } else {
        self.state = RefreshStateRefreshing;
    }
}


- (void)endAction
{
    self.displacement = self.bounds.size.height;
    self.scrollView.scrollEnabled = NO;
    self.startTimeInterval = RefreshScrollDuration;
    [self.displayLink invalidate];
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(tick:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)tick:(CADisplayLink *)sender
{
    CFTimeInterval dt1 = self.startTimeInterval;
    CFTimeInterval dt2 = dt1 - sender.duration;
    if (dt2 < 0) {
        self.startTimeInterval = 0;
        [sender invalidate];
        sender = nil;
        
        self.scrollView.scrollEnabled = YES;
        UIEdgeInsets edgeInset = self.scrollView.contentInset;
        edgeInset.top -= self.bounds.size.height;
        self.deceleratingOffset = CGPointZero;
        self.scrollView.contentInset = edgeInset;
        return;
    }
    
    CGFloat ds = self.displacement * ((pow(dt1, 2) - pow(dt2, 2)) / pow(RefreshScrollDuration, 2));
    printf("%.2f\n", ds);
    self.startTimeInterval = dt2;
    self.scrollView.contentOffset = CGPointMake(0, self.scrollView.contentOffset.y + ds);
}


@end
