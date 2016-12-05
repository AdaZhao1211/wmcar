//
//  Model.h
//  wmcar
//
//  Created by Ada on 11/28/16.
//  Copyright © 2016 Ada. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Model : NSObject

@property (nonatomic, assign) BOOL thisCity;
@property (nonatomic, assign) BOOL thisMulti;
@property (strong, nonatomic) NSString *thisCar;
@property (strong, nonatomic) NSString *thisFloor;
@property (strong, nonatomic) NSString *thisNumber;

@end
