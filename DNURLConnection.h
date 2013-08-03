//
//  DNURLConnection.h
//  MZ Proto
//
//  Created by Darren Ehlers on 8/3/13.
//  Copyright (c) 2013 DoubleNode.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DNURLConnection : NSObject<NSURLConnectionDelegate>
{
    NSURLConnection*    _connection;
    NSMutableData*      _responseData;
    NSURLResponse*      _response;
    
    void    (^_handler)(NSURLResponse*, NSData*, NSError*);
}

+ (id)connectionWithRequest:(NSURLRequest*)request
          completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;

- (id)initWithRequest:(NSURLRequest*)request
    completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;

@end
