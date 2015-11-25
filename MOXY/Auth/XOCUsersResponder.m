//
//  XOCUsersResponder.m
//  Xocolatl
//
//  Created by Fernando Olivares on 5/6/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import "XOCUsersResponder.h"

#import "MOXYUser.h"
#import "YapDatabase.h"

@interface XOCUsersResponder ()

@property (nonatomic, strong, readwrite) MOXYModelObject *modelObject;

@end

@implementation XOCUsersResponder

@synthesize modelObject = _modelObject;

- (NSDictionary *)methods;
{
    return @{HTTPVerbGET: @"/api/users/:username"};
}

- (BOOL)isProtected:(NSString *)method;
{
    return YES;
}

- (XocolatlHTTPResponse *)responseForGETRequest:(HTTPMessage *)message
                            withParameters:(NSDictionary *)parameters;
{
    __block MOXYUser *modelObject;
    __block NSDictionary *modelObjectJSON;
    NSString *objectId = parameters[@"username"];
    
    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        //Only one record.
        modelObject = [MOXYUser objectWithIdentifier:objectId
                                   usingTransaction:transaction];
        modelObjectJSON = [modelObject jsonRepresentationUsingTransaction:transaction];
    }];
    
    //Did we fetch something from the database?
    if (!modelObjectJSON) {
        //Nope. Send an error.
        return [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode404NotFound
                                                    reason:@"User not found."];
    }
    
    //We fetched one entry.
    self.modelObject = modelObject;
    return [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode200OK
                                            andBody:modelObjectJSON];
}

@end
