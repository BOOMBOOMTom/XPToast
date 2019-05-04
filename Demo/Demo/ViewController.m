//
//  ViewController.m
//  Demo
//
//  Created by admin on 2019/5/1.
//  Copyright © 2019 admin. All rights reserved.
//

#import "ViewController.h"
#import "XPToast.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic,strong) NSMutableArray<NSString *> *dataSource;
@property ( nonatomic,strong) UITableView *tableView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView = [UITableView new];
    self.tableView.frame = self.view.bounds;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    
    self.dataSource = [NSMutableArray array];
    [self.dataSource addObject:@"我是默认位置_Top"];
    [self.dataSource addObject:@"我是默认的style\n并且加了一个5秒的延迟消失_Center"];
    [self.dataSource addObject:@"我乱设置的全局style_Bottom"];
    [self.dataSource addObject:@"还原默认的全局style_默认动画从上往下"];
    [self.dataSource addObject:@"全局warning style_从下往上"];
    [self.dataSource addObject:@"全局error style_从右往左"];
    [self.dataSource addObject:@"独立的warning style"];
    [self.dataSource addObject:@"独立的error style"];
    [self.dataSource addObject:@"全局动画从左到右_从左往右"];
    [self.tableView reloadData];
}

#pragma mark - tableview

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellid = @"cellid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellid];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:cellid];
    }
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    NSString *text = self.dataSource[row];
    if (row == 0) {
        [XPToast toastWithText:text point:XPToastPointTypeTop];
    } else if (row == 1) {
        [XPToast toastWithText:text dismissAfter:5 point:XPToastPointTypeCenter];
    } else if (row == 2) {
        [XPToast toastStyleConfigure:^(XPToastStyleConfigure * _Nonnull x) {
            x.dismissAfterTime = 3;
            x.backgroundColor = [UIColor brownColor];
            x.textFont = [UIFont systemFontOfSize:13];
            x.textColor = [UIColor blackColor];
        }];
        [XPToast toastWithText:text point:XPToastPointTypeBottom];
    } else if (row == 3) {
        [XPToast toastStyleConfigure:^(XPToastStyleConfigure * _Nonnull x) {
            x.animationType = XPToastAnimationTypeDefault;
        }];
        [XPToast toastWithText:text point:XPToastPointTypeTop];
    } else if (row == 4) {
        [XPToast toastStyleConfigure:^(XPToastStyleConfigure * _Nonnull x) {
            x.animationType = XPToastAnimationTypeBottom;
        }];
        [XPToast toastWithText:text point:XPToastPointTypeCenter];
    } else if (row == 5) {
        [XPToast toastStyleConfigure:^(XPToastStyleConfigure * _Nonnull x) {
            x.animationType = XPToastAnimationTypeFromRightToLeft;
        }];
        [XPToast toastWithText:text point:XPToastPointTypeBottom];
    } else if (row == 6) {
        [XPToast toastWithText:text dismissAfter:2 point:XPToastPointTypeTop style:(XPToastStyleTypeWarning)];
    } else if (row == 7) {
        [XPToast toastWithText:text dismissAfter:2 point:XPToastPointTypeTop style:(XPToastStyleTypeError)];
    } else if (row == 8) {
        [XPToast toastStyleConfigure:^(XPToastStyleConfigure * _Nonnull x) {
            [x setAnimationType:(XPToastAnimationTypeFromLeftToRight)];
        }];
        [XPToast toastWithText:text point:XPToastPointTypeTop];
    }
}

@end
