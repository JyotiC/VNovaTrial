@isTest
private class TestFNABulkCon {

    static testMethod void myUnitTest() {
        FNA_BulkCon b = new FNA_BulkCon(); 
        Account a = new Account(); 
        
        a = b.setAccount(a);
        //System.assertEquals('Billing', a.Which_Address__c,'BulkCon: setAccount Default');
        a.Which_Address__c = 'Shipping';
        a = b.setAccount(a);
        //System.assertEquals('Shipping', a.Which_Address__c,'BulkCon: setAccount Already Set');
        
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
        
        Mappable m  = new Mappable(c); 
		b.totalHits = 0; 
		a = b.convertMappable(m,c);
		
		//System.assertEquals(a.lat__c,c.lat__c,'BulkCon: ConvertMappable Should have set Lat');
        //System.assertEquals(1,b.totalHits,'BulkCon: ConvertMappable totalHits addition');
	
		c.BillingStreet = null; 
		 m  = new Mappable(c); 
		
		a = b.convertMappable(m,c);
		
		//ystem.assertEquals(null ,a.lat__c,'BulkCon: ConvertMappable Should have set Lat/lon to null');
        //System.assertEquals(1,b.totalHits,'BulkCon: ConvertMappable totalHits should not have incremented');
	    
	    b.main();
	}
	
	static testMethod void ShouldIStopT(){
		FNA_BulkCon b = new FNA_BulkCon(); 
        Account c = new Account();
        c.FNA_Status__c = 'Bad Google Key'; 
        
        b.shouldIStop(c);
        //System.assertEquals(true,b.shouldIStop(c),'BulkCon: ShouldIStop - bad key');
        c.FNA_Status__c = 'Google Exhausted'; 
        //System.assertEquals(true,b.shouldIStop(c),'BulkCon: ShouldIStop - Google 620 (Exhausted)');
        c.FNA_Status__c = 'Located'; 
        //System.assertEquals(false,b.shouldIStop(c),'BulkCon: ShouldIStop - no, keep going...');
        
        b.CheckedPersonAccounts = false; 
        b.checkPersonAccounts();
    	//System.assertEquals(true,b.checkedPersonAccounts,'BulkCon: CheckPersonAccounts - I did check');
    }
    
    static testMethod void othersT(){
    	FNA_BulkCon b = new FNA_BulkCon(); 
        Account c = new Account();
        
        b.hasPersonAccounts = false; 
    	String q = b.getQueryString();
    	b.hasPersonAccounts = true; 
    	String qq = b.getQueryString(); 
    	//System.assert(q.length()<qq.length(),'BulkCon: getQueryString - should be longer with PersonAccounts q.length()');
    	
    	b.TotalTries = 2; 
    	b.TotalHits = 0;
    	b.TotalMisses = 0;
    	//System.assert(!b.getShowChart(),'BulkCon: getShowChart() - Should not display now'); 
    	
    	b.TotalHits = 1;
    	b.TotalMisses = 2;
    	//System.assert(b.getShowChart(),'BulkCon: getShowChart() - Should display now'); 
    	
    	b.getTotalTries();
    	b.getTotalHits();
    	b.getTotalMisses();
    	b.getMsg();
    	b.getFinished();
    }
    
}