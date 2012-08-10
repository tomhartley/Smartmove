//
//  THNeighbourhood.m
//  Househunt
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THNeighbourhood.h"

//#import <KML/KML.h>

@implementation THNeighbourhood
@synthesize ID, crimeIndex, polygon;

- (id) initWithID:(NSString *)neighbourhoodID coordinates:(NSArray *)coords {
    // grab the  KML file
    self = [super init];
    if (self) {
        ID = neighbourhoodID;
        
        CLLocationCoordinate2D points[[coords count]];
        NSUInteger i = 0;
        
        for (NSArray *coordinate in coords)
            points[i++] = CLLocationCoordinate2DMake([[coordinate objectAtIndex:0] doubleValue], [[coordinate objectAtIndex:1] doubleValue]);
        
        // create a polygon annotation for it
        polygon = [MKPolygon polygonWithCoordinates:points count:[coords count]];
        polygon.title = neighbourhoodID;
        
        /*KMLRoot *root = [KMLParser parseKMLAtPath:[[NSBundle mainBundle] pathForResource:neighbourhoodID ofType:@"kml"]];
        NSArray *coords = [[(KMLPolygon *)[(KMLPlacemark *)[[(KMLDocument *)[root feature] features] objectAtIndex:0] geometry] outerBoundaryIs] coordinates];
        CLLocationCoordinate2D points[[coords count]];
        NSUInteger i = 0;
        
        for (KMLCoordinate *coordinate in coords)
            points[i++] = CLLocationCoordinate2DMake(coordinate.latitude, coordinate.longitude);
        
        // create a polygon annotation for it
        polygon = [MKPolygon polygonWithCoordinates:points count:[coords count]];
         */
    }
    return self;
}

@end
