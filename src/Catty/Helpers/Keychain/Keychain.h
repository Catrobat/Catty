//
//  Keychain.h
//
//  Wrapper Class for Keychain access
//
//  Code from http://hayageek.com/ios-keychain-tutorial/
//  Included on April 15 2015
//

#import <Foundation/Foundation.h>

@interface Keychain : NSObject
{
    NSString * service;
    NSString * group;
}
-(id) initWithService:(NSString *) service_ withGroup:(NSString*)group_;

-(BOOL) insert:(NSString *)key : (NSData *)data;
-(BOOL) update:(NSString*)key :(NSData*) data;
-(BOOL) remove: (NSString*)key;
-(NSData*) find:(NSString*)key;
@end



/*  Usage:
 
 INIT:
 
 #define SERVICE_NAME @"ANY_NAME_FOR_YOU"
 #define GROUP_NAME @"YOUR_APP_ID.com.apps.shared" //GROUP NAME should start with application identifier.
 
 Keychain * keychain =[[Keychain alloc] initWithService:SERVICE_NAME withGroup:nil];
 
 
 
 Add Item:
 
 NSString *key =@"YOUR_KEY";
 NSData * value = [@"YOUR_DATA" dataUsingEncoding:NSUTF8StringEncoding];
 
 if([keychain insert:key :value])
 {
 NSLog(@"Successfully added data");
 }
 else
 NSLog(@"Failed to  add data");
 
 
 
 Find Item:
 
 NSString *key= @"YOUR_KEY";
 NSData * data =[keychain find:key];
 if(data == nil)
 {
 NSLog(@"Keychain data not found");
 }
 else
 {
 NSLog(@"Data is =%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
 }
 
 
 
 Update Item:
 
 NSString *key =@"YOUR_KEY";
 NSData * value = [@"NEW_VALUE" dataUsingEncoding:NSUTF8StringEncoding];
 
 if([keychain update:key :value])
 {
 NSLog(@"Successfully updated data");
 }
 else
 NSLog(@"Failed to  add data");
 
 
 
 Remove Item:
 
 NSString *key =@"YOUR_KEY";
 if([keychain remove:key])
 {
 NSLog(@"Successfully removed data");
 }
 else
 {
 NSLog(@"Unable to remove data");
 }
 
 
 
 */
