//
//  Cell.h
//

#import <Foundation/Foundation.h>

@interface Cell : NSObject

@property (assign, nonatomic) BOOL hasMine;   // Cell contain a mine?
@property (assign, nonatomic) BOOL exposed;   // Has the cell has been exposed (may or may not have mine)?
@property (assign, nonatomic) BOOL mexposed;
@property (assign, nonatomic) BOOL marked;    // Cell marked as having a mine (perhaps incorrectly)?
@property (assign, nonatomic) char numSurroundingMines;  // number of mines in 8 adjacent cells
@property (assign, nonatomic) char markedSave;

-(instancetype)init;

@end
