public class ctrlDynamicField {
    public String strDefaultValue { get;set; }
    public String strField {get;set;}
    public Map<String, Schema.SObjectField> FieldMap;
    public String[] lstPick {get;set;}
    public String strCamp {get;set;}
    //public List<Campaign_Form_Item_Picklist__c> lstCFFs = new List<Campaign_Form_Item_Picklist__c>();
    
    public ctrlDynamicField(){       
    }
    
    public List<SelectOption> getSelectOpts(){
        List<SelectOption> options = new List<SelectOption>(); 
        List<Campaign_Form_Item_Picklist__c> lstCFFs = [Select Id, Name, Campaign_Form_Item__r.Name 
            from Campaign_Form_Item_Picklist__c where Campaign_Form_Item__r.Campaign__c =: strCamp];
        if (lstCFFs.size() > 0){
            for (Campaign_Form_Item_Picklist__c p : lstCFFs){
                if (p.Campaign_Form_Item__r.Name == strField){
                    options.add(new SelectOption(p.Name, p.Name));
                }
            }
        } else {
            //Backup to support forms built before picklist add field changes made 
            //(This method limits forms to 10 picklists or less)
            FieldMap = Schema.SObjectType.Lead.fields.getMap();
            SObjectField f;
            Schema.DescribeFieldResult d;
            
            f = FieldMap.get(strField);
            if (f != null){
                d = f.getDescribe();
                List<Schema.PicklistEntry> ple = d.getPicklistValues();
            
               for( Schema.PicklistEntry p : ple)
               {
                  options.add(new SelectOption(p.getLabel(), p.getValue()));
               }  
            }
            
        }
             
        return options; 
    }
    
    static testMethod void testMethods() {
        ctrlDynamicField ctrl = new ctrlDynamicField();
        ctrl.strField = 'Industry';
        ctrl.getSelectOpts();
    }
}