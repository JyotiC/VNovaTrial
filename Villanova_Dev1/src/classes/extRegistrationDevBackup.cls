public with sharing class extRegistrationDevBackup {
    public Boolean isEdit {get;set;}
    public Campaign c {get;set;}
    public String strDate {get;set;}
    public List<LeadField> lstFields {get;set;}
    public List<LeadField> lstDisplayFields {get;set;}
    public String strAddField {get;set;}
    public Date dteTest {get;set;}
    public String strTest {get;set;}
    public String strTest2 {get;set;}
    //public Boolean DisplaySpeaker {get;set;}
    public Boolean Confirm {get;set;}
    public Integer intMaxOrder {get;set;}
    public String strKey {get;set;}
    public String strUserType {get;set;}
    public String strName = '';
    public Boolean isProd {get;set;}
    public String strError {get;set;}
    public String strEndTable {get;set;}
    public String strTable {get;set;}
    
    public List<SelectOption> getAvailFields() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        for (LeadField lf : lstFields){
            options.add(new SelectOption(lf.field, lf.label +' (' +lf.datatype +')'));
        }
        
        return options; 
    }
    
    public void InitCampaign(){
        ApexPages.getMessages().clear();
        if (strKey != '' &&strKey != null){
            System.debug('The encrypted key is ' +strKey);
            //for deleted events or bad encrypted key passed in somehow...
            if ([Select count() from Campaign where Encrypted_Key__c =: strKey] == 0){
                c = new Campaign();
                c.Web_Page_Public__c = false;
            } else {
                c = [Select Id, Date__c, Speaker__c, Location__c, Time__c, Web_Description__c, Display_Speaker__c, Name, 
                    Display_Time__c, Display_Location__c, Confirmation_Text__c, Web_Page_Public__c, Encrypted_Key__c,
                    Display_Date__c, Display_Event_Details_Header__c, Do_Not_Use_VU_Web_Wrapper__c
                    from Campaign where Encrypted_Key__c =: strKey];
                //DisplaySpeaker = c.Display_Speaker__c;
                
                if (c.Date__c != null){
                    strDate = c.Date__c.format(); 
                } else {
                    strDate = null;
                }
            }
        }
    }
    
    public extRegistrationDevBackup(ApexPages.StandardController con) {
        //this.c = (Campaign)con.getRecord();
        strKey = Apexpages.currentpage().getParameters().get('event');
        InitCampaign();
        strTable = '<table>';
        strEndTable = '</table>';
                
        //strUserType = UserInfo.getUserType();
        strUserType = 'Guest';
        System.debug('Str user type in the controller  >>>>>>>>>>>>>>>>>>.'+strUserType);
        lstFields = new List<LeadField>();
        lstDisplayFields = new List<LeadField>();
        
        if (Apexpages.currentpage().getParameters().get('confirmed') == 'true'){
            Confirm = true;
        } else {
            Confirm = false;
        }
        
        if (Apexpages.currentpage().getParameters().get('edit') == 'true'){
            isEdit = true;
        } else {
            isEdit = false;
        }
        System.debug('Entered extRegistration');
        
        ApexPages.getMessages().clear();
        
        if (clsConstants.isProduction){
            isProd = true;
        } else {
            isProd = false;
        }
        
    }//end extRegistration

    
    
    public PageReference EditToggle(){
        ApexPages.getMessages().clear();
        System.debug('Pre toggle: ' +isEdit);
        if (isEdit){
            isEdit = false;
        } else {
            isEdit = true;
        }
        System.debug('Post toggle: ' +isEdit);
        return null;
    }//end EditToggle
    
    public PageReference Register(){
        Lead l = new Lead();
        ApexPages.Message m;
        Boolean FoundCompany = false;
        Confirm = false;
        Boolean IsError = false;
        List<Attachment> lstAttach = new List<Attachment>();
        Map<String, Blob> mapBlob = new Map<String, Blob>();
        strError = null;
        PageReference p = Page.EventRegistration;
        p.getParameters().put('event', strKey);
        
        for (LeadField lf : lstDisplayFields){
            Date d;
            Datetime dte;
            if (lf.datatype == 'DATE' &&lf.value != null){
                try {
                    Integer count = 0;
                    List<String> lstD = new List<String>();
                    if (lf.value.contains('/')){
                        for (String s : lf.value.split('/')){
                            lstD.add(s);
                            count++;
                            System.debug('Parsing date, element ' +count +' value ' +s);
                        }
                    }
                    if (count == 3){
                        d = Date.newInstance(Integer.valueOf(lstD[2]),Integer.valueOf(lstD[0]),Integer.valueOf(lstD[1]));
                    } else {
                        m = new ApexPages.Message(
                            ApexPages.severity.ERROR,
                            'Please enter a valid date in ' +lf.label +'.'
                        );
                        ApexPages.addMessage(m); 
                        IsError = true;
                        strError = (strError == null ? 'Please enter a valid date in ' +lf.label +'.':strError+'<br/>Please enter a valid date in ' +lf.label +'.');
                    }
                } catch (Exception e){
                    m = new ApexPages.Message(
                        ApexPages.severity.ERROR,
                        'Please enter a valid date in ' +lf.label +'.'
                    );
                    ApexPages.addMessage(m);
                    strError = (strError == null ? 'Please enter a valid date in ' +lf.label +'.':strError+'<br/>Please enter a valid date in ' +lf.label +'.'); 
                    IsError = true;
                }
                l.put(lf.field, d);
            } else {
                if (lf.datatype == 'DATETIME' &&lf.value != null){
                    try {
                        
                        Integer count = 0;
                        List<String> lstD = new List<String>();
                        if (lf.value.contains('/')){
                            for (String s : lf.value.split('/')){
                                lstD.add(s);
                                count++;
                                System.debug('Parsing date, element ' +count +' value ' +s);
                            }
                        }
                        if (count == 3){
                            dte = Datetime.newInstance(Integer.valueOf(lstD[2]),Integer.valueOf(lstD[0]),Integer.valueOf(lstD[1]));
                        } else {
                            m = new ApexPages.Message(
                                ApexPages.severity.ERROR,
                                'Please enter a valid date in ' +lf.label +'.'
                            );
                            ApexPages.addMessage(m); 
                            strError = (strError == null? 'Please enter a valid date in ' +lf.label +'.':strError+'<br/>Please enter a valid date in ' +lf.label +'.');
                            IsError = true;
                        }
                    } catch (Exception e){
                        m = new ApexPages.Message(
                            ApexPages.severity.ERROR,
                            'Please enter a valid datetime in ' +lf.label +'.'
                            
                        );
                        ApexPages.addMessage(m); 
                        strError = (strError == null? 'Please enter a valid datetime in ' +lf.label +'.':strError+'<br/>Please enter a valid datetime in ' +lf.label +'.');
                        
                        IsError = true;
                    }
                    if (!IsError){
                        System.debug('Putting datetime ' +dte +' into field ' +lf.field);
                        l.put(lf.field, dte);
                    }
                } else {
                    System.debug('Datatype of field is ' +lf.datatype);
                    if (lf.datatype == 'DECIMAL' || lf.datatype == 'CURRENCY'){
                        if (lf.value != null &&lf.value != ''){
                            Decimal dec;
                            try {
                                dec = Decimal.valueOf(lf.value);
                            } catch (Exception e){
                                m = new ApexPages.Message(
                                    ApexPages.severity.ERROR,
                                    'Please enter a valid number in ' +lf.label +'.'
                                    
                                );
                                ApexPages.addMessage(m); 
                                strError = (strError == null? 'Please enter a valid number in ' +lf.label +'.':strError+'<br/>Please enter a valid number in ' +lf.label +'.');
                                IsError = true;
                            }
                            
                            if (!IsError){
                                System.debug('Putting decimal ' +lf.value +' into field ' +lf.field);
                                l.put(lf.field, dec);
                            }
                        }
                    } else {
                        if (lf.datatype == 'Attachment'){
                            if (lf.attach != null){
                                mapBlob.put(lf.value, lf.attach);
                            }
                        } else {
                            if (lf.datatype == 'BOOLEAN'){
                                l.put(lf.field,lf.bool);
                            } else {
                                if (lf.datatype != 'Heading' && lf.datatype != 'Descrip' & lf.datatype != 'Line'){
                                    l.put(lf.field, lf.value);
                                    if (lf.field == 'firstname' || lf.field == 'lastname'){
                                        strName += lf.value;
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            if (lf.field == 'Company' &&lf.value != null){
                FoundCompany = true;
            }
            if ((lf.required &&lf.datatype != 'Attachment' &&lf.datatype != 'BOOLEAN' &&(lf.value == null || lf.value == ''))
                ||(lf.required &&lf.datatype == 'Attachment' &&(lf.attach == null))
            ){
                m = new ApexPages.Message(
                    ApexPages.severity.ERROR,
                    lf.label +' is a required field.'
                );
                ApexPages.addMessage(m); 
                strError = (strError == null? lf.label +' is a required field.':strError+'<br/>' +lf.label +' is a required field.');
                IsError = true;
            }
        }
        System.debug('Is this an error?' +IsError);
        if (!IsError){
            //If company wasn't collected, fill in default value
            if (!FoundCompany){
                l.Company = 'Company not required';
            }
            l.LeadSource = 'Event Registration';
            
            try {
                insert l;
            } catch (Exception e) {
                m = new ApexPages.Message(
                    ApexPages.severity.ERROR,
                    e.getMessage()
                );
                ApexPages.addMessage(m); 
                strError = (strError == null? e.getMessage():strError+'<br/>' +e.getMessage());
                IsError = true;
            }
            if (!IsError){
                CampaignMember cm = new CampaignMember(
                    LeadId = l.Id,
                    CampaignId = c.Id,
                    Status = 'Will Attend'
                );
                try {
                    insert cm;
                } catch (Exception e) {
                    m = new ApexPages.Message(
                        ApexPages.severity.ERROR,
                        e.getMessage()
                    );
                    ApexPages.addMessage(m);
                    strError = (strError == null? e.getMessage():strError+'<br/>' +e.getMessage());
                    IsError = true; 
                }
                
                if (!isError &&mapBlob.size() >0){
                    for (String att : mapBlob.keySet()){
                        lstAttach.add(new Attachment(
                            ParentId = l.Id, 
                            Name = att, 
                            //ContentType = mapBlob.get(att)., 
                            Body = mapBlob.get(att)
                        ));
                    }
                    try {
                        insert lstAttach;
                    } catch (Exception e) {
                        m = new ApexPages.Message(
                            ApexPages.severity.ERROR,
                            e.getMessage()
                        );
                        ApexPages.addMessage(m);
                        strError = (strError == null? e.getMessage():strError+'<br/>' +e.getMessage());
                        IsError = true; 
                    }
                }
                
                if (!IsError){
                    Confirm = true;
                    p.getParameters().put('confirmed', 'true');
                } 
            }
        }
        if (IsError){
            
            strName = '' +System.now().formatLong();
            p.getParameters().put('temp', strName);
            //Store the values so they can be placed back on the form when the page is reloaded 
            //(since you can't rerender with an inputfile)
            for (LeadField lf : lstDisplayFields){
                Date d;
                Datetime dte;
                Temp_Lead_Data__c tld;
                
                if (lf.value != null || lf.attach != null){
                    tld = new Temp_Lead_Data__c(
                        Name = strName,
                        Campaign__c = c.id,
                        Field__c = lf.field,
                        Value__c = lf.value
                    );
                    if (lf.datatype == 'Boolean'){
                        if (lf.bool){
                            tld.Value__c = 'true';
                        }
                    }
                    insert tld;
                    if (lf.attach != null){
                        insert new Attachment(ParentId = tld.Id, Name = lf.value, Body = lf.attach);
                    }
                }
                
            }
            
            
        }//end if there's an error
        System.debug('At the end of register, strError = ' +strError +' and confirm = ' +Confirm);
        
        return p;
    }
    public PageReference SaveC(){
        //if something goes wrong below, this allows us to roll back
        transient Savepoint sp = Database.setSavepoint();
        ApexPages.Message m;
        List<Attachment> lstAtt = new List<Attachment>();
        
        List<Campaign_Form_Item__c> lstCFFs = new List<Campaign_Form_Item__c>();
        strError = null;
        
        try{
            upsert c;
        } catch (Exception e) {
            m = new ApexPages.Message(
                    ApexPages.severity.ERROR,
                    e.getMessage()
                );
                ApexPages.addMessage(m);
                strError = (strError == null? e.getMessage():strError+'<br/>' +e.getMessage());
        }

        if (m == null){
            //Get existing display fields
            lstCFFs = [Select Id, Name, Order__c, Required__c, Text__c from Campaign_Form_Item__c where Campaign__c =: c.Id];
            
            try{
                delete lstCFFs;
            } catch (Exception e) {
                m = new ApexPages.Message(
                    ApexPages.severity.ERROR,
                    e.getMessage()
                );
                ApexPages.addMessage(m);
                strError = (strError == null? e.getMessage():strError+'<br/>' +e.getMessage());
            }
        }
        
        if (m == null){
            lstCFFs.clear();
            Integer i = 1;
            for (LeadField lf : lstDisplayFields){
                System.debug('Adding display field with type ' +lf.datatype +' and name ' +lf.label);
                
                if (lf.datatype == 'ATTACHMENT' || lf.datatype == 'Line' || lf.datatype == 'Heading' || lf.datatype == 'Descrip'){
                    lf.field = lf.label +lf.order;
                    
                }
                lstCFFs.add(new Campaign_Form_Item__c(Campaign__c = c.Id, Name = lf.field, Order__c = i, Required__c = lf.required, Label__c = lf.label, Type__c = lf.datatype, Text__c = lf.textval));
                i++;
            }
            
            try{
                insert lstCFFs;
            } catch (Exception e) {
                m = new ApexPages.Message(
                    ApexPages.severity.ERROR,
                    e.getMessage()
                    
                );
                ApexPages.addMessage(m);
                strError = (strError == null? e.getMessage():strError+'<br/>' +e.getMessage());
            }
        }
        
        if (m != null){
            Database.rollback(sp);

        } else {
            InitCampaign();
            AllLeadFields();
            isEdit = false;
            /*The whole page is rerendering, even though no one told it to, so skip for now...
            m = new ApexPages.Message(
                    ApexPages.severity.INFO,
                     'Changes saved.'
                );
                ApexPages.addMessage(m); 
            System.debug('Successful change, there should be a message.');
            */
        }
        return null;
    }//end SaveC
    
    public PageReference AllLeadFields(){
        lstFields = new List<LeadField>();
        Map<String, Campaign_Form_Item__c> mapDFields = new Map<String, Campaign_Form_Item__c>();
        List<Campaign_Form_Item__c> lstCFFs = new List<Campaign_Form_Item__c>();
        lstDisplayFields.clear();
        lstFields.clear();
        List<Temp_Lead_Data__c> lstTemp = new List<Temp_Lead_Data__c>();
        List<Attachment> lstAtts = new List<Attachment>();
        ApexPages.Message m;
                    
        //To clear out warning messages about the HTML format
        ApexPages.getMessages().clear();
        if (c != null &&c.Id != null){
            //Get existing display fields
            lstCFFs = [Select Id, Name, Order__c, Required__c, Type__c, Label__c, Text__c from Campaign_Form_Item__c where Campaign__c =: c.Id order by Order__c];
            //Always include First and Last Name fields
            if (lstCFFs.size() == 0){
                lstCFFs.add(new Campaign_Form_Item__c(Campaign__c = c.Id, Name = 'firstname', Order__c = 1, Required__c = true));
                lstCFFs.add(new Campaign_Form_Item__c(Campaign__c = c.Id, Name = 'lastname', Order__c = 2, Required__c = true));
                insert lstCFFs;
            }
            
            if (Apexpages.currentpage().getParameters().get('temp') != null){
                lstTemp = [Select Id, Field__c, Value__c from Temp_Lead_Data__c
                    where Name =: Apexpages.currentpage().getParameters().get('temp')
                    and Campaign__c =: c.Id];
                Set<Id> setIds = new Set<Id>();
                for (Temp_Lead_Data__c tld : lstTemp){
                    setIds.add(tld.Id);
                }
                lstAtts = [Select Id, Body, Name, ParentId from Attachment where Id IN: setIds];
            }
            
            //Get all of the Lead fields and types
            Map<String, Schema.SObjectField> FieldMap = Schema.SObjectType.Lead.fields.getMap();
            Set<String> setFields = FieldMap.keySet();
            Map<String, Schema.DisplayType> LeadFieldMap = new Map<String, Schema.DisplayType>();
            SObjectField f;
            Schema.DescribeFieldResult d;
            for (Campaign_Form_Item__c cff : lstCFFs){
                mapDFields.put(cff.Name, cff); 
            }
            System.debug('I got ' +setFields.size() +' Lead fields');
            for (String fname : setFields) {

                //FOR LEAD FIELDS
                f = FieldMap.get(fname);
                d = f.getDescribe();
                System.debug('Allfields looking at ' +fname +'d.isUpdateable() ' +d.isUpdateable() +' ' +strUserType);
                //Only want fields that can be updated, skipping reference fields
                if (((d.isUpdateable() &&strUserType != 'Guest') || strUserType == 'Guest')
                    &&(''+d.getType()).replace('Schema.DisplayType.','') != 'Reference'
                ){
                    System.debug('Adding lead field = ' +fname);
                    if (mapDFields.get(fname) != null){
                        lstDisplayFields.add(new LeadField(fname,d.getLabel(),(''+d.getType()).replace('Schema.DisplayType.',''),
                                mapDFields.get(fname).Order__c.intvalue(), true, mapDFields.get(fname).Required__c,null, false,null));
                        System.debug('Adding field ' +mapDFields.get(fname) +', Required = ' +mapDFields.get(fname).Required__c);
                        
                    } else {
                        lstFields.add(new LeadField(fname,d.getLabel(),(''+d.getType()).replace('Schema.DisplayType.',''),
                                null,  false, false,null, false,null));
                    }
                    mapDFields.remove(fname);
                }
                
            }//end setFields loop
            
            //Add in attachment items
            for (Campaign_Form_Item__c cff : lstCFFs){
                if (cff.Type__c == 'ATTACHMENT' || cff.Type__c == 'Line' || cff.Type__c == 'Heading' || cff.Type__c == 'Descrip'){
                    lstDisplayFields.add(new LeadField(mapDFields.get(cff.Name).Name,mapDFields.get(cff.Name).Label__c, mapDFields.get(cff.Name).Type__c,
                            mapDFields.get(cff.Name).Order__c.intvalue(), true, mapDFields.get(cff.Name).Required__c,null,false,mapDFields.get(cff.Name).Text__c));
                    System.debug('Adding element ' +mapDFields.get(cff.Name) +', Required = ' +mapDFields.get(cff.Name).Required__c);
                    mapDFields.remove(cff.Name);
                }
            }
            
            //Add an attachment item to the fields
            lstFields.add(new LeadField('File Attachment','File Attachment','ATTACHMENT', null,  false, false,null,false,null));
            lstFields.add(new LeadField('Heading Text','Heading Text','Heading', null,  false, false,null,false,null));
            lstFields.add(new LeadField('Line','Line','Line', null,  false, false,null,false,null));
            lstFields.add(new LeadField('Descriptive text','Descriptive text','Descrip', null,  false, false,null,false,null));
            
            //If there is temp data from a previous registration attempt, populate that
            String strErr;
            for (Temp_Lead_Data__c tld : lstTemp){
                for (LeadField lf : lstDisplayFields){
                    if (tld.Field__c == lf.field){
                        lf.value = tld.Value__c;    
                        if (tld.Value__c == 'true'){
                            lf.bool = true;
                        } else {
                            lf.bool = false;
                        }
                    }
                    
                    
                    for (Attachment a : lstAtts){
                        if (a.ParentId == tld.Id){
                            lf.attach = a.Body;
                        }
                    }
                }
            }
            if (lstTemp.size() > 0){
                delete lstTemp;
            }
            if (lstAtts.size() > 0){
                delete lstAtts;
            }
            
            //Any fields left in the map must have been deleted, remove them from Campaign_Form_Item__c
            //(skip this step when guests are accessing the page)
            if (mapDFields.size() > 0 ){
                if (strUserType != 'Guest'){
                    List<Campaign_Form_Item__c> lstDel = new List<Campaign_Form_Item__c>();
                    
                    for (String s : mapDFields.keySet()){
                        for (Campaign_Form_Item__c cff : lstCFFs){
                            if (cff.Name == s){
                                lstDel.add(cff);
                            }
                        }
                    }
                    
                    if (lstDel.size() > 0){
                        delete lstDel;
                    }
                } else {
                    //The guest user may not have rights to that field, so add it in anyway
                    //(the FieldMap is using the user's rights to grab fields, even though the class has no sharing
                    //but saving Leads is using system admin rights... go figure)
                    for (String s : mapDFields.keySet()){
                        lstDisplayFields.add(new LeadField(s,mapDFields.get(s).Label__c,mapDFields.get(s).Type__c,
                                mapDFields.get(s).Order__c.intvalue(), true, mapDFields.get(s).Required__c,null, false, null));
                    }
                }
            }//end if there are old fields
            SortFields();
        }//end if campaign not null 
        
        return null;
    }//end getLeadFields
    
    public void SortFields(){
        List<LeadField> lstDispSorted = new List<LeadField>();
        List<LeadField> lstSorted = new List<LeadField>();
        List<Integer> lstInt = new List<Integer>();
        List<String> lstStr = new List<String>();
        Integer intOrder = 0;
        
        //Display fields sorted by Order
        Map<Integer, LeadField> mapDispFields = new Map<Integer, LeadField>();
        
        for (LeadField lf : lstDisplayFields){
            mapDispFields.put(lf.order, lf);
            lstInt.add(lf.order);
        }
        
        lstInt.sort();
        
        for (Integer i : lstInt){
            //This corrects any gaps left by removing a field
            intOrder++;
            System.debug('Sorting display fields, adding ' +mapDispFields.get(i).field +' sort order = ' +intOrder);
            mapDispFields.get(i).order = intOrder;
            lstDispSorted.add(mapDispFields.get(i));
        }
        intMaxOrder = intOrder;
        
        lstDisplayFields = lstDispSorted;
        
        //Non-display fields sorted by name
        Map<String, LeadField> mapFields = new Map<String, LeadField>();
        
        for (LeadField lf : lstFields){
            mapFields.put(lf.label, lf);
            if (!(lf.textval == null &&(lf.datatype == 'ATTACHMENT' || lf.datatype == 'Line' 
                || lf.datatype == 'Heading' || lf.datatype == 'Descrip'))
            ){
                lstStr.add(lf.label);
            }
        }
        
        lstStr.sort();
        
        for (LeadField lf : lstFields){
            if (lf.textval == null &&(lf.datatype == 'ATTACHMENT' || lf.datatype == 'Line' 
                || lf.datatype == 'Heading' || lf.datatype == 'Descrip')
            ){
                lstSorted.add(mapFields.get(lf.label));
            }
        }
        
        for (String s : lstStr){
            lstSorted.add(mapFields.get(s));
        }
        
        lstFields = lstSorted;
    }//end SortFields
    
    public PageReference AddField(){
        LeadField lf;
        Integer pos;
        Integer i = 0;
        Boolean isElement = false;
        ApexPages.getMessages().clear();
        System.debug('IN ADD FIELD');
        if (strAddField != null){
            for (LeadField af : lstFields){
                if (af.field == strAddField){
                    pos = i;
                    lf = af;
                    if (af.datatype == 'ATTACHMENT' || af.datatype == 'Heading' || af.datatype == 'Line' || af.datatype == 'Descrip'){
                        isElement = true;
                    }
                }
                i++;
            }
            if (lf != null){
                System.debug('Adding field:' +lf.field);
                //Always keep the Attachment item in the available fields
                if (!isElement){
                    lstFields.remove(pos);
                }
                lf.order = intMaxOrder + 1;
                lstDisplayFields.add(lf);
                intMaxOrder = intMaxOrder + 1;
            }
        }
        return null;
    }
    
    public PageReference MoveUp(){
        String strField;
        Integer intDown;
        
        if (System.currentPageReference().getParameters().get('field') != null){
            strField = System.currentPageReference().getParameters().get('field');
            for (LeadField df : lstDisplayFields){
                System.debug('First loop, field = ' +df.field +' Order = ' +df.order);
                if (df.field == strField &&df.order != 1){
                    
                    df.order = df.order -1;
                    intDown = df.order;
                }
                System.debug('First loop end, field = ' +df.field +' Order = ' +df.order);
            }
            
            //Move up the field that was at that position
            for (LeadField df : lstDisplayFields){
                System.debug('Second loop, field = ' +df.field +' Order = ' +df.order);
                if (df.field != strField &&df.order == intDown){
                    df.order = df.order +1;
                }
                System.debug('Second loop end, field = ' +df.field +' Order = ' +df.order);
            }
            
            SortFields();
        }
        
        return null;
    }
    
    public PageReference MoveDown(){
        String strField;
        Integer intUp;
        
        if (System.currentPageReference().getParameters().get('field') != null){
            strField = System.currentPageReference().getParameters().get('field');
            for (LeadField df : lstDisplayFields){
                System.debug('First loop, field = ' +df.field +' Order = ' +df.order);
                if (df.field == strField &&df.order != intMaxOrder){
                    
                    df.order = df.order +1;
                    intUp = df.order;
                }
                System.debug('First loop end, field = ' +df.field +' Order = ' +df.order);
            }
            
            //Move down the field that was at that position
            for (LeadField df : lstDisplayFields){
                System.debug('Second loop, field = ' +df.field +' Order = ' +df.order);
                if (df.field != strField &&df.order == intUp){
                    df.order = df.order - 1;
                }
                System.debug('Second loop end, field = ' +df.field +' Order = ' +df.order);
            }
            
            SortFields();
        }
        
        return null;
    }
    
    public PageReference RemoveField(){
        LeadField lf;
        Integer pos;
        Integer i = 0;
        String strRemField;
        
        ApexPages.getMessages().clear();
        System.debug('Removing field: ' +System.currentPageReference().getParameters().get('rem_field'));
        if (System.currentPageReference().getParameters().get('rem_field') != null){
            strRemField = System.currentPageReference().getParameters().get('rem_field');
            for (LeadField df : lstDisplayFields){
                if (df.field == strRemField){
                    pos = i;
                    lf = df;
                }
                i++;
            }
            if (lf != null){
                lstDisplayFields.remove(pos);
                lstFields.add(lf);
                SortFields();
            }
        }
        return null;
    }
    
     //wrapper class for lead fields in edit mode
    public class LeadField{
        public String field {get; set;}
        public String label {get;set;}
        public String datatype {get;set;}
        public Integer order {get;set;}
        public Boolean display {get; set;}
        public Boolean required {get;set;}
        public String value {get;set;}
        public Blob attach {get;set;} 
        public Boolean bool {get;set;}
        public String textval {get;set;}
        
        //This is the contructor method. When a new pHS object is created, the High_School__c 
        //passed in is set to the hs property. It also sets the pass value to null
        public LeadField(String s, String l, String t, Integer i, Boolean boo, Boolean req, Blob a, Boolean b, String tv){
            field = s;
            label = l;
            datatype = t;
            order = i;
            display = boo;
            required = req;
            attach = a;
            bool = b;
            textval = tv;
        }
    }
    
    static testMethod void testPageMethods() {
        
        Campaign c = new Campaign(
            Name = 'Test Campaign'
        );
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        extRegistrationDevBackup ext = new extRegistrationDevBackup(stdCon);
        
        ext.AllLeadFields();
        ext.getAvailFields();
        
        //Add the Annual Revenue field to the form add (to test currency and number fields)
        ext.strAddField = 'AnnualRevenue';
        ext.AddField();
        System.currentPagereference().getParameters().put('field','AnnualRevenue');
        //Move it up and down
        ext.MoveUp();
        ext.MoveDown();
        
        //Add City
        ext.strAddField = 'City';
        ext.AddField();
        ext.SaveC();
        
        //Remove City
        System.currentPagereference().getParameters().put('rem_field','City');
        ext.RemoveField();
        ext.SaveC();
        
        ext.EditToggle();
        
        //Populate some fields, but intentionally leave out Last Name (required) and bad data for Annual rev
        for (LeadField lf : ext.lstDisplayFields){
            if (lf.field == 'FirstName'){
                lf.value = 'FirstNameTest';
            }
            if (lf.field == 'AnnualRevenue'){
                lf.value = 'something';
            }
        }
        ext.Register();
        
        //Set the parameter so the data is retrieved
        System.currentPagereference().getParameters().put('temp',ext.strName);
        ext.AllLeadFields();
        
        //Now fix the data
        for (LeadField lf : ext.lstDisplayFields){
            if (lf.field == 'LastName'){
                lf.value = 'LastNameTest';
            }
            if (lf.field == 'AnnualRevenue'){
                lf.value = '10';
            }
        }
        ext.Register();
        
        System.assert([Select count() from Lead where FirstName = 'FirstNameTest' and LastName = 'LastNameTest'] > 0);
    }
}