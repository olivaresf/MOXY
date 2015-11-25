//
//  DatabaseResponder.h
//  Xocolatl
//
//  Created by Fernando Olivares on 5/2/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import <XocolatlFramework/XocolatlFramework.h>

@class MOXYUser;
@class MOXYHTTPServer;
@class YapDatabaseConnection;

@interface MOXYDatabaseResponder : XocolatlHTTPRoute

@property (nonatomic, strong, readonly) MOXYHTTPServer *server;
@property (nonatomic, strong, readonly) YapDatabaseConnection *readConnection;
@property (nonatomic, strong, readonly) YapDatabaseConnection *writeConnection;

@property (nonatomic, strong, readonly) MOXYUser *user;

- (instancetype)initWithReadConnection:(YapDatabaseConnection *)readConnection
                    andWriteConnection:(YapDatabaseConnection *)writeConnection
                              inServer:(MOXYHTTPServer *)server;

// Authentication
- (BOOL)isProtected:(NSString *)method;
- (BOOL)isRequestAuthenticated:(HTTPMessage *)request;
- (XocolatlHTTPResponse *)handleAuthenticationFailure;

@end