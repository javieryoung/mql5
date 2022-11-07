



datetime NewCandleTime = TimeCurrent();
bool isNewCandle() {
   if (NewCandleTime == iTime(Symbol(), 0, 0)) return false;
   else {
      NewCandleTime = iTime(Symbol(), 0, 0);
      return true;
   }
}


double N(double n) {
    return NormalizeDouble(n, Digits);
}




int randomColor() {
    int colors[9] = {
        clrKhaki, clrPowderBlue, clrLightGreen, clrAquamarine, clrPaleGoldenrod, clrPaleTurquoise, clrPeachPuff, clrPink, clrLightSkyBlue
    };
    return colors[MathRand() % 9];
}