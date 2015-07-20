//
//  ___FILENAME___
//
//  Created by : ___FULLUSERNAME___
//  Project    : ___PROJECTNAME___
//  Date       : ___DATE___
//
//  Copyright (c) ___YEAR___ ___ORGANIZATIONNAME___.
//  All rights reserved.
//
// -----------------------------------------------------------------

#import "mainScene.h"
#import "loadScene.h"
#import "CCCredits.h"

// -----------------------------------------------------------------------

#define kGrossiniJumpTime 1.0
#define kGrossiniJumps 5

// -----------------------------------------------------------------------

@implementation mainScene
{
    CCSprite *_grossini;
    float _grossiniStart;
    float _grossiniEnd;
    float _grossiniJumpHeight;
    float _grossiniJumpTime;
    float _grossiniBase;
}

// -----------------------------------------------------------------------
#pragma mark - Create & Destroy
// -----------------------------------------------------------------------

- (id)init
{
    // Apple recommend assigning self with supers return value
    self = [super init];
    
    // The thing is, that if this fails, your app will 99.99% crash anyways, so why bother
    // Just make an assert, so that you can catch it in debug
    NSAssert(self, @"Whoops");
    
    // get the size of the world
    CGSize size = [CCDirector sharedDirector].viewSize;
    
    // Set the background to medium grey
    self.colorRGBA = [CCColor colorWithRed:0.5 green:0.5 blue:0.5];
    
    // add a solid colored node
    CCSprite9Slice *background = [CCSprite9Slice spriteWithImageNamed:@"white_square.png"];
    background.anchorPoint = CGPointZero;
    background.contentSize = size;
    background.color = [CCColor orangeColor];
    [self addChild:background];
    
    // add grossini (we have missed him)
    _grossini = [CCSprite spriteWithImageNamed:@"grossini_hi.png"];
    _grossini.positionType = CCPositionTypeNormalized;
    _grossiniBase = 0.1;
    _grossini.position = (CGPoint){0.1, _grossiniBase};
    [self addChild:_grossini];
    
    // start button
    CCButton *button;
    button = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"start.png"]];
    button.positionType = CCPositionTypeNormalized;
    button.position = ccp(0.5, 0.6);
    [button setTarget:self selector:@selector(startPressed:)];
    [self addChild:button];

    // setup button
    button = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"setup.png"]];
    button.positionType = CCPositionTypeNormalized;
    button.position = ccp(0.5, 0.4);
    [button setTarget:self selector:@selector(setupPressed:)];
    [self addChild:button];
    
    // info button
    button = [CCButton buttonWithTitle:@"" spriteFrame:[CCSpriteFrame frameWithImageNamed:@"info.png"]];
    button.positionType = CCPositionTypeNormalized;
    button.position = (CGPoint){0.92, 0.10};
    [button setTarget:self selector:@selector(infoPressed:)];
    [self addChild:button];

    // enable touch handing
    self.userInteractionEnabled = YES;

    // we are out of here
	return self;
}

// -----------------------------------------------------------------------

- (void)dealloc
{
    // clean up code goes here
}

// -----------------------------------------------------------------------
#pragma mark - Enter & Exit

- (void)onEnter
{
    // always call super onEnter first
    [super onEnter];
    
    // In pre-v3, touch enable and scheduleUpdate was called here
    // In v3, touch is enabled by setting userInteractionEnabled for the individual nodes
    // Per frame update is automatically enabled, if update is overridden
    
}

// -----------------------------------------------------------------------

- (void)onExit
{
    // always call super onExit last
    [super onExit];
}

// -----------------------------------------------------------------------
#pragma mark - Touch Handler

-(void) touchBegan:(CCTouch *)touch withEvent:(UIEvent *)event
{
    // check if we are touching grossini
    if (![_grossini hitTestWithWorldPos:touch.locationInWorld]) return;
    
    // make grossini jump
    _grossiniJumpTime = 0.0;
    _grossiniStart = _grossini.position.x;
    _grossiniEnd = CCRANDOM_0_1();
    CCLOG(@"moving to %.2f", _grossiniEnd);
    _grossiniJumpHeight = 0.2 + (0.5 * CCRANDOM_0_1());
    [self schedule:@selector(updateGrossini:) interval:0.033];
    
}

// -----------------------------------------------------------------------
#pragma mark - Scheduled events

- (void)updateGrossini:(NSTimeInterval)dt
{
    // total jump time is 1.0 seconds
    _grossiniJumpTime += dt;
    
    float normalizedTime = _grossiniJumpTime / kGrossiniJumpTime;

    // calculate linear x position
    // this will make him move faster in the beginning
    float progress = sqrtf(normalizedTime);
    float xPos = (_grossiniStart * (1.0 - progress)) + (_grossiniEnd * progress);
    
    // calculate a decaying sin jump
    float cycleTime = kGrossiniJumpTime / kGrossiniJumps;
    int cycle = (int)(_grossiniJumpTime / cycleTime);
    float height = sinf(M_PI * (_grossiniJumpTime - (cycle * cycleTime)) / cycleTime);
    height *= _grossiniJumpHeight;
    while (cycle > 0)
    {
        // each cycle decays height to 33% of previous
        height *= 0.33;
        cycle --;
    }
    
    _grossini.position = (CGPoint){xPos, _grossiniBase + height};
    
    // stop grossini after kGrossiniJumpTime
    if (_grossiniJumpTime >= kGrossiniJumpTime) [self unschedule:@selector(updateGrossini:)];
}

// -----------------------------------------------------------------------
#pragma mark - Button Callbacks

// -----------------------------------------------------------------------

- (void)startPressed:(id)sender
{
    
}

// -----------------------------------------------------------------------

- (void)setupPressed:(id)sender
{
    
}

// -----------------------------------------------------------------------

- (void)infoPressed:(id)sender
{
    // open dictionary
    NSString *filename = [[NSBundle mainBundle] pathForResource:@"credits.plist" ofType:nil];
    NSDictionary *creditsDict = [NSDictionary dictionaryWithContentsOfFile:filename];
    
    // create list of CCCredits
    CCCredits *credits = [CCCredits creditsWithScene:self andDictionary:creditsDict];
    [self addChild:credits];
}

// -----------------------------------------------------------------------

@end

















