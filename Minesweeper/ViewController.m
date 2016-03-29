//
//  ViewController.m
//  Minesweeper
//
//  Created by Brayden Roth-White on 4/14/15.
//  Copyright (c) 2015 Brayden Roth-White. All rights reserved.
//

/*
 Some changes were made in MineField.m and Minefield.h to Wayne Cochran's Code
 */

#import "ViewController.h"

@implementation ViewController

- (void)updateScore { //Updates the score to count the remaining spaces to be exposed
    if(self.mineField.start) {
        if (self.mineField.kablooey) { //check if a mine was recently clicked
            self.scoreTextField.stringValue = @"LOSE";
            self.mineFieldMatrix.enabled = NO;
        } else {
            const int m = [self.mineField unexposedCells];
            const int f = self.mineField.numMines - self.numFlags;
            if (m == 0) { //If there are no more remaining unexposed spaces
                self.scoreTextField.stringValue = @"WIN";
                self.win = YES;
                [self exposeMatrix];
                self.win = NO;
            } else { //Show the remaining spaces
                self.scoreTextField.stringValue = [NSString stringWithFormat:@"%d",f];
            }
        }
    } else {
        self.scoreTextField.stringValue = @"MINES";
        self.numFlags = 0;
    }
}
    
- (void)updateMatrix { //Updates the playing field to display correct images/numbers
    const int maxWidth = self.mineField.width;
    const int maxHeight = self.mineField.height;
    for(int r = 0; r < maxHeight; r++) { //Loop through the rows
        for(int c = 0; c < maxWidth; c++) { //Loop through the cols
            NSButtonCell* bcell = [self.mineFieldMatrix cellAtRow:r column:c];
            Cell* cell = [self.mineField cellAtRow:r Col:c];
            if(cell.exposed) { //If the cell was recently exposed
                int m = [cell numSurroundingMines];
                if(cell.hasMine) { //Does the recently exposed cell have a mine
                    [bcell setImage: self.bombImage];
                    bcell.enabled = NO;
                }
                if(m > 0) { //Are there mines near the recently exposed cell
                    bcell.image = nil;
                    bcell.title = [NSString stringWithFormat:@"%d", m];
                    bcell.enabled = NO;
                } else if(!cell.marked) { //Make sure the cell isn't marked then proceed
                    bcell.image = nil;
                    bcell.title = @"";
                    bcell.enabled = NO;
                }
                [self.mineFieldMatrix selectCellAtRow:r column:c];
            } else {
                bcell.enabled = YES;
                bcell.image = nil;
                if(cell.marked) { //Check for a flag to set the image
                    [bcell setImage: self.flagImage];
                } else { //If recently unmarked get rid of the image
                    bcell.image = nil;
                    bcell.title = @"";
                }
            }
            cell.mexposed = NO;
        }
    }
}

- (void)exposeMatrix { //Win or lose displays the minefield
    const int maxWidth = self.mineField.width;
    const int maxHeight = self.mineField.height;
    for(int r = 0; r < maxHeight; r++) { //Loop through the rows
        for(int c = 0; c < maxWidth; c++) { //Loop through the cols
            NSButtonCell* bcell = [self.mineFieldMatrix cellAtRow:r column:c];
            bcell.imageDimsWhenDisabled = NO;
            Cell* cell = [self.mineField cellAtRow:r Col:c];
            int m;
            if(cell.marked) { m = [cell markedSave]; } //If its marked finds the real value
            else { m = [cell numSurroundingMines]; } //Gets the value
            if(cell.hasMine && bcell.image != self.flagImage && !self.win) { //Is there a mine if so display the image
                [bcell setImage: self.bombImage];
            } else if(cell.hasMine && bcell.image != self.flagImage && self.win) { //Is there a mine if so display the image
                [bcell setImage: self.flagImage];
            } else if(m > 0 && bcell.image == self.flagImage && !cell.hasMine) {
                [bcell setImage: self.bombImage];
                bcell.title = @"X";
            } else if(m > 0 && !cell.hasMine) { //Display the number of adjacent mines ( > 0)
                bcell.image = nil;
                bcell.title = [NSString stringWithFormat:@"%d",m];
            }
            bcell.enabled = NO;
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mineField = [[MineField alloc] initWithWidth:10 Height:10 Mines:12];
    
    self.levelIndex = 0;
    self.numFlags = 0;
    self.win = NO;
    
    self.bombImage = [NSImage imageNamed:@"bomb"];
    self.flagImage = [NSImage imageNamed:@"flag"];
    
    [self updateMatrix];
    [self updateScore];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)newGame:(id)sender { //newGame button is clicked reset minefield
    [self.mineField reset];
    [self updateMatrix];
    [self updateScore];
    [self.mineFieldMatrix deselectAllCells];
    
}

- (IBAction)levelSelect:(NSPopUpButton *)sender { //Level select to build a different minefield
    const NSInteger level = sender.indexOfSelectedItem;
    
    if(level == self.levelIndex) {
        return;
    }
    self.levelIndex = (int)level;
    
    static struct {
        int width, height, numMines;
    } levels[4] = {
        {10, 10, 12},
        {16, 16, 40},
        {30, 16, 99},
        {30, 20, 150}
    };
    
    const int w = levels[level].width;
    const int h = levels[level].height;
    const int m = levels[level].numMines;
    
    const CGSize matrixSize = self.mineFieldMatrix.frame.size;
    [self.mineFieldMatrix renewRows:h columns:w];
    [self.mineFieldMatrix sizeToCells];
    const CGSize newMatrixSize = self.mineFieldMatrix.frame.size;
    const CGSize deltaSize = CGSizeMake(newMatrixSize.width - matrixSize.width,
                                        newMatrixSize.height - matrixSize.height);
    
    self.widthConstraint.constant = newMatrixSize.width;
    self.heightConstraint.constant = newMatrixSize.height;

    
    NSRect windowFrame = self.view.window.frame;
    NSRect newWindowFrame = CGRectMake(windowFrame.origin.x,
                                       windowFrame.origin.y = deltaSize.height,
                                       windowFrame.size.width + deltaSize.width,
                                       windowFrame.size.height + deltaSize.height);
    [self.view.window setFrame:newWindowFrame display:YES animate:NO];
    
    self.mineField = [[MineField alloc] initWithWidth:w Height:h Mines:m];
    [self updateMatrix];
    [self updateScore];
}

- (IBAction)matrixCellSelected:(NSMatrix *)sender {
    const BOOL shiftKeyDown = ([[NSApp currentEvent] modifierFlags] &
                               (NSShiftKeyMask | NSAlphaShiftKeyMask)) != 0;
    if(shiftKeyDown) { //Shift works in place of rightMouseDown
        [self rightClicked:sender];
        return;
    }
    
    const int r = (int)sender.selectedRow;
    const int c = (int)sender.selectedColumn;
    NSButtonCell* bcell = sender.selectedCell;
    Cell* cell = [self.mineField cellAtRow:r Col:c];
    
    if(!self.mineField.start) {
        while(!cell.numSurroundingMines == 0 || cell.hasMine) {
            [self.mineField reset];
            cell = [self.mineField cellAtRow:r Col:c];
        }
        self.mineField.start = YES;
    }
    
    if(!cell.marked) { //Unmarked cell was clicked
        const int m = [self.mineField exposeCellAtRow:r Col:c];
        if(m == -1) { //Clicked a mine
            [self exposeMatrix];
        } else if(m == 0) { //Call update matrix if it has no adjacent miens
            [self updateMatrix];
        } else { 
            bcell.title = [NSString stringWithFormat:@"%d", m];
        }
        bcell.enabled = NO;
        [self updateScore];
    } else { //Don't do anything to an already marked cell
        [sender deselectSelectedCell];
    }
}

- (void)rightClicked:(NSMatrix*)sender {
    const int r = (int)sender.selectedRow;
    const int c = (int)sender.selectedColumn;
    NSButtonCell* bcell = sender.selectedCell;
    const int f = self.mineField.numMines - self.numFlags;
    
    Cell* cell = [self.mineField cellAtRow:r Col:c];
    
    if(f == 0 && !cell.marked) {
        [sender deselectSelectedCell];
        return;
    }
    
    cell.marked = !cell.marked;
    
    if(cell.marked) {
        [bcell setImage: self.flagImage];
        cell.markedSave = cell.numSurroundingMines;
        cell.numSurroundingMines = 9;
        self.numFlags += 1;
    } else {
        bcell.image = nil;
        bcell.title = @"";
        cell.numSurroundingMines = cell.markedSave;
        self.numFlags -= 1;
    }
    [self updateScore];
    [sender deselectSelectedCell];
}


@end
