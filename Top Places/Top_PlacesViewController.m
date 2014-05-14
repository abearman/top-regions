//
//  Top_PlacesViewController.m
//  Top Places
//
//  Created by Amy Bearman on 5/9/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "Top_PlacesViewController.h"
#import "FlickrFetcher.h"

@interface Top_PlacesViewController ()

@end

@implementation Top_PlacesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    FlickrFetcher *ff = [[FlickrFetcher alloc] init];
    NSURL *url = [[ff class] URLforTopPlaces];
    NSData *data = [NSData dataWithContentsOfURL:url];
    NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    NSDictionary *places = [results valueForKeyPath:@"places.place"];
    
    for (id key in places) {
        id value = [places objectForKey:key];
    }
}


@end
