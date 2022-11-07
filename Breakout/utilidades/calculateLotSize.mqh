
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