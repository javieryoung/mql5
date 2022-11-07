//+------------------------------------------------------------------+
//|                                                 FuncionesComunes |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict



input double cuenta = 20000;
input double risk = 0.1;
input double breakEvenFactor = 0; // % break even (0: disabled)
input double trailingStopFactor = 0; // valor de trailing (0: disabled) (in points)


int cuentas[] = {
   111164, 9223, // Leo
   1678, 5284, // JP
   13696, // Mati
   4315773, 44131396, 7380, 2925, 2926, 123929, 66281006, 4312124,  1652639, 310016731, 10304, 30904634, // JD y Javi
   30887000, 30924850, 30935539, // demos ic markets
   910098384, 1658897, 2132180945, 
   66289948 // mauro
};

void checkBEandTS() {
   checkBreakEven();
   checkTrailingStop();
}


void checkBreakEven() {
   if (breakEvenFactor == 0 || trailingStopFactor > 0) return ;
   double minimumDistance = MarketInfo( Symbol(), MODE_STOPLEVEL ) * Point;
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            if (OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice()) {
               double profit = Ask - OrderOpenPrice();
               if (profit > (OrderTakeProfit() - OrderOpenPrice()) * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() + minimumDistance, Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Compra");
               }
            }
            
            if (OrderType() == OP_SELL && OrderStopLoss() > OrderOpenPrice()) {
               double profit = OrderOpenPrice() - Bid;
               if (profit > (OrderOpenPrice() - OrderTakeProfit()) * breakEvenFactor) {
                  double stoploss = NormalizeDouble(OrderOpenPrice() - minimumDistance,Digits);
                  OrderModify(OrderTicket(),OrderOpenPrice(),stoploss,OrderTakeProfit(),0,Blue);
                  Print("Break Even Venta");
               }
            }
         }
      }
   }
}


void checkTrailingStop() {
   if (trailingStopFactor == 0) return ;
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)){
         if (OrderSymbol() == Symbol() && OrderMagicNumber() == Magic){
         
            double stoplossCompra = NormalizeDouble(Ask - (trailingStopFactor * Point), Digits);
            if (OrderType() == OP_BUY && stoplossCompra > OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossCompra,OrderTakeProfit(),0,Blue);
            }
            
            double stoplossVenta = NormalizeDouble((trailingStopFactor * Point) + Bid, Digits);
            if (OrderType() == OP_SELL && stoplossVenta < OrderStopLoss()) {
               OrderModify(OrderTicket(),OrderOpenPrice(),stoplossVenta,OrderTakeProfit(),0,Blue);
            }
            
         }
      }
   }
}


bool in_array(int needle) {
   char arraySize = ArraySize(cuentas);
   for(int i = 0; i < arraySize; i++) {
      if(cuentas[i] == needle) {
         return true;
      }
   }
   return false;
}

double calculateLotSize(double SL) {
    if (SL == 0) return 0;
   string baseCurr = StringSubstr(Symbol(),0,3);
   string crossCurr = StringSubstr(Symbol(),3,3);
    
   double lotSize = MarketInfo(Symbol(), MODE_LOTSIZE);
   
   double volume;
   if(crossCurr == AccountInfoString(ACCOUNT_CURRENCY)) {
      volume = (cuenta * (risk / 100.0)) / (SL * lotSize);
    } else if(baseCurr == AccountInfoString(ACCOUNT_CURRENCY)) {
      double riesgoEnMonedaContrapartida = (cuenta * (risk / 100.0)) * Bid;
      volume = riesgoEnMonedaContrapartida / (SL * lotSize);
    } else {
      volume = (cuenta * (risk / 100.0)) / (SL * lotSize);
    }
    
    double maxLots= MarketInfo(Symbol(), MODE_MAXLOT);
    if (volume > maxLots) volume = maxLots;
    
    double minLots= MarketInfo(Symbol(), MODE_MINLOT);
    if (minLots > volume) volume = minLots;
    
    
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   int digits = 0;
   if (lotStep == 0.001) digits = 3;
   if (lotStep == 0.01) digits = 2;
   if (lotStep == 0.1) digits = 1;
   if (lotStep == 1) digits = 0;
    
   return NormalizeDouble(volume, digits);
}

datetime NewCandleTime = TimeCurrent();
bool isNewCandle() {
   if (NewCandleTime == iTime(Symbol(), 0, 0)) return false;
   else {
      NewCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}







/////////////////// Esta bien esto? ///////////////////
////////////////////// quién sabe /////////////////////
bool NewYorkSession() {
   bool afterOpen = Hour() > 16;
   bool beforeClose = Hour() < 1;
   return afterOpen || beforeClose ;
}

bool TokyoSession() {
   bool afterOpen = Hour() > 3;
   bool beforeClose = Hour() < 12;
   return afterOpen && beforeClose ;
}

bool SidneySession() {
   bool afterOpen = Hour() > 1;
   bool beforeClose = Hour() < 8;
   return afterOpen && beforeClose ;
}

bool LondonSession() {
   bool afterOpen = Hour() > 11;
   bool beforeClose = Hour() < 20;
   return afterOpen && beforeClose ;
}



int fixHourTimezone(int hour) {
    if (hour + timezone >= 24) {
        return hour + timezone - 24;
    }
    if (hour + timezone < 0) {
        return 24 + hour + timezone;
    }
    return hour + timezone;
}


int fixTimezone(int time, int timezone) {
    return time + (timezone * 60 * 60);
}