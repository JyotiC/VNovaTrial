public with sharing class TestMapCon {
    static testMethod void others() {
        FNA_MapCon b = new FNA_MapCon(); 
        
        Account c = new Account();
        
        c.Name = 'Abc Corp';
        c.Phone = '1234567';
        c.BillingStreet='1 Market St.';
        c.BillingCity ='San Francisco';
        c.BillingPostalCode = '94105';
        c.BillingState = 'Ca';
        c.BillingCountry = 'US'; 
        c.FNA_Status__c = 'Not Located Yet'; 
        c.Which_Address__c ='Billing'; 
        c.Lat__c = 1;
        c.Lon__c = 1; 
        insert c; 
        
        b.MainAccount = c; 
        b.goBack();
        b.goBackMap();
        b.gotoIten();
        b.getTypes();
        b.getMsg();
        b.getError();
        b.getShowDist();
        b.getSearchType();
        b.getId();
        b.getMainAccount();
        String[] t = new String[]{};
        t.add('1');
        t.add('2');
        b.setTypes(t);
        b.getSearchTypes();
        b.getDistances();
        b.checkPersonAccounts();
        b.getItems();
    }   
    
    static testMethod void bottom(){
        FNA_MapCon b = new FNA_MapCon(); 
        //b.init();
        Account c = new Account();
        c.Name = 'Abc Corp';
        c.Phone = '1234567';
        c.BillingStreet='1 Market St.';
        c.BillingCity ='San Francisco';
        c.BillingPostalCode = '94105';
        c.BillingState = 'Ca';
        c.BillingCountry = 'US'; 
        c.FNA_Status__c = 'Not Located Yet'; 
        c.Which_Address__c ='Billing'; 
        c.Lat__c = 1;
        c.Lon__c = 1; 
        
        insert c ; 
        b.mainAccount = c; 
        
        b.FromAdd = 'Hi+lkajsdlfjalsdkjflajsdlfj'; 
        b.toThird = 'abcdefgh';
        b.makeIten();
    
        b.setSearchType('Distance');
        //System.assert(b.showDist,'FNA_MapCon: setSearchTyp - should show distance');
        b.setSearchType('Something');
        //System.assert(!b.showDist,'FNA_MapCon: setSearchTyp - should not show distance');
        
        b.Locations.add(c); 
        
        //System.assert(b.getPlaces().size() < b.getPlacesD().size(),'FNA_MapCon: getPlaces - make sure the other one is longer'); 
        
        //System.assert(b.getLocations().size() > 0,'FNA_MapCon: getLocations - should have some values');
        b.searchAllTypes();
        b.Distance ='4';
        b.findMax();
        b.init();
        b.onlyMyAccounts=true;
        b.makeQuery();
                
        Account d = new Account();
        d.Name = 'Abc Corp';
        d.Phone = '1234567';
        d.BillingStreet='1 Market St.';
        d.BillingCity ='San Francisco';
        d.BillingPostalCode = '94105';
        d.BillingState = 'Ca';
        d.BillingCountry = 'US'; 
        d.FNA_Status__c = 'Not Located Yet'; 
        d.Which_Address__c ='Billing'; 
        d.Lat__c = 1;
        d.Lon__c = 1; 
        
        
        b.setStartAddress();
        b.init();
        
    }
    
  
}