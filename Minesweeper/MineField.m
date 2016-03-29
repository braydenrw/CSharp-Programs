//
//  MineField.m
//
//  Created by Wayne Cochran on 4/21/09.
//

#import "MineField.h"


@implementation MineField

-(instancetype)initWithWidth:(int)w Height:(int)h Mines:(int)m {
    self = [super init];
    if (self != nil) {
        int r, c;
        _cells = [[NSMutableArray alloc] initWithCapacity: h];
        for (r = 0; r < h; r++) {
            NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity: w];
            [_cells addObject: row];
            for (c = 0; c < w; c++) {
                [row addObject: [[Cell alloc] init]];
            }
        }
        _numMines = m;
        [self reset]; // place random mines and unexpose all cells
    }
    return self;
}

-(int)width {
    return (int) [[_cells objectAtIndex: 0] count];
}

-(int)height {
    return (int) [_cells count];
}

-(Cell*)cellAtRow:(int)r Col:(int)c {
    return [[_cells objectAtIndex: r] objectAtIndex: c];
}

-(void)reset {
    int w = [self width], h = [self height];
    int n = w*h;  // total cells left
    int m = _numMines; // total mines left to place
    int r,c;
    
    _numExposedCells = 0;
    _kablooey = _start = NO;
    
    for (r = 0; r < h; r++) { // reset all cells
        for (c = 0; c < w; c++) {
            Cell *cell = [self cellAtRow: r Col: c];
            cell.exposed = cell.marked = cell.hasMine = NO;
            double p = (double) m / (double) n; // probability of placing mine here
            double g = drand48();  // generate random number 0 <= g < 1
            if (g < p) {
                cell.hasMine = YES;
                m--;
            }
            n--;
        }
    }
    _numMines -= m;  // just to be anal, m should be zero at this point
    
    for (r = 0; r < h; r++) { // compute surrounding mine counts
        for (c = 0; c < w; c++) {
            int i,j, count = 0;
            Cell *cell = [self cellAtRow: r Col: c];
            for (j = -1; j <= +1; j++) {
                for (i = -1; i <= +1; i++) {
                    if (i == 0 && j == 0) continue;
                    int rr = r+j, cc = c+i;
                    if (rr < 0 || rr >= h || cc < 0 || cc >= w) continue;
                    Cell *neighbor = [self cellAtRow: rr Col: cc];
                    if (neighbor.hasMine)
                        count++;
                }
            }
            cell.numSurroundingMines = count;
        }
    }
}

-(int)unexposedCells {
    int w = [self width], h = [self height];
    return w*h - _numMines - _numExposedCells;
}

//
// return value
//  -2 => no change (cell already exposed, controller shouldn't allow this)
//  -1 => "BOOM" (new exposed cell contained mine).
//  0 to 8 => cell safely exposed, number of neighboring mines returned
//  When 0 returned, its neighbors are (recursively) exposed
//        controller should rescan grid for exposed cells
//

/* 
 CHANGES MADE IN HERE in order to make flags act more like the do in
 real minesweeper ie: don't expose themselves when an empty space is clicked
 on near the flag.  Also to not look passed a flag when opening blocks
 of the minefield 
 */

-(int)exposeCellAtRow:(int)r Col:(int)c {
    if (self.kablooey) return -2;
    Cell *cell = [self cellAtRow: r Col: c];
    if (cell.exposed) return -2;
    if(!cell.marked) { //Makes sure there isnt a flag
        if(cell.exposed) { //Not the best way to make sure the same spot isnt counted twice
            _numExposedCells--;
        }
        cell.exposed = YES;
        _numExposedCells++;
    }
    cell.mexposed = YES;
    if (cell.hasMine) {  // BOOM!
        _kablooey = YES;
        return -1;
    }
    int n = cell.numSurroundingMines;
    if (n == 0) {
        int w = [self width], h = [self height];
        BOOL changed;
        do {
            int rr, cc;
            changed = NO;
            for (rr = 0; rr < h; rr++)
                for (cc = 0; cc < w; cc++)
                     if ([self autoExposeCellAtRow:rr Col:cc])
                        changed = YES;
        } while (changed);
    }
    return n;
}

-(BOOL)autoExposeCellAtRow:(int)r Col:(int)c {
    Cell *cell = [self cellAtRow: r Col: c];
    if (!cell.mexposed && !cell.hasMine) {
        int w = [self width], h = [self height];
        int i,j;
        for (j = -1; j <= +1; j++) {
            for (i = -1; i <= +1; i++) {
                if (i == 0 && j == 0) continue;
                int rr = r+j, cc = c+i;
                if (rr < 0 || rr >= h || cc < 0 || cc >= w) continue;
                Cell *neighbor = [self cellAtRow:rr Col:cc];
                if (neighbor.mexposed && neighbor.numSurroundingMines == 0) {
                    if(!cell.marked) { //No flag
                        if(cell.exposed) { //Make sure the same exposure isnt counted twice
                            _numExposedCells--;
                        }
                        cell.exposed = YES;
                        _numExposedCells++;
                    }
                    cell.mexposed = YES;
                    return YES;
                }
            }
        }                            
    }
    return NO;
}

@end
