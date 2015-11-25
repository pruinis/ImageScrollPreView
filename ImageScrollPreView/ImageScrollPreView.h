//
//  ImageScrollPreView.h
//
//  Created by Anton Morozov on 11.08.15.
//  Copyright (c) 2015 Anton Morozov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageScrollPreView;
@protocol ImageScrollPreViewDelegate<NSObject>
@optional
-(void)imageScrollPreViewDidSelectAddPhoto:(ImageScrollPreView*)view; 
-(void)imageScrollPreView:(ImageScrollPreView*)view didSelectAsset:(ALAsset*)asset;
-(void)imageScrollPreView:(ImageScrollPreView*)view didDeselectAsset:(ALAsset*)asset;
-(void)imageScrollPreView:(ImageScrollPreView*)view didLongPressAsset:(ALAsset*)asset;
-(void)imageScrollPreView:(ImageScrollPreView *)view shouldChangeSize:(CGSize)newSize; 
-(void)imageScrollPreView:(ImageScrollPreView *)view didChangeSize:(CGSize)newSize; 
@end

@interface ImageScrollPreView : UIView
{
    __weak id <ImageScrollPreViewDelegate> delegate;
}

@property (nonatomic, weak) id <ImageScrollPreViewDelegate> delegate;
@property (nonatomic, assign) ALAsset* selectedAsset;
@property (nonatomic, assign) BOOL allowSelection;
@property (nonatomic, assign) BOOL resizeAnimated;
@property (nonatomic, assign) BOOL elastic;
@property (nonatomic, assign) BOOL showCameraButton; 
@property (nonatomic, assign) int minRowsCount;
@property (nonatomic, assign) int maxRowsCount; 

-(NSArray*)assets;
-(void)setImagesAssets:(NSArray*)assets;
-(void)addImagesAssets:(NSArray *)assets;
-(void)removeAsset:(ALAsset*)asset;
-(void)deselectSelectedtAssets;

@end
