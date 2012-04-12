public with sharing class clsFields1 {
 
   //Returns a set of the updateable fields (skipping reference fields) in the Lead and Contact objects
  //Map returned contains field name and label from Contact
  public static Map<String, String> CommonLeadContactFields(String strUserType){
    Map<String, String> mapMatches = new Map<String, String>();
    
    //Get all of the Lead fields and types
        Map<String, Schema.SObjectField> LeadFieldMap = Schema.SObjectType.Lead.fields.getMap();
        Set<String> setLeadFields = LeadFieldMap.keySet();
        SObjectField fl;
        Schema.DescribeFieldResult dl;

    //Get all of the Contact fields and types
        Map<String, Schema.SObjectField> ContactFieldMap = Schema.SObjectType.Contact.fields.getMap();
        Set<String> setContactFields = ContactFieldMap.keySet();
        SObjectField fc;
        Schema.DescribeFieldResult dc;
        
        Integer LeadField = 0;
    
        for (String lfname : setLeadFields) {

            fl = LeadFieldMap.get(lfname);
            dl = fl.getDescribe();
            System.debug('Looking at ' +lfname +'d.isUpdateable() ' +dl.isUpdateable() +' ' +strUserType);
            //Only want fields that can be updated, skipping reference fields
            if (((dl.isUpdateable() &&strUserType != 'Guest') || strUserType == 'Guest')
                &&(''+dl.getType()).replace('Schema.DisplayType.','') != 'Reference'
            ){
                for (String cfname : setContactFields) {
                  fc = ContactFieldMap.get(cfname);
                  dc = fc.getDescribe();
                if ((cfname == lfname || (cfname == 'user_specified_company__c' && lfname == 'company')
                  || lfname == 'street' || lfname == 'city' || lfname == 'postalcode'
                    || lfname == 'state' || lfname == 'country' || lfname == 'rating')
                  &&((dc.isUpdateable() &&strUserType != 'Guest') || strUserType == 'Guest')
                    &&(''+dc.getType()).replace('Schema.DisplayType.','') == (''+dl.getType()).replace('Schema.DisplayType.','')
                ){
                  mapMatches.put(lfname, dl.getLabel());
                }
                }
            }
                
        }//end setFields loop
        
        system.debug('############' + mapMatches.size() + '--------------' + mapMatches);
        return mapMatches;
  }//end GetLeadFields
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////
  public static Map<String, String> CommonLeadContactFieldsNew(String strUserType){
    Map<String, String> mapMatches = new Map<String, String>();
    
    //Get all of the Lead fields and types
        Map<String, Schema.SObjectField> LeadFieldMap = Schema.SObjectType.Lead.fields.getMap();
        Set<String> setLeadFields = LeadFieldMap.keySet();
        SObjectField fl;
        Schema.DescribeFieldResult dl;

    //Get all of the Contact fields and types
        Map<String, Schema.SObjectField> ContactFieldMap = Schema.SObjectType.Contact.fields.getMap();
        Set<String> setContactFields = ContactFieldMap.keySet();
        SObjectField fc;
        Schema.DescribeFieldResult dc;
        
        Set<String> setLeadFields1 = new Set<String>();
        Set<String> setContactFields1 = new Set<String>();
        
        Map<String,String> MapLeadFieldType = new Map<String,String>();

        for (String lfname : setLeadFields) {
            fl = LeadFieldMap.get(lfname);
            dl = fl.getDescribe();
            String dlType = (''+dl.getType()).replace('Schema.DisplayType.','');
            
            if (((dl.isUpdateable() &&strUserType != 'Guest') || strUserType == 'Guest')
                && dlType != 'Reference'
            ) {
                setLeadFields1.add(lfname);
                MapLeadFieldType.put(lfname,dlType);
            }
            
        }
        
        for (String cfname : setContactFields) {
            String dlType = MapLeadFieldType.get(cfname);
            
            if(dlType!=null && dlType!='') {
                fc = ContactFieldMap.get(cfname);
                dc = fc.getDescribe();
            
                String dcType = (''+dc.getType()).replace('Schema.DisplayType.','');
                if (((dc.isUpdateable() &&strUserType != 'Guest') || strUserType == 'Guest')
                    && dcType == dlType && dcType!='Reference') {
    
                    setContactFields1.add(cfname);
                }
            }
        }
        
        
    
        for (String lfname1 : setLeadFields1) {
            //Only want fields that can be updated, skipping reference fields
            for (String cfname1 : setContactFields1) {
                if ((cfname1 == lfname1 || (cfname1 == 'user_specified_company__c' && lfname1 == 'company')
                    || lfname1 == 'street' || lfname1 == 'city' || lfname1 == 'postalcode'
                    || lfname1 == 'state' || lfname1 == 'country' || lfname1 == 'rating')
            
                ){
                    mapMatches.put(lfname1, dl.getLabel());
                }
            }
                
        }//end setFields loop
        system.debug('############' + mapMatches.size() + '--------------' + mapMatches);
        return mapMatches;
  }//end GetLeadFields  
  
}