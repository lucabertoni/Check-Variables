Libreria per il controllo delle variabili dichiarate all'interno di un file sorgente
dBase.

Questa libreria attraverso la funzione areDeclared analizza il file passato come parametro
ed estrae la lista, per ogni funzione (le variabili all'esterno delle funzioni non vengono
considerate), delle variabili non dichiarate. Per variabili dichiarate ci si riferisce alle
variabili poste dopo alla definizione di local,private e public.


dBase library that helps you finding undeclared variables in dBase source code files (prg,wfm,...)
This library analizes file passed as parameter to the function areDeclared, and extracts
the list, for every function in the file (variables that aren't in in function-return statement
are not classified), of undeclared variables. With the expression "declared variables" I suggest
all the variables that are located after words local,private and public

If you want to execute the code, uncomment lines above


Author:        Luca Bertoni

Version:       1.0

Last Update:   23/04/2015

Email Address: luca.bertoni24@gmail.com

Facebook:      https://www.facebook.com/LucaBertoniLucaBertoni
