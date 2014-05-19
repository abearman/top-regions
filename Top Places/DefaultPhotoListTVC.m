//
//  DefaultPhotoListTVC.m
//  Top Regions
//
//  Created by Amy Bearman on 5/19/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "DefaultPhotoListTVC.h"
#import "FlickrDatabase.h"

@interface DefaultPhotoListTVC ()

@end

@implementation DefaultPhotoListTVC

- (IBAction)refresh {
    [self.refreshControl beginRefreshing];
    [[FlickrDatabase sharedDefaultFlickrDatabase] fetchWithCompletionHandler:^(BOOL success) {
        [self.refreshControl endRefreshing];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    FlickrDatabase *flickrdb = [FlickrDatabase sharedDefaultFlickrDatabase];
    if (flickrdb.managedObjectContext) {
        self.managedObjectContext = flickrdb.managedObjectContext;
    } else {
        id observer = [[NSNotificationCenter defaultCenter] addObserverForName:FlickrDatabaseAvailable
                                                                        object:flickrdb
                                                                         queue:[NSOperationQueue mainQueue]
                                                                    usingBlock:^(NSNotification *note) {
                                                                        self.managedObjectContext = flickrdb.managedObjectContext;
                                                                        [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                    }];
    }
}

@end
