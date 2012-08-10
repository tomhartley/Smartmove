//
//  THCustomPointAnnotation.h
//  Househunt
//
//  Created by Tom Hartley on 09/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface THCustomPointAnnotation : MKPointAnnotation
@property (nonatomic) NSString *urlToShow;
@property BOOL isHouse;
@end
