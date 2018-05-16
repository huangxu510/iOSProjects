//
//  ViewController.m
//  ZFSeatSelection
//
//  Created by qq 316917975  on 16/7/7.
//
//

#import "ViewController.h"
#import "ZFSeatViewController.h"
#import "MTSeatViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btnAction:(id)sender {
    
    ZFSeatViewController *seatsVC = [[ZFSeatViewController alloc]init];
    
    [self.navigationController pushViewController:seatsVC animated:YES];
    
    
}
- (IBAction)btnAction2:(id)sender {
    
    MTSeatViewController *seatVC = [[MTSeatViewController alloc] init];
    [self.navigationController pushViewController:seatVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
