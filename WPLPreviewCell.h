// WPLPreviewCell.h

#import <Preferences/PSTableCell.h>
#import <Preferences/PSSpecifier.h>

@interface WPLPreviewCell : PSTableCell

@property (nonatomic, retain) UIImageView *lightImageView;
@property (nonatomic, retain) UIImageView *darkImageView;

- (id)initWithSpecifier:(PSSpecifier *)specifier;
- (void)update;

@end
