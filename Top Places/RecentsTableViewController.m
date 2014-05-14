//
//  RecentsTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "RecentsTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "NSUserDefaultsAccess.h"

@interface RecentsTableViewController ()
@end

@implementation RecentsTableViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getSavedRecentPhotos];
}

- (void)getSavedRecentPhotos {
    NSUserDefaultsAccess *nsuda = [[NSUserDefaultsAccess alloc] init];
    self.photos = [nsuda getSavedRecentPhotosArray];
}

- (void)refreshTable:(UIRefreshControl *)refreshControl {
    [self getSavedRecentPhotos];
    [refreshControl endRefreshing];
}


@end
