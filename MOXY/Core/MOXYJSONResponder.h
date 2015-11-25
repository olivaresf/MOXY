//
//  XocolatlResponder.h
//  Xocolatl
//
//  Created by Fernando Olivares on 5/6/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import "MOXYDatabaseResponder.h"
#import "MOXYModelObject.h"

@interface MOXYJSONResponder : MOXYDatabaseResponder

+ (Class)modelClass;

@property (nonatomic, copy, readonly) NSArray *modelObjects;
@property (nonatomic, strong, readonly) MOXYModelObject *modelObject;

@end
