//
//  ViewController.m
//  ImageScrollPreView
//
//  Created by Anton Morozov on 25.11.15.
//  Copyright (c) 2015 Anton Morozov. All rights reserved.
//

#import "ViewController.h"

#define BIG_TEXT_FIELD_SIZE CGSizeMake(290, 40)


@interface ViewController () {
    ALAssetsLibrary *library;
    NSArray *imageArray;
    NSMutableArray *mutableArray;
}


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGRect rect = CGRectMake((self.view.frame.size.width - BIG_TEXT_FIELD_SIZE.width) / 2, 100, BIG_TEXT_FIELD_SIZE.width, 170);
    self.photoView = [[ImageScrollPreView alloc] initWithFrame: rect];
    [self.photoView setAllowSelection:YES];
    [self.photoView setMaxRowsCount:2];
    [self.photoView setDelegate:self];
    [self.view addSubview:self.photoView];
    

    [self getAllPictures];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSInteger count = 0;

-(void)getAllPictures
{
    imageArray=[[NSArray alloc] init];
    mutableArray =[[NSMutableArray alloc]init];
    NSMutableArray* assetURLDictionaries = [[NSMutableArray alloc] init];
    
    library = [[ALAssetsLibrary alloc] init];
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                [assetURLDictionaries addObject:[result valueForProperty:ALAssetPropertyURLs]];
                NSURL *url= (NSURL*) [[result defaultRepresentation]url];
                [library assetForURL:url resultBlock:^(ALAsset *asset) {
                    [mutableArray addObject:asset];
                    if ([mutableArray count] == count) {
                         imageArray=[[NSArray alloc] initWithArray:mutableArray];
                         [self allPhotosCollected:imageArray];
                    }
                    
                } failureBlock:^(NSError *error){ NSLog(@"operation was not successfull!"); }];
            }
        }
    };
    
    NSMutableArray *assetGroups = [[NSMutableArray alloc] init];
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            [group enumerateAssetsUsingBlock:assetEnumerator];
            [assetGroups addObject:group];
            count = [group numberOfAssets];
        }
    };
    
    assetGroups = [[NSMutableArray alloc] init];
    [library enumerateGroupsWithTypes:ALAssetsGroupAll
                           usingBlock:assetGroupEnumerator
                         failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

-(void)allPhotosCollected:(NSArray*)imgArray
{
    //write your code here after getting all the photos from library...
    NSLog(@"all assets are %@",imgArray);
    
    [self.photoView setImagesAssets:imgArray];
    [self.photoView setSelectedAsset:[imgArray firstObject]];     
}

@end
