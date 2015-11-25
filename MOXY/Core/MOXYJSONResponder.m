//
//  XocolatlResponder.m
//  Xocolatl
//
//  Created by Fernando Olivares on 5/6/15.
//  Copyright (c) 2015 Quetzal. All rights reserved.
//

#import "MOXYJSONResponder.h"

#import "YapDatabase.h"

@interface MOXYJSONResponder ()

@property (nonatomic, copy, readwrite) NSArray *modelObjects;
@property (nonatomic, strong, readwrite) MOXYModelObject *modelObject;

@end

@implementation MOXYJSONResponder

+ (Class)modelClass;
{
    return [MOXYModelObject class];
}

- (XocolatlHTTPResponse *)responseForGETRequest:(HTTPMessage *)message
                            withParameters:(NSDictionary *)parameters;
{
    __block MOXYModelObject *modelObject;
    __block NSDictionary *modelObjectJSON;
    __block NSMutableArray *modelObjects = [NSMutableArray new];
    __block NSArray *modelObjectsJSON;
    NSString *objectId = parameters[@"id"];

    [self.readConnection readWithBlock:^(YapDatabaseReadTransaction *transaction) {
        //Are we fetching one record or all records?
        if (objectId && objectId.length > 0) {
            //Only one record.
            modelObject = [[[self class] modelClass] objectWithIdentifier:parameters[@"id"]
                                                         usingTransaction:transaction];
            modelObjectJSON = [modelObject jsonRepresentationUsingTransaction:transaction];
        } else {
            //All records.
            [modelObjects addObjectsFromArray:[[[self class] modelClass] allObjectsUsingTransaction:transaction]];
            
            NSMutableArray *fetchedObjectsJSON = [NSMutableArray new];
            [modelObjects enumerateObjectsUsingBlock:^(MOXYModelObject *fetchedModelObject, NSUInteger idx, BOOL *stop) {
                [fetchedObjectsJSON addObject:[fetchedModelObject jsonRepresentationUsingTransaction:transaction]];
            }];
            
            modelObjectsJSON = fetchedObjectsJSON;
        }
    }];
    
    //What did we fetch?
    if (objectId) {
        
        //Did we fetch something from the database?
        if (!modelObjectJSON) {
            //Nope. Send an error.
            return [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode404NotFound
                                                        reason:@"Object Not Found"];
        }
        
        //We fetched one entry.
        self.modelObject = modelObject;
        return [XocolatlHTTPResponse responseWithStatus:200
                                                andBody:modelObjectJSON];
    } else {
        //We fetched multiple entries. Can we transform their JSON in data?
        self.modelObjects = modelObjects;
        
        NSError *jsonError;
        NSData *modelObjectsJSONData = [NSJSONSerialization dataWithJSONObject:modelObjectsJSON
                                                                       options:0
                                                                         error:&jsonError];
        if (jsonError) {
            //We couldn't transform it to data.
            return [XocolatlHTTPResponse responseWithStatus:XocolatlHTTPStatusCode500ServerError
                                                        reason:@"Could not get JSON for this object"];
        }
        
        return [XocolatlHTTPResponse responseWithStatus:200
                                                andData:modelObjectsJSONData];
    }
}

@end
