//
//  ConrraDestinoDePlan.m
//  Conrra
//

#import "ConrraDestinoDePlan.h"

static NSString *sSitio = nil;
static CLLocationDegrees sLat = 0;
static CLLocationDegrees sLng = 0;
static BOOL sHay = NO;

@implementation ConrraDestinoDePlan

+ (void)dejarSitio:(NSString *)sitio
               lat:(CLLocationDegrees)lat
               lng:(CLLocationDegrees)lng {
    sSitio = [sitio copy];
    sLat   = lat;
    sLng   = lng;
    sHay   = YES;
}

+ (BOOL)hayPendiente {
    return sHay;
}

+ (NSString *)sitio {
    return sSitio;
}

+ (CLLocationDegrees)lat {
    return sLat;
}

+ (CLLocationDegrees)lng {
    return sLng;
}

+ (void)consumir {
    sSitio = nil;
    sLat   = 0;
    sLng   = 0;
    sHay   = NO;
}

@end
