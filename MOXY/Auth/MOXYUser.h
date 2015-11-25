//
//  XOCUser.h
//  Xocolatl
//
//  Created by Fernando Olivares on 4/14/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import "MOXYModelObject.h"

@interface MOXYUser : MOXYModelObject

@property (nonatomic, copy, readonly) NSString *username;

/**
 *  This token is optionally used to send push notifications.
 */
@property (nonatomic, copy) NSString *apnToken;

//Self
+ (instancetype)newUserWithUsername:(NSString *)username
                        andPassword:(NSString *)password;

//Passwords
+ (BOOL)verifyPasswordHashForUser:(MOXYUser *)user
                     withPassword:(NSString *)password;

//Auth
- (NSString *)newAuthHeaderWithDefaultExpiration;
- (NSString *)newAuthHeaderWithTimeOfDeath:(NSTimeInterval)secondsUntilExpiration;
- (BOOL)validateAuthHeader:(NSString *)clientProvidedAuth;

@end
