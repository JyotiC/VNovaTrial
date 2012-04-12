public class ContactSummary {
    
   // private final String sFinalStage = 'Stewardship';
    private final Contact objContact;
    

    
    public contact con;

    public ContactSummary(ApexPages.StandardController controller) {
        this.objContact = (Contact)controller.getRecord();
        con = this.objContact;

        con.SYBUNT__c = SYBUNT();
        con.LYBUNT__c = LYBUNT();
    }


    public string getLargestGift() {
        List<Opportunity> objOpp = [Select Amount ,CloseDate from Opportunity 
                where Primary_Contact__r.ID=:objContact.ID and StageName = 'Stewardship'
                order by Amount desc limit 1];
        
        string LargestGift='';
        if (objOpp.size() > 0) {
            string dtDate = string.valueof(objOpp[0].CloseDate);
            string FinalDate = dtDate.substring(5,7) + '/' + dtDate.substring(8,10) + '/' + dtDate.substring(0,4);
            LargestGift = '$' + objOpp[0].Amount + ' and ' + FinalDate;
        }
        return LargestGift;
    }
    
   
    public string getLifeTimeGift() {
        AggregateResult[] objOpp = [Select SUM(Amount) LifeTimeGift from Opportunity 
                where Primary_Contact__r.ID=:objContact.ID 
                and StageName = 'Stewardship'
                group by StageName];
        
        string LifeTimeGift='';
        if (objOpp.size() > 0) {
            LifeTimeGift = '$' + decimal.valueof(string.valueof(objOpp[0].get('LifeTimeGift'))).setScale(2);
        }
        return LifeTimeGift;
    }
    
    private boolean SYBUNT() {
        boolean blnS = False;
        /*List<Opportunity> objOpp = [Select Amount ,CloseDate from Opportunity 
                where Primary_Contact__r.ID=:objContact.ID 
                and StageName = 'Stewardship' and CLOSEDATE< THIS_YEAR];
        
        string LargestGift='';
        if (objOpp.size() > 0) {
        */
            /*List<Opportunity> objOpp1 = [Select Amount ,CloseDate from Opportunity 
                    where Primary_Contact__r.ID=:objContact.ID 
                    and StageName = 'Stewardship' and CLOSEDATE= THIS_YEAR];
            */
            
            List<Opportunity> objOpp1 = [Select Amount ,CloseDate from Opportunity 
                    where Primary_Contact__r.ID=:objContact.ID 
                    and StageName = 'Stewardship'];

            Boolean SYBUNTCondition1 = false;
            Boolean SYBUNTCondition2 = false;
            
            for(Opportunity op: objOpp1){
                //SYBUNT
                //At least one opportunity related to the Contact that has Stage = Stewardship and Date <> THIS YEAR
                if(op.CloseDate.Year()!=system.today().Year() && SYBUNTCondition1 == false) {
                    SYBUNTCondition1 = true;
                }
                //There is no opportunity related to the Contact that has Stage = Stewardship and Date = THIS YEAR
                if(op.CloseDate.Year()==system.today().Year()) {
                    SYBUNTCondition2 = True;
                }
            }
            if(SYBUNTCondition1==true && SYBUNTCondition2==false){
                blnS=true;
            }           
                                        
            /*if (objOpp1.size() == 0) {
                blnS = True;
            }*/
        //}
        
        return blnS;
        
    }
    private boolean LYBUNT() {
        boolean blnL = False;
        /*List<Opportunity> objOpp = [Select Amount ,CloseDate from Opportunity 
                where Primary_Contact__r.ID=:objContact.ID 
                and StageName = 'Stewardship' and CLOSEDATE = Last_YEAR];
        
        string LargestGift='';
        if (objOpp.size() > 0) {
        */
            /*List<Opportunity> objOpp1 = [Select Amount ,CloseDate from Opportunity 
                    where Primary_Contact__r.ID=:objContact.ID 
                    and StageName = 'Stewardship' and CLOSEDATE= THIS_YEAR];
            */
            List<Opportunity> objOpp1 = [Select Amount ,CloseDate from Opportunity 
                    where Primary_Contact__r.ID=:objContact.ID 
                    and StageName = 'Stewardship'];                    

            Boolean LYBUNTCondition1 = false;
            Boolean LYBUNTCondition2 = false;
            
            for(Opportunity op: objOpp1){
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
            if(LYBUNTCondition1==true && LYBUNTCondition2==false){
                blnL=true;
            }           
            
            /*if (objOpp1.size() == 0) {
                blnL = True;
            }*/
        //}
        
        return blnL;
    }
    
 public string getLastGift() {
        /*List<Opportunity> objOpp = [Select Amount,CloseDate from Opportunity 
                where Primary_Contact__r.ID=:objContact.ID 
                and StageName = 'Stewardship'
                order by CloseDate,CreatedDate desc limit 1];
        */
                
        List<Opportunity> objOpp = [Select Amount,CloseDate from Opportunity 
                where Primary_Contact__r.ID=:objContact.ID 
                and StageName = 'Stewardship'
                order by CloseDate Desc limit 1];                
        
        string LastGift = '';
        if (objOpp.size()>0) {
            string dtDate = string.valueof(objOpp[0].CloseDate);
            string FinalDate = dtDate.substring(5,7) + '/' + dtDate.substring(8,10) + '/' + dtDate.substring(0,4);
            LastGift = '$' + objOpp[0].Amount + ' and ' + FinalDate;
        }
        return LastGift;
    }
//////////////////
/* Test Methods */
//////////////////
static testMethod void testGetLifeTimeGift() {
        AggregateResult[] objOpp = [Select SUM(Amount) LifeTimeGift from Opportunity 
            where Primary_Contact__r.ID='0038000000lpit4' 
            and StageName = 'Stewardship'
            group by StageName];
        
        string LifeTimeGift='';
        if (objOpp.size() > 0) {
            LifeTimeGift = '$' + decimal.valueof(string.valueof(objOpp[0].get('LifeTimeGift'))).setScale(2);
        }
        System.assertNotEquals(LifeTimeGift, Null);
    }
    
    static testMethod void testGetLargestGift() {
        List<Opportunity> objOpp = [Select Amount ,CloseDate from Opportunity 
        where Primary_Contact__r.ID='0038000000lpit4'
        and StageName = 'Stewardship'
        order by Amount desc limit 1];
        
        string LargestGift='';
        if (objOpp.size() > 0) {
            string dtDate = string.valueof(objOpp[0].CloseDate);
            string FinalDate = dtDate.substring(5,7) + '/' + dtDate.substring(8,10) + '/' + dtDate.substring(0,4);
            LargestGift = '$' + objOpp[0].Amount + ' (' + FinalDate + ')';
        }
        System.assertNotEquals(LargestGift, Null);
     }
    
//End of Class
}