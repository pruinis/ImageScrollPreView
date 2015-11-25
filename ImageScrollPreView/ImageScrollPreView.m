//
//  ImageScrollPreView.m
//
//  Created by Anton Morozov on 11.08.15.
//  Copyright (c) 2015 Anton Morozov. All rights reserved.
//

#import "ImageScrollPreView.h"
#import "PhotoFlowLayout.h"
#import "PhotoViewerGridCell.h"

CGFloat const kImageScrollPreViewBorder = 18.0;
CGSize const kImageScrollPreViewItemSize = {80, 60};
static NSString * const CameraCell = @"CameraCell";


@interface ImageScrollPreView () <UICollectionViewDataSource,UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>

@property (nonatomic, retain) UICollectionView *collectionView;
@property (nonatomic,strong) PhotoFlowLayout *layout;
@property (nonatomic, strong) NSMutableArray *capturedImages;
@property (nonatomic, strong) NSIndexPath *selectedItemIndexPath;
@property (nonatomic, strong) UIView *scrollIndicatorView;
@property (nonatomic, strong) UIView *shedowIndicatorView;

@end

@implementation ImageScrollPreView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        [self setBackgroundColor:[UIColor whiteColor]];
        
        // variables
        _capturedImages = [NSMutableArray array];
        _allowSelection = NO;
        _resizeAnimated = NO;
        _showCameraButton = NO;
        _elastic = YES;
        _minRowsCount = _maxRowsCount = 1;
        
        // PhotoFlowLayout
        _layout = [[PhotoFlowLayout alloc] init];
        [_layout setItemSize:kImageScrollPreViewItemSize];
        [_layout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        [_layout setMinimumLineSpacing:10];
        [_layout setMinimumInteritemSpacing:10];
        
        // UICollectionView
        CGRect rect = CGRectMake(0, kImageScrollPreViewBorder, frame.size.width, frame.size.height - kImageScrollPreViewBorder);
        _collectionView=[[UICollectionView alloc] initWithFrame:rect collectionViewLayout:_layout];
        [_collectionView setDataSource:self];
        [_collectionView setDelegate:self];
        [self.collectionView registerClass:[PhotoViewerGridCell class] forCellWithReuseIdentifier:PhotoViewerGridCellIdentifier];
        [_collectionView setBackgroundColor:[UIColor clearColor]];
        [self addSubview:_collectionView];
        _collectionView.multipleTouchEnabled = NO;
        [_collectionView setShowsHorizontalScrollIndicator:NO];
        [_collectionView setShowsVerticalScrollIndicator:NO];
        
        // indicator
        CGRect indicatorFrame = CGRectMake(0, frame.size.height - 25, frame.size.width, 10);
        _scrollIndicatorView = [[UIView alloc] initWithFrame:indicatorFrame];
        _scrollIndicatorView.layer.cornerRadius = 5.0f;
        _scrollIndicatorView.backgroundColor = [UIColor colorWithRed:117/255.0 green:168/255.0 blue:46/255.0 alpha:1];
        _scrollIndicatorView.layer.masksToBounds = YES;
        [self addSubview:_scrollIndicatorView];
        
        // shedowIndicatorView
        _shedowIndicatorView = [[UIView alloc] initWithFrame:indicatorFrame];
        _shedowIndicatorView.layer.cornerRadius = 5.0f;
        _shedowIndicatorView.backgroundColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1];
        _shedowIndicatorView.layer.masksToBounds = YES;
        [self addSubview:_shedowIndicatorView];
        [self sendSubviewToBack:_shedowIndicatorView];
                
        CGRect newFrame = self.frame;
        newFrame.size.height = 1 * (_layout.itemSize.height + _layout.minimumInteritemSpacing) + kImageScrollPreViewBorder + 25;
        [self setFrame:newFrame];
    }
    return self;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect rect = CGRectMake(0, kImageScrollPreViewBorder, frame.size.width, frame.size.height - kImageScrollPreViewBorder);
    [_collectionView setFrame:rect];
    
    CGRect indicatorFrame = CGRectMake(0, frame.size.height - 25, frame.size.width, 10);
    [_scrollIndicatorView setFrame:indicatorFrame];     
    [_shedowIndicatorView setFrame:indicatorFrame];
    
    [self.collectionView reloadData];
}

#pragma mark -

-(void)setShowCameraButton:(BOOL)showCameraButton
{
    _showCameraButton = showCameraButton;
    [self checkCameraButtons];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self resizeControlAnimated];
    });
}

-(void)setImagesAssets:(NSArray *)assets
{
    [self.capturedImages removeAllObjects];
    [self addImagesAssets:assets];
}

-(void)addImagesAssets:(NSArray *)assets
{
    [self.capturedImages addObjectsFromArray:assets];
    [self checkCameraButtons];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
        [self resizeControlAnimated];
    });
}

-(void)removeAsset:(ALAsset*)asset
{
    if (asset && [self.capturedImages containsObject:asset]) {
        [self.capturedImages removeObject:asset];
        [self checkCameraButtons];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.collectionView reloadData];
            [self resizeControlAnimated];
        });
    }
}

-(NSArray *)assets
{
    return [self.capturedImages copy];
}

-(void)deselectSelectedtAssets
{
    if (self.selectedItemIndexPath) {
        self.selectedItemIndexPath = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });     
}

-(void)setSelectedAsset:(ALAsset *)selectedAsset
{
    if (selectedAsset && [self.capturedImages containsObject:selectedAsset]) {
        self.selectedItemIndexPath = [NSIndexPath indexPathForRow:[self.capturedImages indexOfObject:selectedAsset] inSection:0];
    } else {
        self.selectedItemIndexPath = nil;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

-(NSInteger)maxItemsPerPage
{
    CGSize canvasSize = self.collectionView.frame.size;
    NSUInteger columnCount = (canvasSize.width - _layout.itemSize.width) / (_layout.itemSize.width + _layout.minimumLineSpacing) + 1;
    return _maxRowsCount * columnCount;
}

-(void)checkCameraButtons
{
    NSMutableArray *allAssets = [NSMutableArray arrayWithArray:self.capturedImages];
    for (id el in allAssets) {
        if ([el isKindOfClass:[NSString class]]) {
            [self.capturedImages removeObject:el];
        }
    }
    
    if (_showCameraButton) {
        [self.capturedImages insertObject:CameraCell atIndex:0];
        [self addCameraButtonsOnPages];
    }
}

-(void)addCameraButtonsOnPages
{
    NSInteger index = 0;
    
    for (int i = 0; i < _capturedImages.count; i++) {
        id obj = [_capturedImages objectAtIndex:i];
        if (i % [self maxItemsPerPage] == 0) {            
            if (![obj isKindOfClass:[NSString class]]) {
                index = i;
                break;
            }
        }
    }
    
    if (index) {
        [self.capturedImages insertObject:CameraCell atIndex:index];
        [self addCameraButtonsOnPages];
    }
}

-(void)resizeIndicatorFrame {
    
    float pagesCount = self.capturedImages.count / (float)[self maxItemsPerPage];
    if (pagesCount > (int)pagesCount) {
        pagesCount++;
    }
    
    if (pagesCount <= 0) {
        pagesCount = 1;
    }
    
    CGRect newIndicatorFrame = self.scrollIndicatorView.frame;
    newIndicatorFrame.size.width = self.frame.size.width / (int)pagesCount;
    self.scrollIndicatorView.frame = newIndicatorFrame;
}

-(void)resizeControlAnimated
{
    if (!_elastic) {
        [self performSelector:@selector(resizeIndicatorFrame) withObject:nil afterDelay:0.2];
        return;
    }
    
    CGSize canvasSize = self.collectionView.frame.size;
    NSUInteger rowCount = (canvasSize.height - _layout.itemSize.height) / (_layout.itemSize.height + _layout.minimumInteritemSpacing) + 1;
    NSUInteger columnCount = (canvasSize.width - _layout.itemSize.width) / (_layout.itemSize.width + _layout.minimumLineSpacing) + 1;
    NSUInteger itemsPerPage = rowCount * columnCount;
    NSInteger instedRows = _maxRowsCount;
    
    if (self.capturedImages.count > itemsPerPage) {
        if (self.capturedImages.count < [self maxItemsPerPage]) {
            float projectedRowCount = _capturedImages.count / (float)columnCount;
            instedRows = projectedRowCount;
            if (projectedRowCount > instedRows) {
                instedRows++;
            }
        }
    } else {
        float projectedRowCount = _capturedImages.count / (float)columnCount;
        instedRows = projectedRowCount;
        if (projectedRowCount > instedRows) {
            instedRows++;
        }
    }
    
    if (!instedRows) {
        instedRows++;
    }
    
    if (instedRows != rowCount) {
        CGRect frame = self.frame;
        frame.size.height = instedRows * (_layout.itemSize.height + _layout.minimumInteritemSpacing) + kImageScrollPreViewBorder + 25;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(imageScrollPreView:shouldChangeSize:)]) {
            [self.delegate imageScrollPreView:self shouldChangeSize:frame.size];
        }
        
        if (_resizeAnimated) {
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setFrame:frame];
                [self resizeIndicatorFrame];
            } completion:^(BOOL finished) {
                if (self.delegate && [self.delegate respondsToSelector:@selector(imageScrollPreView:didChangeSize:)]) {
                    [self.delegate imageScrollPreView:self didChangeSize:self.frame.size];
                }
            }];
        } else {
            [self setFrame:frame];
            [self resizeIndicatorFrame];
            if (self.delegate && [self.delegate respondsToSelector:@selector(imageScrollPreView:didChangeSize:)]) {
                [self.delegate imageScrollPreView:self didChangeSize:self.frame.size];
            }
        }
    } else {
        [self performSelector:@selector(resizeIndicatorFrame) withObject:nil afterDelay:0.2];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.capturedImages.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoViewerGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoViewerGridCellIdentifier
                                                                          forIndexPath:indexPath];
    
    if (![[self capturedImages][indexPath.row] isKindOfClass:[ALAsset class]]) {
        cell.asset = nil;
        [cell setMarkSelected:NO];
        return cell;
    }
    
    cell.backgroundColor = [UIColor whiteColor];
    ALAsset *asset = (ALAsset *)[self capturedImages][indexPath.row];
    [cell setAsset:asset];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 2.0;
    [cell addGestureRecognizer:longPress];
    
    // selection state
    if (_allowSelection) {
        if (self.selectedItemIndexPath && [indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
            [cell setMarkSelected:YES];
        } else {
            [cell setMarkSelected:NO];
        }
    } else {
        if (cell.markSelected) {
            [cell setMarkSelected:NO];
        }
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[self capturedImages][indexPath.row] isKindOfClass:[ALAsset class]]) {
        if ([self.delegate respondsToSelector:@selector(imageScrollPreViewDidSelectAddPhoto:)]) {
            [self.delegate imageScrollPreViewDidSelectAddPhoto:self];
        }
        return;
    }
    
    if (!_allowSelection) {
        return;
    }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithObject:indexPath];
    
    if (self.selectedItemIndexPath) {
        if ([indexPath compare:self.selectedItemIndexPath] == NSOrderedSame) {
            self.selectedItemIndexPath = nil;
            
            if ([self.delegate respondsToSelector:@selector(imageScrollPreView:didDeselectAsset:)]) {
                [self.delegate imageScrollPreView:self didDeselectAsset:[self capturedImages][indexPath.row]];
            }
        }
        else {
            [indexPaths addObject:self.selectedItemIndexPath];
            self.selectedItemIndexPath = indexPath;
            
            if ([self.delegate respondsToSelector:@selector(imageScrollPreView:didSelectAsset:)]) {
                [self.delegate imageScrollPreView:self didSelectAsset:[self capturedImages][indexPath.row]];
            }
        }
    }
    else {
        self.selectedItemIndexPath = indexPath;
        
        if ([self.delegate respondsToSelector:@selector(imageScrollPreView:didSelectAsset:)]) {
            [self.delegate imageScrollPreView:self didSelectAsset:[self capturedImages][indexPath.row]];
        }
    }
    
    [collectionView reloadData];
}

#pragma makr - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    return YES;
}

-(void)handleLongPress:(UILongPressGestureRecognizer*)sender {
    
    if (![(PhotoViewerGridCell *)sender.view asset]) return;
    
    if (sender.state == UIGestureRecognizerStateBegan){
        // NSLog(@"UIGestureRecognizerStateBegan.");
        
        if ([self.delegate respondsToSelector:@selector(imageScrollPreView:didLongPressAsset:)]) {
            [self.delegate imageScrollPreView:self didLongPressAsset:[(PhotoViewerGridCell *)sender.view asset]];
        }
    }
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    float pageWidth = self.frame.size.width;
    
    float currentOffset = scrollView.contentOffset.x;
    float targetOffset = targetContentOffset->x;
    float newTargetOffset = 0;
    
    if (targetOffset > currentOffset)
        newTargetOffset = ceilf(currentOffset / pageWidth) * pageWidth;
    else
        newTargetOffset = floorf(currentOffset / pageWidth) * pageWidth;
    
    if (newTargetOffset < 0)
        newTargetOffset = 0;
    else if (newTargetOffset > scrollView.contentSize.width)
        newTargetOffset = scrollView.contentSize.width;
    
    targetContentOffset->x = currentOffset;
    [scrollView setContentOffset:CGPointMake(newTargetOffset, 0) animated:YES];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat contentWidth = scrollView.contentSize.width;
    CGFloat contentOffsetX = scrollView.contentOffset.x;
    CGFloat scrollWidth = scrollView.frame.size.width;
    
    CGRect newIndicatorFrame = self.scrollIndicatorView.frame;
    newIndicatorFrame.size.width = scrollView.frame.size.width / (scrollView.contentSize.width / scrollView.frame.size.width);
    self.scrollIndicatorView.frame = newIndicatorFrame;
    CGFloat indicatorWidth = self.scrollIndicatorView.frame.size.width;
    
    if (contentOffsetX <= 0) {
        
        CGRect IndicatorFrame = self.scrollIndicatorView.frame;
        IndicatorFrame.origin.x = scrollView.frame.origin.x;
        self.scrollIndicatorView.frame = IndicatorFrame;
        return;
    }
    if (contentOffsetX >= contentWidth-scrollWidth) {
        
        CGRect IndicatorFrame = self.scrollIndicatorView.frame;
        IndicatorFrame.origin.x = (scrollView.frame.origin.x+scrollWidth-indicatorWidth);
        self.scrollIndicatorView.frame = IndicatorFrame;
        return;
    }
    
    CGFloat x = contentOffsetX * (scrollWidth-indicatorWidth) / (contentWidth-scrollWidth);
    
    CGRect IndicatorFrame = self.scrollIndicatorView.frame;
    IndicatorFrame.origin.x = x;
    self.scrollIndicatorView.frame = IndicatorFrame;
}

@end
