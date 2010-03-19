/*
 *  GlusterFS.h
 *  GlusterFS
 *
 *  Created by Scott Jann on 5/17/09.
 *  Copyright (c) 2009 Scott Jann
 *
 */

#undef NSLocalizedStringFromTable
#define NSLocalizedStringFromTable(key, tbl, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:(tbl)]
