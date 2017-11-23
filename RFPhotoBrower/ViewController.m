//
//  ViewController.m
//  RFPhotoBrower
//
//  Created by 冯剑 on 2017/11/23.
//  Copyright © 2017年 冯剑. All rights reserved.
//

#import "ViewController.h"
#import "RFPhotoCollectionVC.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    RFPhotoCollectionVC *photoVC = [[RFPhotoCollectionVC alloc]init];
    photoVC.columNum = 3;
    photoVC.photoArray = @[@"pic0.jpg",@"pic1.jpg",@"pic2.jpg",@"pic3.jpg",@"pic4.jpg",@"pic5.jpg",@"pic6.jpg",@"pic7.jpg",@"pic8.jpg"];
    [self.view addSubview:photoVC.view];
    [self addChildViewController:photoVC];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
