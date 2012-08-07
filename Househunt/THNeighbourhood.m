//
//  THNeighbourhood.m
//  Househunt
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THNeighbourhood.h"

#import "SimpleKML.h"
#import "SimpleKMLContainer.h"
#import "SimpleKMLDocument.h"
#import "SimpleKMLFeature.h"
#import "SimpleKMLPlacemark.h"
#import "SimpleKMLPolygon.h"
#import "SimpleKMLLinearRing.h"

@implementation THNeighbourhood
@synthesize ID, crimeIndex, polygon;

- (id) initWithID:(NSString *)neighbourhoodID {
    // grab the  KML file
    self = [super init];
    if (self) {
        SimpleKML *kml = [SimpleKML KMLWithContentsOfFile:[[NSBundle mainBundle] pathForResource:neighbourhoodID ofType:@"kml"] error:NULL];
        
        // look for a document feature in it per the KML spec

        if (kml.feature && [kml.feature isKindOfClass:[SimpleKMLDocument class]])
        {
            // see if the document has features of its own
            for (SimpleKMLFeature *feature in ((SimpleKMLContainer *)kml.feature).features) {
                if ([feature isKindOfClass:[SimpleKMLPlacemark class]] && ((SimpleKMLPlacemark *)feature).polygon) {
                    
                    SimpleKMLPolygon *simplePolygon = (SimpleKMLPolygon *)((SimpleKMLPlacemark *)feature).polygon;
                    
                    SimpleKMLLinearRing *outerRing = simplePolygon.outerBoundary;
                    
                    CLLocationCoordinate2D points[[outerRing.coordinates count]];
                    NSUInteger i = 0;
                    
                    for (CLLocation *coordinate in outerRing.coordinates)
                        points[i++] = coordinate.coordinate;
                    
                    // create a polygon annotation for it
                    polygon = [MKPolygon polygonWithCoordinates:points count:[outerRing.coordinates count]];
                }
            }
        }
    }
    return self;
}

@end
