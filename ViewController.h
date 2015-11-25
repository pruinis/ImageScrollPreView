//
//  ViewController.h
//  ImageScrollPreView
//
//  Created by Anton Morozov on 25.11.15.
//  Copyright (c) 2015 Anton Morozov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageScrollPreView.h"

@interface ViewController : UIViewController <ImageScrollPreViewDelegate>

@property (nonatomic, retain) ImageScrollPreView *photoView;

@end
