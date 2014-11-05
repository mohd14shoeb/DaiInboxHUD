//
//  DaiInboxViewController.m
//  DaiInboxHUD
//
//  Created by 啟倫 陳 on 2014/11/4.
//  Copyright (c) 2014年 ChilunChen. All rights reserved.
//

#import "DaiInboxViewController.h"

#define inboxViewSize 30.0f
#define borderGap 10.0f

@implementation UIView (Center)

- (void)centerInBounds:(CGRect)bounds {
    CGRect newFrame = self.frame;
    newFrame.origin.x = bounds.size.width / 2 - newFrame.size.width / 2;
    newFrame.origin.y = bounds.size.height / 2 - newFrame.size.height / 2;
    self.frame = newFrame;
}

@end

@interface DaiInboxViewController ()

@property (nonatomic, strong) UIView *centerView;

@end

@implementation DaiInboxViewController

#pragma mark - instance method

// hide hud 然後帶個動畫
- (void)hide:(void (^)(void))completion {
    __weak DaiInboxViewController *wealSelf = self;
    [UIView animateWithDuration:1.0f animations: ^{
        wealSelf.centerView.alpha = 0;
    } completion: ^(BOOL finished) {
        completion();
    }];
}

#pragma mark - private

- (void)setupDefaultHUD {
    CGRect messageFrame = CGRectZero;
    UILabel *hudMessageLabel;
    
    //如果 hud message 有東西, 先算他的 size
    if (self.hudMessage) {
        hudMessageLabel = [UILabel new];
        hudMessageLabel.attributedText = self.hudMessage;
        [hudMessageLabel sizeToFit];
        messageFrame = hudMessageLabel.frame;
    }
    
    //設定好 centerview 的大小
    //寬度的算法, 取 hud 本身或是 label 的最大者, 加上左右兩旁的邊框
    CGFloat centerViewWidth = MAX(inboxViewSize, messageFrame.size.width) + borderGap*2;
    
    //高度的算法, 只有 hud 的時候就是 hud 本身加上上下的邊框, 多 label 的話, 要在 hud 跟 label 之間多塞一個一半大小的 gap
    CGFloat centerViewHeight = inboxViewSize + messageFrame.size.height + borderGap*2 + ((self.hudMessage)?borderGap*0.5:0);
    self.centerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, centerViewWidth, centerViewHeight)];
    [self.centerView centerInBounds:[UIScreen mainScreen].bounds];
    self.centerView.backgroundColor = self.hudBackgroundColor;
    self.centerView.layer.cornerRadius = 5.0f;
    self.centerView.layer.masksToBounds = YES;
    
    //開始把東西加入 centerView
    CGFloat objectHeight = borderGap;
    
    //加入 hud 主體
    DaiInboxView *inboxView = [[DaiInboxView alloc] initWithFrame:CGRectMake(self.centerView.frame.size.width / 2 - inboxViewSize / 2, objectHeight, inboxViewSize, inboxViewSize)];
    inboxView.hudColors = self.hudColors;
    inboxView.hudLineWidth = self.hudLineWidth;
    [self.centerView addSubview:inboxView];
    objectHeight += inboxView.frame.size.height + ((self.hudMessage)?borderGap*0.5:0);
    
    //如果有 label 的話就加
    if (self.hudMessage) {
        hudMessageLabel.frame = CGRectMake(self.centerView.frame.size.width / 2 - hudMessageLabel.frame.size.width / 2, objectHeight, hudMessageLabel.frame.size.width, hudMessageLabel.frame.size.height);
        [self.centerView addSubview:hudMessageLabel];
    }
    
    //放到 view 裡
    [self.view addSubview:self.centerView];
}

#pragma mark - life cycle

- (void)viewDidLoad {
    [self setupDefaultHUD];
    
    //一開始的彈出動畫效果
    self.centerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.001, 0.001);
    __weak DaiInboxViewController *wealSelf = self;
    [UIView animateWithDuration:0.3 / 1.5 animations: ^{
        wealSelf.centerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion: ^(BOOL finished) {
        [UIView animateWithDuration:0.3 / 2 animations: ^{
            wealSelf.centerView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        } completion: ^(BOOL finished) {
            [UIView animateWithDuration:0.3 / 2 animations: ^{
                wealSelf.centerView.transform = CGAffineTransformIdentity;
            }];
        }];
    }];
}

@end
