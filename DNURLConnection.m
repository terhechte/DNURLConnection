//
//  DNURLConnection.m
//  MZ Proto
//
//  Created by Darren Ehlers on 8/3/13.
//  Copyright (c) 2013 DoubleNode.com. All rights reserved.
//

#import "DNURLConnection.h"

// Private hack stuff, because the Videro Server has a wrong certificate
@interface NSURLRequest (DummyInterface)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString*)host;
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString*)host;
@end

@implementation DNURLConnection

+ (id)connectionWithRequest:(NSURLRequest*)request
          completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    return [[DNURLConnection alloc] initWithRequest:request completionHandler:handler];
}

- (id)initWithRequest:(NSURLRequest*)request
    completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    self = [super init];
    
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:[request.URL host]];
    
#ifdef USE_HTTP_AUTH
    NSMutableURLRequest *theRequest = [request mutableCopy];
    NSString *authStr = [NSString stringWithFormat:@"%@:%@", SERVER_HOST_USER, SERVER_HOST_PASSWORD];
    NSData *authData = [authStr dataUsingEncoding:NSASCIIStringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64EncodedStringWithWrapWidth:80]];
    [theRequest setValue:authValue forHTTPHeaderField:@"Authorization"];
    request = [theRequest copy];
#endif
    
    if (self)
    {
        _handler    = handler;
        _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    }
    
    return self;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    _response       = response;
    _responseData   = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    [_responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    (_handler)(_response, _responseData, nil);
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    (_handler)(_response, _responseData, error);
}

@end
