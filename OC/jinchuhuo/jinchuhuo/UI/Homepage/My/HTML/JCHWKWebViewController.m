//
//  JCHWKWebViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2017/2/27.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHWKWebViewController.h"
#import <WebKit/WebKit.h>
#import "CommonHeader.h"

@interface JCHWKWebViewController () <WKNavigationDelegate>

@property (retain, nonatomic, readwrite) NSString *currentURL;

@end

@implementation JCHWKWebViewController

- (id)initWithURL:(NSString *)url
{
    self = [super init];
    if (self) {
        self.currentURL = url;
    }
    
    return self;
}

- (void)dealloc
{
    self.currentURL = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    WKWebView *wkWebView = [[[WKWebView alloc] init] autorelease];
    
    wkWebView.scrollView.bounces = NO;
    wkWebView.scrollView.showsVerticalScrollIndicator = YES;
    wkWebView.scrollView.scrollEnabled = YES;
    wkWebView.navigationDelegate = self;
    [self.view addSubview:wkWebView];
    
    [wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.currentURL]];

    [wkWebView loadRequest:request];
}

#pragma mark - WKNavigationDelegate

// 对于HTTPS的都会触发此代理
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    // 设置信任证书
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        NSURLCredential *card = [[[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust] autorelease];
        completionHandler(NSURLSessionAuthChallengeUseCredential, card);
    }
}



@end
