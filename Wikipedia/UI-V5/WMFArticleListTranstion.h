
@import UIKit;

@class WMFArticleListCollectionViewController;
@class WMFArticleContainerViewController;

@interface WMFArticleListTranstion : UIPercentDrivenInteractiveTransition
    <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isDismissing;
@property (nonatomic, assign) BOOL isPresenting;

@property (nonatomic, weak) WMFArticleListCollectionViewController* listViewController;
@property (nonatomic, weak) WMFArticleContainerViewController* articleContainerViewController;

/**
 *  Duration of the animation when not interactive
 */
@property (assign, nonatomic) NSTimeInterval nonInteractiveDuration;

@end

@protocol WMFArticleListTranstioning <NSObject>

- (UIView*)viewForTransition:(WMFArticleListTranstion*)transition;
- (CGRect)frameOfOverlappingListItemsForTransition:(WMFArticleListTranstion*)transition;

@end
