//
//  PhotoListTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/10/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "PhotoListTableViewController.h"
#import "FlickrFetcher.h"
#import "PhotoViewController.h"
#import "NSUserDefaultsAccess.h"
#import "PlaceTableViewController.h"
#import "RecentsTableViewController.h"

@interface PhotoListTableViewController ()
@end

@implementation PhotoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)setPhotos:(NSArray *)photos {
    _photos = photos;
    [self.tableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    id detail = self.splitViewController.viewControllers[1]; // Gets the detail ViewController. Will be nil if we're on an iPhone.
    if ([detail isKindOfClass:[UINavigationController class]]) {
        detail = [((UINavigationController *)detail).viewControllers firstObject];
    }
    
    if ([detail isKindOfClass:[PhotoViewController class]]) {
        [self preparePhotoViewcontroller:detail toDisplayPhoto:self.photos[indexPath.row]];
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Photo" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Photo"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSDictionary *photo = [self.photos objectAtIndex:indexPath.row];
    NSString *title = [photo objectForKey:FLICKR_PHOTO_TITLE];
    NSString *description = [photo valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
    
    if (([title length] > 0) && ([description length] > 0)) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = description;
    } else if (([title length] > 0) && ([description length] == 0)) {
        cell.textLabel.text = title;
        cell.detailTextLabel.text = @"";
    } else if (([title length] == 0) && ([description length] > 0)) {
        cell.textLabel.text = description;
        cell.detailTextLabel.text = @"";
    } else {
        cell.textLabel.text = @"Unknown";
    }
    
    return cell;
}

#pragma mark - Navigation

- (void)preparePhotoViewcontroller:(PhotoViewController *)pvc toDisplayPhoto:(NSDictionary *)photo {
    pvc.imageURL = [FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge];
    pvc.title = [photo valueForKeyPath:FLICKR_PHOTO_TITLE];
    NSUserDefaultsAccess *nsuda = [[NSUserDefaultsAccess alloc] init];
    [nsuda addPhotoToListOfRecentsWithPhoto:photo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if ([segue.identifier isEqualToString:@"DisplayPhoto"]) {
            [self preparePhotoViewcontroller:segue.destinationViewController toDisplayPhoto:self.photos[indexPath.row]];
        }
    }
}

- (void)refreshTable:(UIRefreshControl *)refreshControl {}

@end
