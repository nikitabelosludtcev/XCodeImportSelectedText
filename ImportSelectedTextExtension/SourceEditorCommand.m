//
//  SourceEditorCommand.m
//  ImportSelectedTextExtension
//
//  Created by Nikita Belosludcev on 17/09/16.
//  Copyright © 2016 nbelosludtcev. All rights reserved.
//

#import "SourceEditorCommand.h"

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler
{
    //update only objective-c source
    if ([invocation.buffer.contentUTI containsString:@"objective-c-source"]) {
        
        //check selections count == 0, because we can add to import only one string
        if ([invocation.buffer.selections count] == 1) {
            
            XCSourceTextRange *selection = invocation.buffer.selections.firstObject;
            
            if (selection.start.line == selection.end.line) {
                NSString *selectionString = nil;
                NSInteger lastImportIndex = -1;
                
                for (int idx = 0; idx < invocation.buffer.lines.count; idx++) {
                    
                    NSString *line = invocation.buffer.lines[idx];
                    
                    //get last import in buffer to add our import after it
                    if ([line containsString:@"#import"]) {
                        lastImportIndex = idx;
                    }
                    if (idx == selection.start.line) {
                        selectionString = [line substringWithRange:NSMakeRange(selection.start.column, selection.end.column - selection.start.column + 1)];
                    }
                }
                
                //check our file contains #import lines
                if (lastImportIndex != -1) {
                    NSString *stringToAdd = [NSString stringWithFormat:@"#import \"%@.h\"", selectionString];
                    //check our bufer already has selected text import
                    if (![invocation.buffer.completeBuffer containsString:stringToAdd]) {
                        [invocation.buffer.lines insertObject:stringToAdd atIndex:lastImportIndex+1];
                    }
                    
                }
            }
        }
    }
    completionHandler(nil);
}

@end
