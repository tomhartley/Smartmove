//
//  THHoodDataController.h
//  Househunt
//
//  Created by Tom Hartley on 10/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartView.h"

@interface THHoodDataController : UIViewController {
    NSDictionary *dataFromAPI;
    IBOutlet PieChartView *chartView;
    
    IBOutlet UIView *viewBurglary;
    IBOutlet UIView *viewAntisocialBehaviour;
    IBOutlet UIView *viewRobbery;
    IBOutlet UIView *viewVehicleCrime;
    IBOutlet UIView *viewViolentCrime;
    IBOutlet UIView *viewOther;
    IBOutlet UIView *viewShoplifting;
    IBOutlet UIView *viewCriminalDamage;
    IBOutlet UIView *viewOtherTheft;
    IBOutlet UIView *viewDrugs;
    IBOutlet UIView *viewPublicDisorder;
    
    IBOutlet UILabel *borough;
    IBOutlet UILabel *totalCrimes;
    IBOutlet UILabel *unemployment;
    IBOutlet UILabel *housePrice;
}

@property (nonatomic) NSDictionary *dataFromAPI;

-(void)reloadDataFromDict;
-(IBAction) dismissModal;

@end
