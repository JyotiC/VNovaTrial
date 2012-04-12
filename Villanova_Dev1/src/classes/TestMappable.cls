@isTest
private class TestMappable {

    static testMethod void MappableObjectTest() {
        // Set up the Account record.
        Account a = new Account(Name='Test Account', Which_Address__c='Billing', Phone='1234567', BillingStreet='730 Bounty Dr.', BillingCity='Foster City', BillingState = 'Ca',BillingPostalCode='94404',Lat__c=1,Lon__c= 2);
        Account b = new Account(Name='Test Account2', Type='Customer', ShippingStreet='730 Bounty Dr.',Which_Address__c ='Shipping', ShippingCity='Foster City', ShippingState = 'Ca');
        Account c = new Account(Name='Test Account2', BillingStreet = 'M',Which_Address__c='Shipping', ShippingStreet='730 Bounty Dr.', ShippingCity='Foster City', ShippingState = 'Ca');
        
        insert a;
        insert b;
        insert c; 
    
        a = [Select Id, Which_Address__c,Name,Type, FNA_Status__c, Phone,lat__c,lon__c,BillingStreet, ShippingStreet, ShippingCity, ShippingState, SHippingPostalCode, ShippingCountry,BillingCountry, BillingCity, BillingState,BillingPostalCode from Account where Id = :a.Id limit 1];  
        b = [Select Id, Which_Address__c,Name,Type, FNA_Status__c, Phone,lat__c,lon__c,BillingStreet, ShippingStreet, ShippingCity, ShippingState, SHippingPostalCode, ShippingCountry,BillingCountry, BillingCity, BillingState,BillingPostalCode from Account where Id = :b.Id limit 1];
        c = [Select Id, Which_Address__c,Name,Type, FNA_Status__c, Phone,lat__c,lon__c,BillingStreet, ShippingStreet, ShippingCity, ShippingState, SHippingPostalCode, ShippingCountry,BillingCountry, BillingCity, BillingState,BillingPostalCode from Account where Id = :c.Id limit 1];
        
        Mappable ma = new Mappable(a);
        Mappable mb = new Mappable(b);
        Mappable mc = new Mappable(c);
        
        
        //System.assertEquals('Billing', a.Which_Address__c,'Mappable: Which Address Failure');
        //System.assertEquals('Not Located Yet', b.FNA_Status__c,'Mappable: Status Failure');
        mc.getStreet();
        ma.getCity();
        ma.getState();
        ma.getId();
        ma.getObjType();
        ma.getZip();
        ma.getCleanAddress();
        ma.getLat();
        ma.getLon();
        mc.getCleanAddress();
        ma.getMappable();
        mb.getMappable();
        mc.getMappable();
        ma.buildWebServiceRequest();
        ma.getPhone();
        ma.GetStatus();
        mb.getName();
        mb.GetType();
        ma.GetURLCleanAddress();
        //System.assertEquals('730 Bounty Dr.',mc.getStreet(),'Mappable: getStreet Failure');
        //System.assertEquals('Foster City',ma.getCity(), 'Mappable: getCity Failure');
        //System.assertEquals('Ca',ma.getState(), 'Mappable: getState Failure');
        //System.assertEquals(a.Id,ma.getId(), 'Mappable: getID Failure');
        //System.assertEquals('Account',ma.getObjType(), 'Mappable: getObjType Failure');
        //System.assertEquals('94404', ma.getZip(),'Mappable: getZip Failure');
        /*System.assert(ma.getCleanAddress().length()>3, 'Mappable: GetCleanAddress Failure');
        System.assert(ma.getCleanAddress() != 'Problem with Address', 'Mappable: GetCleanAddress (Problem With) Failure');
        System.assertEquals(1,ma.getLat(),'Mappable:GetLat Failure');
        System.assertEquals(2,ma.getLon(),'Mappable:GetLat Failure');
        String s = mc.getCleanAddress();
        System.assertEquals(true,ma.getMappable(),'Mappable: Mappable?  1');
        System.assertEquals(true,mb.getMappable(),'Mappable: Mappable? 2');
        System.assertEquals(true,mc.getMappable(),'Mappable: Mappable? 3');
        System.assert(ma.buildWebServiceRequest() != null, 'Mappable: Build Service Request');
        System.assertEquals(a.Phone,ma.getPhone(),'Mappable: GetPhone');
        System.assertEquals('Not Located Yet', ma.GetStatus(),'Mappable:getStatus');
        System.assertEquals(b.Name,mb.getName(),'Mappable:getName');
        System.assertEquals(b.Type,mb.GetType(),'Mappable:getType');
        System.assert(!ma.getURLCleanAddress().contains('+'),'Mappable:URLgetCleanAddress');
        */
        ma.handleWebServiceResponse('200,8,42.7,-73.5');
        ma.getMappable();
        ma.getStatus();
        //System.assertEquals(true,ma.getMappable(),'Mappable: Mappable - Good Response');
        //System.assertEquals('Located',ma.getStatus(),'Mappable: Mappable - Good Response');
        ma.handleWebServiceResponse('200,5,42.7,-73.5');
        ma.getMappable();
        //System.assertEquals(false,ma.getMappable(),'Mappable: Mappable - Poor Accuracy');
        ma.handleWebServiceResponse('500,8,42.7,-73.5');
        //System.assertEquals(false,ma.getMappable(),'Mappable: Mappable - Try Again');
        ma.getMappable();
        ma.getStatus();
        //System.assertEquals('Problem with Address',ma.getStatus(),'Mappable: - Problem with Address 1');
        ma.handleWebServiceResponse('620,8,42.7,-73.5');
        //System.assertEquals(false,ma.getMappable(),'Mappable: Mappable - Google Exhausted');
        ma.getMappable();
        ma.handleWebServiceResponse('602,8,42.7,-73.5');
        //System.assertEquals(false,ma.getMappable(),'Mappable: Mappable - Problem with Address 2');
        ma.getMappable();
        ma.handleWebServiceResponse('610,8,42.7,-73.5');
        ma.getMappable();
        //System.assertEquals(false,ma.getMappable(),'Mappable: Mappable - Bad Google Key');
     }
        
        
        

    static testMethod void KeepTidyTest() {
        // Set up the Account record.
        Account a = new Account(Name='Test Account', FNA_Status__c ='Located', Which_Address__c='Billing', Phone='1234567', BillingStreet='730 Bounty Dr.', BillingCity='Foster City', BillingState = 'Ca',BillingPostalCode='94404',Lat__c=1,Lon__c= 2);
        
        insert a;
        System.assertEquals('Located', a.FNA_Status__c,'KeepTidy: Status 1');
        
        a.BillingStreet= 'B';
        update a; 
        a = [Select Which_Address__c, FNA_Status__c from Account where Id = :a.Id limit 1]; 
        
        System.assertEquals('Not Located Yet', a.FNA_Status__c,'KeepTidy: Status Change Billing');
        
        a.Which_Address__c = 'Shipping';
        update a; 
        a = [Select Which_Address__c, FNA_Status__c from Account where Id = :a.Id limit 1]; 
        
        System.assertEquals('Not Located Yet', a.FNA_Status__c,'KeepTidy: Status Change WHICH address ');
        
        
        a.FNA_Status__c='Located';
        update a; 
        
        System.assertEquals('Located', a.FNA_Status__c,'KeepTidy: Status is Set LOCATED');
        
        a.ShippingPostalCode = '12345';
        
        update a; 
        a = [Select Which_Address__c, FNA_Status__c from Account where Id = :a.Id limit 1]; 
        
        System.assertEquals('Not Located Yet', a.FNA_Status__c,'KeepTidy: Status Change Shipping');
        
        a.Which_Address__c = 'Do Not Map';
        a.lat__c = 23;
        update a; 
        
        System.assert(a.lat__c != null, 'KeepTidy: Lat set');
        a = [Select Which_Address__c, FNA_Status__c,lat__c,lon__c from Account where Id = :a.Id limit 1];   
        
        System.assertEquals('Do Not Map', a.Which_Address__c, 'KeepTidy: Address of Do not Map');
        System.assert(a.lat__c == null, 'KeepTidy: Lat Reset');
        
        
         
    }           
}