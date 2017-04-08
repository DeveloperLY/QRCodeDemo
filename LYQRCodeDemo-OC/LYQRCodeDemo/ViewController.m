//
//  ViewController.m
//  LYQRCodeDemo
//
//  Created by Y Liu on 15/12/13.
//  Copyright © 2015年 DeveloperLY. All rights reserved.
//

#import "ViewController.h"
#import "LYQRCodeViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *scanButton;

@property (weak, nonatomic) IBOutlet UILabel *scanLabel;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

// 扫码
- (IBAction)scanQRCode {
    LYQRCodeViewController *qrcoderVC = [[LYQRCodeViewController alloc] init];
   
    // 扫码成功
    qrcoderVC.LYQRCodeSuncessBlock = ^(LYQRCodeViewController *aqrvc, NSString *qrString){
        self.scanLabel.text = qrString;
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    
    // 扫码失败
    qrcoderVC.LYQRCodeFailBlock = ^(LYQRCodeViewController *aqrvc){
        self.scanLabel.text = @"扫描失败...";
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
    };
    
    // 扫码取消
    qrcoderVC.LYQRCodeCancleBlock = ^(LYQRCodeViewController *aqrvc){
        [aqrvc dismissViewControllerAnimated:NO completion:nil];
        self.scanLabel.text = @"扫码取消...";
    };
    
    [self presentViewController:qrcoderVC animated:YES completion:nil];
}

@end
