//
//  RFPhotoCollectionVC.h
//  RFPhotoBrower
//
//  Created by 冯剑 on 2017/11/23.
//  Copyright © 2017年 冯剑. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RFPhotoCollectionVC : UIViewController
@property (nonatomic,strong) NSArray *photoArray;
@property (nonatomic, assign) NSInteger columNum; // 列数 default=2
@end
