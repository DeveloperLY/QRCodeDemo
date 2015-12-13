//
//  LYQRCodeViewController.m
//  LYQRCodeDemo
//
//  Created by Y Liu on 15/12/13.
//  Copyright © 2015年 CoderYLiu. All rights reserved.
//

#import "LYQRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

static const float kLineMinY = 185;
static const float kLineMaxY = 385;
static const float kReaderViewWidth = 200;
static const float kReaderViewHeight = 200;

/**
 *  获取当前设备的宽/高/坐标
 */
#define kDeviceWidth [UIScreen mainScreen].bounds.size.width
#define KDeviceHeight [UIScreen mainScreen].bounds.size.height
#define KDeviceFrame [UIScreen mainScreen].bounds

@interface LYQRCodeViewController () <AVCaptureMetadataOutputObjectsDelegate> // 用于处理采集信息的代理

/**
 *  会话, 输入输出的中间桥梁
 */
@property (nonatomic, strong) AVCaptureSession *qrSession;

/**
 *  读取
 */
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *qrVideoPreviewLayer;

/**
 *  交互线
 */
@property (nonatomic, strong) UIImageView *line;

/**
 *  交互线控制
 */
@property (nonatomic, strong) NSTimer *lineTimer;

@end

@implementation LYQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 初始化UI
    [self initUI];
    
    [self setOverlayPickerView];
    
    [self startLYQRCodeReading];
    
    [self initTitleView];
    
    [self createBackBtn];
    
}

#pragma mark - createBackBtn
- (void)createBackBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(20, 28, 60, 24)];
    [btn setImage:[UIImage imageNamed:@"bar_back"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(cancleLYQRCodeReading) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
}

#pragma mark - initTitleView
- (void)initTitleView
{
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0,0,kDeviceWidth, 64)];
    bgView.backgroundColor = [UIColor colorWithRed:23.0/255 green:132.0/255 blue:132.0/255 alpha:1.0];
    [self.view addSubview:bgView];
    
    UILabel *titleLab = [[UILabel alloc] initWithFrame:CGRectMake((kDeviceWidth - 100) / 2.0, 28, 100, 20)];
    
    titleLab.text = @"扫描二维码";
    titleLab.shadowColor = [UIColor lightGrayColor];
    titleLab.shadowOffset = CGSizeMake(0, - 1);
    titleLab.font = [UIFont boldSystemFontOfSize:18.0];
    titleLab.textColor = [UIColor whiteColor];
    titleLab.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:titleLab];
}

#pragma mark - setOverlayPickerView
- (void)setOverlayPickerView
{
    // 画中间的基准线
    _line = [[UIImageView alloc] initWithFrame:CGRectMake((kDeviceWidth - 300) / 2.0, kLineMinY, 300, 12 * 300 / 320.0)];
    [_line setImage:[UIImage imageNamed:@"QRCodeLine"]];
    [self.view addSubview:_line];
    
    // 最上部view
    UIView* upView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, kLineMinY)];//80
    upView.alpha = 0.3;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];
    
    // 左侧的view
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMinY, (kDeviceWidth - kReaderViewWidth) / 2.0, kReaderViewHeight)];
    leftView.alpha = 0.3;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    
    // 右侧的view
    UIView *rightView = [[UIView alloc] initWithFrame:CGRectMake(kDeviceWidth - CGRectGetMaxX(leftView.frame), kLineMinY, CGRectGetMaxX(leftView.frame), kReaderViewHeight)];
    rightView.alpha = 0.3;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];
    
    CGFloat space_h = KDeviceHeight - kLineMaxY;
    
    // 底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, kLineMaxY, kDeviceWidth, space_h)];
    downView.alpha = 0.3;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];
    
    // 四个边角
    UIImage *cornerImage = [UIImage imageNamed:@"QRCodeTopLeft"];
    
    // 左侧的view
    UIImageView *leftView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    leftView_image.image = cornerImage;
    [self.view addSubview:leftView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodeTopRight"];
    
    // 右侧的view
    UIImageView *rightView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMaxY(upView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    rightView_image.image = cornerImage;
    [self.view addSubview:rightView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomLeft"];
    
    // 底部view
    UIImageView *downView_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downView_image.image = cornerImage;
    [self.view addSubview:downView_image];
    
    cornerImage = [UIImage imageNamed:@"QRCodebottomRight"];
    
    UIImageView *downViewRight_image = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetMinX(rightView.frame) - cornerImage.size.width / 2.0, CGRectGetMinY(downView.frame) - cornerImage.size.height / 2.0, cornerImage.size.width, cornerImage.size.height)];
    downViewRight_image.image = cornerImage;
    [self.view addSubview:downViewRight_image];
    
    // 说明label
    UILabel *labIntroudction = [[UILabel alloc] init];
    labIntroudction.backgroundColor = [UIColor clearColor];
    labIntroudction.frame = CGRectMake(CGRectGetMaxX(leftView.frame), CGRectGetMinY(downView.frame) + 25, kReaderViewWidth, 20);
    labIntroudction.textAlignment = NSTextAlignmentCenter;
    labIntroudction.font = [UIFont boldSystemFontOfSize:13.0];
    labIntroudction.textColor = [UIColor whiteColor];
    labIntroudction.text = @"将二维码置于框内, 即可自动扫描";
    [self.view addSubview:labIntroudction];
    
    UIView *scanCropView = [[UIView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(leftView.frame) - 1,kLineMinY,self.view.frame.size.width - 2 * CGRectGetMaxX(leftView.frame) + 2, kReaderViewHeight + 2)];
    scanCropView.layer.borderColor = [UIColor greenColor].CGColor;
    scanCropView.layer.borderWidth = 2.0;
    [self.view addSubview:scanCropView];
}

#pragma mark - 输出代理方法
// 此方法是在识别到QRCode，并且完成转换
// 如果QRCode的内容越大，转换需要的时间就越长
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    // 扫描结果
    if (metadataObjects.count > 0)
    {
        [self stopLYQRCodeReading];
        
        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        
        if (obj.stringValue && ![obj.stringValue isEqualToString:@""] && obj.stringValue.length > 0)
        {
            NSLog(@"---------------%@",obj.stringValue);
            
            if ([obj.stringValue containsString:@"http"])
            {
                if (self.LYQRCodeSuncessBlock) {
                    self.LYQRCodeSuncessBlock(self,obj.stringValue);
                }
            }
            else
            {
                if (self.LYQRCodeFailBlock) {
                    self.LYQRCodeFailBlock(self);
                }
            }
        }
        else
        {
            if (self.LYQRCodeFailBlock) {
                self.LYQRCodeFailBlock(self);
            }
        }
    }
    else
    {
        if (self.LYQRCodeFailBlock) {
            self.LYQRCodeFailBlock(self);
        }
    }
}

#pragma mark - 初始化UI
- (void)initUI
{
    // 获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 接收创建输入流的错误(没有错误为nil)
    NSError *error = nil;
    
    // 创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
    if (error){
        NSLog(@"没有摄像头-%@", error.localizedDescription);
        return;
    }
    
    // 设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
    
    // 设置输出的代理
    // 使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [output setRectOfInterest:[self getReaderViewBoundsWithSize:CGSizeMake(kReaderViewWidth, kReaderViewHeight)]];
    
    // 初始化链接对象
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    
    // 读取质量，质量越高，可读取小尺寸的二维码
//    if ([session canSetSessionPreset:AVCaptureSessionPreset1920x1080])
//    {
//        [session setSessionPreset:AVCaptureSessionPreset1920x1080];
//    }
//    else if ([session canSetSessionPreset:AVCaptureSessionPreset1280x720])
//    {
//        [session setSessionPreset:AVCaptureSessionPreset1280x720];
//    }
//    else
//    {
//        [session setSessionPreset:AVCaptureSessionPresetPhoto];
//    }
//    
//    if ([session canAddInput:input])
//    {
//        [session addInput:input];
//    }
//    
//    if ([session canAddOutput:output])
//    {
//        [session addOutput:output];
//    }
    
    // 高质量采集率
    [session setSessionPreset:AVCaptureSessionPresetHigh];
    
    [session addInput:input];
    [session addOutput:output];
    
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容)
    // 一定要先设置会话的输出为output之后，再指定输出的元数据类型
//    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
    
    [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    
    // 设置预览图层
    AVCaptureVideoPreviewLayer *preview = [AVCaptureVideoPreviewLayer layerWithSession:session];
    
    // 设置preview图层的属性
    //preview.borderColor = [UIColor redColor].CGColor;
    //preview.borderWidth = 1.5;
    [preview setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // 设置preview图层的大小
    preview.frame = self.view.layer.bounds;
    //[preview setFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight)];
    
    // 将图层添加到视图的图层
    [self.view.layer insertSublayer:preview atIndex:0];
    //[self.view.layer addSublayer:preview];
    self.qrVideoPreviewLayer = preview;
    self.qrSession = session;
}

- (CGRect)getReaderViewBoundsWithSize:(CGSize)asize
{
    return CGRectMake(kLineMinY / KDeviceHeight, ((kDeviceWidth - asize.width) / 2.0) / kDeviceWidth, asize.height / KDeviceHeight, asize.width / kDeviceWidth);
}

#pragma mark - 交互事件
// 开始扫码
- (void)startLYQRCodeReading
{
    self.lineTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 20 target:self selector:@selector(animationLine) userInfo:nil repeats:YES];
    
    [self.qrSession startRunning];
    
    NSLog(@"开始扫码...");
}

// 停止扫码
- (void)stopLYQRCodeReading
{
    if (self.lineTimer)
    {
        [self.lineTimer invalidate];
        self.lineTimer = nil;
    }
    
    [self.qrSession stopRunning];
    
    NSLog(@"停止扫码...");
}

// 取消扫描
- (void)cancleLYQRCodeReading
{
    [self stopLYQRCodeReading];
    
    if (self.LYQRCodeCancleBlock)
    {
        self.LYQRCodeCancleBlock(self);
    }
    NSLog(@"取消扫码...");
}

#pragma mark - 上下滚动交互线

- (void)animationLine
{
    __block CGRect frame = self.line.frame;
    
    static BOOL flag = YES;
    
    if (flag)
    {
        frame.origin.y = kLineMinY;
        flag = NO;
        
        [UIView animateWithDuration:1.0 / 20 animations:^{
            
            frame.origin.y += 5;
            self.line.frame = frame;
            
        } completion:nil];
    }
    else
    {
        if (self.line.frame.origin.y >= kLineMinY)
        {
            if (self.line.frame.origin.y >= kLineMaxY - 12)
            {
                frame.origin.y = kLineMinY;
                self.line.frame = frame;
                
                flag = YES;
            }
            else
            {
                [UIView animateWithDuration:1.0 / 20 animations:^{
                    
                    frame.origin.y += 5;
                    self.line.frame = frame;
                    
                } completion:nil];
            }
        }
        else
        {
            flag = !flag;
        }
    }
}


@end
