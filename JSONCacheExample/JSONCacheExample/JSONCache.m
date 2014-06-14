//
//  JSONCache.m
//  DestinoRS
//
//  Created by Marcelo Alves Rezende on 13/06/14.
//  Copyright (c) 2014 PROCERGS. All rights reserved.
//
//
//
//
//  Usage :
//
//  JSONCache *cacheNews = [JSONCache alloc] initWithURL: @"http://domain.com/api/news"];
//  cacheNews.timeout = 60;
//  NSDictionary *obj = [cacheNews execute];
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
		NSLog(@"Execute - arquivo não existe");
		[self download];
		self.readFromServer = YES;
	} else {
		NSLog(@"Execute - arquivo existe");
		if ([self isExpired]) {
			NSLog(@"Execute - e está expirado");
			[self download];
			self.readFromServer = YES;
		} else {
			NSLog(@"Execute - e é válido");
			self.readFromServer = NO;
		}
	}
}



- (void) refresh {
	[self download];
	self.readFromServer = YES;
}

- (id) json
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [self filenameFromUrl]];
	
	NSData* data = [NSData dataWithContentsOfFile:filePath];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
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
	
	NSLog(@"Iniciando download da URL %@", self.url);
	
	NSURL  *url = [NSURL URLWithString:self.url];
	NSData *urlData = [NSData dataWithContentsOfURL:url];
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,[self filenameFromUrl]];
	[urlData writeToFile:filePath atomically:YES];
	NSLog(@"Gravando com o nome %@", filePath);
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *now = [NSString stringWithFormat:@"%f", [NSDate timeIntervalSinceReferenceDate]+(self.timeout*60)];
	[defaults setValue:now forKey:[NSString stringWithFormat:@"%@_expires", [self filenameFromUrl]]];
	[defaults synchronize];
	NSLog(@"Finalizou download e guardou data de expiração: %@", now);

	
}


- (BOOL) isExpired
{
	NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSTimeInterval expires = [[defaults valueForKey:[NSString stringWithFormat:@"%@_expires", [self filenameFromUrl]]] doubleValue];
	
	NSLog(@"Now: %f, Before: %f, Diff: %f", now, expires, now-expires);
	
	return now > expires;
}

@end
