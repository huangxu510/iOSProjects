//
//  MTDocumentViewController.m
//  MiaoTong
//
//  Created by huangxu on 2018/3/21.
//  Copyright © 2018年 com.fangtetravel. All rights reserved.
//

#import "BKWebViewController.h"
#import <WebKit/WebKit.h>

@interface BKWebViewController () <WKNavigationDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation BKWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setupUI];
    
    NSString *encodedString = [_urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [_webView loadRequest:[NSURLRequest requestWithURL:URL(encodedString)]];
}


- (void)setupUI {
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectZero];
    _webView.navigationDelegate = self;
    _webView.scrollView.bounces = NO;
    _webView.navigationDelegate = self;
    [self.view addSubview:_webView];
    [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(-44);
        make.bottom.equalTo(self.view).offset(44);
    }];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    [_progressView setTrackTintColor:[UIColor colorWithRed:240.0/255
                                                     green:240.0/255
                                                      blue:240.0/255
                                                     alpha:1.0]];
    _progressView.progressTintColor = [UIColor blueColor];
    [self.view addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.view);
        make.height.mas_equalTo(2);
    }];
    
    [_webView addObserver:self
               forKeyPath:@"estimatedProgress"
                  options:NSKeyValueObservingOptionNew
                  context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    // 计算wkWebView进度条
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
  
        CGFloat newProgress = [change[NSKeyValueChangeNewKey] floatValue];
        
        if (newProgress == 1) {
    
            [self.progressView setProgress:1.0 animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.progressView.hidden = YES;
                [self.progressView setProgress:0 animated:NO];
            });
            
        } else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newProgress animated:YES];
        }
    }
}

// 取消监听
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"网页开始接收网页内容");
    [webView evaluateJavaScript:@"document.getElementsByClassName('com_da')[0].style.display = 'NONE'" completionHandler:nil];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"webview开始加载网页内容");
    [webView evaluateJavaScript:@"document.getElementsByClassName('com_da')[0].style.display = 'NONE'" completionHandler:nil];
}


- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    [webView evaluateJavaScript:@"document.getElementsByClassName('com_da')[0].style.display = 'NONE'" completionHandler:nil];
}

@end
