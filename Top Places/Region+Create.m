//
//  Region+Create.m
//  Top Regions
//
//  Created by Amy Bearman on 5/17/14.
//  Copyright (c) 2014 Amy Bearman. All rights reserved.
//

#import "Region+Create.h"

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
            // set numPhotographersTakenPhoto here?
        } else {
            region = [matches lastObject];
        }
    }
    
    return region;
}

@end
