/*
 * AppController.j
 * NewApplication
 *
 * Created by You on January 29, 2013.
 * Copyright 2013, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "RLListView.j"

var MyData = ["Did you come here", "for something in", "particular or just", "general Riker-bashing?", "Computer, lights up!", "A surprise party? Mr.", "Worf, I hate surprise", "parties. I would", "*never* do that to", "you. Fate protects", "fools, little", "children and", "ships named Enterprise.", "I'll be sure to", "note that in my", "log. Talk about", "going nowhere fast.", "About four years.", "I got tired of", "hearing how young", "I looked. Besides,", "you look good in", "a dress. You're", "going to be an", "interesting companion,", "Mr. Data. When", "has justice ever", "been as simple as", "a rule book? When", "has justice ever been", "as simple as a rule", "book? Not if I weaken", "first. Some days you", "get the bear, and some", "days the bear gets you.", "Maybe if we felt any", "human loss as keenly", "as we feel one of those", "close to us, human", "history would be far", "less bloody. I'm afraid", "I still don't understand,", "sir. Wait a minute -", "you've been declared dead.", "You can't give orders around here.", "The Enterprise computer", "system is controlled by", "three primary main", "processor cores, cross-", "linked with a redundant", "melacortz ramistat,", "fourteen kiloquad interface", "modules. We know you're", "dealing in stolen ore.", "But I wanna talk about", "the assassination attempt", "on Lieutenant Worf. A lot", "of things can change in", "twelve years, Admiral.", "The unexpected is our normal", "routine. Yesterday I did", "not know how to eat", "gagh. What's a knock-", "out like you doing in", "a computer-generated gin", "joint like this? Shields", "up! Rrrrred alert! I think", "you've let your personal", "feelings cloud your judgement.", "Smooth as an android's", "bottom, eh, Data? I'd like", "to think that I haven't", "changed those things, sir.", "What? We're not at all", "alike! Wouldn't that bring", "about chaos?"];

@implementation AppController : CPObject
{
    CPTableView table;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
        contentView = [theWindow contentView];

    table = [[RLListView alloc] initWithFrame:[contentView bounds]];
    [table setDelegate:self];

    [theWindow setContentView:contentView];
    [contentView addSubview:table];
    [theWindow orderFront:self];
debugger;
    // Uncomment the following line to turn on the standard menu bar.
    //[CPMenu setMenuBarVisible:YES];
}

- (int)numberOfRowsForTableView:(RLListView)aTable
{
    return 1000;
}

- (id)tableView:(RLListView)aTable objectValueForRow:(int)aRow
{
    return MyData[aRow % MyData.length];
}

@end
