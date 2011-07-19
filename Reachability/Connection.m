//
//  Connection.m
//  SecondSense
//
//  Created by Camilo Andrés Vera Bezmalinovic on 4/10/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import "Connection.h"


@implementation Connection


+(BOOL)checkWithAlert:(BOOL)show
{
#warning Testear en la U
    //Falta probar si funciona.... no he testeado con esto en la U
	if ([[Reachability reachabilityWithHostName:@"https://1.1.1.1"] currentReachabilityStatus] == NotReachable)
	{
        if (show)
        {
            UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@"Aviso"
                                                           message:@"Asegurese de estar conectado a una red WIFI de la Universidad"
                                                          delegate:self 
                                                 cancelButtonTitle:@"Aceptar"
                                                 otherButtonTitles:nil];
            [alert show];
            [alert release];
        }
        
		return NO;
	}
	return YES;
}


@end
