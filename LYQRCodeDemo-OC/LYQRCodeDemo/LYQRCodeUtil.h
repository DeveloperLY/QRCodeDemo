//
//  LYQRCodeUtil.h
//  LYQRCodeDemo
//
//  Created by LiuY on 2018/6/20.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LYQRCodeUtil : NSObject

/**
 *  读取图片中二维码信息
 *
 *  @param image 图片
 *
 *  @return 二维码内容
 */
+ (NSString *)readQRCodeFromImage:(UIImage *)image;

@end
