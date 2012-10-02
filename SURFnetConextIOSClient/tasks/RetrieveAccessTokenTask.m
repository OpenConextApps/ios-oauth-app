/**
 * SURFnetConextIOSClient RetrieveAccessTokenTask
 * Created by Jochem  Knoops.
 
 * LICENSE
 *
 * Copyright 2012 SURFnet bv, The Netherlands
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and limitations under the License.
 */

#import "RetrieveAccessTokenTask.h"
#import "AuthenticationDbService.h"
#import "RetrieveDataResponseTypeCodeTask.h"
#import "AuthenticationResponseTypeCodeTask.h"

@implementation RetrieveAccessTokenTask

- (NSString*)getUrl
{
    AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
    
    NSString *token_url= [dbService getTokenUrl];
    
    NSString *full_token_url = [NSString stringWithFormat:@"%@", token_url];
    
    return full_token_url;
}

- (NSString*)getParameters
{
    AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
    
    NSString *grant_type = @"refresh_token";
    NSString *refresh_token = [dbService getRefreshToken];   
    
    NSString *full_token_param = [NSString stringWithFormat:@"grant_type=%@&refresh_token=%@", grant_type, refresh_token];

    return full_token_param;
}

- (void)executeRetrieveTask
{
    NSLog(@"Trying to connect to %@", self.getUrl);
    NSLog(@"Trying to connect with %@", self.getParameters);
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.getUrl]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    
    [theRequest setHTTPMethod:@"POST"];
    [theRequest setHTTPBody:[self.getParameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        receivedData = [[NSMutableData alloc] init];
    } else {
        // Inform the user that the connection failed.
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSLog(@"didReceiveResponse");
    if ([response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response; 
        NSLog(@"http statuscode = %i", [httpResponse statusCode]);
        
        int statusCode = [httpResponse statusCode];
        if (statusCode != 200) {
            [connection cancel];
            NSLog(@"refresh token is invalid.");
            AuthenticationResponseTypeCodeTask *task = [[AuthenticationResponseTypeCodeTask alloc] init];
            [task executeRetrieveTask];

        } else {
            
        }
        
        
        
    }
    
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
    
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError");
    
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"connectionDidFinishLoading");
    
    NSError* error;
    
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:receivedData options:kNilOptions error:&error];

    AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
    
    NSString * access_token = [dictionary objectForKey:@"access_token"];
    NSLog(@"access_token = %@", access_token);
    [dbService setAccessToken:access_token];
    NSLog(@"access_token = %@", [dbService getAccessToken]);
    
    NSString * token_type = [dictionary objectForKey:@"token_type"];
    NSLog(@"token_type = %@", token_type);
    [dbService setTokenType:token_type];
    
    NSString * refresh_token = [dictionary objectForKey:@"refresh_token"];
    if (refresh_token != nil) {
        NSLog(@"refresh_token = %@", refresh_token);
        [dbService setRefreshToken:refresh_token];
    }
    
    int expires_in = (int)[dictionary objectForKey:@"expires_in"];
    if (expires_in != 0) {
        NSLog(@"expires_in = %@", expires_in);
        [dbService setExpiresIn:expires_in];
    }
    
    NSString * scope = [dictionary objectForKey:@"scope"];
    if (scope != nil) {
        NSLog(@"scope = %@", scope);
    }
    
    RetrieveDataResponseTypeCodeTask *task = [[RetrieveDataResponseTypeCodeTask alloc] init];
    [task executeRetrieveTask];
}

@end

