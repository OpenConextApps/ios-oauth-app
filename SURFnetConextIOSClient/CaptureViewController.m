/**
 * SURFnetConextIOSClient CaptureViewController
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

#import "CaptureViewController.h"
#import "AuthenticationDbService.h"
#import "RetrieveDataResponseTypeCodeTask.h"

@implementation CaptureViewController

@synthesize txtData;

- (IBAction)refreshButton
{
    RetrieveDataResponseTypeCodeTask *task = [[RetrieveDataResponseTypeCodeTask alloc] init];
    [task executeRetrieveTask];
}

- (IBAction)backButton
{
    AuthenticationDbService *dbService = [AuthenticationDbService sharedInstance];
    [dbService resetData];
}


- (void)reloadView
{
    AuthenticationDbService *dbService = [AuthenticationDbService sharedInstance];
    txtData.text = [dbService getData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadView) name:@"ResultViewUpdate" object:nil];
}

@end
