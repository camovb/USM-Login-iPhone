//
//  Connection.h
//  SecondSense
//
//  Created by Camilo Andrés Vera Bezmalinovic on 4/10/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari­a. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Reachability.h"


@interface Connection : NSObject
{
    
}

/**
 
 Verifica si es posible conectarse a la urlBase,
 Puede enviar una alerta notificando la falta de conexión
 
 @param show Booleano, indica si muestra alerta
 
 */
+(BOOL)checkWithAlert:(BOOL)show;

@end
