# SURFnet's IOS client for use with OAuth 2.0 (rev 31)

The mobile app is able to connect to a secure webservice which is secured in a OAuth 2.0 way. 
The current specification for OAuth 2.0 can be found at http://tools.ietf.org/html/draft-ietf-oauth-v2-31

## Tools used for developing/building the app.

* XCode 4.2+

## Building
Building the android app requires a [git](http://git-scm.com/) client, the android sdk, Eclipse

    git clone git://github.com/OpenConextApps/ios-oauth-app.git

Open the project in XCode.

## Components

### Properties

The properties are configured in the class AuthenticationDbService.

# Summerschool demo
    authorize_url=https://frko.surfnetlabs.nl/php-oauth/authorize.php
    authorize_response_type=code
    authorize_grant_type=authorization_code
    authorize_client_id= oauth-mobile-app
    authorize_scope=grades
    authorize_redirect_uri=oauth-mobile-app://callback
    token_url=https://frko.surfnetlabs.nl/php-oauth/token.php
    token_grant_type=authorization_code
    webservice_url=https://frko.surfnetlabs.nl/php-summerschool/api.php/grades/@me


### ViewController
In the first view some of the properties are shown to the user. After pressing the the login button the app will try to connect to the authentication server to retrieve the requested redirect-uri and an authorization code.

### CaptureViewController

After the the authentication proces is started the second view will be shown.
There are 2 buttons (back, refresh) on this screen. The back-button will shown the first view and will remove the current tokens. The refresh button will reload the data from the webservices. If needed a new access_token will be retrieved with the refresh_token. If the refresh_token is not valid anymore and/or is not available The authentication will start again.

The application can be used with response type "code".

#### Response Type "code"

When the response type "code" is used the application receives the authorization code from response of the authorization server.
This authorization code can only be used once and the code MUST expire shortly after generation (Section 4.1.2).
The application will request for the access token and optional the refresh token. After receiving the tokens,
the access token will be used for retrieving the data from the webservice. (Section 5.1 for successful response).

If available the application will store the date/time when the access token will expire. This will prevent the application
from using a access token which is not valid anymore. (It may be using the access token when the token is not valid anymore for a few seconds.)

If available the application will store the refresh token. The refresh token will be used when the access token is expired or when the access token is used
and an exception in thrown. If the refresh token is not valid anymore (revoked) the logic of the start activity will be followed.


### Authentication

The authentication will be started by generating the url for the authentication server and start the activity which handles http/https connections.
When the authentication succeeds the last redirect in the browser will be catched by the application and this will start the Scheme Capture Activity.

### Storage

The access token and optional refresh token and expires at will be stored in memory of the application.
