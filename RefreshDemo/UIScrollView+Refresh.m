//
//  UIScrollView+Refresh.m
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "UIScrollView+Refresh.h"
#import <objc/runtime.h>

@implementation UIScrollView (Refresh)
@dynamic refreshHeader;

- (RefreshHeader *)refreshHeader {
    return objc_getAssociatedObject(self, "refreshHeader");
}

- (void)setRefreshHeader:(RefreshHeader *)refreshHeader {
    RefreshHeader *header = self.refreshHeader;
    if (header) {
        [header removeFromSuperview];
        header = nil;
    }
    
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self setNeedsLayout];
    [self layoutIfNeeded];

    [self addSubview:refreshHeader];
    objc_setAssociatedObject(self, "refreshHeader", refreshHeader, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
