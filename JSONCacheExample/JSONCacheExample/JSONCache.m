//
//
//  Created by Marcelo Alves Rezende on 13/06/14.
//  Copyright (c) 2014 Marcelo Rezende. All rights reserved.
//
//
//
//
//  Usage :
//
//  JSONCache *cacheNews = [JSONCache alloc] initWithURL: @"http://domain.com/api/news"];
//  cacheNews.timeout = 60;
//  [cacheNews execute];
//  NSDictionary *news = [cacheNews json];
//
//

#import "JSONCache.h"

@implementation JSONCache

- (id) initWithUrl:(NSString*)url {
	if (self == [super init]) {
		self.url = url;
		self.timeout = 30;
	}
	return self;
}

- (void) execute {
	if (![self fileExists]) {
		[self download];
		self.readFromServer = YES;
	} else {
		if ([self isExpired]) {
			[self download];
			self.readFromServer = YES;
		} else {
			self.readFromServer = NO;
		}
	}
}



- (void) refresh {
	if (!self.readFromServer) {
		[self download];
		self.readFromServer = YES;
	} else {
		self.readFromServer = NO;
	}
}

- (id) json
{
	id result = @{};
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [self filenameFromUrl]];
	
	NSData* data = [NSData dataWithContentsOfFile:filePath];
	if (data) {
    	__autoreleasing NSError* error = nil;
    	result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
		if (error != nil) {
			return @{};
		}
	}
	return result;
}





// private methods //////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)filenameFromUrl
{
	NSString *str = [self.url stringByReplacingOccurrencesOfString:@"/" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@"?" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@"&" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
	str = [str stringByReplacingOccurrencesOfString:@"." withString:@""];
	str = [str stringByAppendingString:@".json"];
	return str;
}


- (BOOL)fileExists
{
	NSString *path;
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	path = [documentsDirectory stringByAppendingPathComponent:[self filenameFromUrl]];
	return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (void) download
{
	
	NSURL  *url = [NSURL URLWithString:self.url];
	NSData *urlData = [NSData dataWithContentsOfURL:url];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[self filenameFromUrl]];
	[urlData writeToFile:filePath atomically:YES];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *now = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]+(self.timeout*60)];
	[defaults setValue:now forKey:[NSString stringWithFormat:@"%@_expires", [self filenameFromUrl]]];
	[defaults synchronize];
	
}


- (BOOL) isExpired
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSTimeInterval expires = [[defaults valueForKey:[NSString stringWithFormat:@"%@_expires", [self filenameFromUrl]]] doubleValue];
	
	return now > expires;
}

@end
