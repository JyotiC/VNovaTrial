global class BatchExecUpdateContactSummary implements Database.Batchable<sObject> {
    global final String Query;
    global boolean IsTest;    
    global BatchExecUpdateContactSummary (String q){Query=q;}

    global Database.QueryLocator start(Database.BatchableContext BC)   {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope)   {
        DoBatchExecUpdateContactSummary(scope);
    }
    
    void DoBatchExecUpdateContactSummary(List<sObject> scope) {
        Set<ID> ContactIDs = new Set<ID>();
        
        for(sObject s : scope) {
            Contact c = (Contact)s;
            ContactIDs.add(c.Id);
        }
        
        List<Contact> lstContact = [Select ID,
                    Largest_Gift_Amount__c,
                    Largest_Gift_Dt__c,
                    Last_Gift_Amount__c,
                    Last_Gift_Dt__c,
                    LifeTime_Gift__c,
                    SYBUNT__c,
                    LYBUNT__c,
                    (Select Id,Amount,CloseDate from Donations__r where StageName='Stewardship' order by Amount desc)
                    from Contact where ID IN: ContactIds];
                    
        List<Contact> lstUpdateContact = new List<Contact>();
        
        for(Contact cnt: lstContact) {

            Decimal LargestGiftAmount = 0.0;
            Decimal LastGiftAmount = 0.0;
            Decimal LifeTimeGiftAmount = 0.0;
            
            Date LargestGiftDate;
            Date LastGiftDate;
            Boolean SYBUNT = false;
            Boolean LYBUNT = false;
            
            Boolean SYBUNTCondition1 = false;
            Boolean SYBUNTCondition2 = false;
            Boolean LYBUNTCondition1 = false;
            Boolean LYBUNTCondition2 = false;
            
            List<Opportunity> lstOpportunity = cnt.Donations__r;
            
            if(lstOpportunity.size()>0){
                LargestGiftAmount = lstOpportunity[0].Amount;
                LargestGiftDate = lstOpportunity[0].CloseDate;
                
                LastGiftAmount = lstOpportunity[0].Amount;
                LastGiftDate = lstOpportunity[0].CloseDate;
            }
            
            for(Opportunity op: lstOpportunity) {
                if(op.CloseDate > LastGiftDate) {
                    LastGiftDate = op.CloseDate;
                    LastGiftAmount = op.Amount;
                }
                LifeTimeGiftAmount += op.Amount;
    
                //SYBUNT
                //At least one opportunity related to the Contact that has Stage = Stewardship and Date <> THIS YEAR
                if(op.CloseDate.Year()!=system.today().Year() && SYBUNTCondition1 == false) {
                    SYBUNTCondition1 = true;
                }
                //There is no opportunity related to the Contact that has Stage = Stewardship and Date = THIS YEAR
                if(op.CloseDate.Year()==system.today().Year()) {
                    SYBUNTCondition2 = True;
                }
    
                //LYBUNT
                //At least one opportunity related to the Contact that has Stage = Stewardship and Date = LAST YEAR
                if(op.CloseDate.Year()==system.today().Year()-1 && LYBUNTCondition1 == false) {
                    LYBUNTCondition1 = true;
                }
                //There is no opportunity related to the Contact that has Stage = Stewardship and Date = THIS YEAR
                if(op.CloseDate.Year()==system.today().Year()) {
                    LYBUNTCondition2 = True;
                }
            }
            if(SYBUNTCondition1==true && SYBUNTCondition2==false){
                SYBUNT=true;
            }
                    
            if(LYBUNTCondition1==true && LYBUNTCondition2==false){
                LYBUNT=true;
            }
            
            if(cnt!=null) {
                cnt.Largest_Gift_Amount__c = LargestGiftAmount;
                cnt.Largest_Gift_Dt__c = LargestGiftDate;
                cnt.Last_Gift_Amount__c = LastGiftAmount;
                cnt.Last_Gift_Dt__c = LastGiftDate;
                cnt.LifeTime_Gift__c = LifeTimeGiftAmount;
                cnt.SYBUNT__c = SYBUNT;
                cnt.LYBUNT__c = LYBUNT;
                
                lstUpdateContact.add(cnt);
            }            
        }
        
        if(lstUpdateContact.size()>0) Update lstUpdateContact;
    }
    
    global void finish(Database.BatchableContext BC) {
        //System.debug('####Update Completed...');
    }    

    static testMethod void TestBatchExecUpdateContactSummary () {
        Test.startTest();
        Account a = new Account();
        a.Name = 'TestAcc';
        insert a;
        
        
        Contact c = new Contact();
        c.FirstName = 'TestFirstName';
        c.LastName = 'TestLastName';
        c.AccountID = a.Id;
        
        Opportunity o = new Opportunity();
        o.Name = 'TestOpp';
        o.StageName = 'Stewardship';
        o.Amount = 1000;
        o.CloseDate = system.today().addYears(-1);
        o.Primary_Contact__c = c.Id;
        insert o;
        
        ID batchprocessid;
        BatchExecUpdateContactSummary reassign;
        reassign = new BatchExecUpdateContactSummary('Select ID from contact limit 200');
        batchprocessid = Database.executeBatch(reassign);
        
        BatchUpdateContactSummary.BatchUpdateContactSummary();
        Test.StopTest();     
    }    
}