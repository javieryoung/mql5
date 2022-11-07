//+------------------------------------------------------------------+
//|                                                         US30.mq4 |
//|                                                 Cronopio Trading |
//+------------------------------------------------------------------+
#property copyright "Cronopio Trading"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

#include <../Experts/Breakout/utilidades/mql4_to_mql5.mqh>
#include <../Experts/Breakout/utilidades/MT4Orders.mqh>

input int Magic = 11;
input int operacionesPorDia = 2; // // operaciones por día
input double sl = 50.0; // stoploss
input double tp = 50.0; // takeprofit
input bool slFijo = false; // fijar el stoploss 

input int timezone = 3; // MetaTrader timezone

/*
#define  LIC_TRADE_MODES      { ACCOUNT_TRADE_MODE_CONTEST, ACCOUNT_TRADE_MODE_DEMO }
#define  LIC_EXPIRES_DAYS  5
#define  LIC_EXPIRES_START D'2021.11.11'
*/

#include <../Experts/Volatilidad/FuncionesComunes.mqh>
double usedRisk = risk;


double max = 0.0;
double min = 30000000.0;
int diaActual = 0;
int operacionesHechasHoy = 0;

int ticketBuy;
int ticketSell;



int OnInit()
  {
  
   long  account  =  AccountInfoInteger(ACCOUNT_LOGIN);
   // if (!in_array(account)){
    datetime now = TimeCurrent();
    datetime expiration = StringToTime("2022.12.07 12:00:00");
    Print(now);
    Print(expiration);
    if (expiration < now) {
      Print("CUENTA INVALIDA");
      return(INIT_FAILED);
   }
   
   Print ("Checkeando licencia...");
   // if (!LicenceCheck()) return(INIT_FAILED);
//---
   Print("Se cargó el Expert a la gráfica...");
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Print("Se eliminó el Expert a la gráfica...");
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   checkCambioDeEstado();
   
   // Maximo de operaciones por día
   if (operacionesHechasHoy >= operacionesPorDia) {
      cerrarPendientes();
   } else {
      if (filtro()) {
         abrirPending();
      } else { 
         cerrarPendientes();
      }
   }
   
   
   if (breakEvenFactor != 0 && trailingStopFactor == 0) checkBreakEven();
   if (trailingStopFactor != 0) checkTrailingStop();
   
   if (diaActual != Day()) {
      diaActual = Day();
      
      operacionesHechasHoy = 0;
      usedRisk = risk;
   }
   
  }
//+------------------------------------------------------------------+


double sl() {
    if (sl > max - min) 
        return max - min;
    else
        return sl;
}


double tp() {
    if (tp > max - min) 
        return sl;
    else
        return tp;
}


int estadoOrdenCompra;
int estadoOrdenVenta;
void checkCambioDeEstado() {
   OrderSelect(ticketBuy, SELECT_BY_TICKET);
   if (estadoOrdenCompra == OP_BUYSTOP && OrderType() == OP_BUY) {
      operacionesHechasHoy++;
   }
   
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   if (estadoOrdenVenta == OP_SELLSTOP && OrderType() == OP_SELL) {
      operacionesHechasHoy++;
   }
      
   OrderSelect(ticketBuy, SELECT_BY_TICKET);
   estadoOrdenCompra = OrderType();
   OrderSelect(ticketSell, SELECT_BY_TICKET);
   estadoOrdenVenta = OrderType();
   
   
   
}


// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
    calcularMinimoYMaximo();
    if (Ask < max && Bid > min) {
        bool buy = true;
        bool sell = true;
        for(int i = 0; i < OrdersTotal(); i++){
        if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
            if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
                
                if (OrderType() == OP_BUY || OrderType() == OP_BUYSTOP) {
                    buy = false;
                }   
                
                if (OrderType() == OP_SELL || OrderType() == OP_SELLSTOP) {
                    sell = false;
                }
                
            }
        }
        }
        
        
        double volume = calculateLotSize(sl());
        if (buy) {
        double useTp;
        useTp = max + tp();
        ticketBuy = OrderSend(NULL, OP_BUYSTOP, volume, max, 0.1, max-sl(), useTp, "", Magic);
        }
        if (sell) {
        double useTp;
        useTp = min - tp();
        ticketSell = OrderSend(NULL, OP_SELLSTOP, volume, min, 0.1, min+sl(), useTp, "", Magic);
        }
    }
}

void cerrarPendientes() {
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
            }   
            
         }
      }
   }
}

void calcularMinimoYMaximo() {
   int startHour = fixHourTimezone(9);
   int finishHour = fixHourTimezone(12);
   min = 30000000.0;
   max = 0.0;
   for (int i = startHour; i < finishHour; i++) {

        
        string s;
        StringConcatenate(s, Year(), ".", Month(), ".", Day(), " ", IntegerToString(i) ,":00:00");
      datetime time = StringToTime(s);
      int shift = iBarShift(Symbol(), PERIOD_H1, time);
      double high = iHigh(Symbol(), PERIOD_H1,shift);
      double low = iLow(Symbol(), PERIOD_H1,shift);
      
      if (high > max) {
         max = high;
      }
      if (low < min) {
         min = low;
      }
   }
   
   
   // falta primera vela de 5 min
   
   
        string s;
        StringConcatenate(s, Year(), ".", Month(), ".", Day(), " ", IntegerToString(finishHour) ,":00:00");
      datetime time = StringToTime(s);
   int shift = iBarShift(Symbol(), PERIOD_M5, time);
   double high = iHigh(Symbol(), PERIOD_M5,shift);
   double low = iLow(Symbol(), PERIOD_M5,shift);
   
   if (high > max) {
      max = high;
   }
   if (low < min) {
      min = low;
   }
  
}



bool filtro() {
   // Hora
   bool afterOpen = Hour() > fixHourTimezone(13) || (Hour() == fixHourTimezone(13) && Minute() >= 30);
   bool beforeClose = Hour() < fixHourTimezone(14);
   
   return afterOpen && beforeClose ;
}