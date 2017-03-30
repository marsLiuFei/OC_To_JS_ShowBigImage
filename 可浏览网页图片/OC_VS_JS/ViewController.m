//
//  ViewController.m
//  OC_VS_JS
//
//  Created by apple on 2017/3/30.
//  Copyright © 2017年 baixinxueche. All rights reserved.
//

#import "ViewController.h"
#import "LFShowWebViewPicViewController.h"

@interface ViewController ()

@end

@implementation ViewController
- (IBAction)tiaozhuan:(UIButton *)sender {
    
    LFShowWebViewPicViewController *newVC = [LFShowWebViewPicViewController new];
    newVC.urlStr = @"http://www.baixinxueche.com/webshow/kesan/quanxiang.html";
    [self.navigationController pushViewController:newVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
