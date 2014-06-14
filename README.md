JSONCache
=========

Local cache and remote JSON request for iOS

How it works?
-------------
This component implements a cache in requests that retrieve JSON structures. It works by checking if the file exists locally and is not expired, otherwise it runs the remote request.

Usage
-----

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
