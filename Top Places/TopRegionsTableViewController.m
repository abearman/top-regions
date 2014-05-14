//
//  TopPlacesTableViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "TopRegionsTableViewController.h"
#import "FlickrFetcher.h"
#import "PlaceTableViewController.h"

#define PHOTOS_PER_PLACE 50

@interface TopRegionsTableViewController ()
@property (nonatomic, strong) NSMutableArray *photosForSelectedPlace;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@end

@implementation TopRegionsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self downloadFlickrPlaces];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshTable:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
}

- (void)refreshTable:(UIRefreshControl *)refreshControl {
    [self downloadFlickrPlaces];
    [refreshControl endRefreshing];
}

- (NSMutableDictionary *)countryToPlace {
   if (!_countryToPlace) {
        _countryToPlace = [[NSMutableDictionary alloc] init];
    }
    return _countryToPlace;
}

- (NSMutableArray *)photosForSelectedPlace {
    if (!_photosForSelectedPlace) {
        _photosForSelectedPlace = [[NSMutableArray alloc] init];
    }
    return _photosForSelectedPlace;
}

- (void)downloadFlickrPlaces {
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    NSURL *url = [[ff class] URLforTopPlaces];
    [self.spinner startAnimating];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
        completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
            if (!error) {
                if ([request.URL isEqual:url]) {
                    NSData *data = [NSData dataWithContentsOfURL:localfile];
                    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    NSArray *places = [results valueForKeyPath:FLICKR_RESULTS_PLACES];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.countryToPlace removeAllObjects];
                        [self formatFlickrPlacesData: places];
                        [self.tableView reloadData];
                        [self.spinner stopAnimating];
                    });
                }
            }
    }];
    [task resume];
}

- (void)formatFlickrPlacesData: (NSArray *)places {
    for (NSDictionary *place in places) {
        NSString *title = [place objectForKey:@"woe_name"];
        NSString *content = [place objectForKey:FLICKR_PLACE_NAME];
        
        NSRange rangeForCountry = [content rangeOfString:@", " options:NSBackwardsSearch];
        NSString *country = [content substringFromIndex:rangeForCountry.location + 1];
        
        NSRange rangeForSubtitle = [content rangeOfString:@", "];
        NSString *subtitle = [content substringFromIndex:rangeForSubtitle.location + 1]; // Cuts out the title, comma, and space
        
        NSString *placeId = [place objectForKey:FLICKR_PHOTO_PLACE_ID];
        
        NSDictionary *place = [[NSDictionary alloc] initWithObjectsAndKeys:
                               title, @"title",
                               subtitle, @"subtitle",
                               placeId, @"placeId",
                               nil];
        
        NSMutableArray *currentPlacesForCountry = [self.countryToPlace objectForKey:country];
        if (currentPlacesForCountry == nil) {
            currentPlacesForCountry = [[NSMutableArray alloc] initWithObjects:place, nil];
        } else {
            [currentPlacesForCountry addObject:place];
        }
        
        // Sort places in each country section by name, ascending order
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [currentPlacesForCountry sortedArrayUsingDescriptors:sortDescriptors];
        currentPlacesForCountry =[NSMutableArray arrayWithArray:sortedArray];
        
        [self.countryToPlace setObject:currentPlacesForCountry forKey:country];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.countryToPlace allKeys] count];
}

// Sections (countries) are sorted alphabetically
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sortedCountries = [self sortedCountryKeys];
    NSString *key = [sortedCountries objectAtIndex:section];
    return [[self.countryToPlace objectForKey:key] count];
}

- (NSArray *)sortedCountryKeys {
    NSArray *countries = [self.countryToPlace allKeys];
    return [countries sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Place" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Place"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *country = [[self sortedCountryKeys] objectAtIndex:indexPath.section];
    NSArray *places = [self.countryToPlace objectForKey:country];
    NSDictionary *place = [places objectAtIndex:indexPath.row];
    NSString *title = [place objectForKey:@"title"];
    NSString *subtitle = [place objectForKey:@"subtitle"];
    
    cell.textLabel.text = title;
    cell.detailTextLabel.text = subtitle;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSArray *sortedCountries = [self sortedCountryKeys];
    return [sortedCountries objectAtIndex:section];
}

- (void) downloadFlickrDataForPlace:(NSString *)placeId withController:(PhotoListTableViewController *)pltvc {
    [self.photosForSelectedPlace removeAllObjects];
    
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    NSURL *url = [[ff class] URLforPhotosInPlace:placeId maxResults:PHOTOS_PER_PLACE];
    
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
                        [self.photosForSelectedPlace addObjectsFromArray:photos];
                        pltvc.photos = self.photosForSelectedPlace;
                        [pltvc.spinner stopAnimating];
                    });
                }
            }
        }];
    [task resume];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
    
    NSString *country = [[self sortedCountryKeys] objectAtIndex:indexPath.section];
    NSArray *places = [self.countryToPlace objectForKey:country];
    NSDictionary *place = [places objectAtIndex:indexPath.row];
    NSString *placeId = [place objectForKey:@"placeId"];
    
    PhotoListTableViewController *pltvc = [segue destinationViewController];
    pltvc.placeId = placeId;
    [pltvc.spinner startAnimating];
    [self downloadFlickrDataForPlace:placeId withController:pltvc];
    
    if ([pltvc isKindOfClass: [PlaceTableViewController class]]) {
        // Set title
        UITableViewCell *selectedCell = [self.tableView cellForRowAtIndexPath:indexPath];
        pltvc.title = selectedCell.textLabel.text;
    }
}

@end







