//
//  Cell.m
//

#import "Cell.h"


@implementation Cell

-(instancetype)init {
    self = [super init];
    if (self != nil) {
        _hasMine = _exposed = _mexposed = NO;
        _marked = _numSurroundingMines = 0;
    }
    return self;
}

@end
