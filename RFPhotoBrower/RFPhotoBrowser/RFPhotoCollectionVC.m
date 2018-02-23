//
//  RFPhotoCollectionVC.m
//  RFPhotoBrower
//
//  Created by 冯剑 on 2017/11/23.
//  Copyright © 2017年 冯剑. All rights reserved.
//

#import "RFPhotoCollectionVC.h"
#import "RFPhotoScrollerView.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface RFPhotoCollectionVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collection;
@end

// 间隔
NSInteger const margin = 10;
// cell id
NSString *const cellID = @"collectionViewCellID";

@implementation RFPhotoCollectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = margin;
    layout.minimumLineSpacing = margin;
    self.collection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) collectionViewLayout:layout];
    self.collection.backgroundColor = [UIColor whiteColor];
    self.collection.delegate = self;
    self.collection.dataSource = self;
    [self.view addSubview:self.collection];
    
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID];
    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.photoArray.count;
}
//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(margin, margin, margin, margin);
}
//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger colum = self.columNum ? self.columNum : 2;
    CGFloat itemW = (kScreenWidth - (colum + 1)*margin)/colum;
    return CGSizeMake(itemW, itemW);
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    cell.backgroundColor=[UIColor lightGrayColor];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:cell.bounds];
    UIImage *image = [UIImage imageNamed:self.photoArray[indexPath.row]];
    [imageView setImage:image];
    [cell.contentView addSubview:imageView];
    return cell;
}

//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    RFPhotoScrollerView *scrollerView = [[RFPhotoScrollerView alloc]initWithImagesArray:self.photoArray currentIndex:indexPath.row];
    [[[UIApplication sharedApplication] keyWindow] addSubview:scrollerView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
