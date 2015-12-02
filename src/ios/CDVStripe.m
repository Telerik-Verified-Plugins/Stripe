/********* CDVStripe.m Cordova Plugin Implementation *******/

#import "CDVStripe.h"

@implementation CDVStripe

- (void)process:(CDVInvokedUrlCommand*)command
{
    __block CDVPluginResult* pluginResult = nil;

    NSString *httpMethod = [command.arguments objectAtIndex:0];
    NSString *action = [command.arguments objectAtIndex:1];
    NSDictionary *dictionary = [command.arguments objectAtIndex:2];

    NSString *endpoint = [NSString stringWithFormat:@"%@%@", BASE_URL, action];

    NSURL *url = [NSURL URLWithString:endpoint];

    [self sendAsynchronousRequest:url method:httpMethod dictionary:dictionary block:^(NSDictionary *result, NSError *error) {
        if (!error){
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:result];
        }
        else{
            // TODO: the JS API doesn't support an errorcallback, so this is not received by the app!
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageToErrorObject:[NSNumber numberWithLong:error.code].intValue];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        });
    }];

}

- (void)sendAsynchronousRequest:(NSURL*)url method:(NSString*)method dictionary:(NSDictionary*)dictionary block:(void (^)(NSDictionary * result, NSError *error))block
{

    NSMutableURLRequest *request;
    if (![dictionary isKindOfClass:[NSNull class]]){
        NSString *keyValueString = [self processKeyValueString:dictionary withRoot:@""];
        if ([method isEqualToString:@"POST"]) {
            request = [NSMutableURLRequest requestWithURL:url];
            [request setHTTPBody:[keyValueString dataUsingEncoding:NSUTF8StringEncoding]];
        } else {
            NSString *sep = url.query == nil ? @"?" : @"&" ;
            NSString *absoluteURLString = [url absoluteString];
            NSString *absoluteURLWithParams = [absoluteURLString stringByAppendingString: sep];
            absoluteURLWithParams = [absoluteURLWithParams stringByAppendingString: keyValueString];
            url = [NSURL URLWithString:absoluteURLWithParams];
            request = [NSMutableURLRequest requestWithURL:url];
        }
    } else {
      request = [NSMutableURLRequest requestWithURL:url];
    }


    [request setHTTPMethod:method];

    NSString *apiKey = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"StripeApiKey"];

    NSString *authStr = [NSString stringWithFormat:@"%@:", apiKey];
    NSData *authData = [authStr dataUsingEncoding:NSUTF8StringEncoding];
    NSString *authValue = [NSString stringWithFormat:@"Basic %@", [authData base64Encoding]];

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    [request setValue:authValue forHTTPHeaderField:@"Authorization"];

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];

    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {

        NSError *jsonParsingError = nil;

        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments  error:&jsonParsingError];

        if (jsonParsingError)
            error = jsonParsingError;

        block(result, error);

    }];

    [task resume];

}

- (NSString*)processKeyValueString:(NSDictionary*)dictionary withRoot:(NSString*)root
{
    NSString *keyValueString = @"";

    for (NSString *key in dictionary.allKeys){
        if ([[dictionary objectForKey:key] isKindOfClass:[NSDictionary class]]){
            keyValueString = [keyValueString stringByAppendingString:[self processKeyValueString:[dictionary objectForKey:key] withRoot:key]];
        } else {
            NSString *value;
            if ([[dictionary objectForKey:key] isKindOfClass:[NSNumber class]]){
                NSNumber *nr = [dictionary objectForKey:key];
                value = nr.stringValue;
            } else {
                value = [dictionary objectForKey:key];
            }
            NSString *fragment = [NSString stringWithFormat:@"%@=%@", key, [self urlencode:value]];

            if (![root isEqualToString:@""]){
                fragment = [NSString stringWithFormat:@"%@[%@]=%@", root, key, [self urlencode:value]];
            }
            keyValueString = [keyValueString stringByAppendingString:fragment];
            keyValueString = [keyValueString stringByAppendingString:@"&"];
        }
    }

    return keyValueString;
}

- (NSString *)urlencode:(NSString*)string
{
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[string UTF8String];
    int sourceLen = [NSNumber numberWithLong: strlen((const char *)source)].intValue;
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}


@end
