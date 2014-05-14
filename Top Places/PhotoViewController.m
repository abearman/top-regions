//
//  PhotoViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "PhotoViewController.h"

@interface PhotoViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation PhotoViewController

#pragma mark View Controller Lifecycle

- (void)awakeFromNib {
    self.splitViewController.delegate = self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self scaleImageToScrollView];
}

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    self.imageView.frame = CGRectMake(0, 0, self.imageView.frame.size.width, self.imageView.frame.size.height);
    [UIImageView animateWithDuration:0.8 animations:^{
        [self scaleImageToScrollView];
    }];
}

- (void)scaleImageToScrollView {
    self.imageView.image = self.image;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    CGRect scrollViewFrame = self.scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    self.scrollView.zoomScale = MAX(scaleWidth, scaleHeight);
}

#pragma mark Properties

- (UIImageView *)imageView {
    if (!_imageView) _imageView = [[UIImageView alloc] init];
    return _imageView;
}

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
    [self scaleImageToScrollView];
    [self.spinner stopAnimating];
}

#pragma mark Public API

- (void)setImageURL:(NSURL *)imageURL {
    _imageURL = imageURL;
    [self startDownloadingImage];
}

- (void)startDownloadingImage {
    self.image = nil;
    if (self.imageURL) {
        [self.spinner startAnimating];
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    if ([request.URL isEqual:self.imageURL]) {
                        UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                        dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                    }
                }
            }];
        [task resume];
    }
}

#pragma mark Outlets

- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
}

#pragma mark UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

#pragma mark - UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)svc
   shouldHideViewController:(UIViewController *)vc
              inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

- (void)splitViewController:(UISplitViewController *)svc
     willHideViewController:(UIViewController *)aViewController
          withBarButtonItem:(UIBarButtonItem *)barButtonItem
       forPopoverController:(UIPopoverController *)pc
{
    self.navigationItem.leftBarButtonItem = barButtonItem;
    barButtonItem.title = aViewController.title;
}

- (void)splitViewController:(UISplitViewController *)svc
     willShowViewController:(UIViewController *)aViewController
  invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}



@end
