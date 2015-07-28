//
//  PXSingleton.h
//
//
//  Created by Malek Belkahla on 28/10/10.
//  Copyright 2010 Proxym-IT. All rights reserved.
//

#ifndef PXSINGLETON_H

#define PXSINGLETON_H

#define PXSINGLETON(className) \
{ \
static className * singleton = nil; \
@synchronized (self) { \
if (singleton == nil) { \
singleton = [[className alloc] init]; \
} \
} \
return singleton; \
}

#endif
