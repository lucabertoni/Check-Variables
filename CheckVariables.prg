/*
	Libreria per il controllo delle variabili dichiarate all'interno di un file sorgente
   dBase
	Questa libreria attraverso la funzione areDeclared analizza il file passato come parametro
   ed estrae la lista, per ogni funzione (le variabili all'esterno delle funzioni non vengono
   considerate), delle variabili non dichiarate. Per variabili dichiarate ci si riferisce alle
   variabili poste dopo alla definizione di local,private e public.

   Per eseguire il programma, decommentare le linee sottostanti



   dBase library that helps you finding undeclared variables in dBase source code files (prg,wfm,...)
	This library analizes file passed as parameter to the function areDeclared, and extracts
   the list, for every function in the file (variables that aren't in in function-return statement
   are not classified), of undeclared variables. With the expression "declared variables" I suggest
   all the variables that are located after words local,private and public

   If you want to execute the code, uncomment lines above


	Author: 			Luca Bertoni
   Version: 		1.0
	Last Update:	23/04/2015

	Email Address: luca.bertoni24@gmail.com
   Facebook:		https://www.facebook.com/LucaBertoniLucaBertoni

*/

/*
local lc_oCheckVariables,lc_aRet,lc_aFile

lc_logFile = new File()

lc_pathLogFile = "C:\Documents and Settings\luca\Desktop\logVariabiliNonDichiarate.txt"

lc_bLogVariabiliNonDichiarate = false

if FILE(lc_pathLogFile)
   lc_logFile.open(lc_pathLogFile,"W")
   lc_bLogVariabiliNonDichiarate = true
else
   try
      lc_logFile.create(lc_pathLogFile)

      lc_logFile.open(lc_pathLogFile,"W")
      lc_bLogVariabiliNonDichiarate = true
   catch(Exception e)
      ? "Impossibile creare il file log delle variabili non dichiarate"
   endtry
endif

lc_oCheckVariables = new checkVariables()
lc_aFile = new array()

//lc_aRet = lc_oCheckVariables.areDeclared("C:\path_to_source.*dBase")
lc_aRet = lc_oCheckVariables.areDeclared("C:\Documents and Settings\luca\Desktop\api.prg")
lc_aFile.add(lc_aRet)

//lc_oCheckVariables.stampaArray(lc_aFile,"C:\path_to_file_that_contains_the_list.txt")
lc_oCheckVariables.stampaArray(lc_aFile,lc_logFile)

release object lc_aRet
lc_aRet = NULL

release object lc_aFile
lc_aFile = NULL

release object lc_oCheckVariables
lc_oCheckVariables = NULL
*/

class checkVariables
	
   // Cosa fa			:			Controlla se un elemento è presente in un array
   // pr_elemento		:			elemento da cercare
   // pr_aArray		:			array nel quale cercare
   // Ritorna			:			lc_bRet->true, se l'elemento c'è nell'array, altrimenti false
   function IsIn(pr_elemento,pr_aArray)
      local lc_elemento,lc_aArray,lc_bRet,lc_fine,i

      lc_elemento = pr_elemento
      lc_aArray = pr_aArray

      lc_bRet = false

      lc_fine = ALEN(lc_aArray)

      if ALEN(lc_aArray) == 0
         return lc_bRet
      endif

      for i = 1 to lc_fine
         if lc_elemento == lc_aArray[i]
            lc_bRet = true
            exit
         endif
      next

      return lc_bRet

   // Cosa fa						:			Esplode una stringa
   // pr_stringa					:			stringa, stringa da esplodere
   // pr_separatore				:			carattere sul quale viene esplosa la stringa
   // pr_aDelimitatoriInizio	:			array, delimitatori inizio, nei quali non deve agire il
   //												carattere separatore
   // pr_aDelimitatoriFine		:			array, determinano la fine del range nel quale non agisce il
   //												carattere separatore
   // pr_delimitatoreSpeciale	:			carattere, delimitatore speciale nel quale non hanno effetto né
   //												il carattere separatore, né i delimitatori. Se prima di esso c'è
   //												un carattere di escape (=> \) allora non è da calcolare come delimitatore
   //												N.B. Nel caso non si voglia inserire un delimitatore speciale, mettere come parametro: null
   // Ritorna						:			lc_aRet -> array, array contenente le parole estratte
   function Explode(pr_stringa,pr_separatore,pr_aDelimitatoriInizio,pr_aDelimitatoriFine,pr_delimitatoreSpeciale)
      local lc_stringa,lc_separatore,lc_aDelimitatoriInizio,lc_aDelimitatoriFine,lc_delimitatoreSpeciale
      local lc_aRet,lc_fine,lc_bDentroDelimitatori,lc_bDentroDelimitatoreSpeciale,lc_carattere,lc_exploded
      local lc_count,lc_before,i

      lc_before = ""
      lc_count = 0
      lc_exploded = ""
      lc_bDentroDelimitatori = false
      lc_bDentroDelimitatoreSpeciale = false
      lc_aRet = new array()
      lc_stringa = pr_stringa
      lc_separatore = pr_separatore
      lc_aDelimitatoriInizio = pr_aDelimitatoriInizio
      lc_aDelimitatoriFine = pr_aDelimitatoriFine
      lc_delimitatoreSpeciale = pr_delimitatoreSpeciale

      lc_fine = len(lc_stringa)
      // Per ogni elemento della stringa...
      for i = 1 to lc_fine
    
         lc_carattere = substr(lc_stringa,i,1)

         // Se trovo il separatore
         if lc_carattere == lc_separatore
      	
            // Se non sono dentro ai delimitatori/delimitatore speciale
            if (not lc_bDentroDelimitatori) and (not lc_bDentroDelimitatoreSpeciale)

               // Se la lunghezza della stringa esplosa è maggiore di 0 la memorizzo nell'array e poi la azzero
               if len(lc_exploded) > 0
                  lc_aRet.add(lc_exploded)
                  lc_exploded = ""
               endif
            // Se sono dentro i delimitatori, aggiungo la virgola alla stringa esplosa
            else
               lc_exploded += lc_carattere	
            endif
         endif

         // Se il carattere non è un separatore
         if not (lc_carattere == lc_separatore)

            // Guardo i vari casi...
            do case
               // Nel caso il carattere sia nei delimitatori iniziali...
               case this.IsIn(lc_carattere,lc_aDelimitatoriInizio)

                  // Se non sono dentro il delimitatore speciale, incremento il count dei delimitatori
                  // e entro nei delimitatori
                  if not lc_bDentroDelimitatoreSpeciale
                     lc_count += 1           
                     lc_bDentroDelimitatori = true    	
                  endif

                  lc_exploded += lc_carattere

               // Nel caso il carattere sia nei delimitatori iniziali...
               case this.IsIn(lc_carattere,lc_aDelimitatoriFine)
            	                                         
                  // Se non sono dentro il delimitatore speciale, decremento il count dei delimitatori
                  if not lc_bDentroDelimitatoreSpeciale
                     lc_count -= 1               	
                  endif

                  // Se il count è a 0 (ho chiuso tutti i delimitatori) allora esco dai delimitatori
                  if lc_count == 0
                     lc_bDentroDelimitatori = false
                  endif
                  lc_exploded += lc_carattere

               // Nel caso il carattere sia uguale al delimitatore speciale
               case lc_carattere == lc_DelimitatoreSpeciale

                  // Se prima c'è il carattere di escape, immagazzino il carattere normalmente
                  if lc_before == "\"
                     lc_exploded += lc_carattere
                  // Altrimenti 
                  else
                     // Se non sono dentro il range del delimitatore speciale, ci entro
                     if not lc_bDentroDelimitatoreSpeciale
                        lc_bDentroDelimitatoreSpeciale = true
                        lc_exploded += lc_carattere
                     // Altrimenti, se sono dentro il range del delimitatore speciale, esco
                     else
                        lc_bDentroDelimitatoreSpeciale = false
                        lc_exploded += lc_carattere
                     endif  	
                  endif
               otherwise
                  lc_exploded += lc_carattere
            endcase      
         endif

         lc_before = lc_carattere
      next

      // Nel caso sia rimasto qualcosa in lc_exploded, lo salvo nell'array
      if len(lc_exploded) > 0
         lc_aRet.add(lc_exploded)
      endif
      return lc_aRet

   /*
   // Cosa fa						:			Esplode una stringa
   // pr_stringa					:			stringa, stringa da esplodere
   // pr_separatore				:			carattere sul quale viene esplosa la stringa
   // pr_aDelimitatoriInizio	:			array, delimitatori inizio, nei quali non deve agire il
   //												carattere separatore
   // pr_aDelimitatoriFine		:			array, determinano la fine del range nel quale non agisce il
   //												carattere separatore
   // pr_delimitatoreSpeciale	:			carattere, delimitatore speciale nel quale non hanno effetto né
   //												il carattere separatore, né i delimitatori. Se prima di esso c'è
   //												un carattere di escape (=> \) allora non è da calcolare come delimitatore
   // Ritorna						:			lc_aRet -> array, array contenente le parole estratte
   function Explode(pr_stringa,pr_separatore,pr_aDelimitatoriInizio,pr_aDelimitatoriFine,pr_delimitatoreSpeciale)
      local lc_stringa,lc_separatore,lc_aDelimitatoriInizio,lc_aDelimitatoriFine,lc_delimitatoreSpeciale
      local lc_aRet,lc_fine,lc_bDentroDelimitatori,lc_bDentroDelimatoreSpeciale,lc_carattere,lc_exploded
      local lc_count,lc_before

      lc_before = ""
      lc_count = 0
      lc_exploded = ""
      lc_bDentroDelimitatori = false
      lc_bDentroDelimitatoreSpeciale = false
      lc_aRet = new array()
      lc_stringa = pr_stringa
      lc_separatore = pr_separatore
      lc_aDelimitatoriInizio = pr_aDelimitatoriInizio
      lc_aDelimitatoriFine = pr_aDelimitatoriFine
      lc_delimitatoreSpeciale = pr_delimitatoreSpeciale

      lc_fine = len(lc_stringa)
      // Per ogni elemento della stringa...
      for i = 1 to lc_fine
    
         lc_carattere = substr(lc_stringa,i,1)

         // Se trovo il separatore
         if lc_carattere == lc_separatore
            msgbox("separatore")
            // Se non sono dentro ai delimitatori/delimitatore speciale
            if not lc_bDentroDelimitatori and not lc_bDentroDelimitatoreSpeciale

               // Se la lunghezza della stringa esplosa è maggiore di 0 la memorizzo nell'array e poi la azzero
               if len(lc_exploded) > 0
                  lc_aRet.add(lc_exploded)
                  lc_exploded = ""
               endif
            // Se sono dentro i delimitatori, aggiungo la virgola alla stringa esplosa
            else
               lc_exploded += lc_carattere	
            endif
         endif

         // Se il carattere non è un separatore
         if not (lc_carattere == lc_separatore)

            // Guardo i vari casi...
            do case
               // Nel caso il carattere sia nei delimitatori iniziali...
               case IsIn(lc_carattere,lc_aDelimitatoriInizio)

                  // Se non sono dentro il delimitatore speciale, incremento il count dei delimitatori
                  // e entro nei delimitatori
                  if not lc_bDentroDelimitatoreSpeciale
                     lc_count += 1           
                     lc_bDentroDelimitatori = true    	
                  endif

                  lc_exploded += lc_carattere

               // Nel caso il carattere sia nei delimitatori iniziali...
               case IsIn(lc_carattere,lc_aDelimitatoriFine)
            	                                         
                  // Se non sono dentro il delimitatore speciale, decremento il count dei delimitatori
                  if not lc_bDentroDelimitatoreSpeciale
                     lc_count -= 1               	
                  endif

                  // Se il count è a 0 (ho chiuso tutti i delimitatori) allora esco dai delimitatori
                  if lc_count == 0
                     lc_bDentroDelimitatori = false
                  endif
                  lc_exploded += lc_carattere

               // Nel caso il carattere sia uguale al delimitatore speciale
               case lc_carattere == lc_DelimitatoreSpeciale

                  // Se prima c'è il carattere di escape, immagazzino il carattere normalmente
                  if lc_before == "\"
                     lc_exploded += lc_carattere
                  // Altrimenti 
                  else
                     // Se non sono dentro il range del delimitatore speciale, ci entro
                     if not lc_bDentroDelimitatoreSpeciale
                        lc_bDentroDelimitatoreSpeciale = true
                        lc_exploded += lc_carattere
                     // Altrimenti, se sono dentro il range del delimitatore speciale, esco
                     else
                        lc_bDentroDelimitatoreSpeciale = false
                        lc_exploded += lc_carattere
                     endif  	
                  endif
               otherwise
                  lc_exploded += lc_carattere
            endcase      
         endif

         lc_before = lc_carattere
      next

      // Nel caso sia rimasto qualcosa in lc_exploded, lo salvo nell'array
      if len(lc_exploded) > 0
         ?lc_exploded
         lc_aRet.add(lc_exploded)
      endif
      return lc_aRet
   */


   // Cosa fa			:			Sanitizza un file rimuovendone i commenti(// oppure /* */) e crea un nuovo file (nome_file_temp.txt)
   // pr_file			:			file da sanitizzare
   // Ritorna			:			lc_oFile -> file sanitizzato
   function makeTempFile(pr_file)
      local lc_file,lc_oFile,lc_path,lc_bContinuo,lc_text,lc_line,lc_char,lc_bDentroCommentoSemplice
      local lc_fine,lc_line,lc_bDentroCommentoMultiLine,lc_bDentroFunction,lc_nRiga,i

      lc_file = pr_file
      lc_path = lc_file.path

      lc_oFile = new file()

      lc_text = ""

      lc_bDentroCommentoSemplice = false
      lc_bDentroCommentoMultiLine = false
      lc_bContinuo = true
      lc_bDentroFunction = false

      lc_path = lc_path+"_temp.txt"
      lc_oFile.create(lc_path)

      lc_nRiga = 0

      do while lc_bContinuo

         // Se sono alla fine del file, metto a false lc_bContinuo e
         // passo al ciclo successivo (ovvero, esce dal ciclo, dato che lc_bContinuo è false)
         if lc_file.eof()
            lc_bContinuo = false
            loop
         endif

         lc_line = lc_file.readln()
         lc_nRiga += 1
                               
         lc_bDentroCommentoSemplice = false
		
         if "//"$lc_line

            lc_fine = len(lc_line)

            for i = 1 to lc_fine
               lc_char = substr(lc_line,i,1)

               if lc_char == "/"
                  if substr(lc_line,i+1,1) == "/"
                     // Inizia il commento
                     lc_bDentroCommentoSemplice = true
                  endif
               endif

               // Se non sono dentro al commento "//"
               if not (lc_bDentroCommentoSemplice)
                  lc_text += lc_char
               endif
            next

         elseif "/*"$lc_line

            lc_fine = len(lc_line)

            for i = 1 to lc_fine
               lc_char = substr(lc_line,i,1)

               if lc_char == "/"
                  if substr(lc_line,i+1,1) == "*"
                     // Inizia il commento
                     lc_bDentroCommentoMultiLine = true
                  endif
               endif

               // Se non sono dentro al commento "//"
               if not (lc_bDentroCommentoMultiLine)
                  lc_text += lc_char
               endif          

            next

         elseif "*/"$lc_line

            lc_fine = len(lc_line)

            for i = 1 to lc_fine
               lc_char = substr(lc_line,i,1)

               if lc_char == "*"
                  if substr(lc_line,i+1,1) == "/"
                     // Finisce il commento
                     lc_bDentroCommentoMultiLine = false
                  else
                     lc_text += lc_char
                  endif
               else
                  if not (lc_bDentroCommentoMultiLine)
                     if not (substr(lc_line,i-1,1) == "*")
                        lc_text += lc_char
                     endif
                  endif
               endif

            next
		
         else
            if not (lc_bDentroCommentoMultiLine)
               lc_text += lc_line
            endif
         endif

         if not empty(lc_text)
            lc_text += ";"+lc_nRiga
            lc_oFile.puts(lc_text)
            lc_text = ""
         endif

      enddo

      // Chiudo e riapro il file per tornare all'inizio e uscire dall'eof
      lc_oFile.close()

      lc_oFile.open(lc_path,"R")

      return lc_oFile

   // Cosa fa			:			Elimina gli spazi e i tab all'inizio di una stringa (ltrim non elimina i tab!!)
   // pr_stringa		:			stringa -> stringa dall quale eliminare i caratteri
   // Ritorna			:			lc_newStringa -> stringa, stringa senza spazi/tab iniziali
   function tabsSpacesLTrim(pr_stringa)
      local lc_stringaNew,lc_stringa,lc_bContinuo,i,lc_char,lc_char,lc_asc

      lc_stringa = pr_stringa
      lc_stringaNew = ""

      if empty(lc_stringa)
         return lc_stringaNew
      endif

      i = 1
      do while true

         lc_char = substr(lc_stringa,i,1)
         lc_asc = asc(lc_char)

         if lc_asc == 9 or lc_asc == 32			// 9: tab, 32: spazio
            i++
            loop
         else
            lc_stringaNew = substr(lc_stringa,i)
            exit
         endif

      enddo	
      return lc_stringaNew

   // Cosa fa			:			Elimina tutti gli spazi dalla stringa
   // pr_stringa		:			stringa -> stringa dalla quale eliminare gli spazi
   // Ritorna			.			lc_stringaNew -> stringa, stringa senza spazi
   //									se pr_stringa == "" -> lc_stringaNew = ""
   function delSpaces(pr_stringa)
      local lc_stringa,lc_stringaNew,i,lc_fine,lc_asc,lc_char

      lc_stringa = pr_stringa
      lc_fine = len(lc_stringa)
      lc_stringaNew = ""

      for i = 1 to lc_fine
         lc_char = substr(lc_stringa,i,1)
         lc_asc = asc(lc_char)

         if not(lc_asc == 32)
            lc_stringaNew += lc_char
         endif
      next
	
      return lc_stringaNew

   // Cosa fa			:			Cerca tutte le posizioni di un carattere in una stringa
   // pr_stringa		:			stringa -> stringa nella quale cercare
   // pr_char			:			carattere -> carattere da cercare nella stringa
   // Ritorna			:			lc_aRet -> array, array contenente le posizioni del carattere nella stringa
   //									Se pr_char non è presente in pr_stringa, lc_aRet è vuoto
   function getCharPositions(pr_stringa,pr_char)
      local lc_stringa,lc_char,lc_aRet,i,lc_fine,lc_charStringa,lc_bDentroStringa

      lc_stringa = pr_stringa
      lc_char = pr_char

      lc_aRet = new array()

      if not(lc_char$lc_stringa)
         return lc_aRet
      endif

      lc_bDentroStringa = false

      lc_fine = len(lc_stringa)
      for i = 1 to lc_fine
         lc_charStringa = substr(lc_stringa,i,1)

         if lc_charStringa == "'" or lc_charStringa == '"'
            if not lc_bDentroStringa
               lc_bDentroStringa = true
            else
               lc_bDentroStringa = false
            endif

            loop
         endif

         if lc_charStringa == lc_char
            if not lc_bDentroStringa
               lc_aRet.add(i)
            endif
         endif
      next
   
      return lc_aRet

   // Cosa fa			:			Inverte una stringa, es:
   //									stringa -> agnirts / agnirts -> stringa
   // pr_stringa		:			stringa -> stringa da invertire
   // Ritorna			:			lc_sRet -> stringa, stringa invertita
   //									Se pr_stringa == "" -> lc_sRet = ""
   function reverseString(pr_stringa)
      local lc_stringa,lc_sRet,i,lc_char,lc_fine
	
      lc_sRet = ""
      lc_stringa = pr_stringa

      lc_fine = len(lc_stringa)

      for i = 0 to lc_fine-1 // Parto da 0 perchè mi serve per accedere all'ultimo elemento tramite il substr qui sotto:
                             //(lc_fine-i, dove i = 0, restituisce l'ultimo elemento)
         lc_char = substr(lc_stringa,lc_fine-i,1)

         lc_sRet += lc_char
      next
   	
      return lc_sRet

   // Cosa fa			:			Controlla se un carattere è un numero
   // pr_char			:			carattere -> carattere da controllare, es: "3"
   // Ritorna			:			lc_bRet -> true se è un numero, altrimenti false
   function isNumber(pr_char)
      local lc_char,lc_bRet,lc_asc

      lc_bRet = false
      lc_char = pr_char

      lc_asc = asc(lc_char)

      if (lc_asc >= 48 and lc_asc <= 57)
         lc_bRet = true
      endif

      return lc_bRet

   // Cosa fa			:			Estrae la prima parola che si trova prima di una determinata posizione
   //									Ignora gli spazi tra la parola e la posizione
   // pr_stringa		:			stringa -> Stringa da analizzare
   // pr_aPositions	:			array -> array contenente le posizioni dalle quali estrarre la parola antecedente
   // Ritorna			:			lc_aRet -> array, array contenente le parole estratte
   //									Se pr_stringa == "" -> lc_aRet sarà vuoto
   //									Se pr_aPosition è vuoto -> lc_aRet sarà vuoto
   // Attenzione		:			Nel calcolo sono incluse solo lettere e numeri
   function getWordBeforePositions(pr_stringa,pr_aPositions)
      local lc_aRet,lc_stringa,lc_aPositions,lc_fine,i,lc_bContinuo,lc_position,i7,lc_parola,lc_char
      local lc_bDentroParola,lc_asc

      lc_aRet = new array()
      lc_stringa = pr_stringa
      lc_aPositions = pr_aPositions
      lc_parola = ""

      // Se c'è un punto nella parola ritorno l'array vuoto
      if "."$lc_stringa
         return lc_aRet
      endif

      lc_bDentroParola = false
      lc_bContinuo = true

      lc_fine = ALEN(lc_aPositions)
      for i = 1 to lc_fine

         lc_position = lc_aPositions[i]
         i7 = 1
         lc_parola=""
         lc_bDentroParola = false
         lc_bContinuo = true
		
         do while lc_bContinuo

            lc_char = substr(lc_stringa,lc_position-i7,1)
            lc_asc = asc(lc_char)

            // Controllo che sia una lettera o un numero
            if lc_char == "_" or this.isNumber(lc_char) or isalpha(lc_char) or lc_char == '"'
               lc_bDentroParola = true

               lc_parola += lc_char
            endif
   //         endif

            // 0 è un carattere nullo (si può trovare all'inizio della stringa)
            // Se il carattere è uno spazio/tab/carattere speciale e sono "dentro" alla parola, chiudo il ciclo
            // perchè ho terminato la parola
   //			if lc_asc == 9 or lc_asc == 32 or lc_asc == 0
            if (not (lc_char == "_")) and (not (lc_char == '"')) and (not(isalpha(lc_char))) and (not(this.isNumber(lc_char)))

               // Escludo gli elementi array: lc_array[1] = 7: "lc_array[1]" lo escludo
               if not lc_bDentroParola
                  if lc_char == "]"
                     lc_bContinuo = false
                  endif
               endif

               if lc_bDentroParola
                  lc_bContinuo = false
               endif
            endif

            i7 = i7 + 1
         enddo

         if not (empty(lc_parola))
            lc_aRet.add(lc_parola)
         endif

      next

      // Le parole inserite nell'array sono al contrario, allora le giro
      lc_fine = ALEN(lc_aRet)
      for i = 1 to lc_fine
         lc_parola = lc_aRet[i]

         // Cosa fa			:			Inverte una stringa, es:
         //									stringa -> agnirts / agnirts -> stringa
         // pr_stringa		:			stringa -> stringa da invertire
         // Ritorna			:			lc_sRet -> stringa, stringa invertita
         //									Se pr_stringa == "" -> lc_sRet = ""
         lc_aRet[i] = this.reverseString(lc_parola)
      next

      return lc_aRet

   // Cosa fa			:			Estrae il nome della funzione da una stringa di testo
   //									es: 'function nome_funzione(pr_parametro)', estrae 'nome_funzione'
   // pr_stringa		:			stringa -> stringa da analizzare e dalla quale estrarre il nome della funzione
   // Ritorna			:			lc_sRet -> stringa, stringa contenente il nome della funzione
   //									Se in pr_stringa non è presente 'function' -> lc_sRet sarà ""
   function getFunctionName(pr_stringa)
      local lc_stringa,lc_sRet,lc_parola,lc_parolaBefore,i,lc_char,lc_fine

      lc_stringa = pr_stringa
      lc_sRet = ""

      if not("function"$lc_stringa)
         return lc_sRet
      endif

      // Cosa fa			:			Elimina gli spazi e i tab all'inizio di una stringa (ltrim non elimina i tab!!)
      // pr_stringa		:			stringa -> stringa dall quale eliminare i caratteri
      // Ritorna			:			lc_newStringa -> stringa, stringa senza spazi/tab iniziali
      lc_stringa = this.tabsSpacesLTrim(lc_stringa)

      lc_parolaBefore = ""
      lc_parola = ""
   
      lc_fine = len(lc_stringa)
      for i = 1 to lc_fine
         lc_char = substr(lc_stringa,i,1)

         // Controllo se ho incontrato uno spazio(fine parola), una parentesi (inizio parametri e fine nome funzione)
         // oppure se sono arrivato alla fine della riga [...]
         if lc_char == " " or lc_char == "(" or i == lc_fine
      																		

            if upper(lc_parolaBefore) == "FUNCTION"

               //[...] Se sono arrivato alla fine della riga, aggiungo un carattere (l'ultimo carattere) alla parola(nome funzione)
               // e salvo il nome della funzione
               if i == lc_fine
                  lc_parola += lc_char
               endif
               lc_sRet = lc_parola
               exit
            endif

            lc_parolaBefore = lc_parola
            lc_parola = ""
         else
            lc_parola += lc_char
         endif
      next

      return lc_sRet

   // Cosa fa				:			Stampa l'array ricavato in un file
   // pr_array		:			Array -> array da stampare
   // pr_file				:			File (oggetto), file nel quale salvare
   function stampaArray(pr_array,pr_file)
      local lc_aRet,lc_logFile,lc_aFunzione,lc_aVariabile,lc_app

      lc_aRet = pr_array

      lc_logFile = pr_file

      for i = 1 to ALEN(lc_aRet)
      	lc_app = lc_aRet[i]
         
         lc_chiaveFile = lc_app.firstKey
         for i12 = 1 to lc_app.count()
		
               if lc_chiaveFile == "totale"
                  lc_chiaveFile = lc_app.nextKey(lc_chiaveFile)
                  loop
               endif

               lc_logFile.puts("Nome file: "+lc_chiaveFile)
		
               lc_aFunzione = lc_app[lc_chiaveFile]

               lc_chiaveFunzione = lc_aFunzione.firstKey
               for i9 = 1 to lc_aFunzione.count()

                  lc_logFile.puts(chr(9)+lc_chiaveFunzione)
                  lc_aVariabile = lc_aFunzione[lc_chiaveFunzione]

                  lc_chiaveVariabile = lc_aVariabile.firstKey
                  for i24 = 1 to lc_aVariabile.count()

                     lc_logFile.puts(chr(9)+chr(9)+lc_chiaveVariabile)
                     lc_logFile.puts(chr(9)+chr(9)+chr(9)+"Riga: "+lc_aVariabile[lc_chiaveVariabile])
      	
                     lc_chiaveVariabile = lc_aVariabile.nextKey(lc_chiaveVariabile)
                  next
				   	
                  lc_chiaveFunzione = lc_aFunzione.nextKey(lc_chiaveFunzione)
               next	

               lc_chiaveFile = lc_app.nextKey(lc_chiaveFile)

         next
         lc_logFile.puts("Totale: "+lc_aRet[i]['totale'])
		next

      return

   // Cosa fa			:			Controlla se le varibili presenti nel file sono state dichiarate
   // pr_file			:			File da analizzare, composto come un normalissimo sorgente dBase
   // Ritorna			:			Assoc AssocArray, così formato:
   //									lc_aRet[nome_file]
   //												[nome_funzione]
   //													[nome_variabile] => numero_riga
   //													[nome_variabile] => numero_riga
   //												[nome_funzione]
   //													[nome_variabile] => numero_riga
   //													[nome_variabile] => numero_riga
   //												['totale'] => numeri di variabili non dichiarate
   function areDeclared(pr_file)
      local lc_oFile,lc_aRet,lc_key,lc_count,lc_bContinuo,lc_text,lc_aVariabili,lc_path
      local i,lc_fine,lc_aVariabiliTemp,lc_aVariabiliUsate,lc_variabile,lc_bDichiarata
      local lc_nRiga,lc_functionName,lc_aRiga,lc_aFunzione,lc_aVariabiliNonDichiarate
      local lc_bDentroFunction,i18

      lc_oFile = new file()
      lc_aRet = new AssocArray()

      lc_aFunzione = new assocarray()
      lc_aVariabiliNonDichiarate = new assocarray()
      lc_functionName = ""

      lc_bContinuo = true
      lc_bDentroFunction = false

      lc_text = ""

      // Contiene la lista di tutte le variabili dichiarate
      lc_aVariabili = new array()
   
      lc_count = 0
	
      if not (file(pr_file))
         ? "areDeclared: File Inesistente("+pr_file+")"

         lc_oFile.close()
         release object lc_oFile
         lc_oFile = NULL

         return lc_aRet
      endif

      // Apro il file in sola lettura
      lc_oFile.open(pr_file,"R")

      // Controllo di non essere alla fine del file
      if lc_oFile.eof()
         ? "areDeclared: File vuoto("+pr_file+")"
      
         lc_oFile.close()
         release object lc_oFile
         lc_oFile = NULL

         return lc_aRet
      endif

      // Sanitizzo il file
      // Cosa fa			:			Sanitizza un file rimuovendone i commenti(// oppure /* ) e crea un nuovo file (nome_file_new.txt)
      // pr_file			:			file da sanitizzare
      // Ritorna			:			lc_oFile->file sanitizzato
      lc_oFile = this.makeTempFile(lc_oFile)

      lc_nRiga = 0

      // Leggo il file riga per riga
      do while lc_bContinuo

         // Se sono alla fine del file, metto a false lc_bContinuo e
         // passo al ciclo successivo (ovvero, esce dal ciclo, dato che lc_bContinuo è false)
         if lc_oFile.eof()
            lc_bContinuo = false
            loop
         endif

         lc_text = lc_oFile.gets()
         lc_text = rtrim(lc_text)
         lc_text = lower(lc_text)

         // Cosa fa						:			Esplode una stringa
         // pr_stringa					:			stringa, stringa da esplodere
         // pr_separatore				:			carattere sul quale viene esplosa la stringa
         // pr_aDelimitatoriInizio	:			array, delimitatori inizio, nei quali non deve agire il
         //												carattere separatore
         // pr_aDelimitatoriFine		:			array, determinano la fine del range nel quale non agisce il
         //												carattere separatore
         // pr_delimitatoreSpeciale	:			carattere, delimitatore speciale nel quale non hanno effetto né
         //												il carattere separatore, né i delimitatori. Se prima di esso c'è
         //												un carattere di escape (=> \) allora non è da calcolare come delimitatore
         //												N.B. Nel caso non si voglia inserire un delimitatore speciale, mettere come parametro: null
         // Ritorna						:			lc_aRet -> array, array contenente le parole estratte
         lc_aRiga = this.Explode(lc_text,";",new array(),new array(),null)               	

         // Nel secondo elemento dell'array c'è il numero della riga
         lc_nRiga = lc_aRiga[2]
         lc_text = lc_aRiga[1]

         // Se c'è la parola function
         if "function "$lc_text

         	if not ("if"$lc_text) and (not("do "$lc_text)) and (not "for "$lc_text) and (not "="$lc_text)
               // Cosa fa			:			Estrae il nome della funzione da una stringa di testo
               //									es: 'function nome_funzione(pr_parametro)', estrae 'nome_funzione'
               // pr_stringa		:			stringa -> stringa da analizzare e dalla quale estrarre il nome della funzione
               // Ritorna			:			lc_sRet -> stringa, stringa contenente il nome della funzione
               //									Se in pr_stringa non è presente 'function' -> lc_sRet sarà ""
               lc_functionName = this.getFunctionName(lc_text)

               lc_aVariabiliNonDichiarate = new assocarray()

               // Pulisco l'array delle variabili dichiarate estratte fin'ora
               release object lc_aVariabili
               lc_aVariabili = NULL

               lc_aVariabili = new array()

               lc_aVariabiliUsate = new array()

               lc_bDentroFunction = true

               loop

				endif
         endif

         // Eseguo questo controllo per verificare se effettivamente si tratta di un
         // file contenente delle funzioni
         if lc_bDentroFunction


            // Cosa fa			:			Elimina gli spazi e i tab all'inizio di una stringa (ltrim non elimina i tab!!)
            // pr_stringa		:			stringa -> stringa dall quale eliminare i caratteri
            // Ritorna			:			lc_newStringa -> stringa, stringa senza spazi/tab iniziali
            lc_text = this.tabsSpacesLTrim(lc_text)

            if substr(lc_text,1,6) == "local " or substr(lc_text,1,8) == "private " or substr(lc_text,1,7) == "public "
               do case

                  case substr(lc_text,1,6) == "local "
                     lc_text = substr(lc_text,6)

                  case substr(lc_text,1,8) == "private "
                     lc_text = substr(lc_text,8)

                  case substr(lc_text,1,7) == "public "
                     lc_text = substr(lc_text,7)

               endcase

               // Cosa fa			:			Elimina tutti gli spazi dalla stringa
               // pr_stringa		:			stringa -> stringa dalla quale eliminare gli spazi
               // Ritorna			.			lc_stringaNew -> stringa, stringa senza spazi
               //									se pr_stringa == "" -> lc_stringaNew = ""
               lc_text = this.delSpaces(lc_text)

               // Cosa fa						:			Esplode una stringa
               // pr_stringa					:			stringa, stringa da esplodere
               // pr_separatore				:			carattere sul quale viene esplosa la stringa
               // pr_aDelimitatoriInizio	:			array, delimitatori inizio, nei quali non deve agire il
               //												carattere separatore
               // pr_aDelimitatoriFine		:			array, determinano la fine del range nel quale non agisce il
               //												carattere separatore
               // pr_delimitatoreSpeciale	:			carattere, delimitatore speciale nel quale non hanno effetto né
               //												il carattere separatore, né i delimitatori. Se prima di esso c'è
               //												un carattere di escape (=> \) allora non è da calcolare come delimitatore
               // Ritorna						:			lc_aRet -> array, array contenente le parole estratte
               lc_aVariabiliTemp = this.Explode(lc_text,",",new array(),new array(),"")
            
               // Aggiungo le variabili estratte, nel mio array di variabili
               lc_fine = ALEN(lc_aVariabiliTemp)
               for i = 1 to lc_fine
                  lc_aVariabili.add(lower(lc_aVariabiliTemp[i]))
               next

               release object lc_aVariabiliTemp
               lc_aVariabiliTemp = NULL

            endif // Fine if substr[...]

            lc_text = lower(lc_text)
            if "=="$lc_text or "if "$lc_text or "for "$lc_text or "case "$lc_text
               loop
            endif

            // Se c'è un uguale (o anche due, ma non è significativo) significa che
            // nella stringa (riga del file) è stata utilizzata una variabile
            if "="$lc_text
				
               // Cosa fa			:			Cerca tutte le posizioni di un carattere in una stringa
               // pr_stringa		:			stringa -> stringa nella quale cercare
               // pr_char			:			carattere -> carattere da cercare nella stringa
               // Ritorna			:			lc_aRet -> array, array contenente le posizioni del carattere nella stringa
               lc_aPositions = this.getCharPositions(lc_text,"=")

               // Cosa fa			:			Estrae la prima parola che si trova prima di una determinata posizione
               //									Ignora gli spazi tra la parola e la posizione
               // pr_stringa		:			stringa -> Stringa da analizzare
               // pr_aPositions	:			array -> array contenente le posizioni dalle quali estrarre la parola antecedente
               // Ritorna			:			lc_aRet -> array, array contenente le parole estratte
               //									Se pr_stringa == "" -> lc_aRet sarà vuoto
               //									Se pr_aPosition è vuoto -> lc_aRet sarà vuoto
               lc_aVariabiliUsate = this.getWordBeforePositions(lc_text,lc_aPositions)

               // Per ogni elemento (variabile usata nella funzione), controllo se è stata dichiarata
               for i18 = 1 to ALEN(lc_aVariabiliUsate)

                  lc_variabile = lc_aVariabiliUsate[i18]

                  // Cosa fa			:			Controlla se un elemento è presente in un array
                  // pr_elemento		:			elemento da cercare
                  // pr_aArray		:			array nel quale cercare
                  // Ritorna			:			lc_bRet->true, se l'elemento c'è nell'array, altrimenti false
                  lc_variabile = lower(lc_variabile)

                  lc_bDichiarata = this.IsIn(lc_variabile,lc_aVariabili)

                  if not (lc_bDichiarata)

                     if not (lc_aVariabiliNonDichiarate.isKey(lc_variabile))
                        lc_aVariabiliNonDichiarate[lc_variabile] = lc_nRiga
                        lc_count += 1
                     endif
                  endif
               next

               if not(empty(lc_functionName))
                  if lc_aVariabiliNonDichiarate.count() > 0
                     lc_aFunzione[lc_functionName] = lc_aVariabiliNonDichiarate
                  endif
               endif

            endif // Fine if "="$lc_text

         endif // Fine if lc_bDentroFunction

      enddo

      lc_aRet[pr_file] = lc_aFunzione
      lc_aRet["totale"] = lc_count
      lc_path = lc_oFile.path
      lc_oFile.close()
      lc_oFile.delete(lc_path)

      release object lc_oFile
      lc_oFile = NULL

      // Pulisco l'array delle variabili dichiarate estratte
      release object lc_aVariabili
      lc_aVariabili = NULL

      return lc_aRet
endclass

