//
//  LOCacheManager.h
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

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)
- (NSDictionary *) dictionaryByReplacingNullsWithNil;
- (NSDictionary *) nestedDictionaryByReplacingNullsWithNil;
@end

@interface LOCacheManager : NSObject

/**
 * method to return the shared instance of the class
 * @returns the shared instance
 **/
+ (LOCacheManager *)sharedManager;

/**
 * method to cache a received webservice response
 **/
-(void) cacheResponse:(id)responseDictOrArray withURL:(NSString *)url withParamsDict:(NSDictionary *)params;

/**
 * method to get a cached webservice response
 **/
-(id) getFromCacheWithURL:(NSString *)url withParamsDict:(NSDictionary *)params;

/**
 * method to get the key used when caching webservice response
 **/
-(NSString *) getCacheKeyForURL:(NSString *)url andParams:(NSDictionary *)params;

/**
 * method to cache a dictionary
 **/
-(void)cacheDict:(id)array withKey:(NSString *)savingKey;
//-(void)cacheDict:(id)array;
/**
 * method to get a dictionary from cache
 **/
-(id) getFromCacheWithKey:(NSString *)savingKey;


@end
