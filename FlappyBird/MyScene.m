//
//  MyScene.m
//  FlappyBird
//
//  Created by Akash Shinde on 26/06/14.
//  Copyright (c) 2014 Akash Shinde. All rights reserved.
//

#import "MyScene.h"

#define TIME 1.5
#define MINIMUM_PILLER_HEIGHT 50.0f
#define GAP_BETWEEN_ABOVE_AND_BELOW_PILLER 100.0f
#define UPWARD_PILLER @"Upward_Green_Pipe"
#define Downward_PILLER @"Downward_Green_Pipe"

static const float BG_VELOCITY = (TIME * 60);

static int32_t pillerCategory = 0x1 << 0;
static int32_t flappyBirdCategory = 0x1 <<1;

static inline CGPoint CGPointAdd(const CGPoint a,const CGPoint b)
{
    return CGPointMake(a.x+b.x, a.y+b.y);
}

static inline CGPoint CGPointMultiplyScalar(const CGPoint a, const CGFloat b)
{
    return CGPointMake(a.x * b, a.y * b);
}


@interface MyScene () <SKPhysicsContactDelegate>
{
    NSTimeInterval _dt;
    float bottomScrollerHeight;
    
}

@property (nonatomic) SKSpriteNode* backGroundImageNode;
@property (nonatomic) SKSpriteNode* flappyBird;
@property (nonatomic) NSTimeInterval lastSpawnInterval;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end




@implementation MyScene

-(id)initWithSize:(CGSize)size
{
    if (self == [super initWithSize:size]) {
        
        [self initializedBackground:size];
        
        [self initializedScrollingBackgroung];
        
        [self initializeBird];
        
        self.physicsWorld.gravity = CGVectorMake(0, -4.0);
        
        self.physicsWorld.contactDelegate = self;
        
        
        
    }
    return self;
}

-(void) initializedBackground:(CGSize) scenesize
{
    self.backGroundImageNode = [SKSpriteNode spriteNodeWithImageNamed:@"Night_Background"];
    self.backGroundImageNode.size = scenesize;
    self.backGroundImageNode.position = CGPointMake(self.backGroundImageNode.size.width/2, self.frame.size.height/2);
    [self addChild:self.backGroundImageNode];
}

-(void)initializedScrollingBackgroung
{
    for (int i=0; i<2; i++) {
        SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"Bottom_Scroller"];
        bottomScrollerHeight = bg.size.height;
        bg.position = CGPointMake(i*bg.size.width, 0);
        bg.anchorPoint = CGPointZero;
        bg.name = @"bg";
        [self addChild:bg];
    }
}

-(void) initializeBird
{
    self.flappyBird = [SKSpriteNode spriteNodeWithImageNamed:@"Yellow_Bird_Wing_Down"];
    self.flappyBird.position = CGPointMake(self.backGroundImageNode.size.width*0.3f, self.frame.size.height*0.6f);
    _flappyBird.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_flappyBird.size];
    _flappyBird.physicsBody.dynamic = YES;
    _flappyBird.physicsBody.usesPreciseCollisionDetection = YES;
    _flappyBird.physicsBody.categoryBitMask = flappyBirdCategory;
    _flappyBird.physicsBody.contactTestBitMask = pillerCategory;
    _flappyBird.physicsBody.collisionBitMask = 0;
    [self addChild:self.flappyBird];
    
}

- (void)moveBottomScroller
{
    [self enumerateChildNodesWithName:@"bg" usingBlock: ^(SKNode *node, BOOL *stop)
     {
         SKSpriteNode * bg = (SKSpriteNode *) node;
         CGPoint bgVelocity = CGPointMake(-BG_VELOCITY, 0);
         CGPoint amtToMove = CGPointMultiplyScalar(bgVelocity,_dt);
         bg.position = CGPointAdd(bg.position, amtToMove);
         
         //Checks if bg node is completely scrolled of the screen, if yes then put it at the end of the other node
         if (bg.position.x <= -bg.size.width)
         {
             bg.position = CGPointMake(bg.position.x + bg.size.width*2,
                                       bg.position.y);
         }
         
         [bg removeFromParent];
         [self addChild:bg];        //Ordering is not possible. so this is a hack
     }];
}

-(SKSpriteNode*) createPillerInUpwardDirection :(BOOL) isUpward
{
    NSString* pillerImageName = Nil;
    if (isUpward) {
        pillerImageName = UPWARD_PILLER;
    }
    else
    {
        pillerImageName = Downward_PILLER;
    }
    
    SKSpriteNode* piller = [SKSpriteNode spriteNodeWithImageNamed:pillerImageName];
    piller.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:piller.size];
    piller.physicsBody.dynamic = YES;
    piller.physicsBody.categoryBitMask = pillerCategory;
    piller.physicsBody.contactTestBitMask = flappyBirdCategory;
    piller.physicsBody.collisionBitMask = 0;
    
    piller.physicsBody.affectedByGravity = NO;
    [self addChild:piller];
    
    return piller;
}

-(void)addPiller
{
    SKSpriteNode* upwardPiller = [self createPillerInUpwardDirection:YES];
    
    int minY = MINIMUM_PILLER_HEIGHT;
    int maxY = self.frame.size.height - MINIMUM_PILLER_HEIGHT - GAP_BETWEEN_ABOVE_AND_BELOW_PILLER - bottomScrollerHeight;
    
    int rangeY = maxY - minY;
    
    float upwardPillerY = ((arc4random() % rangeY) +minY) - upwardPiller.size.height;
    upwardPillerY += bottomScrollerHeight;
    upwardPillerY += upwardPiller.size.height * 0.2f;
    
    upwardPiller.position = CGPointMake(self.frame.size.width+upwardPiller.size.width, upwardPillerY);
    
    SKSpriteNode* downwardPiller = [self createPillerInUpwardDirection:NO];
    float downwardPillerY = upwardPillerY + bottomScrollerHeight + GAP_BETWEEN_ABOVE_AND_BELOW_PILLER;
    downwardPiller.position = CGPointMake(upwardPiller.position.x, downwardPillerY);
    
    SKAction* upwardActionMove = [SKAction moveToX:-upwardPiller.size.width/2 duration:(TIME*0.2)];
    SKAction* upwardActionMoveDone = [SKAction removeFromParent];
    [upwardPiller runAction:[SKAction sequence:@[upwardActionMove,upwardActionMoveDone]]];
    
    
    SKAction* downwardPillerMove = [SKAction moveToX:-downwardPiller.size.width/2 duration:(TIME*0.2)];
    SKAction* downwardPillerMoveDone = [SKAction removeFromParent];
    [downwardPiller runAction:[SKAction sequence:@[downwardPillerMove,downwardPillerMoveDone]]];
    
}

- (void)updateWithTimeSinceLastUpdate:(CFTimeInterval)timeSinceLast
{
    self.lastSpawnInterval += timeSinceLast;
    if (self.lastSpawnInterval > TIME)
    {
        self.lastSpawnInterval = 0;
        [self addPiller];
    }
}


- (void)update:(NSTimeInterval)currentTime
{
    
    if (self.lastUpdateTimeInterval)
    {
        _dt = currentTime - _lastUpdateTimeInterval;
    }
    else
    {
        _dt = 0;
    }
    
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > TIME)
    {
        timeSinceLast = 1.0 / (TIME * 60.0);
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
    
    
    [self moveBottomScroller];
}

@end
