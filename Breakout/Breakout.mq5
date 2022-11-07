//+------------------------------------------------------------------+
//|                                                 El bot final.mq4 |
//|                        Not JD lolz. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Not JD lolz."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#include <../Experts/Breakout/utilidades/mql4_to_mql5.mqh>
#include <../Experts/Breakout/utilidades/MT4Orders.mqh>

input int Magic = 10000;
int timeframesUsed[4] = {
    1, // M1
    15, // M15
    240, // H4
    3600 // D2.5
};

int candleTimes[4];


input double cuenta = 20000; // account size
input double risk = 0.1; // risk in %
input int timezone = 3; // UTC timezone

input int operationsPerDay = 5; // maximum operations to open each day
input double tpRatio = 1.25; // TP ratio
input double air = 0; // air in points

double minimumDistance;
int operationsToday = 0;
double max, min, mid;
int ticketBuy, ticketSell;
#include <../Experts/Breakout/utilidades/FuncionesArrays.mqh>
#include <../Experts/Breakout/utilidades/FuncionesComunes.mqh>
#include <../Experts/Breakout/utilidades/jComment.mqh>
#include <../Experts/Breakout/utilidades/calculateLotSize.mqh>
#include <../Experts/Breakout/utilidades/modifiers.mqh>



int OnInit() {

    Print(Point);
    minimumDistance = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL) * Point;
    Print("minimumDistance: ", minimumDistance);
    return(INIT_SUCCEEDED);
}


int openBuy(double volume, double entry, double sl, double tp) {
    if (MathAbs(Ask - entry) < minimumDistance)
        entry = Ask + minimumDistance;
    int ticket = OrderSend(Symbol(), OP_BUYSTOP, volume, N(entry), 0.1, sl, tp, "", Magic);
    if (Ask > entry) {
        ticket = OrderSend(Symbol(), OP_BUY, volume, Ask, 0.1, sl, tp, "", Magic);
    }
    return ticket;
}

int openSell(double volume, double entry, double sl, double tp) {
    if (MathAbs(Bid - entry) < minimumDistance) 
        entry = Bid - minimumDistance;
    int ticket = OrderSend(Symbol(), OP_SELLSTOP, volume, entry, 0.1, sl, tp, "", Magic);
    if (Bid < entry) {
        ticket = OrderSend(Symbol(), OP_BUY, volume, Ask, 0.1, sl, tp, "", Magic);
    }
    return ticket;
}

void OnTick() {
    MqlTick last_tick;
    SymbolInfoTick(_Symbol,last_tick);

    if (isNewCandle()) {

        // OPEN OPERATIONS
        if (Minute() == 33 && Hour() == 13 + timezone) {
            calcularLineas();

            double volume = calculateLotSize(MathAbs(mid - min) + air*Point);

            double tpBuy = N(max + MathAbs(mid-min) * tpRatio);
            ticketBuy = openBuy(volume, max, mid - air*Point, tpBuy);
            
            
            double tpSell = N(min - MathAbs(mid-min) * tpRatio);
            ticketSell = openSell(volume, min, mid + air*Point, tpSell);

            operationsToday = 2;
        }


        // CHECK IF NEED TO OPEN NEW OPERATION
        string startStr = "";
        StringConcatenate(startStr, Year(), ".", Month(), ".", Day(), " ", (13 + timezone),":32:00");
        datetime startTime = StringToTime(startStr);

        string endStr = "";
        StringConcatenate(endStr, Year(), ".", Month(), ".", Day(), " ", (15 + timezone),":30:00");
        datetime endTime = StringToTime(endStr);
        datetime now = TimeCurrent();
        if (startTime < now && now < endTime) {
            if (operationsToday < operationsPerDay) {
                if (orderStatus(ticketBuy) == -1) {
                    double newMax = getMaximumOrMinimumBetween(startTime, now, "max");
                    
                    double tpBuy = N(newMax + MathAbs(mid-newMax) * tpRatio);
                    double volume = calculateLotSize(MathAbs(mid - newMax) + air*Point);
                    ticketBuy = openBuy(volume, newMax, mid - air*Point, tpBuy);
                        
                }
                if (orderStatus(ticketSell) == -1) {
                    double newMin = getMaximumOrMinimumBetween(startTime, now, "min");
                    double volume = calculateLotSize(MathAbs(mid - newMin));

                    double tpSell = N(newMin - MathAbs(mid-newMin) * tpRatio);
                    ticketSell = openSell(volume, newMin, mid + air*Point, tpSell);
                    
                }
            }
        }


        // CLOSE PENDING & RESTART DAY
        if (Minute() == 30 && Hour() == 15 + timezone) {
            min = 0;
            max = 0;
            mid = 0;
            operationsToday = 0;
            cerrarPendientes();
        }
    }
    checkBEandTS();
}

double getMaximumOrMinimumBetween(datetime start, datetime end, string what) {
    double newMax = 0;
    double newMin = 30000000;
    while(start <= end) {
        int shift = iBarShift(Symbol(), PERIOD_M1, start);
        double localMax = iHigh(Symbol(), PERIOD_M1, shift);
        double localMin = iLow(Symbol(), PERIOD_M1, shift);
        if (localMax > newMax)
            newMax = localMax;
        if (localMin < newMin)
            newMin = localMin;
        start += 60;
    }
    if (what == "min") return newMin;
    if (what == "max") return newMax;
    return 0;
}

int orderStatus(const int _ticket){ // -1: stoploss, 1: takeprofit, 0 still open
    if(OrderSelect(_ticket,SELECT_BY_TICKET)){
        if (OrderCloseTime()==0) {
            return 0;
        } else {
            if (OrderProfit() > 0) {
                return 1;
            } else {
                return -1;
            }
        }
        return 0;
    } else {
       int error=GetLastError();
        return(error!=4108 && error!=4051);
    }
}

void calcularLineas() {
    min = 30000000.0;
    max = 0.0;
    bool completed = false;

    int candles = 33;
    int hour = 13 + timezone;
    datetime time;
    for (int i = 0; i < candles; i++) {
        string year = IntegerToString(Year());
        string str = "";
        StringConcatenate(str, Year(), ".", Month(), ".", Day(), " ", hour, ":", i, ":00");
        time = StringToTime(str);
        int shift = iBarShift(Symbol(), PERIOD_M1, time);
        double high = iHigh(Symbol(), PERIOD_M1,shift);
        double low = iLow(Symbol(), PERIOD_M1,shift);
        
        if (high > max) {
            max = high;
        }
        if (low < min) {
            min = low;
        }
    }
    mid = ((max - min) / 2) + min;
    
    
    
    string str = "";
    StringConcatenate(str, Year(), ".", Month(), ".", Day(), " ", (13 + timezone),":00:00");
    datetime startTime = StringToTime(str);
    
    int rAux = rand();
    ObjectCreate(0,rAux,OBJ_RECTANGLE,0,startTime,min,time,max);
    ObjectSetInteger(0, rAux, OBJPROP_BACK, true);
    ObjectSetInteger(0, rAux, OBJPROP_COLOR, clrBlack);
    ObjectSetInteger(0, rAux, OBJPROP_FILL, false);
    ObjectSetInteger(0, rAux, OBJPROP_RAY, false);
  
}


void cerrarPendientes() {
   for(int i = 0; i < OrdersTotal(); i++){
        Print("ACAAA");
      if (OrderSelect(i, SELECT_BY_POS)){
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
