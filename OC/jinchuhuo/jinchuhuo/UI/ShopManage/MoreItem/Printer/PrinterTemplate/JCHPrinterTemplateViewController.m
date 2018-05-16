//
//  JCHPrinterTemplateViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/6.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPrinterTemplateViewController.h"
#import "JCHPrinterTemplateView.h"
#import "CommonHeader.h"

@interface JCHPrinterTemplateViewController ()

@property (retain, nonatomic) JCHPrinterTemplateView *selectedTemplate;
@property (retain, nonatomic) NSArray *templateData;

@end

@implementation JCHPrinterTemplateViewController

- (void)dealloc
{
    self.selectedTemplate = nil;
    [super dealloc];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"打印模板";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
    
    [self createUI];
}

- (void)initData
{
    JCHPrinterTemplateViewData *viewData = [[[JCHPrinterTemplateViewData alloc] init] autorelease];
    viewData.title = @"默认打印模板";
    viewData.imageName = @"";
    
    JCHPrinterTemplateViewData *viewData1 = [[[JCHPrinterTemplateViewData alloc] init] autorelease];
    viewData1.title = @"餐厅打印模板";
    viewData1.imageName = @"";
    
    JCHPrinterTemplateViewData *viewData2 = [[[JCHPrinterTemplateViewData alloc] init] autorelease];
    viewData2.title = @"外卖打印模板";
    viewData2.imageName = @"";
    
    self.templateData = @[viewData, viewData1, viewData2];
}

- (void)createUI
{
    self.backgroundScrollView.backgroundColor = JCHColorGlobalBackground;
    
#if 0
    CGFloat viewHeight = 200;
    CGFloat viewSpacing = 10;
    for (NSInteger i = 0; i < self.templateData.count; i++) {
        JCHPrinterTemplateViewData *data = self.templateData[i];
        
        CGRect rect = CGRectMake(0, (viewHeight + viewSpacing) * i, kScreenWidth, viewHeight);
        JCHPrinterTemplateView *view = [[[JCHPrinterTemplateView alloc] initWithFrame:rect] autorelease];
        view.backgroundColor = [UIColor whiteColor];
        [view setViewData:data];
        [self.backgroundScrollView addSubview:view];
        
        WeakSelf;
        [view setSelectBlock:^{
            weakSelf.selectedTemplate.selected = NO;
            weakSelf.selectedTemplate = view;
        }];
        
        if (i == self.templateData.count - 1) {
            [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(view);
            }];
        }
    }
#endif
    CGFloat imageWidth = [JCHSizeUtility calculateWidthWithSourceWidth:348];
    CGFloat imageHeight = [JCHSizeUtility calculateWidthWithSourceWidth:1212];
    
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"takeout_receipt_all_2"]] autorelease];
    [self.backgroundScrollView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(imageWidth);
        make.height.mas_equalTo(imageHeight);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.backgroundScrollView);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(imageView);
    }];
}


@end
