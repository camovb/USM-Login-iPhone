//
//  AutoLoginViewController.m
//  AutoLogin
//
//  Created by Camilo Andr√©s Vera Bezmalinovic on 6/15/11.
//  Copyright 2011 Universidad Tecnica Federico Santa Mari¬≠a. All rights reserved.
//

#import "AutoLoginViewController.h"

//acepta los certificados chantas de la U
@interface NSURLRequest(anyssl)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host;
@end
@implementation NSURLRequest(anyssl)
+ (BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}
@end


@implementation AutoLoginViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    //fondo al navigation (43 para que se vea la linea)
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 43)];
    [bgView setBackgroundColor:[UIColor colorWithRed:0 green:200.0/255.0 blue:245.0/255.0 alpha:0.5]];
    [navBar insertSubview:bgView atIndex:0];
    [bgView release];
    
    //si tiene los datos guardados, los recupera
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NSString *password = [[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
    if (username) 
        [textFieldUser setText:username];
    if (password) 
        [textFieldPass setText:password];
    
    NSNumber *autoConnect = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto"];
    
    if (autoConnect && [autoConnect boolValue]) 
        [switchAutoConnect setOn:YES];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(applicationDidBecomeActive:) 
                                                 name:UIApplicationDidBecomeActiveNotification 
                                               object:nil];
    
    //indica el origen en Y de la primera notificación    
    for (int i=0; i<8; i++) 
        notificationSlot[i]=NO;
}

//si tiene guardado que intente conectar al iniciar...
-(void)applicationDidBecomeActive:(id)sender
{
    NSLog(@"Active");
    
    NSNumber *autoConnect = [[NSUserDefaults standardUserDefaults] objectForKey:@"auto"];
    
    if (autoConnect && [autoConnect boolValue]) 
        [self buttonLoginPressed:nil];
}

//esconde los teclados
-(IBAction)hideKeyboard:(id)sender
{
    [textFieldUser resignFirstResponder];
    [textFieldPass resignFirstResponder];
}

//si cambia el switch, elimna lo guardado o guarda
-(IBAction)switchSaveChangeValue:(id)sender
{
    if ([switchRemember isOn]) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:textFieldUser.text forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setObject:textFieldPass.text forKey:@"pass"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"pass"];
    }
    
    //si la acción la envia el boton
    if (sender) 
    {
        if ([switchRemember isOn]) 
        {
            [switchAutoConnect setEnabled:YES];
        }
        else
        {
            [switchAutoConnect setEnabled:NO];
            [switchAutoConnect setOn:NO animated:YES];
        }
    }
}
- (IBAction)switchAutoConnectChangeValue:(id)sender
{
    if ([switchAutoConnect isOn]) 
    {
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"auto"];
        [[NSUserDefaults standardUserDefaults] setObject:textFieldUser.text forKey:@"user"];
        [[NSUserDefaults standardUserDefaults] setObject:textFieldPass.text forKey:@"pass"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"auto"];
    }
}

-(IBAction)buttonLoginPressed:(id)sender
{
    
    [self hideKeyboard:nil];
    
    //valida los campos...
    if (!textFieldUser.text || [textFieldUser.text isEqualToString:@""]) 
    {
        [self showNotificationWithMessage:@"Debes escribir tu correo institucional"];
        return;
    }
    else if(!textFieldPass.text || [textFieldPass.text isEqualToString:@""])
    {
        [self showNotificationWithMessage:@"Debes escribir tu contraseña"];
        return;
    }
    
    //guarda los datos si es necesario
    [self switchSaveChangeValue:nil];
    
    //prepara la consulta
    NSString *post= [NSString stringWithFormat:@"username=%@&password=%@&buttonClicked=4",textFieldUser.text,textFieldPass.text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/login.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    //carga la consulta en un webView
    [webHidden loadRequest:request];
    [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(webViewDidTimeOut:) userInfo:nil repeats:NO];
    timeOut = NO;
}
-(IBAction)buttonLogoutPressed:(id)sender
{
    [self hideKeyboard:nil];
    
    [self switchSaveChangeValue:nil];
    
    //manda logout
    NSString *post= @"userStatus=1";
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    
    NSURL *url = [NSURL URLWithString:@"https://1.1.1.1/logout.html"];
    
    NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    
    [webHidden loadRequest:request];
    [NSTimer scheduledTimerWithTimeInterval:7.0 target:self selector:@selector(webViewDidTimeOut:) userInfo:nil repeats:NO];
    timeOut = NO;
}
- (IBAction)infoButtonDidPress:(id)sender
{
    InfoViewController *info = [[InfoViewController alloc] initWithNibName:@"InfoView" bundle:[NSBundle mainBundle]];
    [info setModalTransitionStyle:UIModalTransitionStylePartialCurl];
    [self presentModalViewController:info animated:YES];
    [info release];
}

-(void)showNotificationWithMessage:(NSString*)message
{
    CGFloat limit = 460;
    NSInteger index;
    for (index= 0; index < 8 ; index++) 
    {
        if (!notificationSlot[index]) 
        {
            notificationSlot[index] = YES;
            limit = limit-50*index;
            
            break;
        }
    }
    if (index==8) 
        return;
    
    UILabel *labelAux = [[UILabel alloc] initWithFrame:CGRectMake(5, limit, 310, 45)];
    [labelAux setBackgroundColor:[UIColor colorWithRed:205.0/255.0 green:205.0/255.0 blue:205.0/255.0 alpha:1.0]];
    [labelAux setFont:[UIFont systemFontOfSize:15]];
    [labelAux setTextColor:[UIColor darkGrayColor]];
    [labelAux setShadowColor:[UIColor whiteColor]];
    [labelAux setShadowOffset:CGSizeMake(0, 1)];
    [labelAux.layer setCornerRadius:10];
    [labelAux.layer setBorderColor:[UIColor darkGrayColor].CGColor];
    [labelAux.layer setBorderWidth:1.0];
    [labelAux setTextAlignment:UITextAlignmentCenter];
    [labelAux setText:message];
    [labelAux setTag:index];
    [self.view insertSubview:labelAux atIndex:20];
    [labelAux release];
    
    [self animationStart:labelAux];
    
    //[labelAux removeFromSuperview];
}

-(void)animationStart:(UILabel*)label
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0, -50);
    [UIView animateWithDuration:0.5 
                          delay:0 
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         label.transform = transform;
                     }
                     completion:^(BOOL finished) {
                         [self animationFinish:label];
                     }];
}
-(void)animationFinish:(UILabel*)label
{
    CGAffineTransform transform = CGAffineTransformMakeTranslation(320, -50);
    [UIView animateWithDuration:0.3 
                          delay:2.0 
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         label.transform = transform;
                     }
                     completion:^(BOOL finished) {
                        
                         notificationSlot[[label tag]] = NO;
                         [label removeFromSuperview];
                     }];
    
    
}
-(void)webViewDidStartLoad:(UIWebView *)webView
{
    //emiza a cargar, muestra el actitivy
    [activityIndicator setHidden:NO];
}


-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    //oculta el activity
    [activityIndicator setHidden:YES];

    NSString *urlString = [NSString stringWithFormat:@"%@",[webView.request URL]];

    
    if([urlString isEqualToString:@"https://1.1.1.1/logout.html"])
    {
        [self showNotificationWithMessage:@"Te has desconectado correctamente"];
    }

}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    
    NSLog(@"SHOULD START: %@",[request URL]);
    
    NSString *urlString = [NSString stringWithFormat:@"%@",[request URL]];
    
    
    //si intenta cargar usm, entonces perfect
    if ([urlString isEqualToString:@"http://www.usm.cl/"] || [urlString hasSuffix:@"statusCode=1"]) 
    {
        [self showNotificationWithMessage:@"Te has conectado correctamente"];
        [activityIndicator setHidden:YES];
        return NO;
    }
    else if ([urlString hasSuffix:@"statusCode=3"] || [urlString hasSuffix:@"statusCode=2"])
    {
        [self showNotificationWithMessage:@"Tu usuario ya está siendo utilizando por otro dispositivo"];
        [activityIndicator setHidden:YES];
        return NO;
        
    }
    else if ([urlString hasSuffix:@"statusCode=4"])
    {
        [self showNotificationWithMessage:@"Nombre de usuario y contraseña incorrectos"];
        [activityIndicator setHidden:YES];
        return NO;
        
    }
    else if([urlString hasSuffix:@"statusCode=5"])
    {
        [self showNotificationWithMessage:@"Nombre de usuario o contraseña incorrectos"];
        [activityIndicator setHidden:YES];
        return NO;
    }
    
    
    return YES;
}


-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [activityIndicator setHidden:YES];
    
    NSLog(@"FAIL! %@",error );
    
}
-(void)webViewDidTimeOut:(id)sender
{
    if ([webHidden isLoading] && !timeOut) 
    {
        [webHidden stopLoading];
        //[UIAlertView showAdviceWithMessage:@"Paso el tiempo máximo de espera"];
        [self showNotificationWithMessage:@"Paso el tiempo máximo de espera"];
        timeOut = YES;
    }
    
}


//el primero avancza al siguiente campo, y el otro envia..
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField tag]==777) 
    {
        [textFieldPass becomeFirstResponder];
    }
    else if([textField tag]==888)
    {
        [self buttonLoginPressed:nil];
    }
    
    return YES;
}


- (void)dealloc
{
    [super dealloc];
}

@end
