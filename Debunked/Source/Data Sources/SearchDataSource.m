//  Copyright (c) 2009-2016 Robert Ruana <rob@robruana.com>
//
//  This file is part of Debunked.
//
//  Debunked is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  Debunked is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Debunked.  If not, see <http://www.gnu.org/licenses/>.

#import "SearchDataSource.h"

#import "SearchConsumer.h"
#import "SearchResultTableViewCell.h"

#import "RumorConsumer.h"
#import "RumorDataSource.h"


@implementation SearchDataSource

@synthesize searchResults;

- (void)dealloc
{
    [searchResults release];

    [super dealloc];
}

- (id) init
{
    if(self = [super init]) {
        lastRequestId = 0;
    }
    return self;
}

- (void)loadSearchResults:(NSMutableArray *)theSearchResults
{
	self.searchResults = theSearchResults;
}

- (SearchResult *)searchResultForIndex:(NSUInteger)theIndex
{
	if([searchResults count] > 0) {
		return [searchResults objectAtIndex:theIndex];
	} else {
		return nil;
	}
}

- (NSInteger)requestSearchResults:(NSString *)query notifyDelegate:(NSObject<SearchDelegate> *)theDelegate
{
	NSString *baseQuery = @"http://search.atomz.com/search/?sp-a=00062d45-sp00000000&sp-c=100&sp-q=";
	NSString *queryString = [[query componentsSeparatedByString:@" "] componentsJoinedByString:@"+"];
	NSString *fullQuery = [baseQuery stringByAppendingString:queryString];
	NSNumber *requestId = nil;
	@synchronized(self) {
		lastRequestId++;
		requestId = [NSNumber numberWithInteger:lastRequestId];
		
		SearchConsumer *consumer = [[SearchConsumer alloc] initWithDelegate:theDelegate 
																	 withDataSource:self
																			withUrl:fullQuery];
		NSArray *theRequest = [NSArray arrayWithObjects:
							   consumer, 
							   theDelegate, 
							   nil];
		[activeRequests setObject:theRequest forKey:requestId];
		
		CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
		[dataLoader addClientToDownloadQueue:consumer withExpiration:(60 * 10)]; // 10 minutes
		[consumer release];
	}
	return [requestId intValue];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SearchResultTableViewCell *cell = (SearchResultTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SearchResultTableViewCell"];
	if (cell == nil) {
		cell = [[[SearchResultTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SearchResultTableViewCell"] autorelease];
	}
	cell.searchResult = [self searchResultForIndex:indexPath.row];
	
	return cell;
}

- (void)doRequestItemForIndexPath:(NSIndexPath *)theIndexPath notifyDelegate:(NSObject<AsynchronousDelegate> *)theDelegate
{
	SearchResult *aSearchResult = [self searchResultForIndex:theIndexPath.row];	
	
	RumorConsumer *consumer = [[RumorConsumer alloc] initWithDelegate:(NSObject<RumorDelegate> *)theDelegate
													   withDataSource:(RumorDataSource *)self
															  withUrl:aSearchResult.url];	
	CachedDataLoader *dataLoader = [CachedDataLoader sharedDataLoader];
	[dataLoader addClientToDownloadQueue:consumer withExpiration:(60 * 10)]; // 10 minutes
	[consumer release];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [searchResults count];
}

@end
