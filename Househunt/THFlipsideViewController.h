//
//  THFlipsideViewController.h
//  Househunt
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THFlipsideViewController;

@protocol THFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(THFlipsideViewController *)controller;
@end

@interface THFlipsideViewController : UIViewController

@property (weak, nonatomic) id <THFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
