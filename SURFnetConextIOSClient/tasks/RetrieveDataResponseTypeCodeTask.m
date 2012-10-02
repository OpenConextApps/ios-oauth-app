/**
 * SURFnetConextIOSClient RetrieveDataResponseTypeCodeTask
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

#import "RetrieveDataResponseTypeCodeTask.h"
#import "AuthenticationDbService.h"
#import "RetrieveAccessTokenTask.h"
#import "AuthenticationResponseTypeCodeTask.h"

@implementation RetrieveDataResponseTypeCodeTask

- (NSString*)getUrl
{
    AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];

    NSString *webserviceUrl = [dbService getWebserviceUrl];

    NSString *full_token_url = [NSString stringWithFormat:@"%@", webserviceUrl];
    
    return full_token_url;
}

- (void)executeRetrieveTask
{
    NSLog(@"Trying to connect to %@", self.getUrl);
    
    AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
    
    NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.getUrl]
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                        timeoutInterval:60.0];
    
    NSString *authHeader = [@"Bearer " stringByAppendingFormat:@"%@", [dbService getAccessToken]];  
    [theRequest addValue:authHeader forHTTPHeaderField:@"Authorization"]; 
    
    
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
            NSLog(@"retrieve new tokens");
            AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
            [dbService addData:@"retrieve new tokens\n"];
            if ([dbService getRefreshToken] != nil) {
                RetrieveAccessTokenTask *task = [[RetrieveAccessTokenTask alloc] init];
                [task executeRetrieveTask];
            } else {
                AuthenticationResponseTypeCodeTask *task = [[AuthenticationResponseTypeCodeTask alloc] init];
                [task executeRetrieveTask];
            }
   
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

    NSString *str = [dictionary description];
    NSString *truncatedString = [str substringToIndex:[str length]-1];
    NSString * finalTruncatedString = [truncatedString substringFromIndex:1];
    
    AuthenticationDbService * dbService = [AuthenticationDbService sharedInstance];
    [dbService addData:finalTruncatedString];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResultViewUpdate" object:nil];
    
}



@end
