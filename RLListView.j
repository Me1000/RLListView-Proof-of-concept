@implementation RLListView : CPView
{
    id delegate @accessors;
    CPScrollView _scrollView;
    CPView _containerView;

    int _numberOfRows;
    CPArray _enqueuedDataViews;
    CPDictionary _visibleDataViews;
    CPIndexSet _visibleRows;
    CPArray _data;

    int rowHeight @accessors();
}

- (id)initWithFrame:(CGRect)aRect
{
    self = [super initWithFrame:aRect];

    if (self)
    {
        _scrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0,0, CGRectGetWidth(aRect), CGRectGetHeight(aRect))];
        [_scrollView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
        _containerView = [[CPView alloc] initWithFrame:CGRectMake(0,0,0,0)];
        [_scrollView setDocumentView:_containerView];
        [_scrollView setDelegate:self];
        _numberOfRows = 0;
        _enquedDataViews = [];
        [self addSubview:_scrollView];
        [self setRowHeight:30];

        [[_containerView superview] setPostsFrameChangedNotifications:YES];
        [[_containerView superview] setPostsBoundsChangedNotifications:YES];

        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(superviewFrameChanged:)
                   name:CPViewFrameDidChangeNotification
                 object:[_containerView superview]];

        [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(superviewBoundsChanged:)
                   name:CPViewBoundsDidChangeNotification
                 object:[_containerView superview]];

    }

    return self;
}

- (void)setDelegate:(id)aDelegate
{
    _delegate = aDelegate;
    [self reloadData];
}

- (void)reloadData
{
    _numberOfRows = [_delegate numberOfRowsForTableView:self];
    _data = [];
    _visibleRows = nil;

    // remove current dataviews
    [_visibleDataViews enumerateKeysAndObjectsUsingBlock:function (aKey, anObject, stop){
        [anObject removeFromSuperview];
        [_enquedDataViews addObject:anObject];
    }];

    _visibleDataViews = [CPDictionary dictionary];

    for (var i = 0; i < _numberOfRows; i++)
        _data[i] = [_delegate tableView:self objectValueForRow:i];

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self tileDataViews];
}

- (void)tileDataViews
{
    var frame = [self frame];
    var rowHeight = [self rowHeight];
    var newRect = CGRectMake(0,0, [self frame].size.width, MAX(frame.size.height, _numberOfRows * rowHeight));
    [_containerView setFrame:newRect];

    var previouslyVisibleRows = [_visibleRows copy];
    var rowsInRect = [self rowsInRect:[self exposedRect]];
    _visibleRows = [CPIndexSet indexSetWithIndexesInRange:rowsInRect];
    [previouslyVisibleRows removeIndexes:_visibleRows];

    var indexesOfDataViewsToEnqueue = [];
    [previouslyVisibleRows getIndexes:indexesOfDataViewsToEnqueue maxCount:-1 inIndexRange:nil];

    for (var i = 0; i < indexesOfDataViewsToEnqueue.length; i++)
    {
        var key = indexesOfDataViewsToEnqueue[i];
        var obj = [_visibleDataViews objectForKey:key];
        //[obj removeFromSuperview];
        [_enquedDataViews addObject:obj];
        [_visibleDataViews removeObjectForKey:key];
    }

    var indexesOfVisibleDataViews = [];
    [_visibleRows getIndexes:indexesOfVisibleDataViews maxCount:-1 inIndexRange:nil];

    for (var i = 0; i < indexesOfVisibleDataViews.length; i++)
    {
        var key = indexesOfVisibleDataViews[i];
        var obj = [_visibleDataViews objectForKey:key];

        if (!obj)
        {
            obj = [self _dequeueDataView];
            [obj setObjectValue:_data[key]];
            [obj setFrame:[self rectOfRow:key]];

            if (![obj superview])
                [_containerView addSubview:obj];

            [_visibleDataViews setObject:obj forKey:key];
        }
    }

}

- (int)rowAtPoint:(CGPoint)aPoint
{
    return FLOOR(aPoint.y / [self rowHeight]);
}

- (CGRect)rectOfRow:(int)aRowIndex
{
    return CGRectMake(0, aRowIndex * [self rowHeight], [self frame].size.width, rowHeight);
}

- (CPRange)rowsInRect:(CGRect)aRect
{
    // If we have no rows, then we won't intersect anything.
    if (_numberOfRows <= 0)
        return CPMakeRange(0, 0);

    var firstRow = [self rowAtPoint:aRect.origin];

    // first row has to be undershot, because if not we wouldn't be intersecting.
    if (firstRow < 0)
        firstRow = 0;

    var lastRow = [self rowAtPoint:CGPointMake(0.0, CGRectGetMaxY(aRect))];

    // last row has to be overshot, because if not we wouldn't be intersecting.
    if (lastRow < 0)
        lastRow = _numberOfRows - 1;

    return CPMakeRange(firstRow, lastRow - firstRow + 1);
}

- (CPView)_dequeueDataView
{
    if (_enquedDataViews)
        var view = _enquedDataViews.pop();

    if (!view)
        view = [CPTextField labelWithTitle:"Test"];

    return view;
}

- (CGRect)exposedRect
{
    return [[_scrollView contentView] bounds];
}

- (void)superviewBoundsChanged:(CPNotification)aNotification
{
    [self setNeedsLayout];
}

- (void)superviewFrameChanged:(CPNotification)aNotification
{
    [self setNeedsLayout];
}

@end
