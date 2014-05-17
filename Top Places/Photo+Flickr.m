//
//  Photo+Flickr.m
//  Top Regions
//
//  Created by Amy Bearman on 5/17/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+Create.h"

@implementation Photo (Flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context {
    Photo *photo = nil;
    
    NSString *unique = [photoDictionary valueForKeyPath:FLICKR_PHOTO_ID];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (error || !matches || ([matches count] > 1)) {
        // handle error
    } else if (![matches count]) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                              inManagedObjectContext:context];
        photo.unique = unique;
        photo.title = [photoDictionary valueForKeyPath:FLICKR_PHOTO_TITLE];
        photo.subtitle = [photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION];
        photo.photoURL = [[FlickrFetcher URLforPhoto:photoDictionary
                                              format:FlickrPhotoFormatLarge] absoluteString];
        NSString *photographerName = [photoDictionary valueForKeyPath:FLICKR_PHOTO_OWNER];
        photo.whoTook = [Photographer photographerWithName:photographerName
                                    inManagedObjectContext:context];
    } else {
        photo = [matches firstObject];
    }
    
    return photo;
}


@end
