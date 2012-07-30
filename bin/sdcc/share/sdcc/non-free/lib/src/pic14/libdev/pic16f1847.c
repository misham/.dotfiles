/* Register definitions for pic16f1847.
 * This file was automatically generated by:
 *   inc2h.pl V4850
 *   Copyright (c) 2002, Kevin L. Pauba, All Rights Reserved
 */
#include <pic16f1847.h>

__sfr  __at (INDF0_ADDR)                   INDF0;
__sfr  __at (INDF1_ADDR)                   INDF1;
__sfr  __at (PCL_ADDR)                     PCL;
__sfr  __at (STATUS_ADDR)                  STATUS;
__sfr  __at (FSR0_ADDR)                    FSR0;
__sfr  __at (FSR0L_ADDR)                   FSR0L;
__sfr  __at (FSR0H_ADDR)                   FSR0H;
__sfr  __at (FSR1_ADDR)                    FSR1;
__sfr  __at (FSR1L_ADDR)                   FSR1L;
__sfr  __at (FSR1H_ADDR)                   FSR1H;
__sfr  __at (BSR_ADDR)                     BSR;
__sfr  __at (WREG_ADDR)                    WREG;
__sfr  __at (PCLATH_ADDR)                  PCLATH;
__sfr  __at (INTCON_ADDR)                  INTCON;
__sfr  __at (PORTA_ADDR)                   PORTA;
__sfr  __at (PORTB_ADDR)                   PORTB;
__sfr  __at (PIR1_ADDR)                    PIR1;
__sfr  __at (PIR2_ADDR)                    PIR2;
__sfr  __at (PIR3_ADDR)                    PIR3;
__sfr  __at (PIR4_ADDR)                    PIR4;
__sfr  __at (TMR0_ADDR)                    TMR0;
__sfr  __at (TMR1_ADDR)                    TMR1;
__sfr  __at (TMR1L_ADDR)                   TMR1L;
__sfr  __at (TMR1H_ADDR)                   TMR1H;
__sfr  __at (T1CON_ADDR)                   T1CON;
__sfr  __at (T1GCON_ADDR)                  T1GCON;
__sfr  __at (TMR2_ADDR)                    TMR2;
__sfr  __at (PR2_ADDR)                     PR2;
__sfr  __at (T2CON_ADDR)                   T2CON;
__sfr  __at (CPSCON0_ADDR)                 CPSCON0;
__sfr  __at (CPSCON1_ADDR)                 CPSCON1;
__sfr  __at (TRISA_ADDR)                   TRISA;
__sfr  __at (TRISB_ADDR)                   TRISB;
__sfr  __at (PIE1_ADDR)                    PIE1;
__sfr  __at (PIE2_ADDR)                    PIE2;
__sfr  __at (PIE3_ADDR)                    PIE3;
__sfr  __at (PIE4_ADDR)                    PIE4;
__sfr  __at (OPTION_REG_ADDR)              OPTION_REG;
__sfr  __at (PCON_ADDR)                    PCON;
__sfr  __at (WDTCON_ADDR)                  WDTCON;
__sfr  __at (OSCTUNE_ADDR)                 OSCTUNE;
__sfr  __at (OSCCON_ADDR)                  OSCCON;
__sfr  __at (OSCSTAT_ADDR)                 OSCSTAT;
__sfr  __at (ADRES_ADDR)                   ADRES;
__sfr  __at (ADRESL_ADDR)                  ADRESL;
__sfr  __at (ADRESH_ADDR)                  ADRESH;
__sfr  __at (ADCON0_ADDR)                  ADCON0;
__sfr  __at (ADCON1_ADDR)                  ADCON1;
__sfr  __at (LATA_ADDR)                    LATA;
__sfr  __at (LATB_ADDR)                    LATB;
__sfr  __at (CM1CON0_ADDR)                 CM1CON0;
__sfr  __at (CM1CON1_ADDR)                 CM1CON1;
__sfr  __at (CM2CON0_ADDR)                 CM2CON0;
__sfr  __at (CM2CON1_ADDR)                 CM2CON1;
__sfr  __at (CMOUT_ADDR)                   CMOUT;
__sfr  __at (BORCON_ADDR)                  BORCON;
__sfr  __at (FVRCON_ADDR)                  FVRCON;
__sfr  __at (DACCON0_ADDR)                 DACCON0;
__sfr  __at (DACCON1_ADDR)                 DACCON1;
__sfr  __at (SRCON0_ADDR)                  SRCON0;
__sfr  __at (SRCON1_ADDR)                  SRCON1;
__sfr  __at (APFCON0_ADDR)                 APFCON0;
__sfr  __at (APFCON1_ADDR)                 APFCON1;
__sfr  __at (ANSELA_ADDR)                  ANSELA;
__sfr  __at (ANSELB_ADDR)                  ANSELB;
__sfr  __at (EEADR_ADDR)                   EEADR;
__sfr  __at (EEADRL_ADDR)                  EEADRL;
__sfr  __at (EEADRH_ADDR)                  EEADRH;
__sfr  __at (EEDAT_ADDR)                   EEDAT;
__sfr  __at (EEDATL_ADDR)                  EEDATL;
__sfr  __at (EEDATH_ADDR)                  EEDATH;
__sfr  __at (EECON1_ADDR)                  EECON1;
__sfr  __at (EECON2_ADDR)                  EECON2;
__sfr  __at (RCREG_ADDR)                   RCREG;
__sfr  __at (TXREG_ADDR)                   TXREG;
__sfr  __at (SPBRG_ADDR)                   SPBRG;
__sfr  __at (SPBRGL_ADDR)                  SPBRGL;
__sfr  __at (SPBRGH_ADDR)                  SPBRGH;
__sfr  __at (RCSTA_ADDR)                   RCSTA;
__sfr  __at (TXSTA_ADDR)                   TXSTA;
__sfr  __at (BAUDCON_ADDR)                 BAUDCON;
__sfr  __at (WPUA_ADDR)                    WPUA;
__sfr  __at (WPUB_ADDR)                    WPUB;
__sfr  __at (SSP1BUF_ADDR)                 SSP1BUF;
__sfr  __at (SSPBUF_ADDR)                  SSPBUF;
__sfr  __at (SSP1ADD_ADDR)                 SSP1ADD;
__sfr  __at (SSPADD_ADDR)                  SSPADD;
__sfr  __at (SSP1MSK_ADDR)                 SSP1MSK;
__sfr  __at (SSPMSK_ADDR)                  SSPMSK;
__sfr  __at (SSP1STAT_ADDR)                SSP1STAT;
__sfr  __at (SSPSTAT_ADDR)                 SSPSTAT;
__sfr  __at (SSP1CON1_ADDR)                SSP1CON1;
__sfr  __at (SSPCON_ADDR)                  SSPCON;
__sfr  __at (SSPCON1_ADDR)                 SSPCON1;
__sfr  __at (SSP1CON2_ADDR)                SSP1CON2;
__sfr  __at (SSPCON2_ADDR)                 SSPCON2;
__sfr  __at (SSP1CON3_ADDR)                SSP1CON3;
__sfr  __at (SSPCON3_ADDR)                 SSPCON3;
__sfr  __at (SSP2BUF_ADDR)                 SSP2BUF;
__sfr  __at (SSP2ADD_ADDR)                 SSP2ADD;
__sfr  __at (SSP2MSK_ADDR)                 SSP2MSK;
__sfr  __at (SSP2STAT_ADDR)                SSP2STAT;
__sfr  __at (SSP2CON1_ADDR)                SSP2CON1;
__sfr  __at (SSP2CON2_ADDR)                SSP2CON2;
__sfr  __at (SSP2CON3_ADDR)                SSP2CON3;
__sfr  __at (CCPR1L_ADDR)                  CCPR1L;
__sfr  __at (CCPR1H_ADDR)                  CCPR1H;
__sfr  __at (CCP1CON_ADDR)                 CCP1CON;
__sfr  __at (PWM1CON_ADDR)                 PWM1CON;
__sfr  __at (CCP1AS_ADDR)                  CCP1AS;
__sfr  __at (ECCP1AS_ADDR)                 ECCP1AS;
__sfr  __at (PSTR1CON_ADDR)                PSTR1CON;
__sfr  __at (CCPR2L_ADDR)                  CCPR2L;
__sfr  __at (CCPR2H_ADDR)                  CCPR2H;
__sfr  __at (CCP2CON_ADDR)                 CCP2CON;
__sfr  __at (PWM2CON_ADDR)                 PWM2CON;
__sfr  __at (CCP2AS_ADDR)                  CCP2AS;
__sfr  __at (ECCP2AS_ADDR)                 ECCP2AS;
__sfr  __at (PSTR2CON_ADDR)                PSTR2CON;
__sfr  __at (CCPTMRS_ADDR)                 CCPTMRS;
__sfr  __at (CCPTMRS0_ADDR)                CCPTMRS0;
__sfr  __at (CCPR3L_ADDR)                  CCPR3L;
__sfr  __at (CCPR3H_ADDR)                  CCPR3H;
__sfr  __at (CCP3CON_ADDR)                 CCP3CON;
__sfr  __at (CCPR4L_ADDR)                  CCPR4L;
__sfr  __at (CCPR4H_ADDR)                  CCPR4H;
__sfr  __at (CCP4CON_ADDR)                 CCP4CON;
__sfr  __at (IOCBP_ADDR)                   IOCBP;
__sfr  __at (IOCBN_ADDR)                   IOCBN;
__sfr  __at (IOCBF_ADDR)                   IOCBF;
__sfr  __at (CLKRCON_ADDR)                 CLKRCON;
__sfr  __at (MDCON_ADDR)                   MDCON;
__sfr  __at (MDSRC_ADDR)                   MDSRC;
__sfr  __at (MDCARL_ADDR)                  MDCARL;
__sfr  __at (MDCARH_ADDR)                  MDCARH;
__sfr  __at (TMR4_ADDR)                    TMR4;
__sfr  __at (PR4_ADDR)                     PR4;
__sfr  __at (T4CON_ADDR)                   T4CON;
__sfr  __at (TMR6_ADDR)                    TMR6;
__sfr  __at (PR6_ADDR)                     PR6;
__sfr  __at (T6CON_ADDR)                   T6CON;
__sfr  __at (STATUS_SHAD_ADDR)             STATUS_SHAD;
__sfr  __at (WREG_SHAD_ADDR)               WREG_SHAD;
__sfr  __at (BSR_SHAD_ADDR)                BSR_SHAD;
__sfr  __at (PCLATH_SHAD_ADDR)             PCLATH_SHAD;
__sfr  __at (FSR0L_SHAD_ADDR)              FSR0L_SHAD;
__sfr  __at (FSR0H_SHAD_ADDR)              FSR0H_SHAD;
__sfr  __at (FSR1L_SHAD_ADDR)              FSR1L_SHAD;
__sfr  __at (FSR1H_SHAD_ADDR)              FSR1H_SHAD;
__sfr  __at (STKPTR_ADDR)                  STKPTR;
__sfr  __at (TOSL_ADDR)                    TOSL;
__sfr  __at (TOSH_ADDR)                    TOSH;

// 
// bitfield definitions
// 
volatile __ADCON0bits_t __at(ADCON0_ADDR) ADCON0bits;
volatile __ADCON1bits_t __at(ADCON1_ADDR) ADCON1bits;
volatile __ANSELAbits_t __at(ANSELA_ADDR) ANSELAbits;
volatile __ANSELBbits_t __at(ANSELB_ADDR) ANSELBbits;
volatile __APFCON0bits_t __at(APFCON0_ADDR) APFCON0bits;
volatile __APFCON1bits_t __at(APFCON1_ADDR) APFCON1bits;
volatile __BAUDCONbits_t __at(BAUDCON_ADDR) BAUDCONbits;
volatile __BORCONbits_t __at(BORCON_ADDR) BORCONbits;
volatile __BSRbits_t __at(BSR_ADDR) BSRbits;
volatile __CCP1ASbits_t __at(CCP1AS_ADDR) CCP1ASbits;
volatile __CCP1CONbits_t __at(CCP1CON_ADDR) CCP1CONbits;
volatile __CCP2ASbits_t __at(CCP2AS_ADDR) CCP2ASbits;
volatile __CCP2CONbits_t __at(CCP2CON_ADDR) CCP2CONbits;
volatile __CCP3CONbits_t __at(CCP3CON_ADDR) CCP3CONbits;
volatile __CCP4CONbits_t __at(CCP4CON_ADDR) CCP4CONbits;
volatile __CCPTMRSbits_t __at(CCPTMRS_ADDR) CCPTMRSbits;
volatile __CCPTMRS0bits_t __at(CCPTMRS0_ADDR) CCPTMRS0bits;
volatile __CLKRCONbits_t __at(CLKRCON_ADDR) CLKRCONbits;
volatile __CM1CON0bits_t __at(CM1CON0_ADDR) CM1CON0bits;
volatile __CM1CON1bits_t __at(CM1CON1_ADDR) CM1CON1bits;
volatile __CM2CON0bits_t __at(CM2CON0_ADDR) CM2CON0bits;
volatile __CM2CON1bits_t __at(CM2CON1_ADDR) CM2CON1bits;
volatile __CMOUTbits_t __at(CMOUT_ADDR) CMOUTbits;
volatile __CPSCON0bits_t __at(CPSCON0_ADDR) CPSCON0bits;
volatile __CPSCON1bits_t __at(CPSCON1_ADDR) CPSCON1bits;
volatile __DACCON0bits_t __at(DACCON0_ADDR) DACCON0bits;
volatile __DACCON1bits_t __at(DACCON1_ADDR) DACCON1bits;
volatile __ECCP1ASbits_t __at(ECCP1AS_ADDR) ECCP1ASbits;
volatile __ECCP2ASbits_t __at(ECCP2AS_ADDR) ECCP2ASbits;
volatile __EECON1bits_t __at(EECON1_ADDR) EECON1bits;
volatile __FVRCONbits_t __at(FVRCON_ADDR) FVRCONbits;
volatile __INTCONbits_t __at(INTCON_ADDR) INTCONbits;
volatile __IOCBFbits_t __at(IOCBF_ADDR) IOCBFbits;
volatile __IOCBNbits_t __at(IOCBN_ADDR) IOCBNbits;
volatile __IOCBPbits_t __at(IOCBP_ADDR) IOCBPbits;
volatile __LATAbits_t __at(LATA_ADDR) LATAbits;
volatile __LATBbits_t __at(LATB_ADDR) LATBbits;
volatile __MDCARHbits_t __at(MDCARH_ADDR) MDCARHbits;
volatile __MDCARLbits_t __at(MDCARL_ADDR) MDCARLbits;
volatile __MDCONbits_t __at(MDCON_ADDR) MDCONbits;
volatile __MDSRCbits_t __at(MDSRC_ADDR) MDSRCbits;
volatile __OPTION_REGbits_t __at(OPTION_REG_ADDR) OPTION_REGbits;
volatile __OSCCONbits_t __at(OSCCON_ADDR) OSCCONbits;
volatile __OSCSTATbits_t __at(OSCSTAT_ADDR) OSCSTATbits;
volatile __OSCTUNEbits_t __at(OSCTUNE_ADDR) OSCTUNEbits;
volatile __PCONbits_t __at(PCON_ADDR) PCONbits;
volatile __PIE1bits_t __at(PIE1_ADDR) PIE1bits;
volatile __PIE2bits_t __at(PIE2_ADDR) PIE2bits;
volatile __PIE3bits_t __at(PIE3_ADDR) PIE3bits;
volatile __PIE4bits_t __at(PIE4_ADDR) PIE4bits;
volatile __PIR1bits_t __at(PIR1_ADDR) PIR1bits;
volatile __PIR2bits_t __at(PIR2_ADDR) PIR2bits;
volatile __PIR3bits_t __at(PIR3_ADDR) PIR3bits;
volatile __PIR4bits_t __at(PIR4_ADDR) PIR4bits;
volatile __PORTAbits_t __at(PORTA_ADDR) PORTAbits;
volatile __PORTBbits_t __at(PORTB_ADDR) PORTBbits;
volatile __PSTR1CONbits_t __at(PSTR1CON_ADDR) PSTR1CONbits;
volatile __PSTR2CONbits_t __at(PSTR2CON_ADDR) PSTR2CONbits;
volatile __PWM1CONbits_t __at(PWM1CON_ADDR) PWM1CONbits;
volatile __PWM2CONbits_t __at(PWM2CON_ADDR) PWM2CONbits;
volatile __RCSTAbits_t __at(RCSTA_ADDR) RCSTAbits;
volatile __SRCON0bits_t __at(SRCON0_ADDR) SRCON0bits;
volatile __SRCON1bits_t __at(SRCON1_ADDR) SRCON1bits;
volatile __SSP1CON1bits_t __at(SSP1CON1_ADDR) SSP1CON1bits;
volatile __SSP1CON2bits_t __at(SSP1CON2_ADDR) SSP1CON2bits;
volatile __SSP1CON3bits_t __at(SSP1CON3_ADDR) SSP1CON3bits;
volatile __SSP1STATbits_t __at(SSP1STAT_ADDR) SSP1STATbits;
volatile __SSP2CON1bits_t __at(SSP2CON1_ADDR) SSP2CON1bits;
volatile __SSP2CON2bits_t __at(SSP2CON2_ADDR) SSP2CON2bits;
volatile __SSP2CON3bits_t __at(SSP2CON3_ADDR) SSP2CON3bits;
volatile __SSP2STATbits_t __at(SSP2STAT_ADDR) SSP2STATbits;
volatile __SSPCONbits_t __at(SSPCON_ADDR) SSPCONbits;
volatile __SSPCON1bits_t __at(SSPCON1_ADDR) SSPCON1bits;
volatile __SSPCON2bits_t __at(SSPCON2_ADDR) SSPCON2bits;
volatile __SSPCON3bits_t __at(SSPCON3_ADDR) SSPCON3bits;
volatile __SSPSTATbits_t __at(SSPSTAT_ADDR) SSPSTATbits;
volatile __STATUSbits_t __at(STATUS_ADDR) STATUSbits;
volatile __STATUS_SHADbits_t __at(STATUS_SHAD_ADDR) STATUS_SHADbits;
volatile __T1CONbits_t __at(T1CON_ADDR) T1CONbits;
volatile __T1GCONbits_t __at(T1GCON_ADDR) T1GCONbits;
volatile __T2CONbits_t __at(T2CON_ADDR) T2CONbits;
volatile __T4CONbits_t __at(T4CON_ADDR) T4CONbits;
volatile __T6CONbits_t __at(T6CON_ADDR) T6CONbits;
volatile __TRISAbits_t __at(TRISA_ADDR) TRISAbits;
volatile __TRISBbits_t __at(TRISB_ADDR) TRISBbits;
volatile __TXSTAbits_t __at(TXSTA_ADDR) TXSTAbits;
volatile __WDTCONbits_t __at(WDTCON_ADDR) WDTCONbits;
volatile __WPUAbits_t __at(WPUA_ADDR) WPUAbits;
volatile __WPUBbits_t __at(WPUB_ADDR) WPUBbits;

