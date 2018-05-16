//
//  JCHAddDishesTakeoutInfoViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/31.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHAddDishesTakeoutInfoViewController.h"
#import "CommonHeader.h"

@interface JCHAddDishesTakeoutInfoViewController ()
{
    JCHProductSKUMode _currentMode;
}
@property (retain, nonatomic) NSArray *takeoutInfoList;
@property (retain, nonatomic) NSMutableArray *takeoutInfoSetViews;
@end

@implementation JCHAddDishesTakeoutInfoViewController

- (instancetype)initWithProductSKUMode:(JCHProductSKUMode)mode takeoutInfoList:(NSArray *)takeoutInfoList
{
    self = [super init];
    if (self) {
        self.title = @"外卖信息";
        _currentMode = mode;
        self.takeoutInfoList = takeoutInfoList;
    }
    return self;
}

- (void)dealloc
{
    self.takeoutInfoList = nil;
    self.takeoutInfoSetViews = nil;
    
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
}

- (void)createUI{
    
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveData)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    self.takeoutInfoSetViews = [NSMutableArray array];
    
    if (_currentMode == kJCHProductWithSKU) {
        CGFloat viewOriginY = 0;
        for (JCHTakeoutInfoSetViewData *data in self.takeoutInfoList) {
            JCHTakeoutInfoSetView *takeoutInfoSetView = [[JCHTakeoutInfoSetView alloc] initWithFrame:CGRectZero productSKUMode:_currentMode];
            [self.backgroundScrollView addSubview:takeoutInfoSetView];
            CGRect frame = CGRectMake(0, viewOriginY, kScreenWidth, takeoutInfoSetView.viewHeight);
            takeoutInfoSetView.frame = frame;
            viewOriginY += takeoutInfoSetView.viewHeight;
            
            [takeoutInfoSetView setViewData:data];
            [self.takeoutInfoSetViews addObject:takeoutInfoSetView];
            
            [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(takeoutInfoSetView);
            }];
        }
    } else {
        JCHTakeoutInfoSetView *takeoutInfoSetView = [[JCHTakeoutInfoSetView alloc] initWithFrame:CGRectZero productSKUMode:_currentMode];
        [self.backgroundScrollView addSubview:takeoutInfoSetView];
        
        CGRect frame = CGRectMake(0, 0, kScreenWidth, takeoutInfoSetView.viewHeight);
        takeoutInfoSetView.frame = frame;
        
        JCHTakeoutInfoSetViewData *data = [self.takeoutInfoList firstObject];
        [takeoutInfoSetView setViewData:data];
        
        [self.takeoutInfoSetViews addObject:takeoutInfoSetView];
        
        [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(takeoutInfoSetView);
        }];
    }
}

- (void)handleSaveData
{
    for (NSInteger i = 0; i < self.takeoutInfoList.count; i++) {
        JCHTakeoutInfoSetViewData *data = self.takeoutInfoList[i];
        JCHTakeoutInfoSetViewData *finalData = [self.takeoutInfoSetViews[i] getData];
        data.boxCount = finalData.boxCount;
        data.boxPrice = finalData.boxPrice;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
