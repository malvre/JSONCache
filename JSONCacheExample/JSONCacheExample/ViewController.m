//
//  ViewController.m
//  JSONCacheExample
//
//  Created by Marcelo Rezende on 13/06/14.
//  Copyright (c) 2014 Marcelo Rezende. All rights reserved.
//

#import "ViewController.h"
#import "JSONCache.h"

@interface ViewController ()

@end

@implementation ViewController

NSArray *list;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    JSONCache *cache = [[JSONCache alloc] initWithUrl:@"http://datapoa.com.br/api/3/action/package_list"];
	cache.timeout = 1; // 1 minute
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[cache execute];
		dispatch_async(dispatch_get_main_queue(), ^{
			NSDictionary *json = [cache json];
			list = [json objectForKey:@"result"];
            [self.tableView reloadData];
		});
	});
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return list.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
	
	if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
	cell.textLabel.text = [list objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
