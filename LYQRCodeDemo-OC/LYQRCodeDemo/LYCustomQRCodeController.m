//
//  LYCustomQRCodeController.m
//  LYQRCodeDemo
//
//  Created by Y Liu on 15/12/13.
//  Copyright © 2015年 DeveloperLY. All rights reserved.
//

#import "LYCustomQRCodeController.h"

@interface LYCustomQRCodeController ()

@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;

@end

@implementation LYCustomQRCodeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 生成二维码
    UIImage *qrcode = [self createNonInterpolatedUIImageFormCIImage:[self createQRForString:@"http://www.developerly.net"] withSize:250.0f];
    
    UIImage *customQrcode = [self imageBlackToTransparent:qrcode withRed:60.0f andGreen:74.0f andBlue:89.0f];
    self.qrcodeView.image = customQrcode;
    
    // 设置阴影(自定义)
    self.qrcodeView.layer.shadowOffset = CGSizeMake(0, 0.5); // 设置阴影的偏移量
    self.qrcodeView.layer.shadowRadius = 1; // 设置阴影的半径
    self.qrcodeView.layer.shadowColor = [UIColor blackColor].CGColor; // 设置阴影的颜色为黑色
    self.qrcodeView.layer.shadowOpacity = 0.5; // 设置阴影的不透明度
}

#pragma mark - InterpolatedUIImage
/*
    因为生成的二维码是一个CIImage,
    直接转换成UIImage的话大小不好控制,
    所以使用下面方法返回需要大小的UIImage
 */
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 创建一个位图图像, 将绘制到在所需的大小的位图上下文
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 保存bitmap 到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    // 释放资源
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma mark - QRCodeGenerator 
// 使用CIFilter生成二维码(原生)
- (CIImage *)createQRForString:(NSString *)qrString {
    // 将字符串转换为utf-8编码的NSData对象
    NSData *stringData = [qrString dataUsingEncoding:NSUTF8StringEncoding];
    
    // 创建filter
    CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    
    // 设置内容和纠错级别
    [qrFilter setValue:stringData forKey:@"inputMessage"];
    [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
    
    // 返回CIImage
    return qrFilter.outputImage;
}

#pragma mark - imageToTransparent
/*
    因为生成的二维码是黑白的, 所以还要对二维码进行颜色填充,
    并转换为透明背景，使用遍历图片像素来更改图片颜色,
    因为使用的是CGContext，速度非常快
 */
void ProviderReleaseData (void *info, const void *data, size_t size) {
    free((void*)data);
}

- (UIImage *)imageBlackToTransparent:(UIImage *)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue {
    const int imageWidth = image.size.width;
    const int imageHeight = image.size.height;
    size_t bytesPerRow = imageWidth * 4;
    uint32_t *rgbImageBuf = (uint32_t *)malloc(bytesPerRow * imageHeight);
    // 创建上下文
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++) {
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900) { // 将白色变成透明
            // 改变下面的代码, 会将图片转换成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        } else {
            uint8_t *ptr = (uint8_t *)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage *resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}


@end
