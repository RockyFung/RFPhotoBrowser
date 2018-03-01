//
//  RFWebPhotoCollectionVC.m
//  RFPhotoBrower
//
//  Created by 冯剑 on 2018/2/23.
//  Copyright © 2018年 冯剑. All rights reserved.
//

#import "RFWebPhotoCollectionVC.h"
#import "RFPhotoScrollerView.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface RFWebPhotoCollectionVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic,strong) UICollectionView *collection;
@property (nonatomic,strong) NSMutableArray *imageArray;
@property (nonatomic,strong) UIView *picView;
@end
// 间隔
NSInteger const margin2 = 10;
// cell id
NSString *const cellID2 = @"collectionViewCellID2";

@implementation RFWebPhotoCollectionVC
{
    CGFloat _itemWidth;
    NSInteger _loadNum;
}

- (NSMutableArray *)imageArray{
    if (_imageArray == nil) {
        _imageArray = [NSMutableArray array];
    }
    return  _imageArray;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self loadImages];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    _loadNum = 0;
    NSInteger colum = self.columNum ? self.columNum : 2;
    _itemWidth = (kScreenWidth - (colum + 1)*margin2)/colum;
}
- (void)setupCollectionView{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumInteritemSpacing = margin2;
    layout.minimumLineSpacing = margin2;
    self.collection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) collectionViewLayout:layout];
    self.collection.backgroundColor = [UIColor whiteColor];
    self.collection.delegate = self;
    self.collection.dataSource = self;
    [self.view addSubview:self.collection];
    [self.collection registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:cellID2];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.imageArray.count;
}
//每一个分组的上左下右间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(margin2, margin2, margin2, margin2);
}
//定义每一个cell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{;
    return CGSizeMake(_itemWidth, _itemWidth);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellID2 forIndexPath:indexPath];
    //UICollectionViewCell *cell= [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor=[UIColor whiteColor];
    cell.layer.cornerRadius = 10;
    cell.clipsToBounds = YES;
    // 移除子视图，防止循环引用
    for (UIView *view in cell.contentView.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:cell.bounds];
    UIImage *image = self.imageArray[indexPath.row];
    imageView.image = image;
    CGSize imageReSize = [self resizeImageSize:image.size];
    imageView.frame = CGRectMake((_itemWidth - imageReSize.width) / 2, (_itemWidth - imageReSize.height) / 2, imageReSize.width, imageReSize.height);
    [cell.contentView addSubview:imageView];
    return cell;
}

- (void)loadImages{
    [self.imageArray removeAllObjects];
    if (self.photoArray.count == 0) {
//        [MBProgressHUD showError:@"您没有图片资料" afterDelay:1.0];
        return;
    }
//    [MBProgressHUD showMessage:@"加载中" toView:self.view];
    // 创建组
    dispatch_group_t imageGroup = dispatch_group_create();
    for (NSString *imageUrl in self.photoArray) {
        // 任务加入组
        dispatch_group_enter(imageGroup);
        NSString *urlUTF8 = [imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[SDWebImageManager sharedManager]downloadImageWithURL:[NSURL URLWithString:urlUTF8] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            
        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
            if (image) {
                [self.imageArray addObject:image];
                NSLog(@"%@",imageURL.absoluteString);
            }
            // 任务完成离开组
            dispatch_group_leave(imageGroup);
            
        }];
    }
    // 组里任务都完成后进入这个方法,从主线程刷新UI
    dispatch_group_notify(imageGroup, dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUDForView:self.view];
        if (self.imageArray.count == 0) {
            // [MBProgressHUD showError:@"图片资料加载失败" afterDelay:1.0];
        }else{
            [self setupCollectionView];
            NSLog(@"所有图片下载完毕！！！");
        }
    });
}


// 调整图片
-(CGSize)resizeImageSize:(CGSize)size{
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat maxHeight = _itemWidth;
    CGFloat maxWidth = _itemWidth;
    //如果图片尺寸大于view尺寸，按比例缩放
    if(width > maxWidth || height > width){
        CGFloat ratio = height / width;
        CGFloat maxRatio = maxHeight / maxWidth;
        if(ratio < maxRatio){
            width = maxWidth;
            height = width*ratio;
        }else{
            height = maxHeight;
            width = height / ratio;
        }
    }
    return CGSizeMake(width, height);
}
//cell的点击事件
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    UIImage *image = self.imageArray[indexPath.row];
    if (!image) {
        return;
    }
    RFPhotoScrollerView *scrollerView = [[RFPhotoScrollerView alloc]initWithImagesArray:self.imageArray currentIndex:indexPath.row];
    [[[UIApplication sharedApplication] keyWindow] addSubview:scrollerView];
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
