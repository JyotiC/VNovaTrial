@isTest 
private class Test_tgrOpportunity {
    static testMethod void myTest() {
        Contact c = new Contact();
        c.FirstName='Test';
        c.LastName='Test';
        insert c;
        
        Opportunity opp1 = new Opportunity();
        opp1.Name='Test';
        opp1.Amount=1000;
        opp1.CloseDate=system.today();
        opp1.StageName='Stewardship';
        opp1.Primary_Contact__c=c.Id;
        insert opp1;
        
        opp1.Amount = 1100;
        Update opp1;
        
        Delete opp1;
    }
}