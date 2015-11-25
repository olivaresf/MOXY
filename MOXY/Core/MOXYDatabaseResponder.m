//
//  DatabaseResponder.m
//  Xocolatl
//
//  Created by Fernando Olivares on 5/2/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import "MOXYDatabaseResponder.h"

#import "YapDatabase.h"
#import "MOXYHTTPServer.h"
#import "MOXYUser.h"

@interface MOXYDatabaseResponder ()

@property (nonatomic, strong, readwrite) MOXYUser *user;
@property (nonatomic, strong, readwrite) MOXYHTTPServer *server;
@property (nonatomic, strong, readwrite) YapDatabaseConnection *readConnection;
@property (nonatomic, strong, readwrite) YapDatabaseConnection *writeConnection;

@end

@implementation MOXYDatabaseResponder

- (instancetype)initWithReadConnection:(YapDatabaseConnection *)readConnection
                    andWriteConnection:(YapDatabaseConnection *)writeConnection
                              inServer:(XocolatlHTTPServer *)server;
{
    if (self != [super init]) {
        return nil;
    }
    
    //Make sure our connections are read and readwrite.
    _readConnection = readConnection;
    _readConnection.permittedTransactions = YDB_AnyReadTransaction;
    
    _writeConnection = writeConnection;
    _writeConnection.permittedTransactions = YDB_AnyReadWriteTransaction;
    
    _server = (MOXYHTTPServer *)server;
    
    return self;
}

#pragma mark - Authentication
- (XocolatlHTTPResponse *)responseForRequest:(HTTPMessage *)message
                              withParameters:(NSDictionary *)parameters;
{
    if ([self isProtected:message.method] && ![self isRequestAuthenticated:message]) {
        return [self handleAuthenticationFailure];
    }
    
    return [super responseForRequest:message
                      withParameters:parameters];
}

- (BOOL)isRequestAuthenticated:(HTTPMessage *)request;
{
    NSString *username = request.cookies[@"username"];
    NSString *auth = request.cookies[@"auth"];
    if (!username || username.length <= 0 ||
        !auth || auth.length <= 0) {
        // No user or authorization.
        return NO;
    }
    
    // There appears to be user, expiration and authorization. Is the auth valid?
    __block MOXYUser *user;
    __block BOOL isValidAuth;
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        user = [MOXYUser objectWithIdentifier:username
                            usingTransaction:transaction];
        
        isValidAuth = [user validateAuthHeader:auth];
    }];

    // Save the user and affirm authorization.
    self.user = (isValidAuth) ? user : nil;
    
    return isValidAuth;
}

- (BOOL)isProtected:(NSString *)method;
{
    return NO;
}

- (XocolatlHTTPResponse *)handleAuthenticationFailure;
{
    return [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode403Forbidden
                                             reason:@"You are not authorized."];
}

@end