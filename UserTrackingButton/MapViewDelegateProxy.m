//
//  MapViewDelegateProxy.m
//  UserTrackingButton
//

#import "MapViewDelegateProxy.h"

@interface MapViewDelegateProxy() {
    /**
     The recapturing status. Will be set to false eventually, if
     there are cyclic reference to other similar proxies.
     */
    BOOL _recapture;
}

@property (nonatomic, readwrite, weak) id<MKMapViewDelegate> orignalDelegate;
@property (nonatomic, readwrite, nonnull) id<MKMapViewDelegate> target;
@property (nonatomic, readwrite, nonnull) MKMapView *mapView;

@end

@implementation MapViewDelegateProxy

- (nonnull instancetype)initWithMapView:(nonnull MKMapView *)mapView target:(nonnull id<MKMapViewDelegate>)target
{
    if (self = [super init])
    {
        _target = target;
        _mapView = mapView;
        [self setup];
    }
    return self;
}

- (void)setup
{
    _recapture = YES;
    [self updateDelegates];
}

- (void)dealloc
{
    [self.mapView removeObserver:self forKeyPath:@"delegate"];
    self.mapView.delegate = self.target;
}

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    [self.mapView removeObserver:self forKeyPath:@"delegate"];
    [self updateDelegates];
}

- (void)updateDelegates
{
    if (!_recapture) return;
    
    if (self.orignalDelegate != nil && self.orignalDelegate == self.mapView.delegate)
    {
        // Don't fight it.
        _recapture = NO;
        self.orignalDelegate = nil;
    }
    else
    {
        id<MKMapViewDelegate> orignalDelegate = self.mapView.delegate;
        self.orignalDelegate = nil;
        
        // While setting the map view delegate make sure we don't reference the
        // original delegate. This can cause cyclic respondsToSelector calls.
        self.mapView.delegate = self;
        self.orignalDelegate = orignalDelegate;
        
        [self.mapView addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:NULL];
    }
}

- (BOOL)respondsToSelector:(SEL)selector
{
    // Part of the implementation.
    if ([super respondsToSelector:selector])
    {
        return YES;
    }
    
    // Otherwise ask delegates
    return [self.orignalDelegate respondsToSelector:selector]
    || [self.target respondsToSelector:selector];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    // can this class create the signature?
    NSMethodSignature* signature = [super methodSignatureForSelector:aSelector];
    
    // if not, try our delegates
    if (!signature)
    {
        if ([self.orignalDelegate respondsToSelector:aSelector])
        {
            signature = [(id)self.orignalDelegate methodSignatureForSelector:aSelector];
        }
        else
        {
            signature = [(id)self.target methodSignatureForSelector:aSelector];
        }
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if ([self.orignalDelegate respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.orignalDelegate];
    }
    
    if ([self.target respondsToSelector:invocation.selector])
    {
        [invocation invokeWithTarget:self.target];
    }
}

@end
