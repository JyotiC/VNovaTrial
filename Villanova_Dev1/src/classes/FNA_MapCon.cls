public with sharing class FNA_MapCon {
    public Account mainAccount;
 
    public List<Account> Locations = new List<Account>(); // The list of Accounts to be shared with the Page
    public String Distance {get; set;} // How far do we want to search? (from UI)
    public String searchType; // What Account Types will we search for ? ( from UI)
    public String[] Types = new String[]{'All'}; // The list of ALL account Types
 
    public Boolean error = false; // Do we continue to load the Map
    public String msg=''; // What is the error message to display to the user? 
    
    public String City {get;set;} // What city does the user want us to search? 
    public Boolean showDist; //Do we show the Distance drop down? 
    public Boolean onlyMyAccounts{get;set;} //Filter the Search Query to only show User's Accounts
    /*This block has to do with the Addresses in the Itinerary (or directions) */
    public String fromAdd{get;set;} 
    public String toAdd{get;set;}
    public String toThird{get;set;}
    public String toFourth{get;set;}
    public String toFifth{get;set;}
    public String toSixth{get;set;} 

    public Boolean hasPersonAccounts=false; //Does this Organization have PersonAccounts Enabled?
    
    //These will be set as the Bounding Box for the query
    private Double LatMax =0;
    private Double LatMin =0;
    private Double LonMin =0;
    private Double LonMax =0;
    
    public void init(){
        error = !isSourceAccountGood();
        checkPersonAccounts();

        Distance='5';
        Types.add('All');
        SearchType = 'Distance';
        msg='The Account cannot be mapped, please look over the Account record for more information (Account:'+mainAccount.FNA_Status__c+')';
        onlyMyAccounts=false;
        SetStartAddress();
        toThird = '...';
        toFourth='...';
        toFifth='...';
        toSixth='...';
        showDist = true; 

        //If there is no error, let's populate the map. 
        if(!error){Search();}
    } 

    /*Helps clean up the init() method.  I need to set the FROM address for driving directions.
        If the User doesn't have the Street/City / State set. I use the Organization's address. 
        If the Organization doesn't have a fully populated address I use the text 'Street,City,State' 
    */
    public void setStartAddress(){
        
        User u = [Select Street, City, State from User where Id = :UserInfo.getUserId()];
        
        if(u.Street != null && u.City != null && u.State != null)
        {
            fromAdd= u.Street+', '+u.City+', '+u.State;  
        }
        else{
            fromAdd = 'Street, City, State';
        }
    }
    
    /*To do the search, I Find the Dimensions of my bounding box (serach area), Generate the list of accounts, and refresh the page. */ 
    public PageReference Search() {
        findMax();    
        makeList();
        return null;
    }

    public Boolean isSourceAccountGood(){
        Mappable m; 
        try{
            mainAccount = [Select Id,Name,Lat__c,Lon__c, Type, BillingStreet,BillingCity,BillingPostalCode,BillingState, ShippingStreet,
                           ShippingCity,ShippingState,ShippingPostalCode, FNA_Status__c, Phone, Which_Address__c 
                           from Account where Id  = :ApexPages.currentPage().getParameters().get('id') limit 1]; 
            
            m = new Mappable(mainAccount); // Make a "Mappable" object off of the account 
            //If it hasn't been located it... TRY! If it has... we're already in business!
            
            if(mainAccount.FNA_Status__c != 'Located'){
                
                m.geoTag();
                
                mainAccount.lat__c = m.getLat();
                mainAccount.lon__c = m.getLon();
                mainAccount.FNA_Status__c = m.getStatus(); // The Status will tell us if it worked.  
                update mainAccount; 
            }
        }catch(Exception e){
                //something crazy went down. 
                error = true;  
                Msg = 'We encountered issues while attempting to locate the account, here is the system generated Error:' + e;
                return false;  // definately not mappable. 
        }
        return m.getMappable();          
    }

    public void makeList(){
        Locations = new List<Account>(); //Clear the list. 
        try{
            Locations = Database.query(makeQuery()); 
            Locations = OrderSource(Locations); // Make sure the Original Account is in the list and only at the top.  
        }
        catch(Exception e) {error= true; Msg='An Error has occured while trying to gather accounts: Error Msg:'+e;}
    }

    /*This method takes in the list of locations, and makes sure that the MainAccount is at the top of the list.
      That ensures that the Account the user clicked on is at the TOP of the dataTable on the UI*/
    public List<Account> OrderSource(List<Account> locations){
       
        Boolean foundMain = false;
       
        for(Integer k=0; k<Locations.size(); k++)
        {  
           //If you find the main account.
           if(Locations[k].Id == mainAccount.Id)
           {
                //Remove i from the list
                Account temp = Locations.remove(k);
                foundMain=true;    
                //If that was the only account found... then you have to add it with different syntax.    
                if(Locations.isEmpty()){Locations.add(temp);}
                else{Locations.add(0,temp);}
                break;
            }
        }
       
        if(!foundMain){
            Account theMain = [Select Id,Name,Lat__c,Lon__c, Type, BillingStreet,BillingCity,BillingPostalCode,BillingState, ShippingStreet,
                ShippingCity,ShippingState,ShippingPostalCode, FNA_Status__c, Phone, Which_Address__c from Account where Id = :mainAccount.ID limit 1];
                if(Locations.isEmpty()){Locations.add(theMain);}
                else{Locations.add(0,theMain);}
        }
       
        return Locations;
    }

    public String makeQuery(){
        String searchQ = 'Select Id,Name,Lat__c,Lon__c, Type, BillingStreet,BillingCity,BillingPostalCode,BillingState, ShippingStreet,';
            searchQ+='ShippingCity,ShippingState,ShippingPostalCode, FNA_Status__c, Phone, Which_Address__c from Account';
            
        if(showDist){    // If this is by Distance
            searchQ+=' where (( lat__c <= :latMax and lat__c >=:latMin ';
            searchQ+=' and lon__c <= :lonMax and lon__c >=:lonMin and FNA_Status__c = \'Located\' and Which_Address__c !=\'Do Not Map\''; 
        }
        else{ // If this is by City
            searchQ+=' where ((';
            searchQ+=  ' (BillingCity = \''+city+'\' and Which_Address__c =\'Billing\')';
            searchQ+=  ' OR (ShippingCity = \''+city+'\' and Which_Address__c = \'Shipping\' )';
            searchQ+=  ')';
            searchQ+=' and (FNA_Status__c = \'Located\' and Which_Address__c !=\'Do Not Map\''; 
        }
        
        //Cover our rear ends incase the Organization is using PersonAccounts
        if(hasPersonAccounts){
            searchQ+=' and IsPersonType = false ';
        } 
        
        //If the user didn't Select "all" on th UI, then each TYPE they did select needs to be added to the list. 
        if(!searchAllTypes())
        {
            String toLookFor=''; 
            for(String k:Types)
            {
                toLookFor+='\''+k+'\',';
            }
            toLookFor = toLookFor.substring(0,toLookFor.length()-1); 
            searchQ+=' and type in ( '+ToLookFor+' ) ';
        }               
        
        if(onlyMyAccounts){
            searchQ+=' and OwnerId = \''+UserInfo.getUserId()+'\' ';
        }
        
        searchQ+=')) OR Id = \''+mainAccount.Id+'\'  limit 31'; //the limit of 31 is imposed to keep the Table on the UI from getting TOO long. 
        return searchQ; 
    }
    
    
    
    
    public void findMax(){
        
        //These track the delta in lat /long, and the range to search for. 
        Double LatDiff=0; 
        Double LonDiff=0;
        Double LatEnd,LonEnd,X,Y; 
        LatMax=0;
        LatMin=0;
        LonMin=0;
        LonMax=0;
        Double Answer =0; 
        
        try{
            Double D = Double.valueOf(Distance);
        
            /*reset the Lat/Lon*/
            
            //Fixed Latitude 
            while(Answer < D){
                LatDiff+=.001;
                latEnd = mainAccount.lat__c+latDiff;
                X = 69.1 * (latEnd - mainAccount.lat__c);
                Answer = Math.sqrt(X*X);
            }
            
            //Fixed Longitude
            Answer = 0; 
            while(Answer<D){
                LonDiff+=.001;
                lonEnd=LonDiff+mainAccount.lon__c;
                Y = 69.1* (lonEnd-mainAccount.lon__c)*Math.cos(mainAccount.lat__c/57.3);
                Answer = Math.sqrt(Y*Y);
            }
            
            LatMin = mainAccount.lat__c-latDiff;
            LatMax = mainAccount.lat__c+latDiff;
            LonMin = mainAccount.lon__c-LonDiff;
            LonMax = mainAccount.lon__c+lonDiff;
        
        }catch(Exception e){
            //I assume I got a crazy math exception. So let's set some values.
            //This way, no accounts SHOULD meet this criteria, no Error, just no result. 
            latMax= 1;
            latMin = 2; 
            lonMin = 2;
            lonMax = 1; 
            LonEnd = 1;
            LatEnd = 2; 
        }
        
    }
    
    /*Checking to see if the List of Types contains All*/
    public Boolean searchAllTypes(){
        for(Integer k=0; k<Types.size(); k++)
        {
            if(types[k] == 'All')
            {
                return true;
            }
        }
        return false;
    } 
    
    
 
    /*Returns the list of located accounts to the UI
      I've made them Mappable Objects, just incase we want to map 
      other objects in the future, the UI can be setup for that.*/
    public List<Mappable> getLocations(){
        List<Mappable> maps = new List<Mappable>(); 
        for(Account a : locations){
                Mappable m = new Mappable(a);
                maps.add(m);
        }
            return maps;
    }
    

    
    /*To create Dynamic TYPE List on Accounts*/ 
    public List<SelectOption> getItems(){
        List<SelectOption> items = new List<SelectOption>();
        Schema.DescribeFieldResult F = Account.Type.getDescribe();
        List<Schema.PicklistEntry> P = F.getPicklistValues();
    
        items.add(new SelectOption('All','All'));
    
        for(integer k =0; k< P.size(); k++)
        {
            if(P[k].isActive())
            {
               items.add(new SelectOption(P[k].getLabel(),P[k].getLabel()));
            }
        }
        
        return items;
    }
    
    public void checkPersonAccounts(){
            Map<String, Schema.SObjectField> M = Schema.SObjectType.Account.fields.getMap();
                    
            if(M.containsKey('IsPersonType')){
                hasPersonAccounts = true; 
            }
            else{
                hasPersonAccounts = false;   
            }    
    }
    
    /* Creates drop down of Distances */  
    public List<SelectOption> getDistances(){ 
        List<SelectOption> distances = new List<SelectOption>{new SelectOption('1','1'),
                new SelectOption('5','5'),new SelectOption('10','10'), new SelectOption('15','15'),
                new SelectOption('20','20'), new SelectOption('25','25'), new SelectOption('50','50'), new SelectOption('75','75')
        }; 
    
       return distances;
    }
    /*This populates the Radio buttons on the page*/
    public List<SelectOption> getSearchTypes(){
        List<SelectOption> o = new List<SelectOption>{ new SelectOption('City','City'), new SelectOption('Distance','Distance')};   
        return o;
    }
     
    /*Returns the list of Account Names for the Drop down boxes on the UI
      I've capped the lenght of the Account Names to ensure REALLY long names don't tweak the UI. */
    public List<SelectOption> getPlaces(){
        List<SelectOption> pl = new List<SelectOption>();
        for(Account a: Locations)
        {
            String aName = a.Name; 
            if(aname.length() >= 20){aName = aName.substring(0,18)+'...';}
            
            /*I don't want any odd Account Names messing up the URL*/
            aName= aname.replace('\'','');
            aName= aname.replace('"','');
            aName= aname.replace('','');
            
            Mappable m = new Mappable(a);
            String addr = m.getURLCleanAddress();
            pl.add(new SelectOption(addr+' ('+aname+')',aname));
        }
       return pl;
    } 
    
    /*This takes the normal "Places" list and adds a ... to the last item.
      This way, each of the second,third... destinations can be "..." instead of an Account Name. 
    */
    public List<SelectOption> getPlacesD(){
        List<SelectOption> pl = new List<SelectOption>();
        pl = getPlaces();
        pl.add(new SelectOption('...','...'));
        return pl; 
    }
    
    /*Set's the SearchType, and the boolean that determines if the UI shows the Distance or the City field*/
    public void setSearchType(String s){ 
        SearchType = s;
        if(SearchType =='Distance') {showDist = true; } 
        else{ showDist = false;} 
    }
  
    /*
        Makes the URL for the multiple destinations. 
    */
    public PageReference makeIten(){
        String FromA='';
        FromA = EncodingUtil.urlEncode(FromAdd, 'UTF-8');
        FromA = FromA.replace('+',' '); // I clean up the Starting Address... you can't be too sure. 
        
        String ToQuery='http://maps.google.com/maps?saddr='+FromA+' to:'+ToAdd;
        if(toThird != '...'){toQuery+=' to:'+toThird;}
        if(toFourth != '...'){toQuery+=' to:'+toFourth;}
        if(toFifth != '...'){toQuery+=' to:'+toFifth;}
        if(toSixth != '...'){toQuery+=' to:'+toSixth;}
        return new PageReference(toQuery);
    }
  
    public PageReference goBack(){return new PageReference('/'+mainAccount.id);}
    public PageReference goBackMap(){return new PageReference('/apex/FindNearbyAccountsMap?Id='+mainAccount.id);}
    public PageReference gotoIten(){return Page.FindNearbyAccountsIten;}
    public String[] getTypes() {return Types;}
    public void setTypes(String[] s){ Types = s;}
    public String getMsg(){return msg;}
    public Boolean getError() {return error;}  
    public Boolean getShowDist(){return showDist;} 
    public String getSearchType(){return searchType;}
    public String getId(){ return mainAccount.Id;} 
    public Account getmainAccount(){return mainAccount;}
}