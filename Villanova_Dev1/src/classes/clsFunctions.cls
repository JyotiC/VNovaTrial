public with sharing class clsFunctions {
	/*
	//For date input, returns the day of the week it falls on
	public static String FindDayName(Date dteInput){
		String strReturn;
		Date dte = dteInput.toStartofWeek();

		//To track what day of the week we're currently on,
		//start with 0 since we're at the start of the week
		Integer intDteDay = 0; 
		while (dte < dteInput) {
			dte = dte.addDays(1);
			intDteDay++;
		}
		strReturn = (intDteDay == 0 ? 'Sunday' : strReturn);
		strReturn = (intDteDay == 1 ? 'Monday' : strReturn);
		strReturn = (intDteDay == 2 ? 'Tuesday' : strReturn);
		strReturn = (intDteDay == 3 ? 'Wednesday' : strReturn);
		strReturn = (intDteDay == 4 ? 'Thursday' : strReturn);
		strReturn = (intDteDay == 5 ? 'Friday' : strReturn);
		strReturn = (intDteDay == 6 ? 'Saturday' : strReturn);
		
		return strReturn; 
	}
	
	public static String FindMonthName(Date dteInput){
		String strReturn;
		
		strReturn = (dteInput.month() == 1 ? 'January' : strReturn);
		strReturn = (dteInput.month() == 2 ? 'February' : strReturn);
		strReturn = (dteInput.month() == 3 ? 'March' : strReturn);
		strReturn = (dteInput.month() == 4 ? 'April' : strReturn);
		strReturn = (dteInput.month() == 5 ? 'May' : strReturn);
		strReturn = (dteInput.month() == 6 ? 'June' : strReturn);
		strReturn = (dteInput.month() == 7 ? 'July' : strReturn);
		strReturn = (dteInput.month() == 8 ? 'August' : strReturn);
		strReturn = (dteInput.month() == 9 ? 'September' : strReturn);
		strReturn = (dteInput.month() == 10 ? 'October' : strReturn);
		strReturn = (dteInput.month() == 11 ? 'November' : strReturn);
		strReturn = (dteInput.month() == 12 ? 'December' : strReturn);
		
		return strReturn;
	}
	*/
	public static void CreateWhere(Campaign c, List<Group_Criterion__c> lstCrit){
		Boolean isError = false;
        List<Integer> lstLeftParen = new List<Integer>();
        List<Integer> lstRightParen = new List<Integer>();
        //Stores the Integers that represent Criteria records along with their place in the logic string
        Map<Integer, Integer> mapIntegers = new Map<Integer, Integer>();
        //Just the place of Integers in the logic string so they can be sorted later
        List<Integer> lstIntPlace = new List<Integer>();
        
        //Parse the Logic string
        
        for (Integer i = 0; i < c.Boolean__c.length(); i++){
            String sub = c.Boolean__c.substring(i,i+1);
            System.debug('Parsing string, sub = ' +sub +' at i = ' +i);
            Boolean Found = false;
            String strTemp = '';
            if (sub == ' '){
                Found = true;
            } else {
                //Find the references to the criteria records
                if (sub == '0' || sub == '1' || sub == '2' || sub == '3'
                    || sub == '4' || sub == '4' || sub == '5' || sub == '6'
                    || sub == '7' || sub == '8' || sub == '9'
                ){
                    System.debug(sub +' is an Integer');
                    Found = true;
                    strTemp = sub;
                    //To build double digit integers
                    if (i + 1 < c.Boolean__c.length()){
                        System.debug('Found an integer and there is more string to parse');
                        for (Integer q = i + 1; q < c.Boolean__c.length(); q++){
                            System.debug('In sub2, q = ' +q +' and c.Boolean__c.length()' +c.Boolean__c.length());
                            String sub2 = c.Boolean__c.substring(q,q+1);
                            if (sub2 == '0' || sub2 == '1' || sub2 == '2' || sub2 == '3'
                                || sub2 == '4' || sub2 == '4' || sub2 == '5' || sub2 == '6'
                                || sub2 == '7' || sub2 == '8' || sub2 == '9'
                            ){
                                strTemp += sub2;
                            } else {
                                mapIntegers.put(i,Integer.valueOf(strTemp));
                                lstIntPlace.add(i);
                                q = c.Boolean__c.length();
                                Found = true;
                            }
                        }//end integer loop
                    } else {
                        System.debug('Found an integer and there is no more string to parse');
                        mapIntegers.put(i,Integer.valueOf(strTemp));
                        lstIntPlace.add(i);
                        Found = true;
                    }
                } else {
                    //Looking for AND or OR
                    if (sub == 'A' || sub == 'O'){
                    	strTemp = sub;
                        //To build double digit integers
                        for (Integer q = i + 1; q < c.Boolean__c.length(); q++){
                            String sub2 = c.Boolean__c.substring(q,q+1);
                            System.debug('In AND/OR sub2 loop, sub2 = ' +sub2 +' and q = ' +q);
                            if (sub2 == 'N' || sub2 == 'D' || sub2 == 'R'){
                                strTemp += sub2;
                                System.debug('Adding to strTemp ' +strTemp);
                            }else {
                            	System.debug('Done checking and strTemp = ' +strTemp);
                                if (strTemp == 'AND' || strTemp == 'OR'){
                                    
                                    i = q-1;
                                    System.debug('q-1 = ' +i);
                                    q = c.Boolean__c.length();
                                    Found = true;
                                } else {
                                    c.addError('Illegal sub-string found in boolean Logic: \'' +strTemp +'\', character number ' +i);
                                    isError = true;
                                }
                           }
                        }//end integer loop
                    } else {
                        if (sub == '('){
                            lstLeftParen.add(i);
                            Found = true;
                        } else {
                            if (sub == ')'){
                                lstRightParen.add(i);
                                Found = true;
                            }
                        }
                    }
                }
                
            }//end if sub not a space
            if (!Found){
            	System.debug('Illegal character found in boolean Logic: \'' +sub +'\', character number ' +i);
                c.addError('Illegal character found in boolean Logic: \'' +sub +'\', character number ' +i);
                isError = true;
            }
        }//end loop through boolean string
        
        //If no errors were found
        if (!isError){
            List<Group_Criterion__c> lstCritTemp = lstCrit.clone();
            List<Integer> lstCritInts = mapIntegers.values();
            //make sure all group criteria are in the boolean string
            Integer intTrack = 1;
            map<Integer, Group_Criterion__c> mapCriteria = new map<Integer, Group_Criterion__c>();
            for (Group_Criterion__c gc : lstCrit){
                for (Integer i : lstCritInts){
                    if (gc.Order__c == i){
                    	intTrack = intTrack - 1;
                    	System.debug('Putting criteria in map at key: ' +i +' intTrack = ' +intTrack);
                        lstCritTemp.remove(intTrack);
                        //Put Criteria into a map so they're easier to find later
                        mapCriteria.put(i, gc);
                        
                    }
                }
                
                intTrack++;
            }
            //and vice versa
            intTrack = 1;
            for (Integer i : mapIntegers.values()){
                for (Group_Criterion__c gc : lstCrit){
                    if (gc.Order__c == i){
                    	intTrack = intTrack - 1;
                        lstCritInts.remove(intTrack);
                    }
                }
                intTrack++;
            }
            
            if (lstCritInts.size() > 0){
                String strErr = 'The following criteria integers in the boolean Logic do not match existing Criteria:';
                for (Integer i : lstCritInts){
                    strErr += '<br>' +i;
                }
                c.addError(strErr);
                isError = true;
            }
            if (lstCritInts.size() > 0){
                String strErr = 'The following Criteria are not represented in the boolean Logic:';
                for (Group_Criterion__c gc : lstCritTemp){
                    strErr += '<br>' +gc.Order__c;
                }
                c.addError(strErr);
                isError = true;
            }
            
            //Make sure parentheses are balanced
            if (lstRightParen.size() <> lstLeftParen.size()){
                c.addError('The parentheses in the logic are not balanced.');
                isError = true;
            }
            
            //Finally, build the WHERE CLAUSE
            if (!isError){
                map<Integer, String> mapClauses = new map<Integer, String>();
                for (Integer i : mapIntegers.keyset()){
                    String strClause = '';
                    Group_Criterion__c gc = mapCriteria.get(mapIntegers.get(i));    
                    System.debug('Getting criteria from map at key: ' +i);
                    strClause = gc.Name;
                    
                    if (gc.Operator__c == 'Equals'){
                    	if (gc.Field_Type__c == 'DECIMAL' || gc.Field_Type__c == 'CURRENCY' || 
                    		gc.Field_Type__c == 'DOUBLE' || gc.Field_Type__c == 'BOOLEAN' ||
                    		gc.Field_Type__c == 'DATE' || gc.Field_Type__c == 'DATETIME'
                    	){
                        	strClause += ' = ' +gc.Value__c;
                    	} else {
                    		strClause += ' = \'' +gc.Value__c +'\'';
                    	}
                    }
                    if (gc.Operator__c == 'Does Not Equal'){
                    	if (gc.Field_Type__c == 'DECIMAL' || gc.Field_Type__c == 'CURRENCY' || 
                    		gc.Field_Type__c == 'DOUBLE' || gc.Field_Type__c == 'BOOLEAN' ||
                    		gc.Field_Type__c == 'DATE' || gc.Field_Type__c == 'DATETIME'
                    	){
                        	strClause += ' <> ' +gc.Value__c;
                    	} else {
                    		strClause += ' <> \'' +gc.Value__c +'\'';
                    	}
                    	if (gc.Field_Type__c == 'STRING'){
                        	strClause += ' <> \'' +gc.Value__c +'\'';
                    	} else {
                    		strClause += ' <> ' +gc.Value__c;
                    	}
                    }
                    if (gc.Operator__c == 'Contains'){
                        strClause += ' like \'%' +gc.Value__c +'%\'';
                    }
                    if (gc.Operator__c == 'Does Not Contains'){
                        strClause += ' not like \'%' +gc.Value__c +'%\'';
                    }
                    if (gc.Operator__c == 'Greater Than'){
                        strClause += ' > ' +gc.Value__c;
                    }
                    if (gc.Operator__c == 'Greater Than or Equal To'){
                        strClause += ' >= ' +gc.Value__c;
                    }
                    if (gc.Operator__c == 'Less Than'){
                        strClause += ' < ' +gc.Value__c;
                    }
                    if (gc.Operator__c == 'Less Than or Equal To'){
                        strClause += ' <= ' +gc.Value__c;
                    }
                    if (gc.Operator__c == 'Includes' ){
                        Integer n = 0;
                        strClause += ' includes (\'' +gc.Value__c +'\')';
                    }
                    if (gc.Operator__c == 'Excludes' ){
                        Integer n = 0;
                        strClause += ' excludes (\'' +gc.Value__c +'\')';
                    }
                    mapClauses.put(i, strClause);
                }//end loop through Integers in logic string
                
                //Sort the placement of criterion Integers to loop through them in order
                lstIntPlace.sort();
                
                
                Integer intSpace = 0;
                Integer intLastI = 0;
                String strWhere = '';
                for (Integer i : lstIntPlace){
                    System.debug('Creating where clause, i = ' +i +'and sub = ' +mapClauses.get(i));
                    String sub = mapClauses.get(i);
                    //This should get everything in the logic between the last integer (or string start)
                    //and the reference to criteria
                    System.debug('Creating where clause, c.Boolean__c.substring(intLastI, i+1) = ' +c.Boolean__c.substring(intLastI, i+1));
                    strWhere += c.Boolean__c.substring(intLastI, i);
                    //NEED LOGIC FOR THE COMPANY FIELD (OR DO WE?)
                    strWhere += sub;
                    System.debug('Creating where clause, strWhere = ' +strWhere);
                    
                    //Find the end of the current criteria integer so we know where to 
                    //start parsing in the next loop
                    intLastI = i +String.valueOf(i).length();
                    System.debug('Creating where clause, intLastI = ' +intLastI);
                }//end loop through criteria places
                //Get the last bit of the logic string, if there is any
                if (intLastI < c.Boolean__c.length()){
                    strWhere += c.Boolean__c.substring(intLastI).toLowerCase();
                }
                System.debug('Creating where clause, strWhere = ' +strWhere);
                
                //Test it out
                String strSoQL = 'Select Id from Contact where ' +strWhere +' Limit 10';
                try{
                    Database.query(strSoQL);
                } catch (Exception e) {
                    c.addError('Error when testing where clause generated from criteria: <br/>' 
                        +strWhere +'<br/>' +e.getMessage()
                    );
                    isError = true;
                }
                
                //If the test worked, add the clause to the record
                if (!isError){
                    c.Where_Clause__c = strWhere;
                }
            }//end if no Errors (2)
        }//end if no Errors (1)
	}
}