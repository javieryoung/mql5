
input double breakEvenFactor = 0; // % break even (0: disabled)
input double trailingStopFactor = 0; // trailing (in Points) (0: disabled)

void checkBEandTS() {
   checkBreakEven();
   checkTrailingStop();
}

void checkBreakEven() {
   if (breakEvenFactor == 0 || trailingStopFactor > 0) return ;
   double minimumDistance = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   for(int i = 0; i < OrdersTotal(); i++){
      if (OrderSelect(i)){
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
      if (OrderSelect(i)){
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

