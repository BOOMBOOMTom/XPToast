//
//  XPToast.m
//  Demo
//
//  Created by admin on 2019/5/1.
//  Copyright © 2019 admin. All rights reserved.
//

#import "XPToast.h"
#import "Masonry.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#pragma mark - window category
@interface UIWindow (_XPToast)
@property (nonatomic,strong) UIView *xp_toastLastToastView;
@end

@implementation UIWindow (_XPToast)

- (void)setXp_toastLastToastView:(UIView *)x {
    objc_setAssociatedObject(self, @selector(xp_toastLastToastView), x, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)xp_toastLastToastView {
    return objc_getAssociatedObject(self, _cmd);
}

@end

#pragma mark - XPToastStyleConfigure interface
@interface XPToastStyleConfigure ()
///默认的style，其实我是一个单例。
+ (instancetype)defaultStyle;
///默认的style
- (instancetype)initDefaultConfigure;
@end

#pragma mark - XPToast @implementation
@implementation XPToast

+ (void)toastWithText:(NSString *)text point:(XPToastPointType)point {
    [self toastWithText:text dismissAfter:[XPToastStyleConfigure defaultStyle].dismissAfterTime point:point];
}

+ (void)toastWithText:(NSString *)text dismissAfter:(NSTimeInterval)time point:(XPToastPointType)point {
    [self _toastWithText:text time:time point:point config:XPToastStyleConfigure.defaultStyle];
}

+ (void)toastWithText:(NSString *)text dismissAfter:(NSTimeInterval)time point:(XPToastPointType)point style:(XPToastStyleType)style {
    XPToastStyleConfigure *con = [[XPToastStyleConfigure alloc] initDefaultConfigure];
    switch (style) {
        case XPToastStyleTypeWarning:
            XPToastStyleWarning(con);
            break;
        case XPToastStyleTypeError:
            XPToastStyleError(con);
            break;
        default:
            break;
    }
    [self _toastWithText:text time:time point:point config:con];
}

+ (void)toastStyleConfigure:(void (^)(XPToastStyleConfigure * _Nonnull))block {
    !block?:block(XPToastStyleConfigure.defaultStyle);
}

#pragma mark - private

+ (void)_toastWithText:(NSString *)text time:(NSTimeInterval)time point:(XPToastPointType)point config:(XPToastStyleConfigure *)config {
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    keyWindow.windowLevel = UIWindowLevelStatusBar;
    
    UIView *bgView = [UIView new];
    bgView.backgroundColor = config.backgroundColor;
    [keyWindow addSubview:bgView];
    
    UILabel *label = [UILabel new];
    label.text = text;
    label.textColor = config.textColor;
    label.adjustsFontSizeToFitWidth = YES;
    label.numberOfLines = 0;
    label.font = config.textFont;
    [label setTextAlignment:(NSTextAlignmentCenter)];
    [bgView addSubview:label];
    
    CGFloat bgViewHeight = [self _navHeight] + [self _statusHeight];
    
    switch (point) {
        case XPToastPointTypeTop:{
            [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.offset(0);
                make.height.offset(bgViewHeight);
            }];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(15);
                make.right.offset(-15);
                make.top.offset([self _statusHeight]);
                make.height.offset([self _statusHeight]);
            }];
            break;
        }
        case XPToastPointTypeCenter:{
            [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(20);
                make.right.offset(-20);
                make.center.mas_equalTo(keyWindow);
                make.height.offset([self _navHeight]);
            }];
            break;
        }
        case XPToastPointTypeBottom:{
            [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.offset(20);
                make.right.offset(-20);
                make.bottom.mas_offset(-[self _tabbarHeight]);
                make.height.offset([self _navHeight]);
            }];
            break;
        }
        default:
            break;
    }
    
    if (point != XPToastPointTypeTop) {
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.offset(15);
            make.right.offset(-15);
            make.top.bottom.mas_equalTo(bgView);
        }];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width-40, [self _navHeight]) cornerRadius:10];
        CAShapeLayer *sLayer = [[CAShapeLayer alloc]init];
        sLayer.frame = CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width-40, [self _navHeight]);
        sLayer.path = path.CGPath;
        bgView.layer.mask = sLayer;
    }
    
    NSTimeInterval newTime = time;
    if (newTime <= 0.0) {
        newTime = config.dismissAfterTime;
    }
    //animation
    void(^animationTranslationBlock)(CGAffineTransform t) = ^(CGAffineTransform t) {
        [self _animationWithView:bgView dimissAfterTime:newTime formTransform:t];
    };
    switch (config.animationType) {
        case XPToastAnimationTypeFromLeftToRight: {
            animationTranslationBlock(CGAffineTransformMakeTranslation(0-[UIScreen mainScreen].bounds.size.width, 0));
            break;
        }
        case XPToastAnimationTypeDefault:{
            animationTranslationBlock(CGAffineTransformMakeTranslation(0, -bgViewHeight));
            break;
        }
        case XPToastAnimationTypeBottom:{
            if (point == XPToastPointTypeTop) {
                animationTranslationBlock(CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.width + bgViewHeight));
            }else{
                animationTranslationBlock(CGAffineTransformMakeTranslation(0, [UIScreen mainScreen].bounds.size.width + [self _tabbarHeight]));
            }
            break;
        }
        case XPToastAnimationTypeFromRightToLeft:{
            animationTranslationBlock(CGAffineTransformMakeTranslation([UIScreen mainScreen].bounds.size.width, 0));
            break;
        }
        default: {
            animationTranslationBlock(CGAffineTransformMakeTranslation(0, -bgViewHeight));
            break;
        }
    }
    
}

+ (void)_animationWithView:(UIView *)view dimissAfterTime:(NSTimeInterval)dimissAfterTime formTransform:(CGAffineTransform)formTransform {
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    UIView *bgView = view;
    CGFloat duration = .35;
    //animation show
    bgView.alpha = 0;
    bgView.transform = formTransform;
    [UIView animateWithDuration:duration animations:^{
        bgView.alpha = 1;
        bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        if (keyWindow.xp_toastLastToastView) {
            [keyWindow.xp_toastLastToastView removeFromSuperview];
        }
        keyWindow.xp_toastLastToastView = bgView;
    }];
    
    //dismiss
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((dimissAfterTime + duration) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (bgView.superview) {
            [UIView animateWithDuration:duration animations:^{
                bgView.alpha = 0;
                bgView.transform = formTransform;
            } completion:^(BOOL finished) {
                keyWindow.windowLevel = UIWindowLevelNormal;
            }];
        }
    });
}

+ (CGFloat)_statusHeight {
    return [[UIApplication sharedApplication] statusBarFrame].size.height;
}

+ (CGFloat)_navHeight {
    return 44;
}

+ (CGFloat)_tabbarHeight {
    return 49 + 34 + 10;
}

@end


#pragma mark - XPToastStyleConfigure

@implementation XPToastStyleConfigure

+ (instancetype)defaultStyle {
    static dispatch_once_t onceToken;
    static XPToastStyleConfigure *x;
    dispatch_once(&onceToken, ^{
        x = [[XPToastStyleConfigure alloc] initDefaultConfigure];
    });
    return x;
}

- (instancetype)init {
    self = [self initDefaultConfigure];
    if (self) {//防止外部别人配置style的时候进行对象的重新init
        NSAssert(NO, @"You can't init");
    }
    return self;
}

- (instancetype)initDefaultConfigure {
    if (self = [super init]) {
        XPToastStyleDefault(self);
    }
    return self;
}

#pragma mark - setter & getter

- (void)setDismissAfterTime:(NSTimeInterval)dismissAfterTime {
    _dismissAfterTime = dismissAfterTime;
    if (_dismissAfterTime <= 0.0) {
        _dismissAfterTime = 2;
    }
}

@end


#pragma mark - styles
///private
void _XPToastStyleInitConfigure(XPToastStyleConfigure *x) {
    x.textColor = [UIColor whiteColor];
    x.dismissAfterTime = 2;
    x.textFont = [UIFont systemFontOfSize:17];
    [x setAnimationType:(XPToastAnimationTypeDefault)];
}

void XPToastStyleDefault(XPToastStyleConfigure *x) {
    x.backgroundColor = [UIColor colorWithRed:77/255.0 green:130/255.0 blue:193/255.0 alpha:1];
    _XPToastStyleInitConfigure(x);
}

void XPToastStyleWarning(XPToastStyleConfigure *x) {
    x.backgroundColor = [UIColor colorWithRed:241/255.0 green:169/255.0 blue:95/255.0 alpha:1];
    _XPToastStyleInitConfigure(x);
}

void XPToastStyleError(XPToastStyleConfigure *x) {
    x.backgroundColor = [UIColor colorWithRed:236/255.0 green:95/255.0 blue:76/255.0 alpha:1];
    _XPToastStyleInitConfigure(x);
}
