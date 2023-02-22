//
//  Toast.h
//  ButtonView
//
//  Created by Nathan Zheng on 2017/3/13.
//  Copyright © 2017年 Justin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Toast : NSObject

// 设置提示文字
+ (void)showWithText:(NSString *)text;

// 设置提示文字、显示时间
+ (void)showWithText:(NSString *)text
            duration:(CGFloat)duration;

// 设置提示文字、Toast与顶部距离
+ (void)showWithText:(NSString *)text
           topOffset:(CGFloat)topOffset;

// 设置提示文字、Toast与顶部距离、显示时间
+ (void)showWithText:(NSString *)text
           topOffset:(CGFloat)topOffset
            duration:(CGFloat)duration;

// 设置提示文字、Toast与底部距离
+ (void)showWithText:(NSString *)text
        bottomOffset:(CGFloat)bottomOffset;

// 设置提示文字、Toast与底部距离、显示时间
+ (void)showWithText:(NSString *)text
        bottomOffset:(CGFloat) bottomOffset
            duration:(CGFloat) duration;


@end
