//
//  LYQRCodeViewController.h
//  LYQRCodeDemo
//
//  Created by Y Liu on 15/12/13.
//  Copyright © 2015年 DeveloperLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYQRCodeViewController : UIViewController

/**
 *  取消扫码
 */
@property (nonatomic, copy) void (^LYQRCodeCancleBlock) (LYQRCodeViewController *);

/**
 *  扫码成功, 返回结果
 */
@property (nonatomic, copy) void (^LYQRCodeSuncessBlock) (LYQRCodeViewController *, NSString *);

/**
 *  扫码失败
 */
@property (nonatomic, copy) void (^LYQRCodeFailBlock) (LYQRCodeViewController *);

@end
