//
//  XPCPlaneConnect.h
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XPCPlaneConnect : NSObject

- (instancetype)initWithHost:(NSString *) host;

-(void) getDREF:(NSString *) dref;

@end
