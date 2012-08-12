//
//  THCustomPointAnnotation.h
//  Smartmove
//
//  Created by Tom Hartley on 09/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {
    THPropertyTypeHouse,
    THPropertyTypeFlat,
    THPropertyTypeUndefined
} THPropertyType;

@interface THCustomPointAnnotation : MKPointAnnotation
@property (nonatomic) NSString *urlToShow;
@property (nonatomic) NSDictionary *dataDict;
@property THPropertyType propertyType;
@end
