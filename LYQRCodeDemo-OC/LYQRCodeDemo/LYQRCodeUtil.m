//
//  LYQRCodeUtil.m
//  LYQRCodeDemo
//
//  Created by LiuY on 2018/6/20.
//  Copyright © 2018年 DeveloperLY. All rights reserved.
//

#import "LYQRCodeUtil.h"

@implementation LYQRCodeUtil

#pragma mark 读取图片二维码

+ (NSString *)readQRCodeFromImage:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    CIImage *ciimage = [CIImage imageWithData:data];
    if (ciimage) {
        CIDetector *qrDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:[CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer:@(YES)}] options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
        NSArray *resultArr = [qrDetector featuresInImage:ciimage];
        if (resultArr.count >0) {
            CIFeature *feature = resultArr[0];
            CIQRCodeFeature *qrFeature = (CIQRCodeFeature *)feature;
            NSString *result = qrFeature.messageString;
            
            return result;
        } else {
            return nil;
        }
    } else {
        return nil;
    }
}

@end
