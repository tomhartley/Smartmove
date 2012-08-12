//
//  THFlipsideViewController.h
//  Smartmove
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class THFlipsideViewController;

@protocol THFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(THFlipsideViewController *)controller;
- (void)flipsideViewControllerDidUpdate:(THFlipsideViewController *)controller;
- (void)performSelectorInBackground:(SEL)selector withObject:(id)object;
@end

@interface THFlipsideViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *tableView;
    NSMutableArray *userPreferences;
    NSMutableDictionary *enabledRows;
    int numberOfDisabledRows;
}


@property (weak, nonatomic) id <THFlipsideViewControllerDelegate> delegate;
@property (nonatomic, readonly) NSMutableArray *userPreferences;
@property (nonatomic, readonly) NSMutableDictionary *enabledRows;

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath;
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath;

-(IBAction)openDetailsController;

@end
