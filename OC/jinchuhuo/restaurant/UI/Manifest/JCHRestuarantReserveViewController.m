//
//  JCHRestuarantReserveViewController.m
//  jinchuhuo
//
//  Created by apple on 2017/1/5.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHRestuarantReserveViewController.h"
#import "JCHRestaurantOpenTableCollectionViewCell.h"
#import "JCHTitleTextField.h"
#import "CommonHeader.h"

@interface JCHRestuarantReserveViewController ()
{
    UILabel *topTableInfoLabel;
    JCHTitleTextField *personTextfield;
    JCHTitleTextField *phoneTextfield;
    JCHTitleTextField *timeTextfield;
}

@property (retain, nonatomic, readwrite) DiningTableRecord4Cocoa *currentTableRecord;

@end

@implementation JCHRestuarantReserveViewController

- (id)initWithTableRecord:(DiningTableRecord4Cocoa *)tableRecord;

{
    self = [super init];
    if (self) {
        self.title = @"预订";
        self.currentTableRecord = tableRecord;
    }
    
    return self;
}

- (void)dealloc
{
    self.currentTableRecord = nil;
    
    [super dealloc];
    return;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI
{
    UIBarButtonItem *saveItem = [[[UIBarButtonItem alloc] initWithTitle:@"保存"
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(handleSaveRecord:)] autorelease];
    self.navigationItem.rightBarButtonItem = saveItem;
 
    CGFloat titleHeight = 42;
    UIFont *titleFont = JCHFont(14.0);
    UIColor *textColor = JCHColorMainBody;
    topTableInfoLabel = [JCHUIFactory createLabel:CGRectZero
                                            title:[NSString stringWithFormat: @"   预订桌台: %@ 完善预订信息",
                                                   self.currentTableRecord.tableName]
                                             font:titleFont
                                        textColor:textColor
                                           aligin:NSTextAlignmentLeft];
    [self.backgroundScrollView addSubview:topTableInfoLabel];
    topTableInfoLabel.backgroundColor = [UIColor whiteColor];
    
    [topTableInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.top.equalTo(self.backgroundScrollView);
        make.height.mas_equalTo(titleHeight);
    }];
    
    UIView *separatorLine = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
    [self.backgroundScrollView addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(topTableInfoLabel.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    // 联系人
    personTextfield = [[[JCHTitleTextField alloc] initWithTitle:@"联系人"
                                                           font:titleFont
                                                    placeholder:@"请输入联系人姓名"
                                                      textColor:textColor] autorelease];
    [self.backgroundScrollView addSubview:personTextfield];
    [personTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(separatorLine.mas_bottom).with.offset(kStandardTopMargin);
        make.height.mas_equalTo(titleHeight);
    }];
    
    separatorLine = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
    [self.backgroundScrollView addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(personTextfield.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    // 手机号
    phoneTextfield = [[[JCHTitleTextField alloc] initWithTitle:@"手机号"
                                                          font:titleFont
                                                   placeholder:@"请输入联系人手机号码"
                                                     textColor:textColor] autorelease];
    [self.backgroundScrollView addSubview:phoneTextfield];
    [phoneTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(separatorLine.mas_bottom).with.offset(kStandardTopMargin);
        make.height.mas_equalTo(titleHeight);
    }];
    
    separatorLine = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
    [self.backgroundScrollView addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(phoneTextfield.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    // 时间段
    timeTextfield = [[[JCHTitleTextField alloc] initWithTitle:@"时间段"
                                                         font:titleFont
                                                  placeholder:@"请输入预订时间段"
                                                      textColor:textColor] autorelease];
    [self.backgroundScrollView addSubview:timeTextfield];
    [timeTextfield mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(separatorLine.mas_bottom).with.offset(kStandardTopMargin);
        make.height.mas_equalTo(titleHeight);
    }];
    
    separatorLine = [JCHUIFactory createSeperatorLine:kSeparateLineWidth];
    [self.backgroundScrollView addSubview:separatorLine];
    [separatorLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(timeTextfield.mas_bottom);
        make.height.mas_equalTo(kSeparateLineWidth);
    }];
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(separatorLine);
    }];
}


#pragma mark -
#pragma mark 保存记录
- (void)handleSaveRecord:(id)sender
{
    self.currentTableRecord.tableStatus = kJCHRestaurantOpenTableCollectionViewCellReserved;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
