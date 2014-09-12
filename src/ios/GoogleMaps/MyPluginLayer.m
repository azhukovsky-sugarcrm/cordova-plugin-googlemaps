//
//  DummyView.m
//  DevApp
//
//  Created by masashi on 8/13/14.
//
//

#import "MyPluginLayer.h"

@implementation MyPluginLayer

NSMutableDictionary *HTMLNodes = nil;

-  (id)initWithFrame:(CGRect)aRect
{
  self = [super initWithFrame:aRect];
  HTMLNodes = [[NSMutableDictionary alloc] init];
  self.clickable = YES;
  return self;
}


- (void)putHTMLElement:(NSString *)domId size:(NSDictionary *)size {
  [HTMLNodes setObject:size forKey:domId];
}
- (void)removeHTMLElement:(NSString *)domId {
  [HTMLNodes removeObjectForKey:domId];
}
- (void)clearHTMLElement {
  [HTMLNodes removeAllObjects];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
  if (self.clickable == NO ||
      self.mapCtrl.map.hidden == YES) {
    return [super hitTest:point withEvent:event];
  }
  
  float offsetX = self.webView.scrollView.contentOffset.x;// + self.mapCtrl.view.frame.origin.x;
  float offsetY = self.webView.scrollView.contentOffset.y;// + self.mapCtrl.view.frame.origin.y;
  
  float left = [[self.embedRect objectForKey:@"left"] floatValue] - offsetX;
  float top = [[self.embedRect objectForKey:@"top"] floatValue] - offsetY;
  float width = [[self.embedRect objectForKey:@"width"] floatValue];
  float height = [[self.embedRect objectForKey:@"height"] floatValue];
  
  BOOL isMapAction = NO;
  if (point.x >= left && point.x <= (left + width) &&
      point.y >= top && point.y <= (top + height)) {
    isMapAction = YES;
  } else {
    isMapAction = NO;
  }
  if (isMapAction == YES) {
    NSDictionary *elemSize;
    for (NSString *domId in HTMLNodes) {
      elemSize = [HTMLNodes objectForKey:domId];
      left = [[elemSize objectForKey:@"left"] floatValue] - offsetX;
      top = [[elemSize objectForKey:@"top"] floatValue] - offsetY;
      width = [[elemSize objectForKey:@"width"] floatValue];
      height = [[elemSize objectForKey:@"height"] floatValue];
      
      if (point.x >= left && point.x <= (left + width) &&
          point.y >= top && point.y <= (top + height)) {
        isMapAction = NO;
        break;
      }
      
    }
  }
  if (isMapAction == YES) {
    offsetX += self.mapCtrl.view.frame.origin.x;
    offsetY += self.mapCtrl.view.frame.origin.y;
    point.x -= offsetX;
    point.y -= offsetY;
    
    UIView *hit =[self.mapCtrl.view hitTest:point withEvent:event];
    NSString *hitClass = [NSString stringWithFormat:@"%@", [hit class]];
    if ([PluginUtil isIOS7_OR_OVER] &&
        [hitClass isEqualToString:@"UIButton"] &&
        self.mapCtrl.map.isMyLocationEnabled &&
        (point.x  + offsetX) >= (left + width - 50) &&
         (point.y + offsetY) >= (top + height - 50)) {
      [self.mapCtrl didTapMyLocationButtonForMapView:self.mapCtrl.map];
    }
    return [self.mapCtrl.view hitTest:point withEvent:event];
  }
  
  return [super hitTest:point withEvent:event];
}

@end
