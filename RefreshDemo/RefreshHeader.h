//
//  RefreshHeader.h
//  RefreshDemo
//
//  Created by 张尉 on 2017/1/11.
//  Copyright © 2017年 wayne. All rights reserved.
//

#import "RefreshLoadView.h"

typedef NS_ENUM(NSUInteger, RefreshStatus) {
    RefreshStatusNormal,
    RefreshStatusReady,
    RefreshStatusRefreshing
};

@interface RefreshHeader : RefreshLoadView

@property (nonatomic, assign) BOOL isRefreshing;
@property (nonatomic, assign) RefreshStatus status;

@end
