//
//  Region+Create.m
//  Top Regions
//
//  Created by Amy Bearman on 5/17/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "Region+Create.h"
#import "Photo.h"
#import "Photographer+Create.h"
#import "Region.h"

@implementation Region (Create)

+ (Region *)regionWithName:(NSString *)name inManagedObject:(NSManagedObjectContext *)context {
    
    Region *region = nil;
    
    if ([name length]) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Region"];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        
        NSError *error;
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || [matches count] > 1) {
            // handle error
        } else if (![matches count]) {
            region = [NSEntityDescription insertNewObjectForEntityForName:@"Region" inManagedObjectContext:context];
            region.name = name;
            region.numDifferentPhotographers = [NSNumber numberWithInt:1];
        } else {
            region = [matches lastObject];
            
            NSMutableSet *photographersForRegion = [[NSMutableSet alloc] init];
            for (Photo *photo in region.photos) {
                Photographer *photographer = photo.whoTook;
                [photographersForRegion addObject:photographer];
            }
            region.numDifferentPhotographers = [NSNumber numberWithInteger:[photographersForRegion count]];
        }
    }
    
    return region;
}

@end
