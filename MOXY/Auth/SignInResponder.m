//
//  LoginRoute.m
//  Xocolatl
//
//  Created by Fernando Olivares on 4/28/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import "SignInResponder.h"

#import "MOXYUser.h"
#import "YapDatabase.h"

#import "NSError+XocolatlHTTPError.h"

@implementation SignInResponder

- (NSDictionary *)methods;
{
    return @{HTTPVerbPOST: @"/api/signin"};
}

- (NSObject <HTTPResponse> *)responseForPOSTRequest:(HTTPMessage *)message
                                     withParameters:(NSDictionary *)parameters;
{
    // Attempt to log in the user with the given credentials.
    NSString *username = message.parsedBody[@"username"];
    NSString *password = message.parsedBody[@"password"];
    
    if (!username || username.length <= 0 || !password || password.length <= 0)
    {
        return [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode400BadRequest
                                                 reason:@"Missing username or password"];
    }
    
    __block MOXYUser *registeredUser;
    __block NSString *authorization;
    __block NSError *error;
    __block NSDictionary *registeredUserJSON;
    [self.writeConnection readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        // Let's see if this user exists.
        MOXYUser *fetchedUser = [MOXYUser objectWithIdentifier:username
                                            usingTransaction:transaction];
        
        if (!fetchedUser)
        {
            // User is not registered.
            error = [NSError errorWithHTTPCode:XocolatlHTTPStatusCode404NotFound
                                     andReason:@"The requested user is not registered."];
            return;
        }
        
        // The user exists. Is the password valid?
        if (![MOXYUser verifyPasswordHashForUser:fetchedUser
                                        withPassword:password])
        {
            //Nope. Invalid password.
            error = [NSError errorWithHTTPCode:XocolatlHTTPStatusCode400BadRequest
                                     andReason:@"That password is not valid for the given username."];
            return;
        }
        
        // The password is valid. Create an auth string and return the user.
        registeredUser = fetchedUser;
        authorization = [fetchedUser newAuthHeaderWithDefaultExpiration];
        NSAssert(authorization, @"Auth should never be null");
        
        // Save the user.
        [fetchedUser saveUsingTransaction:transaction];
        registeredUserJSON = [registeredUser jsonRepresentationUsingTransaction:transaction];
    }];
    
    if (!registeredUser)
    {
        return [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode404NotFound
                                                 reason:@"The requested user is not registered."];
    }
    
    if (error)
    {
        return [XocolatlHTTPResponse responseWithStatus:error.code
                                                 reason:error.reason];
    }
    
    // Now that we have all the info, add our cookies and redirect the user back to home.
    NSMutableDictionary *dictionaryWithAuth = [registeredUserJSON mutableCopy];
    dictionaryWithAuth[@"auth"] = authorization;
    dictionaryWithAuth[@"username"] = registeredUser.username;
    XocolatlHTTPResponse *response = [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode200OK
                                                                      andBody:dictionaryWithAuth];
    
    [response setCookieNamed:@"username"
                   withValue:registeredUser.username
                    isSecure:YES
                    httpOnly:NO];
    
    [response setCookieNamed:@"auth"
                   withValue:authorization
                    isSecure:YES
                    httpOnly:NO];
    
    return response;
}

@end
