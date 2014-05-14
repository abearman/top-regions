//
//  PlaceTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "PlaceTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"

@interface PlaceTableViewController ()
@end

#define PHOTOS_PER_PLACE 50

@implementation PlaceTableViewController

- (void)refreshTable:(UIRefreshControl *)refreshControl {
    [self downloadFlickrData];
    [refreshControl endRefreshing];
}

- (void) downloadFlickrData {
    self.photos = nil;
    
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    NSURL *url = [[ff class] URLforPhotosInPlace:self.placeId maxResults:PHOTOS_PER_PLACE];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:url]) {
                    NSData *data = [NSData dataWithContentsOfURL:localfile];
                    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSArray *photos = [results valueForKeyPath:FLICKR_RESULTS_PHOTOS];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.photos = photos;
                    });
                }
            }
        }];
    [task resume];
}

@end



