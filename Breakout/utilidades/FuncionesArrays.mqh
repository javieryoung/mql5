
template<typename T>
void Push(T &vect[], T i){
   int sizeVect = ArraySize(vect);
   ArrayResize(vect, sizeVect + 1);
   vect[sizeVect] = i; 
}


/* 
estaEnArray
busca target en el array vect, deuelve true si lo encontró
Params:
    vect: vector en el cual se quiere buscar 
    target: elemento a buscar
*/
template<typename T>
bool enArray(T &vect[], T target) { 
   for (int i = 0; i < ArraySize(vect); i ++) {
      if (vect[i] == target) 
         return true;
   }
   return false;
}


/* 
eliminarDelArrayPorPosicion
elimina el elemento en la posicion indicada
Params:
    vect: vector del cual se quiere eliminar 
    index: indice
*/
template<typename T>
void eliminarDelArrayPorPosicion(T &vect[], int index) { 
   T copy[];
   ArrayCopy(copy, vect);
   ArrayFree(vect);
   for (int i = 0; i < ArraySize(copy); i ++) {
      if (i != index)
         Push(vect, copy[i]);
   }
}

/* 
eliminarDelArray
busca target en el array vect, deuelve true si lo encontró. Si lo encontró lo borra
Params:
    vect: vector del cual se quiere eliminar 
    target: elemento a buscar
    comienzo (opcional): desde que indice se quiere comenzar a buscar
*/
template<typename T>
bool eliminarDelArray(T &vect[], T target, int comienzo = 0) { 
   bool encontre = false;
   int copy[];
   ArrayCopy(copy, vect);
   ArrayFree(vect);
   for (int i = 0; i < comienzo; i ++) Push(vect, copy[i]);
   for (int i = comienzo; i < ArraySize(copy); i ++) {
      if (copy[i] == target) 
         encontre = true;
      else
         Push(vect, copy[i]);
   }
   return encontre;
}

/* 
eliminarDuplicados
Elimina elementos repetidos. Devuelve true si eliminó alguno. 
Deja en el arreglo solo la primera aparición de cada elemento repetido.
*/
template<typename T>
bool eliminarDuplicados(T &vect[]) { // 
   bool elimine = false;
   int i = 0;
   while(i < ArraySize(vect)) {
      if(eliminarDelArray(vect, vect[i], i+1)) elimine = true;
      i++;
   }
   return elimine;
}