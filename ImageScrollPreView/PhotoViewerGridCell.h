//
//  PhotoViewerGridCell.h
//
//  Created by Anton Morozov on 25.07.14.
//  Copyright (c) 2014 Anton Morozov. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const PhotoViewerGridCellIdentifier;

@interface PhotoViewerGridCell : UICollectionViewCell

@property (nonatomic, strong) ALAsset *asset;
@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, assign) BOOL markSelected;

-(void)showCameraButton:(BOOL)show;

@end

