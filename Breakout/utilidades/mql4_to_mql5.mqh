// MQL4&5-code

#ifdef __MQL5__

#define show_inputs script_show_inputs

#define extern input

#define init OnInit

#define Point _Point
#define Digits _Digits

#define Bid (::SymbolInfoDouble(_Symbol, ::SYMBOL_BID))
#define Ask (::SymbolInfoDouble(_Symbol, ::SYMBOL_ASK))

#define True true
#define False false

#define TimeToStr TimeToString
#define DoubleToStr DoubleToString

#define CurTime TimeCurrent

#define HistoryTotal OrdersHistoryTotal

#define LocalTime TimeLocal

#define MODE_BID 9
#define MODE_ASK 10
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


#define StringGetChar StringGetCharacter
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string  StringSetChar(const string &String_Var,const int iPos,const ushort Value)
  {
   string Str=String_Var;

   ::StringSetCharacter(Str,iPos,Value);

   return(Str);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeek(const datetime Date)
  {
   MqlDateTime mTime;

   ::TimeToStruct(Date,mTime);

   return(mTime.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTesting(void)
  {
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeContextBusy(void)
  {
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTradeAllowed(void)
  {
   return(::MQLInfoInteger(::MQL_TRADE_ALLOWED));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RefreshRates(void)
  {
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string WindowExpertName(void)
  {
   return(::MQLInfoString(::MQL_PROGRAM_NAME));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AccountName(void)
  {
   return(::AccountInfoString(::ACCOUNT_NAME));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AccountNumber(void)
  {
   return((int)::AccountInfoInteger(::ACCOUNT_LOGIN));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountFreeMargin(void)
  {
   return(::AccountInfoDouble(::ACCOUNT_MARGIN_FREE));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountFreeMarginCheck(const string Symb,const int Cmd,const double dVolume)
  {
   double Margin;

   return(::OrderCalcMargin((ENUM_ORDER_TYPE)Cmd, Symb, dVolume,
          ::SymbolInfoDouble(Symb,(Cmd==::ORDER_TYPE_BUY) ? ::SYMBOL_ASK : ::SYMBOL_BID),Margin) ?
          ::AccountInfoDouble(::ACCOUNT_MARGIN_FREE) - Margin : -1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double AccountEquity(void)
  {
   return(::AccountInfoDouble(::ACCOUNT_EQUITY));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MT4Bars(void)
  {
   return(::Bars(_Symbol, _Period));
  }

#define Bars (::MT4Bars())


#define DEFINE_TIMESERIE(NAME,FUNC,T)                                                                         \
  class CLASS##NAME                                                                                           \
  {                                                                                                           \
  public:                                                                                                     \
    static T Get(const string Symb,const int TimeFrame,const int iShift)                                      \
    {                                                                                                         \
      T tValue[];                                                                                             \
                                                                                                              \
      return((Copy##FUNC((Symb == NULL) ? _Symbol : Symb, _Period, iShift, 1, tValue) > 0) ? tValue[0] : -1); \
    }                                                                                                         \
                                                                                                              \
    T operator[](const int iPos) const                                                                        \
    {                                                                                                         \
      return(CLASS##NAME::Get(_Symbol, _Period, iPos));                                                       \
    }                                                                                                         \
  };                                                                                                          \
                                                                                                              \
  CLASS##NAME NAME;                                                                                           \
                                                                                                              \
  T i##NAME(const string Symb,const int TimeFrame,const int iShift)                                           \
  {                                                                                                           \
    return(CLASS##NAME::Get(Symb, TimeFrame, iShift));                                                        \
  }

DEFINE_TIMESERIE(Volume,TickVolume,long)
DEFINE_TIMESERIE(Time,Time,datetime)
DEFINE_TIMESERIE(Open,Open,double)
DEFINE_TIMESERIE(High,High,double)
DEFINE_TIMESERIE(Low,Low,double)
DEFINE_TIMESERIE(Close,Close,double)

#endif // __MQL5__




int Year() {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.year);
}
int Day() {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.day);
}
int Hour() {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.hour);
}
int Minute() {
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.min);
}
int Month() {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.mon);
}
int Seconds() {
    MqlDateTime tm;
    TimeCurrent(tm);
    return(tm.sec);
}












#define OP_BUY 0           //Buy 
#define OP_SELL 1          //Sell 
#define OP_BUYLIMIT 2      //Pending order of BUY LIMIT type 
#define OP_SELLLIMIT 3     //Pending order of SELL LIMIT type 
#define OP_BUYSTOP 4       //Pending order of BUY STOP type 
#define OP_SELLSTOP 5      //Pending order of SELL STOP type 
//---
#define MODE_OPEN 0
#define MODE_CLOSE 3
#define MODE_VOLUME 4 
#define MODE_REAL_VOLUME 5
#define MODE_TRADES 0
#define MODE_HISTORY 1
#define SELECT_BY_POS 0
#define SELECT_BY_TICKET 1
//---
#define DOUBLE_VALUE 0
#define FLOAT_VALUE 1
#define LONG_VALUE INT_VALUE
//---
#define CHART_BAR 0
#define CHART_CANDLE 1
//---
#define MODE_ASCEND 0
#define MODE_DESCEND 1
//---
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_SWAPTYPE 26
#define MODE_PROFITCALCMODE 27
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33
//---
#define EMPTY -1





double MarketInfo(string symbol,
                      int type)
  {
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
      case MODE_TIME:
         return(SymbolInfoInteger(symbol,SYMBOL_TIME));
      case MODE_BID:
         return(Bid);
      case MODE_ASK:
         return(Ask);
      case MODE_POINT:
         return(SymbolInfoDouble(symbol,SYMBOL_POINT));
      case MODE_DIGITS:
         return(SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      case MODE_SPREAD:
         return(SymbolInfoInteger(symbol,SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         return(0);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
      case MODE_SWAPTYPE:
         return(SymbolInfoInteger(symbol,SYMBOL_SWAP_MODE));
      case MODE_PROFITCALCMODE:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_CALC_MODE));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(0);
      case MODE_MARGINMAINTENANCE:
         return(0);
      case MODE_MARGINHEDGED:
         return(0);
      case MODE_MARGINREQUIRED:
         return(0);
      case MODE_FREEZELEVEL:
         return(SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));

      default: return(0);
     }
   return(0);
  }




















  bool ObjectSet(string name,
                   int index,
                   double value)
  {
   switch(index)
     {
      
      case OBJPROP_STYLE:
         ObjectSetInteger(0,name,OBJPROP_STYLE,(int)value);return(true);
      case OBJPROP_WIDTH:
         ObjectSetInteger(0,name,OBJPROP_WIDTH,(int)value);return(true);
      case OBJPROP_BACK:
         ObjectSetInteger(0,name,OBJPROP_BACK,(int)value);return(true);
      case OBJPROP_RAY:
         ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,(int)value);return(true);
      case OBJPROP_ELLIPSE:
         ObjectSetInteger(0,name,OBJPROP_ELLIPSE,(int)value);return(true);
      case OBJPROP_SCALE:
         ObjectSetDouble(0,name,OBJPROP_SCALE,value);return(true);
      case OBJPROP_ANGLE:
         ObjectSetDouble(0,name,OBJPROP_ANGLE,value);return(true);
      case OBJPROP_ARROWCODE:
         ObjectSetInteger(0,name,OBJPROP_ARROWCODE,(int)value);return(true);
      case OBJPROP_TIMEFRAMES:
         ObjectSetInteger(0,name,OBJPROP_TIMEFRAMES,(int)value);return(true);
      case OBJPROP_DEVIATION:
         ObjectSetDouble(0,name,OBJPROP_DEVIATION,value);return(true);
      case OBJPROP_FONTSIZE:
         ObjectSetInteger(0,name,OBJPROP_FONTSIZE,(int)value);return(true);
      case OBJPROP_CORNER:
         ObjectSetInteger(0,name,OBJPROP_CORNER,(int)value);return(true);
      case OBJPROP_XDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_XDISTANCE,(int)value);return(true);
      case OBJPROP_YDISTANCE:
         ObjectSetInteger(0,name,OBJPROP_YDISTANCE,(int)value);return(true);
      case OBJPROP_LEVELCOLOR:
         ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,(int)value);return(true);
      case OBJPROP_LEVELSTYLE:
         ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,(int)value);return(true);
      case OBJPROP_LEVELWIDTH:
         ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,(int)value);return(true);

      default: return(false);
     }
   return(false);
  }

  bool ObjectCreateMQL4(string name,
                      ENUM_OBJECT type,
                      int window,
                      datetime time1,
                      double price1,
                      datetime time2=0,
                      double price2=0,
                      datetime time3=0,
                      double price3=0)
  {
   return(ObjectCreate(0,name,type,window,
          time1,price1,time2,price2,time3,price3));
  }
