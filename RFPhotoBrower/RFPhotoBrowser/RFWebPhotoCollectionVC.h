//
//  RFWebPhotoCollectionVC.h
//  RFPhotoBrower
//
//  Created by 冯剑 on 2018/2/23.
//  Copyright © 2018年 冯剑. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFWebPhotoCollectionVC : UIViewController
@property (nonatomic,strong) NSArray *photoArray;
@property (nonatomic, assign) NSInteger columNum; // 列数 default=2
@end
