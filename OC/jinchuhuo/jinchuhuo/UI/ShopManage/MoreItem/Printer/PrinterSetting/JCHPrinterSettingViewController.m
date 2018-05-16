//
//  JCHPrinterSettingViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2016/12/1.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "JCHPrinterSettingViewController.h"
#import "JCHSwitchLabelView.h"
#import "CommonHeader.h"
#import "JCHBluetoothManager.h"

@interface JCHPrinterSettingViewController () <JCHPickerViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    JCHSwitchLabelView *_defaultPrintSwitchView;
    JCHArrowTapView *_printCountTapView;
    JCHArrowTapView *_printMeanwhileTapView;
    JCHSwitchLabelView *_manifestDetailPrintStatusSwitchView;
    JCHArrowTapView *_printDefaultTypeTapView;
    JCHPickerView *_pickerView;
    
    JCHArrowTapView *_currentEditView;
}

@property (retain, nonatomic) NSArray *pickerViewDataSource;
@property (retain, nonatomic) NSArray *printCountDataSource;
@property (retain, nonatomic) NSArray *printMeanwhileDataSource;
@property (retain, nonatomic) NSArray *printDefaultTypeDataSource;
@end

@implementation JCHPrinterSettingViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.title = @"个性化设置";
        self.printCountDataSource = @[@"一联", @"两联", @"三联"];
        self.printMeanwhileDataSource = @[@"无", @"出品标签"];
        self.printDefaultTypeDataSource = @[@"小票", @"出品标签"];
    }
    return self;
}

- (void)dealloc
{
    self.pickerViewDataSource = nil;
    self.printCountDataSource = nil;
    self.printMeanwhileDataSource = nil;
    self.printDefaultTypeDataSource = nil;
    
    [super dealloc];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self createUI];
    
    [self loadData];
}

- (void)createUI
{
    _defaultPrintSwitchView = [[[JCHSwitchLabelView alloc] init] autorelease];
    _defaultPrintSwitchView.titleLabel.text = @"开单即打印";
    _defaultPrintSwitchView.backgroundColor = [UIColor whiteColor];
    _defaultPrintSwitchView.switchButton.on = YES;
    [_defaultPrintSwitchView addSeparateLineWithMasonryTop:YES bottom:NO];
    [_defaultPrintSwitchView.switchButton addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    _defaultPrintSwitchView.switchButton.tag = 0;
    [self.backgroundScrollView addSubview:_defaultPrintSwitchView];
    
    [_defaultPrintSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backgroundScrollView).offset(kStandardSeparateViewHeight);
        make.left.width.equalTo(self.backgroundScrollView);
        make.height.mas_equalTo(kStandardItemHeight);
    }];
    
    _printCountTapView = [[[JCHArrowTapView alloc] init] autorelease];
    _printCountTapView.titleLabel.text = @"打印份数";
    _printCountTapView.detailLabel.text = @"一联";
    _printCountTapView.bottomLine.hidden = YES;
    [_printCountTapView addSeparateLineWithMasonryTop:NO bottom:YES];
    [_printCountTapView.button addTarget:self action:@selector(showPickView:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_printCountTapView];
    
    [_printCountTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(_defaultPrintSwitchView);
        make.top.equalTo(_defaultPrintSwitchView.mas_bottom);
    }];
    
#if 0
    _printMeanwhileTapView = [[[JCHArrowTapView alloc] init] autorelease];
    _printMeanwhileTapView.titleLabel.text = @"同时打印";
    _printMeanwhileTapView.detailLabel.text = @"无";
    _printMeanwhileTapView.bottomLine.hidden = YES;
    [_printMeanwhileTapView addSeparateLineWithMasonryTop:YES bottom:YES];
    [_printMeanwhileTapView.button addTarget:self action:@selector(showPickView:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_printMeanwhileTapView];
    
    [_printMeanwhileTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(_defaultPrintSwitchView);
        make.top.equalTo(_printCountTapView.mas_bottom).offset(kStandardSeparateViewHeight);
    }];
#endif
    _manifestDetailPrintStatusSwitchView = [[[JCHSwitchLabelView alloc] init] autorelease];
    _manifestDetailPrintStatusSwitchView.titleLabel.text = @"详情页打印";
    _manifestDetailPrintStatusSwitchView.backgroundColor = [UIColor whiteColor];
    _manifestDetailPrintStatusSwitchView.switchButton.on = YES;
    [_manifestDetailPrintStatusSwitchView setBottomLineHidden:YES];
    [_manifestDetailPrintStatusSwitchView addSeparateLineWithMasonryTop:YES bottom:YES];
    [_manifestDetailPrintStatusSwitchView.switchButton addTarget:self action:@selector(changeValue:) forControlEvents:UIControlEventValueChanged];
    _manifestDetailPrintStatusSwitchView.switchButton.tag = 1;
    [self.backgroundScrollView addSubview:_manifestDetailPrintStatusSwitchView];
    
    [_manifestDetailPrintStatusSwitchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.height.width.equalTo(_defaultPrintSwitchView);
//        make.top.equalTo(_printMeanwhileTapView.mas_bottom).offset(kStandardSeparateViewHeight);
        make.top.equalTo(_printCountTapView.mas_bottom).offset(kStandardSeparateViewHeight);
    }];
#if 0
    _printDefaultTypeTapView = [[[JCHArrowTapView alloc] init] autorelease];
    _printDefaultTypeTapView.titleLabel.text = @"打印票据类型";
    _printDefaultTypeTapView.detailLabel.text = @"小票";
    _printDefaultTypeTapView.bottomLine.hidden = YES;
    [_printDefaultTypeTapView addSeparateLineWithMasonryTop:YES bottom:YES];
    [_printDefaultTypeTapView.button addTarget:self action:@selector(showPickView:) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroundScrollView addSubview:_printDefaultTypeTapView];
    
    [_printDefaultTypeTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.width.height.equalTo(_defaultPrintSwitchView);
        make.top.equalTo(_manifestDetailPrintStatusSwitchView.mas_bottom).offset(kStandardSeparateViewHeight);
    }];
#endif
    
    [self.backgroundScrollView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_manifestDetailPrintStatusSwitchView);
    }];
}

- (void)loadData
{
    JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
    
    _defaultPrintSwitchView.switchButton.on = bluetoothManager.canPrintInShipment;
    _manifestDetailPrintStatusSwitchView.switchButton.on = bluetoothManager.canPrintInManifestDetail;
    _printCountTapView.detailLabel.text = self.printCountDataSource[bluetoothManager.printRepeatCount];
    _printMeanwhileTapView.detailLabel.text = self.printMeanwhileDataSource[bluetoothManager.printMeanwhileItem];
    _printDefaultTypeTapView.detailLabel.text = self.printDefaultTypeDataSource[bluetoothManager.defaultPrintType];
}

- (void)showPickView:(UIButton *)sender
{
    [_pickerView hide];
    
    NSString *title = nil;
    if (sender == _printCountTapView.button) {
        title = @"重复打印份数";
        _currentEditView = _printCountTapView;
        self.pickerViewDataSource = self.printCountDataSource;
    } else if (sender == _printMeanwhileTapView.button) {
        title = @"同时打印";
        _currentEditView = _printMeanwhileTapView;
         self.pickerViewDataSource = self.printMeanwhileDataSource;
    } else if (sender == _printDefaultTypeTapView.button) {
        title = @"默认打印票据类型";
        _currentEditView = _printDefaultTypeTapView;
        self.pickerViewDataSource = self.printDefaultTypeDataSource;
    }
    const CGRect pickerRect = CGRectMake(0, kScreenHeight, self.view.frame.size.width, kJCHPickerViewHeight);
    _pickerView = [[[JCHPickerView alloc] initWithFrame:pickerRect title:title showInView:self.view] autorelease];
    _pickerView.delegate = self;
    _pickerView.dataSource = self;
    
    [_pickerView show];
    
    NSInteger row = 0;
    if ([self.pickerViewDataSource containsObject:_currentEditView.detailLabel.text]) {
        row = [self.pickerViewDataSource indexOfObject:_currentEditView.detailLabel.text];
    }
    [_pickerView.pickerView selectRow:row inComponent:0 animated:NO];
}

#pragma mark - JCHPickerViewDelegate

- (void)pickerViewDidHide:(JCHPickerView *)pickerView
{

}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return self.view.frame.size.width;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kJCHPickerViewRowHeight;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.pickerViewDataSource[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
    
    if (_currentEditView == _printCountTapView) {
        _printCountTapView.detailLabel.text = self.pickerViewDataSource[row];
        bluetoothManager.printRepeatCount = row;
    } else if (_currentEditView == _printMeanwhileTapView) {
        _printMeanwhileTapView.detailLabel.text = self.pickerViewDataSource[row];
    } else if (_currentEditView == _printDefaultTypeTapView) {
        _printDefaultTypeTapView.detailLabel.text = self.pickerViewDataSource[row];
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.pickerViewDataSource.count;
}

- (void)changeValue:(UISwitch *)sender
{
    JCHBluetoothManager *bluetoothManager = [JCHBluetoothManager shareInstance];
    if (sender.tag == 0) {
        bluetoothManager.canPrintInShipment = sender.on;
    } else if (sender.tag == 1) {
        bluetoothManager.canPrintInManifestDetail = sender.on;
    } 
}


@end
