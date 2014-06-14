//
//  JSONCache.h
//  DestinoRS
//
//  Created by Marcelo Alves Rezende on 13/06/14.
//  Copyright (c) 2014 PROCERGS. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONCache : NSObject

@property (strong, nonatomic) NSString *url;
@property BOOL readFromServer;
@property NSUInteger timeout; // em minutos

- (id) initWithUrl:(NSString*)url;
- (void) execute;
- (void) refresh;
- (id) json;

@end
