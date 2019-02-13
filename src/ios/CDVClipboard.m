#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>
#import <Cordova/CDVPluginResult.h>
#import "CDVClipboard.h"

@implementation CDVClipboard

- (void)copy:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        NSString     *text       = [command.arguments objectAtIndex:0];
        
        NSLog(@"Copying text -> %@", text);
        pasteboard.string = text;
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:text];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)paste:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        
        NSLog(@"Pasteboard types: %@", pasteboard.pasteboardTypes);
        
        NSArray *pasteboardTypes = @[@"public.rtfd",
                                     @"public.rtf",
                                     @"public.html",
                                     @"public.text"];
        NSDictionary *pasteboardTypesDict = @{@"public.text" : NSPlainTextDocumentType,
                                              @"public.rtfd" : NSRTFDTextDocumentType,
                                              @"public.rtf" : NSRTFTextDocumentType,
                                              @"public.html" : NSHTMLTextDocumentType};
        
        NSString     *htmlAsString;
        
        for (NSString *pasteboardType in pasteboardTypes){
            @try{
                NSData *pasteboardData = [pasteboard dataForPasteboardType:pasteboardType];
                if(pasteboardData){
                    NSLog(@"Found data for type %@", pasteboardType);
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                                                   initWithData:pasteboardData
                                                                   options:@{NSDocumentTypeDocumentAttribute: pasteboardTypesDict[pasteboardType]}
                                                                   documentAttributes:NULL error:NULL];
                    
                    //Saving the NSAttributedString with all its attributes as a NSData Entity
                    NSData *htmlData = [attributedString dataFromRange:NSMakeRange(0, attributedString.length)
                                                    documentAttributes:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                                 error:NULL];
                    //Convert the NSData into HTML String with UTF-8 Encoding
                    htmlAsString = [[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding];
                    break;
                }
            }
            @catch(NSException *e){
                NSLog(@"Unparseable pasteboard data type %@", pasteboardType);
            }
        }
        
        if (htmlAsString == nil) {
            htmlAsString = @"";
        }
        NSLog(@"Returning HTML: %@", htmlAsString);
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:htmlAsString];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

- (void)clear:(CDVInvokedUrlCommand*)command {
    [self.commandDelegate runInBackground:^{
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setValue:@"" forPasteboardType:UIPasteboardNameGeneral];
        
        CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsBool:true];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }];
}

@end
