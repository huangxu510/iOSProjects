//
//  JCHShopCoverSelectViewController.m
//  jinchuhuo
//
//  Created by huangxu on 16/5/31.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHShopCoverSelectViewController.h"
#import "CommonHeader.h"

@interface JCHShopCoverSelectViewController ()
@property (nonatomic, retain) UIImageView *selectImageView;
@end

@implementation JCHShopCoverSelectViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"选择封面";
    }
    return self;
}

- (void)dealloc
{
    self.selectImageView = nil;
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createUI];
}

- (void)createUI
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    CGFloat imageViewWidth = kScreenWidth - 2 * kStandardLeftMargin;
    CGFloat imageViewHeight = imageViewWidth * 460 / 750;
    for (NSInteger i = 0; i < 5; i++) {
        CGFloat imageViewX = kStandardLeftMargin;
        CGFloat imageViewY = kStandardLeftMargin + (kStandardLeftMargin +imageViewHeight) * i;
        
        UIImageView *coverImageView = [[[UIImageView alloc] initWithFrame:CGRectMake(imageViewX, imageViewY, imageViewWidth, imageViewHeight)] autorelease];
        coverImageView.userInteractionEnabled = YES;
        coverImageView.tag = i;
        [self.backgroundScrollView addSubview:coverImageView];
        NSString *imageName = [NSString stringWithFormat:@"bg_manage_%ld", (long)i + 1];
        coverImageView.image = [UIImage imageNamed:imageName];
        
        
        UITapGestureRecognizer *tap = [[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleSelectCover:)] autorelease];
        [coverImageView addGestureRecognizer:tap];
        
        UIImageView *markImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addgoods_keyboard_mutiplyselect_selected"]] autorelease];
        markImageView.hidden = YES;
        [coverImageView addSubview:markImageView];
        [markImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(coverImageView).with.offset(-kStandardLeftMargin / 2);
            make.bottom.equalTo(coverImageView).with.offset(-kStandardLeftMargin / 2);
            make.width.height.mas_equalTo(23);
        }];
        
        if ([statusManager.shopCoverImageName isEqualToString:imageName]) {
            self.selectImageView = markImageView;
            markImageView.hidden = NO;
        }
        if (i == 4) {
            [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(coverImageView).with.offset(kStandardLeftMargin);
            }];
        }
    }
}

- (void)handleSelectCover:(UITapGestureRecognizer *)tap
{
    JCHSyncStatusManager *statusManager = [JCHSyncStatusManager shareInstance];
    UIImageView *selectImageView = (UIImageView *)tap.view;
    self.selectImageView.hidden = YES;
    UIImageView *markImageView = [selectImageView.subviews firstObject];
    markImageView.hidden = NO;
    self.selectImageView = markImageView;
    
    NSString *imageName = [NSString stringWithFormat:@"bg_manage_%ld", (long)selectImageView.tag + 1];
    statusManager.shopCoverImageName = imageName;
    [JCHSyncStatusManager writeToFile];
}

@end
