//
//  MapViewDelegateProxy.m
//  UserTrackingButton
//

#import "MapViewDelegateProxy.h"

@interface MapViewDelegateProxy()

@property (nonatomic, weak) id<MKMapViewDelegate> orignalDelegate;
@property (nonatomic, weak) id<MKMapViewDelegate> target;
@property (nonatomic, weak) MKMapView *mapView;

@end

@implementation MapViewDelegateProxy

- (instancetype)initWithMapView:(MKMapView *)mapView target:(id<MKMapViewDelegate>)target
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
    [self updateDelegates];
}

- (void)dealloc
{
    [self.mapView removeObserver:self forKeyPath:@"delegate"];
    self.mapView.delegate = self.target;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.mapView removeObserver:self forKeyPath:@"delegate"];
    [self updateDelegates];
}

- (void)updateDelegates
{
    // Support for CCHMapClusterController.
    if ([self.mapView.delegate respondsToSelector:NSSelectorFromString(@"addDelegate:")])
    {
        id delegate = self.mapView.delegate;
        SEL selector = NSSelectorFromString(@"addDelegate:");
        ((void (*)(id, SEL))[delegate methodForSelector:selector])(delegate, selector);
    }
    else
    {
        self.orignalDelegate = self.mapView.delegate;
        self.mapView.delegate = self;
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
