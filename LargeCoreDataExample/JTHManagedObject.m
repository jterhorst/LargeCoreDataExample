//
//  JTHManagedObject.m
//  LargeCoreDataExample
//
//  Created by Jason Terhorst on 12/7/13.
//  Copyright (c) 2013 Jason Terhorst. All rights reserved.
//

#import "JTHManagedObject.h"

#import "JTHDataManager.h"

@implementation JTHManagedObject

+ (JTHManagedObject *)createOrUpdateWithDictionary:(NSDictionary *)dictionary withContext:(NSManagedObjectContext *)context
{
	/*
	NSFetchRequest * objectFetch = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
	*/
	NSString * primaryKeyElement = [[self class] primaryKeyElementName];
	NSString * primaryKeyProperty = [[self class] primaryKeyPropertyName];

	id primaryKeyValue = [dictionary objectForKey:primaryKeyElement];
	/*
	[objectFetch setPredicate:[NSPredicate predicateWithFormat:@"%K == %@", primaryKeyProperty, primaryKeyValue]];
	*/
	JTHManagedObject * foundObject = nil;//[[context executeFetchRequest:objectFetch error:nil] lastObject];
	if (!foundObject)
	{
		foundObject = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
		[foundObject setPrimitiveValue:primaryKeyValue forKey:primaryKeyProperty];
	}

	[foundObject updatePropertiesWithDictionary:dictionary];

	return foundObject;
}

- (void)updatePropertiesWithDictionary:(NSDictionary *)dictionary
{
	for (id attributeElementKey in [[[self class] mappableAttributes] allKeys])
	{
		NSString * matchingProperty = [[[self class] mappableAttributes] objectForKey:attributeElementKey];

		if ([dictionary objectForKey:attributeElementKey])
		{
			id matchingAttributeValue = [dictionary objectForKey:attributeElementKey];
			matchingAttributeValue = [self _transformObject:matchingAttributeValue forAttributeWithName:matchingProperty];

			[self setPrimitiveValue:matchingAttributeValue forKey:matchingProperty];
		}
	}
}

- (id)_transformObject:(id)object forAttributeWithName:(NSString *)attributeName
{
	if (![object isKindOfClass: [self _expectedDataTypeForPropertyName:attributeName]])
	{
		if ([self _expectedDataTypeForPropertyName:attributeName] == [NSString class])
		{
			if ([object isKindOfClass:[NSNumber class]])
			{
				return [object stringValue];
			}
			else
			{
				return [object description];
			}
		}
		else if ([self _expectedDataTypeForPropertyName:attributeName] == [NSNumber class])
		{
			if ([object isKindOfClass:[NSString class]])
			{
				return @([object floatValue]);
			}
		}
		else if ([self _expectedDataTypeForPropertyName:attributeName] == [NSDate class])
		{
			if ([object isKindOfClass:[NSString class]])
			{
				NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
				//[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
				[formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZZZZ"];
				[formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT"]];

				NSDate * convertedDate = [formatter dateFromString:object];

				return convertedDate;
			}
		}

		return nil;
	}

	return object;
}

- (Class)_expectedDataTypeForPropertyName:(NSString *)propertyName
{
	NSDictionary * attribDefinitions = [[self entity] attributesByName];
	NSAttributeDescription * attribDefinition = [attribDefinitions objectForKey:propertyName];

	switch ([attribDefinition attributeType]) {
		case NSInteger16AttributeType:
			return [NSNumber class];
			break;
		case NSInteger32AttributeType:
			return [NSNumber class];
			break;
		case NSInteger64AttributeType:
			return [NSNumber class];
			break;
		case NSDecimalAttributeType:
			return [NSNumber class];
			break;
		case NSDoubleAttributeType:
			return [NSNumber class];
			break;
		case NSFloatAttributeType:
			return [NSNumber class];
			break;
		case NSStringAttributeType:
			return [NSString class];
			break;
		case NSBooleanAttributeType:
			return [NSNumber class];
			break;
		case NSDateAttributeType:
			return [NSDate class];
			break;
		case NSBinaryDataAttributeType:
			return [NSData class];
			break;


		default:
			break;
	}

	return nil;
}

+ (NSString *)primaryKeyElementName
{
	return @"id";
}

+ (NSString *)primaryKeyPropertyName
{
	return @"remoteID";
}

+ (NSDictionary *)mappableAttributes
{
	return @{@"id": @"remoteID"};
}

+ (NSString *)entityName
{
	NSAssert(0 == 1, @"+entityName must be overridden by JTHManagedObject subclasses");
	return nil;
}

@end
