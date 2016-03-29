//
//  NSButtonCellTitle.m
//  Minesweeper
//
//  Created by Brayden Roth-White on 5/8/15.
//  Copyright (c) 2015 Brayden Roth-White. All rights reserved.
//

#import "NSButtonCellTitle.h"

@implementation NSButtonCellTitle

-(NSColor*)getColor:(int)m {
    NSColor* darkGreenColor = [NSColor colorWithCalibratedRed:0.0f green:0.5f blue:0.0f alpha:1.0f];
    NSColor* darkCyanColor = [NSColor colorWithCalibratedRed:0.0f green:0.75f blue:1.0f alpha:1.0f];
    NSColor* darkRedColor = [NSColor colorWithCalibratedRed:0.5f green:0.0f blue:0.0f alpha:1.0f];
    NSColor* lightPurpleColor = [NSColor colorWithCalibratedRed:0.6f green:0.0f blue:0.75f alpha:1.0f];
    
    if(m == 1) { return [NSColor blueColor]; }
    else if(m == 2) { return darkGreenColor; }
    else if(m == 3) { return [NSColor redColor]; }
    else if(m == 4) { return lightPurpleColor; }
    else if(m == 5) { return darkRedColor; }
    else if(m == 6) { return darkCyanColor; }
    else if(m == 7) { return [NSColor blackColor]; }
    else if(m == 8) { return [NSColor lightGrayColor]; }
    else { return [NSColor redColor]; }
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView {
    
    NSAttributedString *temp = title;
    
    NSString *str = [temp string];
    
    int m = [str intValue];
    
    NSColor *newColor = [self getColor:m];
    
    NSDictionary *attributes = [title attributesAtIndex:0 effectiveRange:nil];
    
    NSColor *systemDisabled = [NSColor colorWithCatalogName:@"System"
                                                  colorName:@"disabledControlTextColor"];
    NSColor *buttonTextColor = attributes[NSForegroundColorAttributeName];
    
    if (systemDisabled == buttonTextColor) {
        NSMutableDictionary *newAttrs = [attributes mutableCopy];
        newAttrs[NSForegroundColorAttributeName] = newColor;
        title = [[NSAttributedString alloc] initWithString:title.string attributes:newAttrs];
    }
    
    return [super drawTitle:title withFrame:frame inView:controlView];
    
}

@end
