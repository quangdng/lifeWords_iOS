//
//  PPPageViewDetailController.m
//
//  Created by Thiên Phong on 24/7/12.
//  Copyright (c) 2012 simpleDudes. All rights reserved.
//

#import "PPPageViewDetailController.h"

@implementation PPPageViewDetailController
@synthesize tag;

/*
 This class is just an empty UIViewController to carry PPPageViewDetailWrapper for implementing UIPageViewController
 */

//This is mandatory
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
  return YES;
}

//iOS6
- (BOOL)shouldAutorotate
{
  return YES;
}

@end
