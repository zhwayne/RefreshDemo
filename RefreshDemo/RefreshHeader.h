//
//  RefreshHeader.h
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "RefreshLoadView.h"


@class RefreshHeader;
@protocol RefreshHeaderDelegate <NSObject>

@optional

- (void)refreshHeader:(RefreshHeader *)header changeToState:(RefreshState)state progress:(CGFloat)progress;

@end

@interface RefreshHeader : RefreshLoadView

@property (nonatomic, weak) id<RefreshHeaderDelegate> delegate;

@property (nonatomic, assign) RefreshState state;

@end
