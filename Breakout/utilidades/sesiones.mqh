input string operarSesionesTitle = ""; // --- SESIONES ---
input int gmt = 4; // GMT
input bool operarNewYork = true; // New York
input bool operarTokyo = true; // Tokyo
input bool operarSidney = true; // Sidney
input bool operarLondon = true; // London

bool checkIfBetweenTwoHours(int start, int end, int val) {
    if (start > end) {
        return (val >= start) || (val < end);
    } else {
        return (val >= start) && (val < end);
    }
}

int fixHour(int h) {
    if (h >= 24) return h - 24;
    return h;
}
/////////////////// Esta bien esto? ///////////////////
////////////////////// quién sabe /////////////////////
bool NewYorkSession() {
    int open = fixHour(12 + gmt);
    int close = fixHour(20 + gmt);
    bool in = checkIfBetweenTwoHours(open, close, Hour());
    return in;
}

bool TokyoSession() {
    int open = fixHour(23 + gmt);
    int close = fixHour(8 + gmt);
    bool in = checkIfBetweenTwoHours(open, close, Hour()) ;
    return in;
}

bool SidneySession() {
    int open = fixHour(22 + gmt);
    int close = fixHour(5 + gmt);
    bool in = checkIfBetweenTwoHours(open, close, Hour()) ;
    return in;
}

bool LondonSession() {
    int open = fixHour(7 + gmt);
    int close = fixHour(16 + gmt);
    bool in = checkIfBetweenTwoHours(open, close, Hour()) ;
    return in;
}


bool session() {
    return (
        (operarNewYork && NewYorkSession()) || 
        (operarTokyo && TokyoSession()) || 
        (operarSidney && SidneySession()) || 
        (operarLondon && LondonSession())
    );
}