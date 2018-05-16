//
//  JCHBarCodeScannerViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/30.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHBarCodeScannerViewController.h"
#import "JCHShopSelectViewController.h"
#import "JCHShopAssistantHomepageViewController.h"
#import "JCHManifestViewController.h"
#import "JCHCheckoutOnAccountViewController.h"
#import "JCHAddProductRecordViewController.h"
#import "JCHSettleAccountsViewController.h"
#import "JCHHomepageViewController.h"
#import "JCHUISettings.h"
#import "JCHAudioUtility.h"
#import "CommonHeader.h"
#import <Masonry.h>


@interface JCHBarCodeScannerViewController () <AVCaptureMetadataOutputObjectsDelegate>
{
    UIView *_scanLine;
    UIView *_scanRectView;
    UIButton *_turnLightButton;
    UIButton *_dismissButton;
    UIViewController *_presentingViewController;
}
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) NSTimer *scanLineTimer;
@end

@implementation JCHBarCodeScannerViewController

- (id)initWithController:(UIViewController *)controller
{
    self = [super init];
    if (self) {
        _presentingViewController = controller;
    }
    
    return self;
}

- (void)dealloc
{
    [self.detailInfo release];
    [self.session release];
    [self.previewLayer release];
    [self.barCodeBlock release];
    [self.scanLineTimer release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //self.title = @"扫码";

    [self createUI];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.session startRunning];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scanLineTimer = [NSTimer scheduledTimerWithTimeInterval:2.5
                                                          target:self
                                                        selector:@selector(moveScanLine)
                                                        userInfo:nil
                                                         repeats:YES];
    [self.scanLineTimer fire];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    if (_turnLightButton.selected) {
        [self turnLight:_turnLightButton];
    }
}

- (void)createUI
{
    CGFloat scanRecgViewWidth = kScreenWidth * 2 / 3;
    self.view.backgroundColor = [UIColor blackColor];
    _scanRectView =  [[[UIView alloc] init] autorelease];
    _scanRectView.backgroundColor = [UIColor clearColor];
    _scanRectView.frame = CGRectMake(0, 0, scanRecgViewWidth, scanRecgViewWidth);
    _scanRectView.center = CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds)/2, CGRectGetHeight([UIScreen mainScreen].bounds)/2 - 50);;
    
    _scanRectView.layer.borderWidth = 3;
    _scanRectView.layer.borderColor = [UIColor whiteColor].CGColor;
    _scanRectView.layer.shadowOffset = CGSizeMake(2, 2);
    _scanRectView.layer.shadowRadius = 5;
    _scanRectView.layer.shadowOpacity = 1;
    _scanRectView.layer.shadowColor = [UIColor blackColor].CGColor;
    [self.view addSubview:_scanRectView];
    
    _scanLine = [[[UIView alloc] init] autorelease];
    _scanLine.frame = CGRectMake(0, 0, scanRecgViewWidth, 1);
    _scanLine.backgroundColor = [UIColor greenColor];
    [_scanRectView addSubview:_scanLine];
    
    {
        UIView *topMaskView = [[[UIView alloc] init] autorelease];
        topMaskView.backgroundColor = [UIColor blackColor];
        topMaskView.alpha = 0.7;
        [self.view addSubview:topMaskView];
        
        [topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(self.view);
            make.bottom.equalTo(_scanRectView.mas_top);
        }];
        
        UIView *leftMaskView = [[[UIView alloc] init] autorelease];
        leftMaskView.backgroundColor = [UIColor blackColor];
        leftMaskView.alpha = 0.7;
        [self.view addSubview:leftMaskView];
        
        [leftMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(_scanRectView.mas_left);
            make.top.equalTo(topMaskView.mas_bottom);
            make.bottom.equalTo(_scanRectView);
        }];
        
        UIView *rightMaskView = [[[UIView alloc] init] autorelease];
        rightMaskView.backgroundColor = [UIColor blackColor];
        rightMaskView.alpha = 0.7;
        [self.view addSubview:rightMaskView];
        
        [rightMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_scanRectView.mas_right);
            make.right.equalTo(self.view);
            make.top.equalTo(leftMaskView);
            make.bottom.equalTo(_scanRectView);
        }];
        
        UIView *bottomMaskView = [[[UIView alloc] init] autorelease];
        bottomMaskView.backgroundColor = [UIColor blackColor];
        bottomMaskView.alpha = 0.7;
        [self.view addSubview:bottomMaskView];
        
        [bottomMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view);
            make.right.equalTo(self.view);
            make.top.equalTo(_scanRectView.mas_bottom);
            make.bottom.equalTo(self.view);
        }];
        
        _dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dismissButton setImage:[UIImage imageNamed:@"bt_back"] forState:UIControlStateNormal];
        _dismissButton.frame = CGRectMake(10, 20, 44, 44);
        [_dismissButton addTarget:self action:@selector(handleDismiss) forControlEvents:UIControlEventTouchUpInside];
        [topMaskView addSubview:_dismissButton];
        
        _turnLightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_turnLightButton setImage:[UIImage imageNamed:@"btn_flashlight_close"] forState:UIControlStateNormal];
        [_turnLightButton setImage:[UIImage imageNamed:@"btn_flashlight_open"] forState:UIControlStateSelected];
        _turnLightButton.frame = CGRectMake(kScreenWidth - 30 - 20, 30, 30, 30);
        [_turnLightButton addTarget:self action:@selector(turnLight:) forControlEvents:UIControlEventTouchUpInside];
        [topMaskView addSubview:_turnLightButton];
        
        UILabel *titleLabel = [JCHUIFactory createJCHLabel:CGRectMake(kScreenWidth / 2 - 75, 20, 150, 44)
                                                     title:self.title
                                                      font:[UIFont boldSystemFontOfSize:18]
                                                 textColor:[UIColor whiteColor]
                                                    aligin:NSTextAlignmentCenter];
        [topMaskView addSubview:titleLabel];
        
        UILabel *detailInfoLabel = [JCHUIFactory createJCHLabel:CGRectZero
                                                          title:@""
                                                           font:[UIFont systemFontOfSize:16]
                                                      textColor:[UIColor whiteColor]
                                                         aligin:NSTextAlignmentCenter];
        [topMaskView addSubview:detailInfoLabel];
        
        if (self.detailInfo) {
            detailInfoLabel.text = self.detailInfo;
        }
        
        [detailInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(topMaskView).with.offset(-20);
            make.width.mas_equalTo(scanRecgViewWidth + 2 * kStandardLeftMargin);
            make.centerX.equalTo(topMaskView);
            make.height.mas_equalTo(40);
        }];
    }
    //1.摄像头设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //2.设置输入
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error) {
        NSLog(@"摄像头开启失败:%@", error.localizedDescription);
        return;
    }
    
    //3.设置输出(Metadata元数据)
    AVCaptureMetadataOutput *output = [[[AVCaptureMetadataOutput alloc] init] autorelease];
    
    // 3.1 设置输出的代理
    // 说明：使用主线程队列，相应比较同步，使用其他队列，相应不同步，容易让用户产生不好的体验
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    //4.拍摄会话
    AVCaptureSession *session = [[[AVCaptureSession alloc] init] autorelease];
    //添加session的输入输出
    [session addInput:input];
    [session addOutput:output];
    //使用1080p的图像输出
    session.sessionPreset = AVCaptureSessionPreset1920x1080;
    self.session = session;
    //[output setMetadataObjectTypes:[output availableMetadataObjectTypes]];
    
    
    //4 设置输出的格式
    if (self.metadataObjectTypes) {
        if ([self.metadataObjectTypes isEqualToArray:@[]]) {
            [output setMetadataObjectTypes:[output availableMetadataObjectTypes]];
        } else {
            [output setMetadataObjectTypes:self.metadataObjectTypes];
        }
    } else {
        [output setMetadataObjectTypes:[output availableMetadataObjectTypes]];
    }
    

    
    //5.设置预览图层（用来让用户能够看到扫描情况）
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = [UIScreen mainScreen].bounds;
    self.previewLayer = previewLayer;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    //调整识别范围
    CGSize size = [UIScreen mainScreen].bounds.size;
    CGRect cropRect = _scanRectView.frame;
    CGFloat p1 = size.height/size.width;
    CGFloat p2 = 1920./1080.;  //使用1080p的图像输出
    if (p1 < p2) {
        CGFloat fixHeight = [UIScreen mainScreen].bounds.size.width * 1920. / 1080.;
        CGFloat fixPadding = (fixHeight - size.height)/2;
        output.rectOfInterest = CGRectMake((cropRect.origin.y + fixPadding)/fixHeight,
                                           cropRect.origin.x/size.width,
                                           cropRect.size.height/fixHeight,
                                           cropRect.size.width/size.width);
    } else {
        CGFloat fixWidth = [UIScreen mainScreen].bounds.size.height * 1080. / 1920.;
        CGFloat fixPadding = (fixWidth - size.width)/2;
        output.rectOfInterest = CGRectMake(cropRect.origin.y/size.height,
                                           (cropRect.origin.x + fixPadding)/fixWidth,
                                           cropRect.size.height/size.height,
                                           cropRect.size.width/fixWidth);
    }
}

- (void)turnLight:(UIButton *)sender
{
    sender.selected = !sender.selected;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        if (sender.selected) {
            [device setTorchMode:AVCaptureTorchModeOn];
        }
        else
        {
            [device setTorchMode:AVCaptureTorchModeOff];
        }
        [device unlockForConfiguration];
    }
}

- (void)moveScanLine
{
    [UIView animateWithDuration:2 animations:^{
        _scanLine.transform = CGAffineTransformMakeTranslation(0, _scanRectView.frame.size.height - 4);
    } completion:^(BOOL finished) {
        _scanLine.transform = CGAffineTransformIdentity;
    }];
}

- (void)applicationWillEnterForeground:(NSNotification*)note {
    [self.session  startRunning];
}
- (void)applicationDidEnterBackground:(NSNotification*)note {
    if (_turnLightButton.selected) {
        [self turnLight:_turnLightButton];
    }
    [self.session stopRunning];
}

- (void)handleDismiss
{
    [self.scanLineTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    if (metadataObjects.count > 0) {

        AVCaptureMetadataOutput *output = (AVCaptureMetadataOutput *)captureOutput;
        [output setMetadataObjectsDelegate:nil queue:nil];
        
        //音效
        [JCHAudioUtility playAudio:@"barCodeAudio.wav" shake:NO];

        AVMetadataMachineReadableCodeObject *obj = metadataObjects[0];
        NSString *barCode = [obj stringValue];
        if (barCode) {
            if (self.barCodeBlock) {
                self.barCodeBlock(barCode);
                [self handleDismiss];
            }
        }
    }
}



@end
