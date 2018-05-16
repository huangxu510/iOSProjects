//
//  BKTabBarViewController.m
//  BookKeeping123
//
//  Created by huangxu on 2018/5/15.
//  Copyright © 2018年 huangxu. All rights reserved.
//

#import "BKTabBarViewController.h"
#import "BKHomePageViewController.h"
#import "BKToolViewController.h"
#import "BKInformationViewController.h"
#import "BKMyCenterViewController.h"
#import "BKBaseNavigationController.h"

@interface BKTabBarViewController ()

@end

@implementation BKTabBarViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupTabBarController];
        [self setupTabBarUI];
    }
    return self;
}

- (void)setupTabBarController {
    
    // 加载沙盒中的main.json
    NSString *jsonPath = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES).firstObject stringByAppendingPathComponent:@"main.json"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:jsonPath];
    
    // 如果没有则去Bundle拿
    if (nil == data) {
        jsonPath = [[NSBundle mainBundle] pathForResource:@"main.json" ofType:nil];
        data = [[NSData alloc] initWithContentsOfFile:jsonPath];
    }
    NSArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    
    NSMutableArray *viewControllers = [NSMutableArray array];
    for (NSDictionary *dict in array) {
        UIViewController *vc = [self setupViewController:dict];
        [viewControllers addObject:vc];
    }

    self.viewControllers = viewControllers;
    
    // 未选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]} forState:UIControlStateNormal];
    
    // 选中字体颜色
    [[UITabBarItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:HexColor(0xfff100)} forState:UIControlStateSelected];
}

- (void)setupTabBarUI {
    
    // 自定义 TabBar 高度
    //    self.tabBarHeight = CYL_IS_IPHONE_X ? 65 : 40;
    
    // 普通状态下的文字属性
    NSMutableDictionary *normalAttrs = [NSMutableDictionary dictionary];
    normalAttrs[NSForegroundColorAttributeName] = [UIColor grayColor];
    normalAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:9];
    
    // 选中状态下的文字属性
    NSMutableDictionary *selectedAttrs = [NSMutableDictionary dictionary];
    selectedAttrs[NSForegroundColorAttributeName] = [UIColor blackColor];
    selectedAttrs[NSFontAttributeName] = [UIFont systemFontOfSize:9];
    
    // 设置文字属性
    UITabBarItem *tabBarItem = [UITabBarItem appearance];
    [tabBarItem setTitleTextAttributes:normalAttrs forState:UIControlStateNormal];
    [tabBarItem setTitleTextAttributes:selectedAttrs forState:UIControlStateSelected];
    
    // 设置背景图片
    UITabBar *tabBar = [UITabBar appearance];
    
    // 去除 TabBar 自带的顶部阴影
    [tabBar setShadowImage:[[UIImage alloc] init]];
    [tabBar setBackgroundImage:[[UIImage alloc] init]];
    [tabBar setBackgroundColor:[UIColor whiteColor]];
    //    [self hideTabBadgeBackgroundSeparator];
}


- (BKBaseNavigationController *)setupViewController:(NSDictionary *)dict {
    NSString *className = dict[@"clsName"];
    NSString *title = dict[@"title"];
    NSString *imageName = dict[@"imageName"];
    NSString *selectedImageName = dict[@"selectedImageName"];
    UIViewController *vc = [[NSClassFromString(className) alloc] init];
    BKBaseNavigationController *nav = [[BKBaseNavigationController alloc] initWithRootViewController:vc];
    nav.tabBarItem = [[UITabBarItem alloc] initWithTitle:title image:IMG(imageName) selectedImage:IMG(selectedImageName)];
    return nav;
}

@end
