/**
 * SURFnetConextIOSClient ViewController
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

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>
{
        IBOutlet UITextField * txtAuthorizeUrl;
        IBOutlet UITextField * txtResponseType;
        IBOutlet UITextField * txtClientId;
        IBOutlet UITextField * txtRedirectUri;
}
- (IBAction)startButton;

@property (nonatomic, retain)  IBOutlet UITextField *txtAuthorizeUrl;
@property (nonatomic, retain)  IBOutlet UITextField *txtResponseType;
@property (nonatomic, retain)  IBOutlet UITextField *txtClientId;
@property (nonatomic, retain)  IBOutlet UITextField *txtRedirectUri;

@end
