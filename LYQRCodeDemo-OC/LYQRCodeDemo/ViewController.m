//
//  ViewController.m
//  LYQRCodeDemo
//
//  Created by Y Liu on 15/12/13.
//  Copyright © 2015年 DeveloperLY. All rights reserved.
//

#import "ViewController.h"
#import "LYQRCodeViewController.h"
#import "LYQRCodeUtil.h"

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

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
- (IBAction)readQRCode:(id)sender {
    // 选择照片
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请选择操作" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    // 判断是否支持相机
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.allowsEditing = YES;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.delegate = self;
            imagePicker.allowsEditing = YES;
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }]];
    } else {
        [alertController addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc]init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            imagePicker.allowsEditing = YES;
            imagePicker.delegate = self;
            [self presentViewController:imagePicker animated:YES completion:nil];
        }]];
    }
    
    UIAlertAction *canelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:canelAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 获取的图片
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.scanLabel.text = [LYQRCodeUtil readQRCodeFromImage:image];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
