//
//  XPToast.h
//  Demo
//
//  Created by admin on 2019/5/1.
//  Copyright © 2019 admin. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, XPToastStyleType) {
    XPToastStyleTypeDefault,
    XPToastStyleTypeWarning,
    XPToastStyleTypeError,
};

typedef NS_ENUM(NSUInteger, XPToastPointType) {
    XPToastPointTypeTop,
    XPToastPointTypeCenter,
    XPToastPointTypeBottom,
};

typedef NS_ENUM(NSUInteger, XPToastAnimationType) {
    ///from top to bottom
    XPToastAnimationTypeDefault,
    ///from bottom to top
    XPToastAnimationTypeBottom,
    ///from left to right
    XPToastAnimationTypeFromLeftToRight,
    ///from right to left
    XPToastAnimationTypeFromRightToLeft,
};

@class XPToastStyleConfigure;
@interface XPToast : NSObject

/**
 在顶部显示一个最基本的text居中消息

 @param text 显示的text
 @param point 显示text的位置
 */
+ (void)toastWithText:(NSString *)text point:(XPToastPointType)point;

/**
 在顶部显示一个最基本的text居中消息，N秒后消失

 @param text 显示的文本
 @param point 显示text的位置
 @param time 手动指定多少秒之后消失，如果小于等于0则会去全局配置信息里获取值
 */
+ (void)toastWithText:(NSString *)text dismissAfter:(NSTimeInterval)time point:(XPToastPointType)point;

/**
 toast，可单独自定义style，不采用全局的style。

 @param text text
 @param time dismissAfterTime
 @param point 显示text的位置
 @param style style:此style是单独的toast配置(吃独食)。不会影响全局.
 */
+ (void)toastWithText:(NSString *)text dismissAfter:(NSTimeInterval)time point:(XPToastPointType)point style:(XPToastStyleType)style;

/**
 toast的全局配置样式

 @param block block回调，全局配置样式的对象(默认配置的对象)在block的回调参数里。
 */
+ (void)toastStyleConfigure:(void(^)(XPToastStyleConfigure *x))block;

@end

#pragma mark - XPToastConfigure
@class UIColor,UIFont;
@interface XPToastStyleConfigure : NSObject
///多少秒以后消失toast，默认2秒,如果设置的值小于等于0，则内部会自动设置为2
@property (nonatomic,assign) NSTimeInterval dismissAfterTime;
///default is [UIColor colorWithRed:77/255.0 green:130/255.0 blue:193/255.0 alpha:1]
@property (nonatomic,strong) UIColor *backgroundColor;
///default is white
@property (nonatomic,strong) UIColor *textColor;
///default is system font.
@property (nonatomic,strong) UIFont *textFont;
///default is XPToastAnimationTypeDefault
@property (nonatomic,assign) XPToastAnimationType animationType;
@end

NS_ASSUME_NONNULL_END

#pragma mark - styles
typedef XPToastStyleConfigure *_Nonnull(^XPToastStyleConfigureBlock)(void);

///default style
void XPToastStyleDefault(XPToastStyleConfigure *_Nullable x);
///warning style
void XPToastStyleWarning(XPToastStyleConfigure *_Nullable x);
///error style
void XPToastStyleError(XPToastStyleConfigure *_Nullable x);
