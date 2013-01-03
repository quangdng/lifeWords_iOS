//
//  lifeWordsColorSelectViewController.m
//  lifeWords
//
//  Created by Thiên Phong on 1/2/13.
//  Copyright (c) 2013 simpleDudes. All rights reserved.
//

#import "lifeWordsColorSelectViewController.h"

@interface lifeWordsColorSelectViewController ()

@end

@implementation lifeWordsColorSelectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    color = [[NSMutableArray alloc] init];
    
    [color addObject:[NSArray arrayWithObjects:@"Blue Sky", nil]];
    [color addObject:[NSArray arrayWithObjects:@"Green Leaf", nil]];
    [color addObject:[NSArray arrayWithObjects:@"Indigo Horizon", nil]];
    [color addObject:[NSArray arrayWithObjects:@"Orange Sunset", nil]];
    [color addObject:[NSArray arrayWithObjects:@"Red Sunrise", nil]];
    [color addObject:[NSArray arrayWithObjects:@"Violet Silk", nil]];
    [color addObject:[NSArray arrayWithObjects:@"Yellow Autumn", nil]];

    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [color count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Color_Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [[color objectAtIndex:indexPath.row] objectAtIndex:0];
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *name = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ColorSelected" object:name];
}



@end
