trigger tgrOpportunity on Opportunity (after delete, after insert, after update) {
    Opportunity opp = new Opportunity();
    
    if (Trigger.IsInsert || Trigger.IsUpdate) {
        opp = Trigger.New[0]; 
    }
    else if(Trigger.isDelete) {
        opp = Trigger.Old[0];
    }
    

    if (opp.Primary_Contact__c!=null) {
        Contact c = [Select ID,
                    Largest_Gift_Amount__c,
                    Largest_Gift_Dt__c,
                    Last_Gift_Amount__c,
                    Last_Gift_Dt__c,
                    LifeTime_Gift__c,
                    SYBUNT__c,
                    LYBUNT__c
                    from Contact where ID=: opp.Primary_Contact__c];
        
        
        List<Opportunity> lstOpportunity = [Select Id,Amount,CloseDate from Opportunity where Primary_Contact__c =: opp.Primary_Contact__c and StageName='Stewardship' order by Amount desc];

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
        
        if(c!=null) {
            c.Largest_Gift_Amount__c = LargestGiftAmount;
            c.Largest_Gift_Dt__c = LargestGiftDate;
            c.Last_Gift_Amount__c = LastGiftAmount;
            c.Last_Gift_Dt__c = LastGiftDate;
            c.LifeTime_Gift__c = LifeTimeGiftAmount;
            c.SYBUNT__c = SYBUNT;
            c.LYBUNT__c = LYBUNT;
            Update c;
        }
    
    }
}