//
//  JCHDishCharacterViewController.m
//  jinchuhuo
//
//  Created by huangxu on 2017/1/2.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "JCHTakeoutDishesCharacterViewController.h"
#import "JCHTakeoutDishesCharacterEditView.h"
#import "CommonHeader.h"

@interface JCHTakeoutDishesCharacterViewController ()
{
    UILabel *_footerInflLabel;
}
@property (retain, nonatomic) NSMutableArray *characterViews;
@property (retain, nonatomic) NSString *jsonString;
@end

@implementation JCHTakeoutDishesCharacterViewController

- (instancetype)initWithString:(NSString *)jsonString
{
    self = [super init];
    if (self) {
        self.title = @"菜品特性";
        self.jsonString = jsonString;
        self.characterViews = [NSMutableArray array];
    }
    return self;
}

- (void)dealloc
{
    self.saveCharacterBlock = nil;
    self.characterViews = nil;
    
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
    UIBarButtonItem *saveButton = [[[UIBarButtonItem alloc] initWithTitle:@"完成"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(handleSaveData)] autorelease];
    self.navigationItem.rightBarButtonItem = saveButton;
    
    UIView *footerView = [[[UIView alloc] init] autorelease];
    [footerView addSeparateLineWithMasonryTop:YES bottom:NO];
    [self.view addSubview:footerView];
    
    [footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.height.mas_equalTo(kTabBarHeight);
    }];
    
    CGFloat buttonWidth = 20;
    UIButton *addButton = [JCHUIFactory createButton:CGRectZero
                                              target:self
                                              action:@selector(addNewCharacter)
                                               title:@""
                                          titleColor:JCHColorMainBody
                                     backgroundColor:nil];
    [addButton setImage:[UIImage imageNamed:@"btn_setting_goods_add"] forState:UIControlStateNormal];
    [addButton setEnlargeEdgeWithTop:10 right:10 bottom:10 left:10];
    [footerView addSubview:addButton];
    
    [addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(footerView).offset(-kStandardLeftMargin);
        make.width.height.mas_equalTo(buttonWidth);
        make.centerY.equalTo(footerView);
    }];
    
    _footerInflLabel = [JCHUIFactory createLabel:CGRectZero
                                           title:@"0种特性"
                                            font:JCHFont(16.0)
                                       textColor:JCHColorMainBody
                                          aligin:NSTextAlignmentLeft];
    [footerView addSubview:_footerInflLabel];
    
    [_footerInflLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(footerView).offset(kStandardLeftMargin);
        make.top.bottom.equalTo(footerView);
        make.right.equalTo(addButton.mas_left).offset(-kStandardLeftMargin);
    }];
    
    self.backgroundScrollView.backgroundColor = JCHColorGlobalBackground;
    [self.backgroundScrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-kTabBarHeight);
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
    }];
    
   
}

- (void)loadData
{
    NSArray *characters = [self.jsonString jsonStringToArrayOrDictionary];
    
    for (NSDictionary *dict in characters) {
        [self handleAddCharacter:dict];
    }
}

- (void)handleSaveData
{
    NSMutableArray *characters = [NSMutableArray array];
    for (NSInteger i = 0; i < self.characterViews.count; i++) {
        JCHTakeoutDishesCharacterEditView *subView = self.characterViews[i];
        NSDictionary *character = [subView getData];
        NSString *propertyName = character[@"propertyName"];
        if ([propertyName isEmptyString]) {
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"有未输入的特性名称" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        if ([character[@"values"] count] < 2) {
            NSString *message = [NSString stringWithFormat:@"%@特性请至少添加两个不为空的标签", propertyName];
            UIAlertView *alertView = [[[UIAlertView alloc] initWithTitle:@"温馨提示" message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil] autorelease];
            [alertView show];
            return;
        }
        
        [characters addObject:character];
    }
    
    NSString *jsonString = [characters dataToJSONString];
    self.jsonString = jsonString;
    
    if (self.saveCharacterBlock) {
        self.saveCharacterBlock(self.jsonString);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    return;
}


- (void)handleDeleteCharacter:(JCHTakeoutDishesCharacterEditView *)view
{
    [view removeFromSuperview];
    [self.characterViews removeObject:view];
    
    JCHTakeoutDishesCharacterEditView *lastView = nil;
    for (NSInteger i = 0; i < self.characterViews.count; i++) {
        JCHTakeoutDishesCharacterEditView *subView = self.characterViews[i];
        
        if (i == 0) {
            [subView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.backgroundScrollView);
            }];
        } else {
            [subView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastView.mas_bottom).offset(kStandardSeparateViewHeight);
            }];
        }
        lastView = subView;
    }
    
    [self updateViewHeight:nil];
    
    _footerInflLabel.text = [NSString stringWithFormat:@"%ld种特性", self.characterViews.count];
}

- (void)addNewCharacter
{
    [self handleAddCharacter:nil];
}
                           
- (void)handleAddCharacter:(NSDictionary *)dict
{
    JCHTakeoutDishesCharacterEditView *lastView = nil;
    if (self.characterViews.count > 0) {
        lastView = [self.characterViews lastObject];
    }
    
    WeakSelf;
    JCHTakeoutDishesCharacterEditView *view = [[[JCHTakeoutDishesCharacterEditView alloc] initWithFrame:CGRectZero] autorelease];
    [view addSeparateLineWithMasonryTop:YES bottom:YES];
    if (dict) {
        [view setData:dict];
    } else {
        [view.characterTitleTextField becomeFirstResponder];
    }
    
    view.delectCharacterBlock = ^(JCHTakeoutDishesCharacterEditView *editView){
        [weakSelf handleDeleteCharacter:editView];
    };
    view.updateViewHeightBlock = ^(JCHTakeoutDishesCharacterEditView *editView){
        [weakSelf updateViewHeight:editView];
    };
    
    [self.backgroundScrollView addSubview:view];
    [self.characterViews addObject:view];
    
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        if (lastView) {
            make.top.equalTo(lastView.mas_bottom).offset(kStandardSeparateViewHeight);
        } else {
            make.top.equalTo(self.backgroundScrollView);
        }
        make.left.equalTo(self.backgroundScrollView);
        make.width.mas_equalTo(kScreenWidth);
        make.height.mas_equalTo(view.viewHeight);
    }];
    
    CGFloat contentSizeHeight = 0;
    for (NSInteger i = 0; i < self.characterViews.count; i++) {
        JCHTakeoutDishesCharacterEditView *subView = self.characterViews[i];
        if (i == 0) {
            contentSizeHeight += subView.viewHeight;
        } else {
            contentSizeHeight += subView.viewHeight + kStandardSeparateViewHeight;
        }
    }
    
    [self.backgroundScrollView setContentSize:CGSizeMake(0, contentSizeHeight)];
    
    _footerInflLabel.text = [NSString stringWithFormat:@"%ld种特性", self.characterViews.count];
}

// 删除或新增标签时更新这个特性view的高度
- (void)updateViewHeight:(JCHTakeoutDishesCharacterEditView *)view
{
    if (view) {
        [view mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(view.viewHeight);
        }];
    }
    
    CGFloat contentSizeHeight = 0;
    for (NSInteger i = 0; i < self.characterViews.count; i++) {
        JCHTakeoutDishesCharacterEditView *subView = self.characterViews[i];
        if (i == 0) {
            contentSizeHeight += subView.viewHeight;
        } else {
            contentSizeHeight += subView.viewHeight + kStandardSeparateViewHeight;
        }
    }
    
    [self.backgroundScrollView setContentSize:CGSizeMake(0, contentSizeHeight)];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.backgroundScrollView) {
        if ([keyPath isEqualToString:@"contentSize"]) {
            
            NSValue *contentSizeValue = change[NSKeyValueChangeNewKey];
            NSValue *oldContentSizeValue = change[NSKeyValueChangeOldKey];
            
            CGSize contentSize;
            CGSize oldContentSize;
            [contentSizeValue getValue:&contentSize];
            [oldContentSizeValue getValue:&oldContentSize];
            
            if (contentSize.height < self.view.frame.size.height - kTabBarHeight - 64) {
                
                [self.backgroundScrollView removeObserver:self forKeyPath:@"contentSize"];
                self.backgroundScrollView.contentSize = CGSizeMake(0, kScreenHeight - 64 - 49 + 1);
                [self.backgroundScrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:NULL];
            }
        }
    }
}

@end
