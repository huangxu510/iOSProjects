//
//  JCHClauseViewController.m
//  jinchuhuo
//
//  Created by huangxu on 15/11/9.
//  Copyright © 2015年 apple. All rights reserved.
//

#import "JCHClauseViewController.h"
#import "JCHUISettings.h"

@interface JCHClauseViewController ()
{
    NSString *_htmlName;
}
@end

@implementation JCHClauseViewController

- (instancetype)initWithHTMLName:(NSString *)htmlName title:(NSString *)title
{
    self = [super init];
    if (self) {
        self.title = title;
        _htmlName = htmlName;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)createUI
{
    NSLog(@"%@", NSStringFromCGRect(self.view.bounds));
    UIWebView *contentWebView = [[[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigatorBarHeight - kStatusBarHeight)] autorelease];
    contentWebView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:contentWebView];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:_htmlName ofType:@"html"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url] ;
    [contentWebView loadRequest:request];
}

@end
