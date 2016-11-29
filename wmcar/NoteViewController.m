//
//  NoteViewController.m
//  wmcar
//
//  Created by Ada on 11/26/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import "NoteViewController.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)saveButton:(id)sender {
}
- (IBAction)cancelButton:(id)sender {
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"saveNote"]){
        NSLog(@"%@", _floorField.text);
        NSLog(@"%@", _numField.text);
        _model.thisNumber = _numField.text;
        _model.thisFloor = _floorField.text;
    }
}

@end
