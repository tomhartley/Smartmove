//
//  THHouseDetailsController.h
//  Househunt
//
//  Created by Tom Hartley on 08/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface THHouseDetailsController : UIViewController {
    IBOutlet UISegmentedControl *bedrooms;
    IBOutlet UISegmentedControl *bathrooms;
    IBOutlet UISegmentedControl *flatOrHouse;
    IBOutlet UISlider *budget;
    IBOutlet UILabel *budgetLabel;
}

-(IBAction)close;
-(IBAction)dataUpdated;
@end
