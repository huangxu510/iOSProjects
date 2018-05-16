//
//  JCHHTMLViewController.m
//  jinchuhuo
//
//  Created by apple on 16/2/17.
//  Copyright © 2016年 apple. All rights reserved.
//

/*
 JavaScriptCore中类及协议：
 
 JSContext：给JavaScript提供运行的上下文环境
 JSValue：JavaScript和Objective-C数据和方法的桥梁
 JSManagedValue：管理数据和方法的类
 JSVirtualMachine：处理线程相关，使用较少
 JSExport：这是一个协议，如果采用协议的方法交互，自己定义的协议必须遵守此协议
 
 */

#import "JCHHTMLViewController.h"
#import "JCHUserInfoViewController.h"
#import "JCHMenuView.h"
#import "JCHLoginViewController.h"
#import "JCHSyncStatusManager.h"
#import "CommonHeader.h"
#import "JCHDeviceUtility.h"
#import "JCHLocationManager.h"
#import "CommonHeader.h"
#import "LCActionSheet.h"
#import <SSKeychain.h>
#import <AddressBook/AddressBook.h>
#import <Masonry.h>
#import <QBImagePickerController.h>

#define kResponseResule            @"result"
#define kResponseSuccess           @"success"
#define kResponseMSG               @"msg"
#define kResponseTrue              @"true"
#define kResponseFalse             @"false"


//消除代理方法未实现警告
#pragma clang diagnostic push
#pragma clang diagnostic ignored"-Wprotocol"
@implementation JSContextHolder


- (id)initWithController:(JCHHTMLViewController *)controller
{
    self = [super init];
    if (self) {
        self.financeController = controller;
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

//消息重定向
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    if ([self.financeController respondsToSelector:[anInvocation selector]])
        [anInvocation invokeWithTarget:self.financeController];
    else
        [super forwardInvocation:anInvocation];
}

@end
#pragma clang diagnostic pop

@interface JCHHTMLViewController ()<UIWebViewDelegate,
                                        LCActionSheetDelegate,
                                        UINavigationControllerDelegate,
                                        QBImagePickerControllerDelegate,
                                        JCHMenuViewDelegate,
                                        UIImagePickerControllerDelegate,
                                        UINavigationControllerDelegate>

{
    BOOL _authenticated;
}

@property (retain, nonatomic, readwrite) UIWebView *webView;
@property (retain, nonatomic, readwrite) JSContext *jsContext;
@property (retain, nonatomic, readwrite) NSString *currentURL;
@property (assign, nonatomic, readwrite) BOOL postRequestFlag;
@property (retain, nonatomic, readwrite) NSString *currentCallBackName;
@property (retain, nonatomic, readwrite) NSString *currentExtraString;



@end


@implementation JCHHTMLViewController

- (id)initWithURL:(NSString *)url postRequest:(BOOL)postRequest
{
    self = [super init];
    if (self) {
        self.currentURL = url;
        self.postRequestFlag = postRequest;
        self.showNavigationBarRightButton = YES;
    }
    
    return self;
}

- (void)dealloc
{
    self.webView = nil;
    self.jsContext = nil;
    self.currentURL = nil;
    self.currentCallBackName = nil;
    self.currentExtraString = nil;
    self.navigationBarColor = nil;
    self.homeViewController = nil;
    self.popActionCallBack = nil;
    
    [JCHNotificationCenter removeObserver:self];
    
    [super dealloc];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
    
    
    return;
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.navigationBarColor) {
        [self.navigationController.navigationBar setBarTintColor:self.navigationBarColor];
    } else {
        [self.navigationController.navigationBar setBarTintColor:JCHColorHeaderBackground];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.needReloadWebView) {
        [self.webView reload];
    }
    self.needReloadWebView = NO;
}

- (void)createUI
{
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    
    if (true == self.showNavigationBarRightButton) {
        UIButton *addAccountBookButton = [JCHUIFactory createButton:CGRectMake(0, 0, 30, 44)
                                                             target:self
                                                             action:@selector(showTopMenuView)
                                                              title:nil
                                                         titleColor:nil
                                                    backgroundColor:nil];
        [addAccountBookButton setImage:[UIImage imageNamed:@"finance_icon_more"] forState:UIControlStateNormal];
        UIBarButtonItem *addItem = [[[UIBarButtonItem alloc] initWithCustomView:addAccountBookButton] autorelease];
        self.navigationItem.rightBarButtonItem = addItem;
    }

    
    self.webView = [[[UIWebView alloc] init] autorelease];
    self.webView.scalesPageToFit = YES;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.showsVerticalScrollIndicator = YES;
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    

    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSString *token = statusManager.syncToken;
    
    if (!statusManager.isLogin) {
        token = @"";
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.currentURL]];
    if (self.postRequestFlag) {
        NSString *body = [NSString stringWithFormat:@"token=%@&v=%@", token, @"1"];
        request.HTTPMethod = @"POST";
        request.HTTPBody = [body dataUsingEncoding:NSUTF8StringEncoding];
    }
    [self.webView loadRequest:request];
    
    
    
    return;
}

#pragma mark -
#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    self.jsContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    // 注入桥梁对象名为iOSFinance，承载的对象为self即为此控制器
    self.jsContext[@"iosFinance"] = [[[JSContextHolder alloc] initWithController:self] autorelease];
    NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (title && ![title isEmptyString]) {
        self.title = title;
    }
    
    self.jsContext.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue) {
        NSLog(@"ERROR: %@", exceptionValue);
    };
}


#pragma mark -
#pragma mark - requestLogin         1.登录
- (void)requestLogin:(NSString *)jsonRequest
        callBackName:(NSString *)callBackName
         extraString:(NSString *)extraString
{
    self.currentCallBackName = callBackName;
    self.currentExtraString = extraString;
    
     //1) 依据jsonParamString中的请求参数处理业务逻辑
    NSDictionary *requestData = [NSJSONSerialization JSONObjectWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    
    NSInteger statusCode = [requestData[@"type"] integerValue];
    
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    
    //如果未登录或者服务器验证失败，跳转到登录页面
    if (!statusManager.isLogin || statusCode == 2) {
        
        [JCHUserInfoViewController clearUserLoginStatus];
        JCHLoginViewController *loginVC = [[[JCHLoginViewController alloc] init] autorelease];
        UINavigationController *nav = [[[UINavigationController alloc] initWithRootViewController:loginVC] autorelease];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self presentViewController:nav animated:YES completion:nil];
        });
        
        [JCHNotificationCenter addObserver:self
                                  selector:@selector(hasLogin)
                                      name:kJCHHTMLViewControllerLoginSuccessNotification
                                    object:nil];
    } else {
        
        JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
        NSString *token = statusManager.syncToken;
        
        NSDictionary *response = @{kResponseResule : @{@"token" : token,
                                                       @"v" : @"1"},
                                   kResponseSuccess : kResponseTrue};
        // 生成响应参数
        NSString *jsonResponse = [response dataToJSONString];
        NSString *jsonResponseExtra = extraString;
        
        // 调用JS回调函数
        JSValue *callbackHandler = self.jsContext[callBackName];
        [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    }
    return;
}

- (void)hasLogin
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    NSString *token = statusManager.syncToken;
    
    NSDictionary *response = @{kResponseResule : @{@"token" : token,
                                                   @"v" : @""},
                               kResponseSuccess : kResponseTrue};
    // 生成响应参数
    NSString *jsonResponse = [response dataToJSONString];
    NSString *jsonResponseExtra = self.currentExtraString;
    
    // 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[self.currentCallBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
}

#pragma mark -
#pragma mark - requestUpdateApp         2.更新app
- (void)requestUpdateApp:(NSString *)jsonRequest
            callBackName:(NSString *)callBackName
             extraString:(NSString *)extraString
{
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/us/app/id1035522428"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark -
#pragma mark - getVersionCode       3.获取版本号  (暂时和版本名称一样)
- (void)getVersionCode:(NSString *)jsonRequest
          callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionCode = infoDictionary[@"CFBundleShortVersionString"];//CFBundleVersion
    
    
    NSDictionary *response = @{kResponseResule : @{@"versionCode" : appVersionCode},
                               kResponseSuccess : kResponseTrue,
                               kResponseMSG : @"成功"};
    
    NSString *jsonResponse = [response dataToJSONString];;
    NSString *jsonResponseExtra = extraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[callBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
}

#pragma mark -
#pragma mark - getVersionName       4.获取版本名称
- (void)getVersionName:(NSString *)jsonRequest
          callBackName:(NSString *)callBackName
           extraString:(NSString *)extraString
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersionName = infoDictionary[@"CFBundleShortVersionString"];
    
    
    NSDictionary *response = @{kResponseResule : @{@"versionName" : appVersionName},
                               kResponseSuccess : kResponseTrue,
                               kResponseMSG : @"成功"};
    
    NSString *jsonResponse = [response dataToJSONString];;
    NSString *jsonResponseExtra = extraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[callBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
}

#pragma mark -
#pragma mark - closePage        5.关闭页面
- (void)closePage:(NSString *)jsonRequest
     callBackName:(NSString *)callBackName
      extraString:(NSString *)extraString
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

#pragma mark -
#pragma mark - requestCredit    6.打开新页面
- (void)requestCredit:(NSString *)jsonRequest
         callBackName:(NSString *)callBackName
          extraString:(NSString *)extraString
{
    // 1) 依据jsonParamString中的请求参数处理业务逻辑
    NSDictionary *requestData = [NSJSONSerialization JSONObjectWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    NSString *urlString = requestData[@"url"];
    JCHHTMLViewController *newController = [[[JCHHTMLViewController alloc] initWithURL:urlString postRequest:NO] autorelease];
    newController.navigationBarColor = self.navigationController.navigationBar.barTintColor;

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:newController animated:YES];
    });
    
    
    if ([callBackName isEqualToString:@""]) {
        return;
    }
    
    // 2) 生成响应参数
    NSString *jsonResponse = @"";
    NSString *jsonResponseExtra = extraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[callBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    
    return;
}

#pragma mark -
#pragma mark - uploadImage    7.上传图片
- (void)uploadImage:(NSString *)jsonRequest
       callBackName:(NSString *)callBackName
        extraString:(NSString *)extraString
{
    self.currentCallBackName = callBackName;
    self.currentExtraString = extraString;
   
    LCActionSheet *actionSheet = [LCActionSheet sheetWithTitle:nil
                                                  buttonTitles:@[@"拍照", @"从手机相册选择"]
                                                redButtonIndex:-1
                                                      delegate:self];
    actionSheet.darkView.hidden = YES;
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [actionSheet show];
    });
}

#pragma mark -
#pragma mark - requestAddressBook    8.获取通讯录
- (void)requestAddressBook:(NSString *)jsonRequest
              callBackName:(NSString *)callBackName
               extraString:(NSString *)extraString
{
    self.currentCallBackName = callBackName;
    self.currentExtraString = extraString;
    [self loadPerson];
}

#pragma mark -
#pragma mark - getDeviceData    9.获取设备数据
- (void)getDeviceData:(NSString *)jsonRequest
         callBackName:(NSString *)callBackName
          extraString:(NSString *)extraString
{
    NSLog(@"获取设备数据");
    UIDevice *currentDevice = [UIDevice currentDevice];
    NSString *deviceSystemVersion = currentDevice.systemVersion;
    
    
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    CGFloat height = kScreenHeight * scale_screen;
    CGFloat width = kScreenWidth * scale_screen;
    
    
    NSString *deviceType = [JCHDeviceUtility getDeviceString];
    NSString *operatingSystem = [NSString stringWithFormat:@"iOS %@", deviceSystemVersion];
    NSString *resolution = [NSString stringWithFormat:@"%g*%g", height, width];
    NSString *networkType = [JCHDeviceUtility getNetWorkStates];
    NSString *deviceLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    /**
     “deviceType”:设备型号// 字符串
	    “imei” : 手机imei,
     “sequenceNum”:序号,//字符串,
     “resolution” : 分辨率,
     “manufacturer”:手机厂商,
     “deviceLanguage”:设备语言,
	    “networkType”: 网络类型,
	    “operatingSystem”: 操作系统,
	    “GPSPostion”: GPS设备所在地理位置

     
     */
    NSString *identifierForVendor = [SSKeychain passwordForService:kIdentifierForVendorService
                                                           account:kIdentifierForVendorAccount];
    
    JCHLocationManager *locationManager = [JCHLocationManager shareInstance];
    [locationManager getCoordinate2dResult:^(CLLocationCoordinate2D coordinage2D) {
        NSLog(@"经度 : %f", coordinage2D.longitude);
        NSLog(@"纬度 : %f", coordinage2D.latitude);
        
        NSDictionary *deviceInfo = @{@"deviceType" : deviceType,
                                     @"imei" : identifierForVendor,
                                     @"sequenceNum" : @"",
                                     @"resolution" : resolution,
                                     @"manufacturer" : @"Apple Inc.",
                                     @"deviceLanguage" : deviceLanguage,
                                     @"networkType" : networkType,
                                     @"operatingSystem" : operatingSystem,
                                     @"GPSPosition" : [NSString stringWithFormat:@"%f,%f", coordinage2D.longitude, coordinage2D.latitude]};
        NSDictionary *response = @{kResponseResule : deviceInfo,
                                   kResponseSuccess : kResponseTrue,
                                   kResponseMSG : @"成功"};
        
        NSString *jsonResponse = [response dataToJSONString];
        NSString *jsonResponseExtra = extraString;
        
        // 3) 调用JS回调函数
        NSLog(@"获取设备数据");
        JSValue *callbackHandler = self.jsContext[callBackName];
        [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    }];
}

#pragma mark -
#pragma mark - isRefresh     10.后退是否刷新
- (void)backRefresh:(NSString *)jsonRequest
     callBackName:(NSString *)callBackName
      extraString:(NSString *)extraString
{
    NSLog(@"backRefresh");
    
    NSArray *viewControllers = self.navigationController.viewControllers;
    UIViewController *viewController = viewControllers[viewControllers.count - 2];
    if ([viewController isKindOfClass:[JCHHTMLViewController class]]) {
        JCHHTMLViewController *lastFinanceViewContrller = (JCHHTMLViewController *)viewController;
        lastFinanceViewContrller.needReloadWebView = YES;
    }
}

#pragma mark -
#pragma mark - requestCall     11.拨打电话
- (void)requestCall:(NSString *)jsonRequest
       callBackName:(NSString *)callBackName
        extraString:(NSString *)extraString
{
    NSDictionary *requestData = [NSJSONSerialization JSONObjectWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    NSString *callNumber = requestData[@"callNumber"];
    
    NSString * str = [NSString stringWithFormat:@"telprompt://%@",callNumber];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:str]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
    }
}

#pragma mark -
#pragma mark - creditAndClosePage   12.打开新页面同事关闭旧页面

- (void)creditAndClosePage:(NSString *)jsonRequest
              callBackName:(NSString *)callBackName
               extraString:(NSString *)extraString
{
    // 1) 依据jsonParamString中的请求参数处理业务逻辑
    NSDictionary *requestData = [NSJSONSerialization JSONObjectWithData:[jsonRequest dataUsingEncoding:NSUTF8StringEncoding]
                                                                options:NSJSONReadingMutableContainers
                                                                  error:nil];
    NSString *urlString = requestData[@"url"];
    JCHHTMLViewController *newController = [[[JCHHTMLViewController alloc] initWithURL:urlString postRequest:NO] autorelease];
     newController.navigationBarColor = self.navigationController.navigationBar.barTintColor;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *viewControllers = self.navigationController.viewControllers;
        NSMutableArray *newViewControllers = [NSMutableArray arrayWithArray:viewControllers];
        
        NSInteger count = self.navigationController.viewControllers.count;
        if (count >= 3) {
            
            [newViewControllers replaceObjectAtIndex:count - 1 withObject:newController];
            [self.navigationController setViewControllers:newViewControllers animated:YES];
        }
    });
    
    
    if ([callBackName isEqualToString:@""]) {
        return;
    }
    
    // 2) 生成响应参数
    NSString *jsonResponse = @"";
    NSString *jsonResponseExtra = extraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[callBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    
    return;
}

#pragma mark - LCActionSheetDelegate

- (void)actionSheet:(LCActionSheet *)actionSheet didClickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ((buttonIndex == 0) || (buttonIndex == 1)) {
        [self takePhoto:buttonIndex];
    } else if (buttonIndex == 2) {
        
        NSDictionary *response = @{kResponseResule : @{@"images" : @[]},
                                   kResponseSuccess : kResponseTrue,
                                   kResponseMSG : kResponseFalse};
        
        NSString *jsonResponse = [response dataToJSONString];
        NSString *jsonResponseExtra = self.currentExtraString;
        
        // 3) 调用JS回调函数
        JSValue *callbackHandler = self.jsContext[self.currentCallBackName];
        [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    } else {
        //pass
    }
}


//TODO: 照片多选
- (void)takePhoto:(NSInteger)buttonIndex
{
#if 0
    UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
    picker.delegate = self;
    picker.allowsEditing = NO;//设置可编辑
    
    if (buttonIndex == 0) {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera; //拍照
    }
    else if (buttonIndex == 1)
    {
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //相册
    }
    
    [self presentViewController:picker animated:YES completion:nil];
#else
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[[UIImagePickerController alloc] init] autorelease];
        picker.delegate = self;
        picker.allowsEditing = NO;//设置可编辑
        picker.sourceType = UIImagePickerControllerSourceTypeCamera; //拍照
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        [self presentViewController:picker animated:YES completion:nil];
    }
    else if (buttonIndex == 1)
    {
        //picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //相册
        QBImagePickerController *imagePicker = [[[QBImagePickerController alloc] init] autorelease];
        imagePicker.delegate = self;
        imagePicker.mediaType = QBImagePickerMediaTypeImage;
        imagePicker.allowsMultipleSelection = YES;
        imagePicker.maximumNumberOfSelection = 5;
        NSArray *viewControllers = imagePicker.childViewControllers;
        if ([[viewControllers firstObject] isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = (UINavigationController *)[viewControllers firstObject];
            if (self.navigationBarColor) {
                nav.navigationBar.barTintColor = self.navigationBarColor;
            }
        }
        [self presentViewController:imagePicker animated:YES completion:nil];
    }

#endif
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingAssets:(NSArray *)assets
{
    NSMutableArray *images = [NSMutableArray array];
    for (PHAsset *asset in assets) {
        PHImageRequestOptions *options = [[[PHImageRequestOptions alloc] init] autorelease];
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset
                                                   targetSize:[UIScreen mainScreen].bounds.size
                                                  contentMode:PHImageContentModeAspectFit
                                                      options:options
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
            //设置图片
            NSData *imageData = UIImageJPEGRepresentation(result, 1);
            
            //压缩图片不超过400k
            NSInteger imageKB = imageData.length / 1024;
            CGFloat compressionQuality = 1.0f;
            while (imageKB > 400) {
                compressionQuality -= 0.05;
                imageData = UIImageJPEGRepresentation(result, compressionQuality);
                imageKB = imageData.length / 1024;
            }
            NSString *imageBase64String = [imageData base64EncodedStringWithOptions:0];
            [images addObject:imageBase64String];
            
            if (images.count == assets.count) {
                
                NSDictionary *response = @{kResponseResule : @{@"images" : images},
                                           kResponseSuccess : kResponseTrue,
                                           kResponseMSG : @""};
                
                NSString *jsonResponse = [response dataToJSONString];
                NSString *jsonResponseExtra = self.currentExtraString;
                
                // 3) 调用JS回调函数
                JSValue *callbackHandler = self.jsContext[self.currentCallBackName];
                [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
            }
        }];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController
{
    NSDictionary *response = @{kResponseResule : @{@"images" : @[]},
                               kResponseSuccess : kResponseTrue,
                               kResponseMSG : kResponseFalse};
    
    NSString *jsonResponse = [response dataToJSONString];
    NSString *jsonResponseExtra = self.currentExtraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[self.currentCallBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Save the image to the album
    //    UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:), nil);

    image = [UIImage compressImage:image scaledToSize:[UIScreen mainScreen].bounds.size];
    
    
    //压缩图片不超过400k
    NSData *imageData = UIImageJPEGRepresentation(image, 1);
    NSInteger imageKB = imageData.length / 1024;
    CGFloat compressionQuality = 1.0f;
    while (imageKB > 400) {
        compressionQuality -= 0.05;
        imageData = UIImageJPEGRepresentation(image, compressionQuality);
        imageKB = imageData.length / 1024;
    }
    
    NSString *imageBase64String = [imageData base64EncodedStringWithOptions:0];
    
    NSDictionary *response = @{kResponseResule : @{@"images" : @[imageBase64String]},
                               kResponseSuccess : kResponseTrue,
                               kResponseMSG : @""};
    
    NSString *jsonResponse = [response dataToJSONString];
    NSString *jsonResponseExtra = self.currentExtraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[self.currentCallBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
    return ;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSDictionary *response = @{kResponseResule : @{@"images" : @[]},
                               kResponseSuccess : kResponseTrue,
                               kResponseMSG : kResponseFalse};
    
    NSString *jsonResponse = [response dataToJSONString];
    NSString *jsonResponseExtra = self.currentExtraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[self.currentCallBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:
(NSError *)error contextInfo:(void *)contextInfo;
{
    // Handle the end of the image write process
    if (!error)
        NSLog(@"Image written to photo album");
    else
        NSLog(@"Error writing to photo album: %@",
              [error localizedDescription]);
}


#pragma mark - 读取通讯录
- (void)loadPerson
{
    //The Create Rule : If the function name contains "Copy" or "Create", then you own the object, so you must release it when you finish your work with it.
    ABAddressBookRef addressBokRef = ABAddressBookCreateWithOptions(NULL, NULL);
    
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBokRef, ^(bool granted, CFErrorRef error) {
            
            CFErrorRef *error1 = NULL;
            ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error1);
            [self copyAddressBook:addressBook];
            CFRelease(addressBook);
        });
    } else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized){
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        [self copyAddressBook:addressBook];
        CFRelease(addressBook);
    } else {
        NSLog(@"没有获得通讯录权限");
    }
    CFRelease(addressBokRef);
}

- (void)copyAddressBook:(ABAddressBookRef)addressBook
{
    CFIndex numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef people = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    NSMutableArray *contactsList = [NSMutableArray array];
    
    for ( int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(people, i);
        
        //名
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        
        //姓
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));

        //读取organization公司
        NSString *organization = (__bridge NSString*)ABRecordCopyValue(person, kABPersonOrganizationProperty);
        
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        NSString * personPhone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phone, 0);
        
        NSDictionary *contact = @{@"name" : [NSString stringWithFormat:@"%@%@", [self processTheParameter:firstName], [self processTheParameter:lastName]],
                                  @"company" : [self processTheParameter:organization],
                                  @"cellphone" : [self processTheParameter:personPhone]};
        
        [contactsList addObject:contact];
        CFRelease(phone);
    }
    
    CFRelease(people);
    
    NSLog(@"ContactList = %@", contactsList);
    
    NSDictionary *response = @{kResponseResule : @{@"data" : contactsList},
                               kResponseSuccess : kResponseTrue,
                               kResponseMSG : @"成功"};
    
    NSString *jsonResponse = [response dataToJSONString];
    NSString *jsonResponseExtra = self.currentExtraString;
    
    // 3) 调用JS回调函数
    JSValue *callbackHandler = self.jsContext[self.currentCallBackName];
    [callbackHandler callWithArguments:@[jsonResponse, jsonResponseExtra]];
}

- (NSString *)processTheParameter:(NSString *)parameter
{
    if (parameter) {
        return parameter;
    } else {
        return @"";
    }
}

- (void)showTopMenuView
{
    CGFloat menuWidth = 70;
    CGFloat rowHeight = 44;  //@[@"finance_icon_refresh", @"finance_icon_close"]
    JCHMenuView *topMenuView = [[[JCHMenuView alloc] initWithTitleArray:@[@"刷新", @"首页"]
                                                             imageArray:nil
                                                                 origin:CGPointMake(kScreenWidth - menuWidth - 25, 55)
                                                                  width:menuWidth
                                                              rowHeight:rowHeight
                                                              maxHeight:CGFLOAT_MAX
                                                                 Direct:kRightTriangle] autorelease];
    topMenuView.delegate = self;
    UIWindow *window = [UIApplication sharedApplication].windows[0];
    [window addSubview:topMenuView];
}

#pragma mark - JCHMenuViewDelegate

- (void)menuItemDidSelected:(JCHMenuView *)menuView indexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        [self.webView reload];
    } else {
        
        if (self.homeViewController) {
            [self.navigationController popToViewController:self.homeViewController animated:YES];
        } else {
            NSArray *viewControllers = self.navigationController.viewControllers;
            for (UIViewController *viewController in viewControllers) {
                if ([viewController isKindOfClass:[JCHHTMLViewController class]]) {
                    [self.navigationController popToViewController:viewController animated:YES];
                    break;
                }
            }
        }
    }
}


- (void)handlePopAction
{
    if (self.popActionCallBack) {
        self.popActionCallBack();
    } else {
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        } else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


@end

