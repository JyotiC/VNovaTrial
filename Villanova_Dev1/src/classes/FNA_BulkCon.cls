public with sharing class FNA_BulkCon {
    public boolean checkedPersonAccounts = false; 
    public boolean hasPersonAccounts = false; 
    public boolean Finished = false; 
    public String msg='Checking Accounts... this can take some time, please do not navigate away from the page until the flag turns Green.';    
    public Integer totalTries = 0;
    public Integer totalHits = 0; 
    public Integer totalMisses = 0;
    //This re-runs every 10 seconds. 
    
    public PageReference main(){
        List<Account> accountsToUpdate = new List<Account>(); // Clear the list of Accounts for this batch. 
        if(!checkedPersonAccounts){ checkPersonAccounts();} // If we haven't checked for person accounts before... let's do it now. 
        msg='Checking Accounts... this can take some time, please do not navigate away from the page until the flag turns Green.';
        
        try{
            Account[] toTag = Database.query(getQueryString()); // get the list of accounts
           
            if(toTag.size() == 0){
                Finished = true; 
                Msg = 'Finished. '; 
            }   //if none are returned, we're done!
            else{
                accountsToUpdate = GoThroughAccounts(toTag); 
            }//end Else
         
            update accountsToUpdate;
         }//endTry
         catch(Exception e){
            totalMisses++; //some crazy error. Just move on... 
            Msg=' You encountered a System Error: '+ e; 
         }
         
         return null; //refresh the page
    }   
    public Account setAccount(Account acc){
      //if you haven't selected which address you want to map, then I'll pick "billing" for you. 
        if(acc.Which_Address__c !='Billing' && acc.Which_Address__c != 'Shipping' && acc.Which_Address__c !='Do Not Map')
        {
            acc.Which_Address__c = 'Billing'; 
        }
        
        return acc; 
    }
    
    public Account convertMappable(Mappable m, Account acc){
        acc.FNA_Status__c = m.getStatus(); // what's the status? 
        
        if(m.getMappable()) 
        {
            totalHits++;
            acc.Lat__c = m.getLat();
            acc.Lon__c = m.getLon(); 
        }
        else{ 
            totalMisses++; 
            acc.Lat__c = null;
            acc.Lon__c = null; 
        }
        return acc; 
    }
    //Takes the found accoungs and sees if they are Mappable
    public List<Account> GoThroughAccounts(List<Account> toTag){
        List<Account> accountsToUpdate = new List<Account>(); 
        
        for(Account acc :toTag)
        {   
            totalTries++; // keep that counter going. 
            acc = setAccount(acc); 
          
            Mappable m = new Mappable(acc); 
            m.geoTag(); // Try to tag the accoung. 
            
            accountstoUpdate.add(convertMappable(m,acc));
            
            Boolean toBreak = shouldIStop(acc);
            if(toBreak){break;}
        }//end for 
        return accountsToUpdate; 
    }
    
    /**If the account had bad results, it will stop the app from looping**/ 
    public boolean shouldIStop(Account acc){
        
        /*If you get either of these errors, there's no point in continuing, let's stop*/
        if(acc.FNA_Status__c == 'Bad Google Key')
        {
            Finished = true;
            Msg = 'Your Google Map Key is not correct, please have your administrator set it and then reload this page. (Steps in \'Installation Guide\' Tab)'; 
            return true; 
        }
        else if ( acc.FNA_Status__c == 'Google Exhausted')
        {
            Finished = true;
            Msg = 'Google will no longer service Salesforce.com for the day, Google\'s services have been Exhausted.' 
                 +'You must wait for the 24 hour \'ban\' to be lifted, or purchase a premium Google Maps API key';
            return true; 
        }
        return false; 
    }
    
    /*Checks for person Accounts, sets hasPersonAccounts flag, and checkedPersonAccounts (so I don't rerun this check).*/ 
    public void checkPersonAccounts(){
        Map<String, Schema.SObjectField> M = Schema.SObjectType.Account.fields.getMap();
        checkedPersonAccounts=true;
                    
        if(M.containsKey('IsPersonAccount')){
            hasPersonAccounts = true; 
        }
        else{
            hasPersonAccounts = false;
        }
    }
    
    /*Constructs the String based on Person Accounts Response. */
    public String getQueryString(){
        String q= 'Select BillingStreet,BillingCity,BillingState,BillingPostalCode, phone,Type, lat__c, lon__c, ShippingStreet,ShippingCity,ShippingState,ShippingPostalCode, FNA_Status__c, Which_Address__c, Name, Id from Account where ';
                
        if(hasPersonAccounts){
            q+=' (IsPersonAccount = false) and '; 
        }
        q+='(FNA_Status__c != \'Located\' and FNA_Status__c != \'Problem With Address\') and (Which_Address__c != \'Do Not Map\') limit 10'; 
        return q;
   }
   
    /*Only show the Google Chart on the Bulk page if there are some misses and some hits... no point otherwise. */
    public boolean getShowChart() {
        if(totalHits>0 && totalMisses>0 ){return true;}
        else{ return false;}
    }
    
    public Integer getTotalTries(){return totalTries;}
    public Integer getTotalHits(){return totalHits;}
    public Integer getTotalMisses(){return totalMisses;}
    public String getMsg(){return Msg;}
    public Boolean getFinished(){return !finished;}
    
    
}