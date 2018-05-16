//
//  JCHHelpViewController.m
//  jinchuhuo
//
//  Created by apple on 15/8/17.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "JCHHelpViewController.h"
#import "JCHUISettings.h"
#import "JCHColorSettings.h"
#import "Masonry.h"

@interface JCHHelpViewController ()
{
    UIWebView *contentWebView;
}
@end

@implementation JCHHelpViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.title = @"帮助中心";
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
    return;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createUI];
    
    [contentWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.maimairen.com"]]];
    
    return;
}

- (void)createUI
{
    self.view.backgroundColor = JCHColorGlobalBackground;
    
    contentWebView = [[[UIWebView alloc] initWithFrame:CGRectZero] autorelease];
    [self.view addSubview:contentWebView];
    
    [contentWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(self.view.frame.size);
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    
    return;
}


@end
