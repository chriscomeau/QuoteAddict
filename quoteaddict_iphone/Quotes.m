//
//  Quotes.m
//  test1
//
//  Created by Chris Comeau on 28/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Quotes.h"

static sqlite3_stmt *init_statement = nil;

@implementation Quotes
@synthesize primaryKey,rowId, text, quote, author1, author2, categories, isNew;
@synthesize name,description;

- (id)initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db
{
	//printf("initWithPrimaryKey: \n");
	
	if(self = [super init])
	{
		primaryKey = pk;
		database = db;
		
		if(init_statement == nil)
		{
			const char *sql = "SELECT id, quote, author1, author2, categories, new from quotes where id=?";
			if(sqlite3_prepare_v2(database, sql, -1, &init_statement, NULL) != SQLITE_OK)
			{
				NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
			}
		}
		
		sqlite3_bind_int(init_statement, 1, primaryKey);
		if(sqlite3_step(init_statement) == SQLITE_ROW)
		{
			//self.text = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			
            self.rowId = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 0)];
			self.quote = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 1)];
			self.author1 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 2)];
			self.author2 = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 3)];
			self.categories = [NSString stringWithUTF8String:(char *)sqlite3_column_text(init_statement, 4)];
			self.isNew = sqlite3_column_int(init_statement, 5);
		}
		else
		{
			//self.text = @"Nothing;";
			self.rowId = @"Nothing;";
			self.quote = @"Nothing;";
			self.author1 = @"Nothing;";
			self.author2 = @"Nothing;";
			self.categories = @"Nothing;";
			self.isNew = 0;
		}
		
		//printf("%s\n", [self.text cString]); 
		//NSLog(@"%@", self.quote);

		
		sqlite3_reset(init_statement);
	}
	
	
	return self;
}

-(id)initWithName: (NSString*)n description:(NSString*)desc
{
	self.name = n;
	self.description = desc;
	return self;
}

@end
