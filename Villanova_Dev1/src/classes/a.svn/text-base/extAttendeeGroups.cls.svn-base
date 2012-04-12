public with sharing class extAttendeeGroups {
    public Campaign camp {get;set;}
    public List<Campaign> lstGroups {get;set;}
    public String strField1 {get;set;}
    public List<Criterion> lstCrit {get;set;} 
    public Campaign grp {get;set;}
    public Decimal decLastOrder = 0;
    //public Map<String, Schema.SObjectField> ContactFieldMap;
    public Map<String, Schema.SObjectField> LeadFieldMap;
    public Boolean isFullScreen {get;set;}
    public List<Contact> lstContacts {get;set;}
    public id idAttGrpRT;
    public Integer intMaxOrder {get;set;}
    public List<Match> lstMatches {get;set;}
    public Boolean SelectAll {get;set;}
    public String strAddOption {get;set;}
    public String strStat {get;set;}
    public String strErr {get;set;}
    public static Boolean InitialGroupSave = false;
    
    public extAttendeeGroups(ApexPages.StandardController ctrl) {
        this.camp = (Campaign)ctrl.getRecord();
        InitGroups();
        SelectAll = false;
        
        
        String strFull = Apexpages.currentpage().getParameters().get('full');
        
        isFullScreen = (strFull == 'true' ? true : false);
        idAttGrpRT = [Select Id from RecordType where SobjectType ='Campaign' and DeveloperName = 'Event_Attendee_Group'][0].Id;
        
        if (isFullScreen){
            //Get all of the Lead fields and types
            LeadFieldMap = Schema.SObjectType.Lead.fields.getMap();

            InitAttGroup();
        }
        
        if (camp.Id != null){
            camp = [Select Id, Name, Date__c from Campaign where Id =: camp.Id];
        }
    }
    
    public PageReference NewGroup(){
        InitAttGroup();
        
        return null;
    }
    
    public void InitGroups(){
        lstGroups = [Select Id, Name, Short_Name__c, Registration_Limit__c, Order__c, Wait_List_Limit__c, Current_Registration__c, Current_Wait_List__c
            from Campaign where Event__c =: camp.Id and RecordType.DeveloperName = 'Event_Attendee_Group' order by Order__c
        ];
        intMaxOrder = 0;
        for (Campaign c : lstGroups){
            if (c.Order__c != null){
                intMaxorder = c.Order__c.intValue();
            }
        }
    }
    
    public PageReference DelGroup(){
        ApexPages.Message mssErr;
        if (System.currentPageReference().getParameters().get('del_group') != null){
            List<Campaign> lstDel = [Select Id from Campaign where Id =: System.currentPageReference().getParameters().get('del_group')]   ;
            try{
            	delete lstDel;
            } catch (Exception e){
            	mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            }
        }
        InitGroups();
        Apexpages.currentpage().getParameters().put('del_group','');
        return null; 
    }
    
    public PageReference FullScreen(){
        PageReference pr = new PageReference('/apex/AttendeeGroups');
        pr.setRedirect(true);
        pr.getParameters().clear();
        pr.getParameters().put('full', 'true');
        pr.getParameters().put('id', camp.Id);
        //pr.getParameters().put('group', Apexpages.currentpage().getParameters().get('group'));
        System.debug('In FullScreen now');
        return pr;
    }
    
    public void InitAttGroup(){
        lstCrit = new List<Criterion>();
        List<Group_Criterion__c> lstGroup;
        lstMatches = new List<Match>();
        strAddOption = 'None';
        
        String strGroup = Apexpages.currentpage().getParameters().get('group'); 
        System.debug('I am in InitAttGroup now!' +Apexpages.currentpage().getParameters().get('group') +' (strGroup == null || strGroup == )' +(strGroup == null || strGroup == ''));
        
        
        if (strGroup == null || strGroup == ''){
            grp = new Campaign();
            
            lstGroup = new List<Group_Criterion__c>();
        } else {
            grp = [Select Id, Name, Short_Name__c, Registration_Limit__c, Order__c, Wait_List_Limit__c, Boolean__c, Where_Clause__c,
                Current_Registration__c, Current_Wait_List__c
                from Campaign where Id =: strGroup
            ];
            lstGroup = [Select Id, Name, Order__c, Operator__c, Value__c, Field_Type__c
                from Group_Criterion__c where Attendee_Group__c =: grp.Id order by Order__c
            ];
        }
        
        
        
        for (Group_Criterion__c gc : lstGroup){
            lstCrit.add(new Criterion(gc.Name, gc.Operator__c, gc.Value__c, gc.Order__c, gc.Field_Type__c));
            decLastOrder = gc.Order__c;
        }
        
        if (lstGroup.size() == 0){
            decLastOrder = 0;
        }
        
        while (lstCrit.size() < 5){
            NewCriterion();
        }
        Apexpages.currentpage().getParameters().put('group','');
        System.debug('End of InitAttGroup and grp.Id = ' +grp.Id);
    }
    
    public PageReference NewCriterion(){
        decLastOrder ++;
        lstCrit.add(new Criterion('','','',decLastOrder,''));
        
        return null;
    }//end NewCriterion
    
    public List<SelectOption> getStatuses() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('','---None----'));
        options.add(new SelectOption('New (not invited yet)','New (not invited yet)'));
        options.add(new SelectOption('Registered','Registered'));
        options.add(new SelectOption('Attended','Attended'));
        options.add(new SelectOption('Wait List','Wait List'));
        
        return options;
    }
    
    public PageReference SaveGroup(){
        lstMatches = new List<Match>();
        System.debug('SaveGroup starts here');
        transient Savepoint sp = Database.setSavepoint();
        ApexPages.Message mssErr;
        System.debug('In SaveGroup and grp.Id = ' +grp.Id);
        Boolean isNew = (grp.Id == null ? true : false);
        grp.Event__c = camp.Id;
        grp.IsActive = true;
        grp.RecordTypeId = idAttGrpRT;
        if (isNew){
            intMaxOrder = intMaxOrder + 1;
            grp.Order__c = intMaxOrder;
        }
        
        //Can't save this until criterion records are inserted, so remove it for now...
        String strTemp = grp.Boolean__c;
        grp.Boolean__c = null;
        InitialGroupSave = true;
        
        try{
            upsert grp;
        } catch (Exception e) {
            mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
        }
        
        //If no errors have been hit
        if (mssErr == null){
            System.debug('No errors inserting Group campaign, creating criterion records...');
            List<Group_Criterion__c> lstGC;
            
            //Easier just to delete everything and start over
            if (grp.Id != null){
                lstGC = [Select Id from Group_Criterion__c where Attendee_Group__c =: grp.Id];
                delete lstGC;
            }
            lstGC = new List<Group_Criterion__c>();
            
            for (Criterion c : lstCrit){
                //Map<String, Schema.SObjectField> ContactFieldMap = Schema.SObjectType.Contact.fields.getMap();
                SObjectField fc;
                Schema.DescribeFieldResult dc;

                if (c.Field != null &&c.Field != ''){
                    fc = LeadFieldMap.get(c.Field);
                    dc = fc.getDescribe();
                    lstGC.add(new Group_Criterion__c(
                        Name = c.Field,
                        Operator__c = c.Operator,
                        Value__c = c.Value,
                        Order__c = c.Order,
                        Attendee_Group__c = grp.Id,
                        Field_Type__c = (''+dc.getType()).replace('Schema.DisplayType.','')
                    ));
                }
            }
            
            try{
                insert lstGC;
            } catch (Exception e) {
                mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            }
            
        }
        grp.Boolean__c = strTemp;
        InitialGroupSave = false;
        if (mssErr == null){
            try{
                upsert grp;
            } catch (Exception e) {
                mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            }
        }
        
        if (mssErr != null){
            Database.rollback(sp);
            intMaxOrder = intMaxOrder - 1;
            if (isNew){
                grp = grp.clone(false);
            }
            ApexPages.addMessage(mssErr);
        } else {
            mssErr = new ApexPages.Message(ApexPages.severity.INFO,'Save successful');
            ApexPages.addMessage(mssErr);
            intMaxOrder++;
            InitGroups();
            
            if (strAddOption != 'None'){
                grp = [Select Id, Name, RecordType.DeveloperName, Short_Name__c, Registration_Limit__c, Order__c, Wait_List_Limit__c, Boolean__c, Where_Clause__c
                    from Campaign where Id =: grp.Id][0];
                //Need to get everyone already added to the Event so they're not added again.
                List<CampaignMember> lstCMs = [Select Id, ContactId from CampaignMember where CampaignId =: camp.Id];
                lstMatches = new List<Match>();
                SelectAll = false;
                
                Set<Id> setMembers = new Set<Id>();
                for (CampaignMember cm : lstCMs){
                    setMembers.add(cm.ContactId);
                }
                
                String strSoQL = 'Select Id, FirstName, LastName, Phone, Email from Contact ';
                if (grp.Where_Clause__c != null &&grp.RecordType.DeveloperName == 'Event_Attendee_Group'){
                    strSoQL += 'where ' +grp.Where_Clause__c;
                }
                System.debug('strSoQl = ' +strSoQL);
                List<Contact> lstContacts = Database.query(strSoQL +' Order by LastName, FirstName');
                        
                for (Contact c : lstContacts){
                    if (!setMembers.contains(c.Id)){
                        lstMatches.add(new Match((strAddOption == 'All' ? true : false),c));
                    }
                }
                
                if (strAddOption == 'All'){
                    AddToEvent();
                }
            }
        }
        return null;
    }
    
    public PageReference SelectAllMatches(){
        
        for (Match m : lstMatches){
            m.isSelected = SelectAll;
        }
        return null;
    }
    
    public PageReference AddToEvent(){
        List<CampaignMember> lstCM = new List<CampaignMember>();
        List<CampaignMember> lstGroup = new List<CampaignMember>();
        ApexPages.Message mssErr;
        System.debug('In AddToEvent and strStat = ' +strStat);
        if (strStat != null){
            for (Match m : lstMatches){
                if (m.isSelected){
                    CampaignMember cm = new CampaignMember();
                    cm.ContactId = m.con.Id;
                    cm.CampaignId = camp.Id;
                    cm.Attendee_Group__c = grp.Id;
                    cm.Status = strStat; //'New (not invited yet)';
                    lstCM.add(cm.clone());
                    
                    cm = new CampaignMember();
                    cm.ContactId = m.con.Id;
                    cm.CampaignId = grp.Id;
                    cm.Status = strStat;
                    lstGroup.add(cm.clone());
                }
            }
            
            if (lstGroup.size() > 0){
                try{
                    insert lstGroup;
                } catch (Exception e) {
                    mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                }
                
            }
            
            if (mssErr == null){
                for (CampaignMember cm : lstCM){
                    for (CampaignMember gm : lstGroup){
                        if (cm.ContactId == gm.ContactId){
                            cm.Group_Membership__c = gm.Id;
                        }
                    }
                    
                    //Remove people that were just added from lstMatches
                    List<Match> lstMatchesTemp = lstMatches.clone();
                    Integer i = 0;
                    for (Match m : lstMatchesTemp){
                        if (cm.ContactId == m.con.Id){
                            lstMatches.remove(i);
                        }
                        i++;
                    }
                }
                
                if (lstCM.size() > 0){
                    try{
                        insert lstCM;
                    } catch (Exception e) {
                        mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                    }
                    
                    if (mssErr == null){
                        mssErr = new ApexPages.Message(ApexPages.severity.INFO,lstCM.size() +' Contacts successfully added to the Event.');
                    }
                    
                }
            }
        } else {
            mssErr = new ApexPages.Message(ApexPages.severity.INFO,'Please select a Status for the new Attendees.');
        }
        if (mssErr == null){
            mssErr = new ApexPages.Message(ApexPages.severity.INFO,lstCM.size() +' Contacts added to the Event.');
        }
        ApexPages.addMessage(mssErr);
        return null;
    }
    
    public List<SelectOption> getFields() {
        List<SelectOption> options = new List<SelectOption>(); 
        Map<String, String> mapFields = clsFields.CommonLeadContactFields(UserInfo.getUserType());
        SObjectField f;
        Schema.DescribeFieldResult d;
        String strType;
        
        //First let's sort the field names
        List<String> lstFields = new List<String>();
        for (String field : mapFields.keySet()){
            f = LeadFieldMap.get(field);
            d = f.getDescribe();
            strType = (''+d.getType()).replace('Schema.DisplayType.','');
            //Skipping date fields unless requested
            if (strType <> 'Date' &&strType <> 'Datetime'){
                lstFields.add(field);
            }
        }
        lstFields.sort();
        
        options.add(new SelectOption('','--- None ---'));
        for (String field : lstFields){
            options.add(new SelectOption(field, mapFields.get(field)));
        }
        
        return options; 
    }
    
    public List<SelectOption> getOperators() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('','--- None ---'));
        options.add(new SelectOption('Equals','Equals'));
        options.add(new SelectOption('Does Not Equal','Does Not Equal'));
        options.add(new SelectOption('Contains','Contains'));
        options.add(new SelectOption('Includes','Includes'));
        options.add(new SelectOption('Excludes','Excludes'));
        options.add(new SelectOption('Greater Than or Equal To','Greater Than or Equal To'));    
        options.add(new SelectOption('Greater Than','Greater Than'));
        options.add(new SelectOption('Less Than or Equal To','Less Than or Equal To'));
        options.add(new SelectOption('Less Than','Less Than'));
        
        return options; 
    }
    
    public List<SelectOption> getAddOptions() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('None','Don\'t add any matching Contacts to Event'));
        options.add(new SelectOption('All','Add all matching Contacts to Event'));
        options.add(new SelectOption('Some','Select which matching Contacts to add to Event'));
        
        return options; 
    }
    
    public PageReference MoveUp(){
        String strGroup;
        Integer intDown;
        
        if (System.currentPageReference().getParameters().get('up_group') != null){
            strGroup = System.currentPageReference().getParameters().get('up_group');
            for (Campaign c : lstGroups){
                System.debug('First loop, group = ' +c.Name +' Order = ' +c.Order__c);
                if (c.Id == strGroup &&c.Order__c.intValue() != 1){
                    
                    c.Order__c = c.Order__c -1;
                    intDown = c.Order__c.intValue();
                }
                System.debug('First loop end, group = ' +c.Name +' Order = ' +c.Order__c);
            }
            
            //Move up the field that was at that position
            for (Campaign c : lstGroups){
                System.debug('Second loop, group = ' +c.Name +' Order = ' +c.Order__c);
                if (c.Id != strGroup &&c.Order__c.intValue() == intDown){
                    c.Order__c = c.Order__c.intValue() +1;
                }
                System.debug('Second loop end, group = ' +c.Name +' Order = ' +c.Order__c);
            }
            
            update lstGroups;
            InitGroups();
        }
        
        return null;
    }
    
    public PageReference MoveDown(){
        String strGroup;
        Integer intUp;
        
        if (System.currentPageReference().getParameters().get('down_group') != null){
            strGroup = System.currentPageReference().getParameters().get('down_group');
            for (Campaign c : lstGroups){
                System.debug('First loop, group = ' +c.Name +' Order = ' +c.Order__c);
                if (c.Id == strGroup &&c.Order__c.intValue() != intMaxOrder){
                    
                    c.Order__c = c.Order__c.intValue() +1;
                    intUp = c.Order__c.intValue();
                }
                System.debug('First loop end, group = ' +c.Name +' Order = ' +c.Order__c);
            }
            
            //Move down the field that was at that position
            for (Campaign c : lstGroups){
                System.debug('Second loop, group = ' +c.Name +' Order = ' +c.Order__c);
                if (c.Id != strGroup &&c.Order__c.intValue() == intUp){
                    c.Order__c = c.Order__c.intValue() - 1;
                }
                System.debug('Second loop end, field = ' +c.Name +' Order = ' +c.Order__c);
            }
            
            update lstGroups;
            InitGroups();
        }
        
        return null;
    }
    
    public class Criterion{
        public String Field {get; set;}
        public String FieldType {get; set;}
        public String Operator {get; set;}
        public String Value {get; set;}
        public Decimal Order {get; set;}
        
        //This is the contructor method
        public Criterion(String f, String o, String v, Decimal ord, String t){
            
            Field = f;
            Operator = o;
            Value = v;
            Order = ord;
            FieldType = t;
        }
        
    }//end Criteria
    
    public class Match{
        public Boolean isSelected {get; set;}
        public Contact con {get; set;}
        
        
        //This is the contructor method
        public Match(Boolean isSel, Contact c){
            isSelected = isSel;
            con = c;

        }
	}//end match
	
	static testMethod void testPageMethods() {
        Id idRT = [Select Id from RecordType where SObjectType = 'Campaign' and DeveloperName = 'Event'][0].Id;
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true,
            RecordTypeId = idRT, 
            Date__c = System.today()
        );
        
        insert c;
        Id idIndiv = [Select Id from Account Limit 1][0].id;
        Contact con1 = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = idIndiv
        );
        insert con1;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('full','true');
        extAttendeeGroups ext = new extAttendeeGroups(stdCon);
        
        ext.getFields();
        ext.getOperators();
        ext.getAddOptions();
        ext.getStatuses();
        
        ext.grp.Name = 'Test';
        ext.grp.Short_Name__c = 'Test';
        ext.lstCrit[0].Field = 'firstname';
		ext.lstCrit[0].FieldType = 'text'; 
		ext.lstCrit[0].Operator = 'Equals';       
        ext.lstCrit[0].Value = 'Test';
        ext.lstCrit[1].Field = 'lastname';
		ext.lstCrit[1].FieldType = 'text'; 
		ext.lstCrit[1].Operator = 'Equals';       
        ext.lstCrit[1].Value = 'Person';
        ext.lstCrit[2].Field = 'birth_date__c';
		ext.lstCrit[2].FieldType = 'text'; 
		ext.lstCrit[2].Operator = 'Equals';       
        ext.lstCrit[2].Value = '3/15/1976';
        ext.grp.Boolean__c = '(1 AND 2) OR 3';
        ext.strAddOption = 'All';
        ext.SaveGroup();
        
        ext.SelectAllMatches();
        ext.AddToEvent();
        
        System.currentPagereference().getParameters().put('up_group','' +c.Id);
        ext.MoveUp();
        System.currentPagereference().getParameters().put('down_group','' +c.Id);
        ext.MoveDown();
        
        
        ext.FullScreen();
        ext.NewGroup();
        ext.grp.Short_Name__c = 'Test2';
        ext.grp.Registration_Limit__c = 10;
        ext.grp.Wait_List_Limit__c = 10;
        ext.SaveGroup();
        System.currentPagereference().getParameters().put('del_group','' +c.Id);
        ext.DelGroup();
	}
}