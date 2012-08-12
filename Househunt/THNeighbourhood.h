//
//  THNeighbourhood.h
//  Smartmove
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface THNeighbourhood : NSObject {
    NSString *ID;
    float crimeIndex;
    float unemploymentIndex;
    
    MKPolygon *polygon;
}

- (id) initWithID:(NSString *)neighbourhoodID coordinates:(NSArray *)coords;

@property (nonatomic, readonly) NSString *ID;
@property (nonatomic, readonly) MKPolygon *polygon;
@property (nonatomic) float crimeIndex;

@end
