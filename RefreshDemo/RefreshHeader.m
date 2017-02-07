//
//  RefreshHeader.m
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "RefreshHeader.h"

@interface RefreshHeader ()

@end

@implementation RefreshHeader

/*******************************************************************************
 * Header 添加到其父视图上时监听 frame 和 contentOffset.
 *******************************************************************************/
- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    
    self.frame = CGRectMake(0, -60, 0, 60);
    NSCAssert([self.superview isKindOfClass:[UIScrollView class]], @"RefreshHeader must add into a scroll view.");
    [self.superview addObserver:self forKeyPath:@"frame" options:0x01 | 0x02 context:nil];
    [self.superview addObserver:self forKeyPath:@"contentOffset" options:0x01 | 0x02 context:nil];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    [self.superview removeObserver:self forKeyPath:@"frame"];
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if ([keyPath isEqualToString:@"frame"]) {
        
        CGRect frame = [change[NSKeyValueChangeNewKey] CGRectValue];
        self.frame = CGRectMake(0, -self.bounds.size.height, frame.size.width, self.bounds.size.height);
        
    } else if ([keyPath isEqualToString:@"contentOffset"]) {
        
        UIScrollView *superView = (UIScrollView *)self.superview;
        
        CGFloat dragThresholdOffset = -superView.contentInset.top - self.bounds.size.height;
        
        /***********************************************************************
         * 下拉刷新操作分为两个阶段，第一阶段为手指拖动 scroll view，第二阶段为手指放开。在第
         * 一阶段，我们需要矫正 scroll view 的原始 content offset 并根据滑动偏移量设置刷新
         * 控件当前所处的状态。
         ***********************************************************************/
        if (superView.isDragging) {
            if (_isRefreshing) {
                return;
            }
            
            /*******************************************************************
             * 刷新状态默认处于 normal，需要处理何时进入 ready 及 refreshing。
             * 一般来讲，当 status 处于 normal 状态，并且下拉偏移量高于一个阈值时，才会进入
             * ready 状态。
             *******************************************************************/
            if (_status == RefreshStatusNormal && superView.contentOffset.y < dragThresholdOffset) {
                self.status = RefreshStatusReady;
            } else if (_status == RefreshStatusReady && superView.contentOffset.y > dragThresholdOffset) {
                self.status = RefreshStatusNormal;
            }
        } else {
            /*******************************************************************
             * 如果放开手指时正处于 ready 状态，则开始刷新。
             *******************************************************************/
            if (_status == RefreshStatusReady) {
                self.status = RefreshStatusRefreshing;
            }
        }
        
        
        
    }
}


- (void)setStatus:(RefreshStatus)status {
    _status = status;
    switch (status) {
        case RefreshStatusNormal: {
            self.backgroundColor = [UIColor clearColor];
        } break;
        
        case RefreshStatusReady: {
            self.backgroundColor = [UIColor redColor];
        } break;
            
        default: {
            self.backgroundColor = [UIColor greenColor];
            [self beginAction];
        }
    }
}

- (void)beginAction {
    if (_status == RefreshStatusRefreshing) {
        UIScrollView *superView = (UIScrollView *)self.superview;
        UIEdgeInsets edgeInset = superView.contentInset;
        edgeInset.top += self.bounds.size.height;
        
        [UIView animateWithDuration:0.3 animations:^{
            superView.contentInset = edgeInset;
        }];
        
        [super beginAction];
        
    } else {
        self.status = RefreshStatusRefreshing;
    }
    
}

- (void)endAction {
    UIScrollView *superView = (UIScrollView *)self.superview;
    UIEdgeInsets edgeInset = superView.contentInset;
    edgeInset.top -= self.bounds.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        superView.contentInset = edgeInset;
    } completion:^(BOOL finished) {
        self.status = RefreshStatusNormal;
        self.backgroundColor = [UIColor clearColor];
    }];
}

@end
