//
//  CFProductManager.m
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

#import "CFProductManager.h"
#import "AFNetworking.h"
#import "CFConstants.h"


@implementation CFProductManager


static CFProductManager *sharedProductManager = nil;

+ (CFProductManager *)sharedManager {
    @synchronized(self) {
        if (sharedProductManager == nil) {
            sharedProductManager = [[self alloc] init];
        }
    }
    return sharedProductManager;
}



-(void)getProductsByEAN:(NSString *)productEAN successBlock:(void (^)(NSDictionary *))success failureBlock:(void (^)(NSError *, int, NSString *))failure {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [[manager requestSerializer] setAuthorizationHeaderFieldWithUsername:kCFWebServiceUsername password:kCFWebServicePassword];
    
    // manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    NSMutableURLRequest *request = [manager.requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:[kCFWebServicesProductsHostName stringByAppendingString:productEAN]relativeToURL:manager.baseURL] absoluteString] parameters:nil error:nil];
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSLog(@"response %@",responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        failure(error, 0, nil);
        
    }];
    [manager.operationQueue addOperation:operation];
    
}
@end
