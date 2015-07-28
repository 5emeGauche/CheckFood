//
//  LOCacheManager.m
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

#import "LOCacheManager.h"

#define kLOCachePrefix @"LOCache_"
#define kLOCacheDatePrefix @"LOCacheDate_"


@implementation NSDictionary (Additions)

- (NSDictionary *) dictionaryByReplacingNullsWithNil {
    
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    const id nul = [NSNull null];
    
    for(NSString *key in replaced) {
        const id object = [self objectForKey:key];
        if(object == nul) {
            [replaced setValue:nil forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:replaced];
}

-(NSDictionary *) nestedDictionaryByReplacingNullsWithNil {
    NSMutableDictionary *replaced = [NSMutableDictionary dictionaryWithDictionary:self];
    const id nul = [NSNull null];
    const NSString *blank = @"";
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL *stop) {
        object = [self objectForKey:key];
        if([object isKindOfClass:[NSDictionary class]])
        {
            NSDictionary *innerDict = object;
            [replaced setObject:[innerDict nestedDictionaryByReplacingNullsWithNil] forKey:key];
            
        }
        else if([object isKindOfClass:[NSArray class]]){
            NSMutableArray *nullFreeRecords = [NSMutableArray array];
            for (id record in object) {
                
                if([record isKindOfClass:[NSDictionary class]])
                {
                    NSDictionary *nullFreeRecord = [record nestedDictionaryByReplacingNullsWithNil];
                    [nullFreeRecords addObject:nullFreeRecord];
                }
            }
            [replaced setObject:nullFreeRecords forKey:key];
        }
        else
        {
            if(object == nul) {
                [replaced setObject:blank forKey:key];
            }
        }
    }];
    
    return [NSDictionary dictionaryWithDictionary:replaced];
}
@end

@implementation LOCacheManager

static LOCacheManager *sharedCacheManager = nil;

+ (LOCacheManager *)sharedManager {
    @synchronized(self) {
        if (sharedCacheManager == nil) {
            sharedCacheManager = [[self alloc] init];
        }
    }
    return sharedCacheManager;
}

-(void) cacheResponse:(id)responseDict withURL:(NSString *)url withParamsDict:(NSDictionary *)params {
    NSString *savingKey = [self getCacheKeyForURL:url andParams:params];
    
    if (responseDict != nil) {
        [self cacheDict:responseDict withKey:savingKey];
    }
}

-(id) getFromCacheWithURL:(NSString *)url withParamsDict:(NSDictionary *)params {
    NSString *savingKey = [self getCacheKeyForURL:url andParams:params];
    return [self getFromCacheWithKey:savingKey];
}

-(NSString *) getCacheKeyForURL:(NSString *)url andParams:(NSDictionary *)params {
    NSString *savingKey = [NSString stringWithFormat:@"%@%@",kLOCachePrefix,url];
    NSArray *sortedKeys = [[params allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    for (NSString *key in sortedKeys) {
        if ([key isEqualToString:@"token"]) {
            //skip token
        } else {
            savingKey = [NSString stringWithFormat:@"%@_%@=%@",savingKey,key,params[key]];
        }
    }
    return savingKey;
}

-(void)cacheDict:(id)array withKey:(NSString *)savingKey
{
//    [[NSUserDefaults standardUserDefaults] setObject:[dict nestedDictionaryByReplacingNullsWithNil] forKey:savingKey];
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:savingKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(id) getFromCacheWithKey:(NSString *)savingKey {
    return [[NSUserDefaults standardUserDefaults] objectForKey:savingKey];
}



@end
