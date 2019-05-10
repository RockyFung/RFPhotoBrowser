//
//  RFPhotoScrollerView.m
//  RFPhotoBrower
//
//  Created by 冯剑 on 2017/11/23.
//  Copyright © 2017年 冯剑. All rights reserved.
//

#import "RFPhotoScrollerView.h"
#import "UIImageView+WebCache.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
@interface RFPhotoScrollerView()<UIScrollViewDelegate>
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIScrollView *itemScrollView;
@end


@implementation RFPhotoScrollerView
{
    NSArray *_imagesArray;
    NSInteger _currentIndex;
    UILabel *_pageLabel;
    CGFloat _offset;
}
- (instancetype)initWithImagesArray:(NSArray *)imagesArray currentIndex:(NSInteger)currentIndex{
    _imagesArray = [imagesArray copy];
    _currentIndex = currentIndex;
    _offset = 0.0;
    self = [super initWithFrame:[[UIScreen mainScreen]bounds]];
    if (self) {
        // 设置scrollView
        [self setupScrollView];
        // 添加点击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];

        // 页码显示
        UILabel *pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.frame) - 100, kScreenWidth, 50)];
        _pageLabel = pageLabel;
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.textColor = [UIColor whiteColor];
        pageLabel.font = [UIFont systemFontOfSize:18];
        pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentIndex+1,_imagesArray.count];
        [self addSubview:pageLabel];
    }
    return self;
}
- (void)setupScrollView{
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:[[UIScreen mainScreen]bounds]];
    self.scrollView = scrollView;
    scrollView.delegate = self;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled =  YES;
    scrollView.bounces = NO;
    scrollView.contentSize = CGSizeMake(_imagesArray.count * kScreenWidth, kScreenHeight);
    scrollView.contentOffset = CGPointMake(_currentIndex * kScreenWidth, 0);
    [self addSubview:scrollView];
    
    // 添加图片
    [_imagesArray enumerateObjectsUsingBlock:^(NSString *imageUrl, NSUInteger idx, BOOL * _Nonnull stop) {
        UIScrollView *itemScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(idx * kScreenWidth, 0, kScreenWidth, kScreenHeight)];
        self.itemScrollView = itemScrollView;
        itemScrollView.delegate = self;
        itemScrollView.maximumZoomScale = 3.0;//最大缩放倍数
        itemScrollView.minimumZoomScale = 1.0;//最小缩放倍数
        itemScrollView.showsVerticalScrollIndicator = NO;
        itemScrollView.showsHorizontalScrollIndicator = NO;
        itemScrollView.backgroundColor =[UIColor blackColor];
        [itemScrollView setZoomScale:1];
        [self.scrollView addSubview:itemScrollView];

        
        // 添加图片并适配
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.userInteractionEnabled = YES;
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [itemScrollView addSubview:imageView];
        
        if ([imageUrl hasPrefix:@"http"]) {
            [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                CGSize imageReSize = [self resizeImageSize:image.size];
                imageView.frame = CGRectMake((kScreenWidth - imageReSize.width) / 2, (kScreenHeight - imageReSize.height) / 2, imageReSize.width, imageReSize.height);
            }];
        }else{
            UIImage *image = [UIImage imageNamed:imageUrl];
            CGSize imageReSize = [self resizeImageSize:image.size];
            imageView.image = image;
            imageView.frame = CGRectMake((kScreenWidth - imageReSize.width) / 2, (kScreenHeight - imageReSize.height) / 2, imageReSize.width, imageReSize.height);
        }
    }];

}

// 调整图片
-(CGSize)resizeImageSize:(CGSize)size{
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGFloat maxHeight = kScreenHeight;
    CGFloat maxWidth = kScreenWidth;
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

#pragma mark UIScrollViewDelegate
//指定缩放view
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    for (UIView *v in scrollView.subviews){
        return v;
    }
    return nil;
}

// 正在放大缩小
-(void)scrollViewDidZoom:(UIScrollView *)scrollView{
    // 增量为=位移距离/2
    UIView *v = [scrollView.subviews objectAtIndex:0];
    if ([v isKindOfClass:[UIImageView class]]){
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
        (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
        (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
        v.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                  scrollView.contentSize.height * 0.5 + offsetY);
    }
   

}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{

}

// 滚动完成
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView;{
    NSInteger page = scrollView.contentOffset.x / kScreenWidth;
    _currentIndex = page;
    _pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",page+1,_imagesArray.count];
    
    
    if (scrollView == self.scrollView){
        CGFloat x = scrollView.contentOffset.x;
        if (x !=_offset){
            _offset = x;
            for (UIScrollView *s in scrollView.subviews){
                if ([s isKindOfClass:[UIScrollView class]]){
                    [s setZoomScale:1.0];
                }
            }
        }
    }

    
}

- (void)tapAction:(UITapGestureRecognizer *)tap{
    [self removeFromSuperview];
}





























@end
