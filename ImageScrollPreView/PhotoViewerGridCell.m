//
//  PhotoViewerGridCell.m
//  Traveloggia
//
//  Created by Anton Morozov on 25.07.14.
//  Copyright (c) 2014 Anton Morozov. All rights reserved.
//

#import "PhotoViewerGridCell.h"

NSString * const PhotoViewerGridCellIdentifier = @"THUMBNAIL_CELL";

#define kBigHeightInterv    10.0
#define GREEN_COLOR [UIColor colorWithRed:117/255.0 green:168/255.0 blue:46/255.0 alpha:1] 
#define TravFontLight   @"HelveticaNeue-Light"

@interface PhotoViewerGridCell ()

@property (strong, nonatomic) UIView *marckView;
@property (strong, nonatomic) UIView *cameraView;

@end


@implementation PhotoViewerGridCell

@synthesize imgView;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = 3.0f;
        self.layer.masksToBounds = YES;
        
        //
        self.imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        [self.contentView addSubview:self.imgView];
        
        [self setMarkSelected:NO];
        [self showCameraButton:NO]; 
    }
    return self;
}

-(UIView *)marckView
{
    if (!_marckView) {
                
        _marckView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        [self.contentView addSubview:_marckView];
        
        UIImageView *prevImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"make_post_preview"]];
        prevImageView.center = CGPointMake(prevImageView.frame.size.width / 2 + kBigHeightInterv, prevImageView.frame.size.height / 2 + 30);
        [_marckView addSubview:prevImageView];
        
        UILabel *prevLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        prevLabel.backgroundColor = [UIColor clearColor];
        prevLabel.font = [UIFont fontWithName:TravFontLight size: 12.0];
        prevLabel.textAlignment = NSTextAlignmentLeft;
        prevLabel.textColor = [UIColor whiteColor];
        prevLabel.text = @"Preview";
        [prevLabel sizeToFit];
        prevLabel.center = CGPointMake(prevLabel.frame.size.width / 2 + kBigHeightInterv, prevImageView.frame.origin.y + prevImageView.frame.size.height + prevLabel.frame.size.height / 2);
        [_marckView addSubview:prevLabel];
        
        return _marckView;
    }
    return _marckView;
}

-(UIView *)cameraView
{
    if (!_cameraView) {
        
        _cameraView = [[UIView alloc] initWithFrame: self.contentView.frame];

        UIImageView *cameraImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"make_post_add_photos"]];
        [cameraImageView setCenter:CGPointMake(_cameraView.center.x, _cameraView.center.y - 10)];
        [_cameraView addSubview:cameraImageView];
        
        UILabel *addLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        addLabel.backgroundColor = [UIColor clearColor];
        addLabel.font = [UIFont fontWithName:TravFontLight size: 12.0];
        addLabel.textAlignment = NSTextAlignmentCenter;
        addLabel.textColor = [UIColor lightGrayColor];
        addLabel.text = @"Add photos";
        [addLabel sizeToFit];
        addLabel.center = CGPointMake(_cameraView.center.x, _cameraView.center.y + addLabel.frame.size.height);
        [_cameraView addSubview:addLabel];
        
        [self.contentView addSubview:_cameraView];
        
        return _cameraView;
    }
    return _cameraView;
}

-(void)showCameraButton:(BOOL)show
{
    if (show) self.imgView.image = nil;
    
    [self.cameraView setHidden: !show];
}

-(void)setMarkSelected:(BOOL)markSelected
{
    _markSelected = markSelected;
    
    if (_markSelected) {
        [self.marckView setHidden: !_markSelected];
        self.layer.borderWidth = 2.0f;
        self.layer.borderColor = GREEN_COLOR.CGColor;
    } else {
        [self.marckView setHidden: !_markSelected];
        self.layer.borderWidth = 1.0f;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

-(void)setAsset:(ALAsset *)asset
{
    _asset = asset;
    
    if (_asset) {
        [self showCameraButton:NO];
        UIImage *thumbnail = [UIImage imageWithCGImage:[asset thumbnail]];
        self.imgView.image = thumbnail;
    } else {
        [self showCameraButton:YES];
    }
}

@end