//
//  CFDepositCenterManager.m
//  CheckFood
//
//  Copyright 2014 5emeGauche
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "CFDepositCenterManager.h"
#import "AFNetworking.h"
#import "CFConstants.h"

@implementation CFDepositCenterManager


static CFDepositCenterManager *sharedDepositCenterManager = nil;

+ (CFDepositCenterManager *)sharedManager {
    @synchronized(self) {
        if (sharedDepositCenterManager == nil) {
            sharedDepositCenterManager = [[self alloc] init];
        }
    }
    return sharedDepositCenterManager;
}


-(void)getAllDepositCenter:(void (^)(NSArray *))success failureBlock:(void (^)(NSError *, int, NSString *))failure {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:kCFWebServiceUsername password:kCFWebServicePassword];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:kCFWebServicesDepositeCenterHostName relativeToURL:manager.baseURL] absoluteString] parameters:nil error:nil];

    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSLog(@"response %@",responseObject);
        
       if ([responseObject isKindOfClass:[NSArray class]]) {
            success(responseObject);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    
        failure(error, 0, [error localizedDescription]);

    }];
    [manager.operationQueue addOperation:operation];
    
}



@end
