//
//  MapViewController.m
//  wmcar
//
//  Created by Ada on 11/20/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController () <MKMapViewDelegate> {
    CLLocationManager *locationmanager;
}
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self customSetup];
    _city = NO;
    locationmanager = [CLLocationManager new];
    if([locationmanager respondsToSelector:@selector(requestWhenInUseAuthorization)]){
        [locationmanager requestWhenInUseAuthorization];
    }
    // Do any additional setup after loading the view.
}

- (void)customSetup
{
    _revealButtonItem.target = self.revealViewController;
    _revealButtonItem.action = @selector(revealToggle:);
    [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
}


@end
