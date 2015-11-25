//
//  MOXYHTTPServer.h
//  MOXYServer
//
//  Created by Fernando Olivares on 5/6/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.

#import <XocolatlFramework/XocolatlFramework.h>

@class MOXYDatabaseResponder;
@class YapDatabase;
@class YapDatabaseConnection;
@class SignUpResponder;

@interface MOXYHTTPServer : XocolatlHTTPServer

/**
 *  Since the server is synchronous, we only provide one read and one write connection.
 */
@property (nonatomic, strong) YapDatabase *database;
@property (nonatomic, strong) YapDatabaseConnection *readConnection;
@property (nonatomic, strong) YapDatabaseConnection *writeConnection;

/**
 *  MOXYHTTPServer can only handle HTTPS connections. In order for the server to function correctly, you must provide a .p12 file (which contains your private key and its X.509 certificate. If you do not have one, you can use this convenience method to initialize a server using a provided self-signed certificate.
 *
 *  @param serverName This will be used to identify the server, its database and the server's document root.
 *  @param port The port you want the server to listen to.
 *
 *  @return a valid MOXYHTTPServer. Nil if the database cannot be instantiated.
 */
+ (instancetype)newServerNamed:(NSString *)serverName
               listeningAtPort:(NSInteger)port
                   withSiteURL:(NSString *)siteURL;

@property (nonatomic, copy, readonly) NSString *siteURL;

/**
 *  MOXYHTTPServer can only handle HTTPS connections. In order for the server to function correctly, you must provide a .p12 file (which contains your private key and its X.509 certificate. These types of files are password protected, so you must provide the password in order to extract the key and certificate.
 *
 *  @param serverName          This will be used to identify the server, its database and the server's document root.
 *  @param port                The port you want the server to listen to.
 *  @param p12CertificatePath  The path to the .p12 file.
 *  @param certificatePassword The password with which the .p12 file was encrypted
 *
 *  @return a valid MOXYHTTPServer. Nil if the database cannot be instantiated.
 */
+ (instancetype)newServerNamed:(NSString *)serverName
               listeningAtPort:(NSInteger)port
     usingSSLCertificateAtPath:(NSString *)p12CertificatePath
        andCertificatePassword:(NSString *)certificatePassword
                   withSiteURL:(NSString *)siteURL;

/**
 *  A MOXYHTTPServer provides routing to different paths in your server. All dynamic paths (e.g. /api/things) should be associated with a XocolatlHTTPRoute. You can do so by calling registerRoute:. Usually, however, these paths will want to authenticate the user and access the server's database in order to return information in the server's response. DatabaseRouteResponder is a convenience class that does cookie-based authentication and provides convenience methods for incoming requests. Since DatabaseRouteResponder requires repetitive initialization (every different responder must call initWithReadConnection:andWriteConnection:inServer: a convenience method is provided that does this initialization for you as long as routeClass is a subclass of DatabaseRoute.
 *
 *  @param routeClass A subclass of DatabaseRoute.
 */
- (void)addDatabaseRoute:(Class)routeClass;

/**
 *  A MOXYHTTPServer provides routing to different paths in your server. All dynamic paths (e.g. /api/things) should be associated with a RouteResponder. You can do so by calling registerRoute:. Creating users has its own convenience method because it involves creating objects that contain sensitive information (i.e. password hashes). Whenever a new user is created, the server will create an object of the given class, provided they are subclasses of XOCUser. You can find more about user creation by reading what SignUpResponder does.
 *
 *  @param signUpRouteClass A subclass of SignUpResponder or SignUpResponder itself.
 *  @param userClass        A subclass of XOCUser.
 */
- (void)setSignUpRoute:(Class)signUpRouteClass
         withUserClass:(Class)userClass;

@end
