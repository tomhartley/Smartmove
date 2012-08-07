//
//  THFlipsideViewController.m
//  Househunt
//
//  Created by Tom Hartley on 06/08/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "THFlipsideViewController.h"

@interface THFlipsideViewController ()

@end

@implementation THFlipsideViewController

@synthesize delegate = _delegate;
@synthesize userPreferences;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSMutableArray *arr = [[defaults objectForKey:@"userprefs"] mutableCopy];
        if (arr) {
            userPreferences = arr;
        } else {
            userPreferences = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:@"crime",@"unemployment",@"schools",@"prices", nil]];
        }
        [defaults setObject:userPreferences forKey:@"userprefs"];
        [defaults synchronize];
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
        numberOfDisabledRows = 0;
    }
    return self;
}
							
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [tableView setEditing:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"NEIN"];
    cell.showsReorderControl = YES;
    cell.imageView.image = [UIImage imageNamed:@"17-check"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    NSString *str = [userPreferences objectAtIndex:indexPath.row];
    if ([str isEqualToString:@"crime"]) {
        cell.textLabel.text = @"Crime Levels";
        cell.detailTextLabel.text = @"Number of crimes committed ";
    } else if ([str isEqualToString:@"unemployment"]) {
        cell.textLabel.text = @"Unemployment";
        cell.detailTextLabel.text = @"Number of unemployed people";
    } else if ([str isEqualToString:@"schools"]) {
        cell.textLabel.text = @"Schools";
        cell.detailTextLabel.text = @"Quality of education in area";
    } else {
        cell.textLabel.text = @"House prices";
        cell.detailTextLabel.text = @"Average house price";
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}


-(BOOL)tableView:(UITableView *)aTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.imageView.image isEqual:[UIImage imageNamed:@"17-blank"]]) {
        return NO;
    } else {
        //just got de-selected
        return YES;
    }
}

-(BOOL)tableView:(UITableView *)aTableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.imageView.image isEqual:[UIImage imageNamed:@"17-blank"]]) {
        return NO;
    } else {
        //just got de-selected
        return YES;
    }
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    NSString *stringToMove = [userPreferences objectAtIndex:sourceIndexPath.row];
    [userPreferences removeObjectAtIndex:sourceIndexPath.row];
    [userPreferences insertObject:stringToMove atIndex:destinationIndexPath.row];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userPreferences forKey:@"userprefs"];
    [defaults synchronize];
}

-(void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([cell.imageView.image isEqual:[UIImage imageNamed:@"17-blank"]]) {
        cell.imageView.image = [UIImage imageNamed:@"17-check"];
        cell.showsReorderControl = YES;
        [tableView moveRowAtIndexPath:indexPath toIndexPath:indexPath];
        numberOfDisabledRows -= 1;
        [tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:3-numberOfDisabledRows inSection:0]];
    } else {
        //just got de-selected
        cell.imageView.image = [UIImage imageNamed:@"17-blank"];
        cell.showsReorderControl = NO;
        [tableView moveRowAtIndexPath:indexPath toIndexPath:indexPath];
        [tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:3-numberOfDisabledRows inSection:0]];
        numberOfDisabledRows += 1;
    }
}

- (NSIndexPath *)tableView:(UITableView *)aTableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    if ([[[[tableView cellForRowAtIndexPath:proposedDestinationIndexPath] imageView] image] isEqual:[UIImage imageNamed:@"17-blank"]]) {
        return [NSIndexPath indexPathForRow:3-numberOfDisabledRows inSection:0];
    }
    return proposedDestinationIndexPath;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}
#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

@end
