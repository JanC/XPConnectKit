//
//  XPCPlaneConnect.m
//  XPConnectKit
//
//  Created by Jan Chaloupecky on 04.12.17.
//  Copyright © 2017 TequilaApps. All rights reserved.
//

#import "XPCPlaneConnect.h"
#import "xplaneConnect.h"

@interface XPCPlaneConnect () {
    XPCSocket _socket;
}


@end

@implementation XPCPlaneConnect

- (instancetype)initWithHost:(NSString *)host
{
    self = [super init];
    if (self) {

        const char *IP = [host cStringUsingEncoding:NSUTF8StringEncoding];
        _socket = openUDP(IP);
    }

    return self;
}

- (void)getDREF:(NSString *)dref
{
//    float values = 0.0F;
//    int size = 1;
    int size = 50;
    float *values = (float *) malloc(size * sizeof(float));
    
    if(getDREF(_socket, [dref cStringUsingEncoding:NSUTF8StringEncoding], values, &size) < 0) {
        // error
        return;
    }
}


@end
