//+------------------------------------------------------------------+
//|                                              La vela Definitiva  |
//|                                                     Javier Young |
//|                                                 https://young.uy |
//+------------------------------------------------------------------+
#property copyright "Javier Young"
#property link      "https://young.uy"
#property version   "1.10"
#property strict

#include <../Experts/Breakout/utilidades/mql4_to_mql5.mqh>
#include <../Experts/Breakout/utilidades/MT4Orders.mqh>
input int Magic = 24;

input double sl = 5; // stoploss
input double tp = 15; // takeprofit
input bool cerrarSiHayTp = true; // si la primera operacion toca TP cerrar la segunda
input double minimoParaOperar = 5;
double minimoParaUsarLoca = 0;
input bool abrirCompra = true; // abrir compras
input bool abrirVenta = true; // abrir ventas
input int horaComienzo = 16;
input int minutoComienzo = 30;
input int segundoComienzo = 0;
input int horaFin = 16;
input int minutoFin = 31;
int operacionesPorDia = 2;
input int timezone = 3; // MetaTrader timezone
input double minimoDecimal = 1;


double standardLot = 10000;

double min;
double max;

int diaActual = 0;
int operacionesHechasHoy = 0;
int ticketBuy;
int ticketSell;
int ultimoBalance;



#include <../Experts/Volatilidad/FuncionesComunes.mqh>


int OnInit(){

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
  
  
bool  abriHoy = false;
void OnTick() {
   
   datetime candleTime = iTime(Symbol(), 0, 0);

   
    string s;
    StringConcatenate(s, Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaComienzo), ":", IntegerToString(minutoComienzo), ":00");
    datetime time = StringToTime(s);

   if (candleTime == time && Seconds() >= segundoComienzo && !abriHoy) {
      Print("Segundos: ", Seconds());
      abriHoy = true;
      abrirPending();
   }
     
     
    string s2;
    StringConcatenate(s2, Year(), ".", Month(), ".", Day(), " ", IntegerToString(horaFin), ":", IntegerToString(minutoFin), ":00");
    datetime timeClose = StringToTime(s2);

   if (candleTime == timeClose) { 
      cerrarPendientes();
      abriHoy = false;
   }
      
   
   if (cerrarSiHayTp) checkSiCerro();
   if (breakEvenFactor > 0 && trailingStopFactor==0) checkBreakEven();
   if (trailingStopFactor > 0) checkTrailingStop();
   
}



double sl() {
    return sl * minimoDecimal;
}


double tp() {
    return tp * minimoDecimal;
}



// se fija si hay pending orders abiertas de buy y sell, y abre las que correspondan
void abrirPending() {
      double Spread = MarketInfo(Symbol(), MODE_SPREAD);
      // Calculo max y min para poner buy y sell stop
      calcularMinimoYMaximo();
      
      double volume = calculateLotSize(sl());      
      
      double tpCompra;
        if (minimoParaOperar == 0)
        tpCompra = Ask+tp();
        else
        tpCompra = max+tp();
        
      operacionesHechasHoy++;
      
      double ts = NormalizeDouble(trailingStopFactor * minimoDecimal, Digits);
      double mpo = NormalizeDouble(minimoParaOperar * minimoDecimal, Digits);
      double mpul  = NormalizeDouble(minimoParaUsarLoca * minimoDecimal, Digits);
      
      string comment = ""; 
      

        if (abrirCompra) {
        if (minimoParaOperar == 0)
            ticketBuy = OrderSend(Symbol(), OP_BUY, volume, Ask, 0.01, NormalizeDouble(Ask-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
        else
            ticketBuy = OrderSend(Symbol(), OP_BUYSTOP, volume, max, 0.01, NormalizeDouble(max-sl(), Digits), NormalizeDouble(tpCompra,Digits), comment, Magic);
        }
        
        string commentVenta = "";
        double tpVenta;
        if (minimoParaOperar == 0)
            tpVenta = Bid-tp();
        else
            tpVenta = min-tp();
        operacionesHechasHoy++;
        
        if (abrirVenta) {
        if (minimoParaOperar == 0) 
            ticketSell = OrderSend(Symbol(), OP_SELL, volume, Bid, 0.01, NormalizeDouble(Bid+sl(), Digits), NormalizeDouble(tpVenta,Digits), comment, Magic);
        else
            ticketSell = OrderSend(Symbol(), OP_SELLSTOP, volume, min, 0.01, NormalizeDouble(min+sl(), Digits), NormalizeDouble(tpVenta,Digits), comment, Magic);
        }

}


void cerrarPendientes() {
   for(int i = OrdersTotal(); i >= 0; i--){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
            
            if (OrderType() == OP_BUYSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            }   
            
            if (OrderType() == OP_SELLSTOP) {
               OrderDelete(OrderTicket());
               operacionesHechasHoy--;
            }   
            
         }
      }
   }
}

void calcularMinimoYMaximo() { 
   
   int hour = Hour();
   int minutes = Minute()-1;
   if (minutes == -1){
      minutes = 60;
      hour = hour -1;
   }
   
   
    string s;
    StringConcatenate(s, Year(), ".", Month(), ".", Day(), " ", IntegerToString(hour) ,":", IntegerToString(minutes),":00");
    datetime time = StringToTime(s);

   int shift = iBarShift(Symbol(), PERIOD_M1, time);
   max = iHigh(Symbol(), PERIOD_M1,shift);
   min = iLow(Symbol(), PERIOD_M1,shift);
   
   
   if (max-min > minimoParaUsarLoca * minimoDecimal) {
      max = Ask + minimoParaOperar * minimoDecimal;
      min = Bid - minimoParaOperar * minimoDecimal;
   } 
   
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL ) * minimoDecimal;
   if (max < Ask + minimumDistance) { // Solo sucede si la el maximo de la vela anterior esta muy cerca de el cierre de la misma 
      max = Ask + minimoParaOperar * minimoDecimal;
   }
   
   if (Bid - minimumDistance < min) {
      min = Bid - minimoParaOperar * minimoDecimal;
   }
   
   max = NormalizeDouble(max, Digits);
   min = NormalizeDouble(min, Digits);
   
}




void checkSiCerro() {
   if(OrderSelect(ticketBuy, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0 && (MathAbs( OrderClosePrice() - OrderTakeProfit() ) < 1) && OrderSelect(ticketSell, SELECT_BY_TICKET)) {
         OrderDelete(ticketSell);
         ticketSell = 0;
      }
   }
   if(OrderSelect(ticketSell, SELECT_BY_TICKET)) {
      if (OrderCloseTime() != 0 && (MathAbs( OrderClosePrice() - OrderTakeProfit() ) < 1) && OrderSelect(ticketBuy, SELECT_BY_TICKET)){
         OrderDelete(ticketBuy);
         ticketBuy = 0;
      }
   }
}

