#import <UIKit/UIKit.h>
#import <sqlite3.h>

//
//  Quotes.h
//  test1
//
//  Created by Chris Comeau on 28/04/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Quotes : NSObject
{
	sqlite3 *database;
	NSInteger primaryKey;
    
	NSString *rowId;
	NSString *text;
	NSString *quote;
	NSString *author1;
	NSString *author2;
	NSString *categories;
    NSInteger isNew;

	NSString *name;
	NSString *description;
}

@property (assign, nonatomic, readonly) NSInteger primaryKey;
@property (nonatomic, retain) NSString *rowId;
@property (nonatomic, retain) NSString *text;
@property (nonatomic, retain) NSString *quote;
@property (nonatomic, retain) NSString *author1;
@property (nonatomic, retain) NSString *author2;
@property (nonatomic, retain) NSString *categories;
@property (nonatomic, assign) NSInteger isNew;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *description;


- (id) initWithPrimaryKey:(NSInteger)pk database:(sqlite3 *)db;
- (id) initWithName:(NSString*)n description:(NSString *)desc;
@end
