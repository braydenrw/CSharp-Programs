//
//  ViewController.h
//  Minesweeper
//
//  Created by Brayden Roth-White on 4/14/15.
//  Copyright (c) 2015 Brayden Roth-White. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MineField.h"

@interface ViewController : NSViewController

- (IBAction)newGame:(id)sender;
- (IBAction)levelSelect:(NSPopUpButton *)sender;
- (IBAction)matrixCellSelected:(NSMatrix *)sender;

@property (weak) IBOutlet NSTextField *scoreTextField;
@property (weak) IBOutlet NSMatrix *mineFieldMatrix;
@property (weak) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak) IBOutlet NSLayoutConstraint *widthConstraint;

@property (strong, nonatomic) MineField *mineField;
@property (strong, nonatomic) NSImage *bombImage;
@property (strong, nonatomic) NSImage *flagImage;

@property (nonatomic) int levelIndex;
@property (nonatomic) int numFlags;
@property (nonatomic) BOOL win;

-(void)rightClicked:(NSMatrix*)sender;

@end