//
//  MPStaticTableViewController.m
//  MobileProject2
//
//  Created by huangxu on 2018/3/1.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKStaticTableViewController.h"


@interface BKStaticTableViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@end

@implementation BKStaticTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.tableViewStyle = UITableViewStyleGrouped;
    self.tableView.mj_header = nil;
    self.tableView.mj_footer = nil;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BKStaticTableViewCell" bundle:nil] forCellReuseIdentifier:@"BKStaticTableViewCell"];
}

- (NSMutableArray<BKItemSection *> *)sections
{
    if(_sections == nil)
    {
        _sections = [NSMutableArray array];
    }
    return _sections;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.sections[section].items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BKWordItem *item = self.sections[indexPath.section].items[indexPath.row];
    BKStaticTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BKStaticTableViewCell"];
    cell.item = item;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.view endEditing:YES];
    BKWordItem *item = self.sections[indexPath.section].items[indexPath.row];
    
    if (item.hasTextField) {
        BKStaticTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell.textField becomeFirstResponder];
    }
    
    if (item.itemOperation) {
        item.itemOperation(indexPath);
        return;
    }
    
    if ([item isKindOfClass:[BKWordArrowItem class]]) {
        BKWordArrowItem *arrowItem = (BKWordArrowItem *)item;
        if (arrowItem.destVC) {
            UIViewController *vc = [[arrowItem.destVC alloc] init];
            vc.navigationItem.title = arrowItem.title;
            for (NSString *key in arrowItem.keyValueInfo.allKeys) {
                [vc setValue:arrowItem.keyValueInfo[key] forKey:key];
            }
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.sections[section].headerTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return self.sections[section].footerTitle;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.sections[indexPath.section].items[indexPath.row].cellHeight;
}

- (BKStaticTableViewController *(^)(BKWordItem *))addItem
{
    WeakSelf;
    if (!self.sections.firstObject) {
        [self.sections addObject:[BKItemSection sectionWithItems:@[] andHeaderTitle:nil footerTitle:nil]];
    }
    return ^(BKWordItem *item) {
        [weakSelf.sections.firstObject.items addObject:item];
        return weakSelf;
    };
}


@end
