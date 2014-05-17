//
//  Photo+Flickr.m
//  Top Regions
//
//  Created by Amy Bearman on 5/17/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Region+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo *photo = nil;
    
    // Fetch into the database to try to find this unique photo to see if already exists
    NSString *unique = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID]; // unique ID
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || error || ([matches count] > 1)) { // Error
        // handle error
    } else if ([matches count]) { // Found existing photo
        photo = [matches firstObject];
    } else { // [matches count] = 0; create a new object
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.photoURL = [[FlickrFetcher URLforPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        
        // Query Flickr again (off the main queue) to get the region info
        NSURL *placeInfoURL = [FlickrFetcher URLforInformationAboutPlace:FLICKR_PHOTO_PLACE_ID];
        NSString __block *regionName;
        
        NSURLRequest *request = [NSURLRequest requestWithURL:placeInfoURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        NSURLSessionTask *task = [session downloadTaskWithRequest:request
            completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                if (!error) {
                    if ([request.URL isEqual:placeInfoURL]) {
                        NSData *data = [NSData dataWithContentsOfURL:localfile];
                        NSDictionary *placeInfoDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        regionName = [FlickrFetcher extractRegionNameFromPlaceInformation:placeInfoDict];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            // Stuff to do on main queue
                        });
                    }
                }
            }];
        [task resume];
        
        // Loading a Photo causes a Region to be created
        photo.whereTaken = [Region regionWithName:regionName inManagedObject:context];
    }
    
    return photo;
}

+ (void)loadPhotosFromFlickrArray:(NSArray *)photos intoManagedObjectObjectContext:(NSManagedObjectContext *)context {
    
}


@end
