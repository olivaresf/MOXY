//
//  SignUpRoute.h
//  Xocolatl
//
//  Created by Fernando Olivares on 4/28/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import "MOXYDatabaseResponder.h"

@interface SignUpResponder : MOXYDatabaseResponder

@property (nonatomic) Class userClass;

- (instancetype)initWithReadConnection:(YapDatabaseConnection *)readConnection
                    andWriteConnection:(YapDatabaseConnection *)writeConnection
                              inServer:(MOXYHTTPServer *)server
                         withUserClass:(Class)userClass;

- (void)willSaveUser:(MOXYUser *)user
    usingRequestBody:(id)body;

@end

@interface XocolatlHTTPResponse (SignUpResponder)

@property (nonatomic, strong) MOXYUser *registeredUser;

@end