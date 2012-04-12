public class extRegistration {
    public Boolean isEdit {get;set;}
    public Campaign c {get;set;}
    public String strCMToBeDisplayed {get;set;}
    public String strDate {get;set;}
    public String strTitle {get;set;}
    public List<LeadField> lstFields {get;set;}
    public List<LeadField> lstDisplayFields {get;set;}
    public String strAddField {get;set;} 
    public Date dteTest {get;set;}
    public String strTest {get;set;}
    public String strTest2 {get;set;}
    //public Boolean DisplaySpeaker {get;set;} 
    public Boolean Confirm {get;set;}
    public Boolean Wait {get;set;}
    public Boolean Decline {get;set;}
    public Integer intMaxOrder {get;set;}
    public String strKey {get;set;}
    public String strUserType {get;set;}
    public String strName = '';
    public Boolean isProd {get;set;}
    public String strError {get;set;}
    public String strEndTable {get;set;}
    public String strTable {get;set;}
    public Contact con {get;set;}
    public Lead le {get;set;}
    public List<CampaignMember> lstCM {get;set;}
    public CampaignMember cm {get;set;}
    public String strCMErr {get;set;}
    public String strEPErr {get;set;}
    public String strEmail {get;set;}
    public String strRegLink {get;set;}
    public String strTemp {get;set;}
    
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
                c = [Select Id, Date__c, Location__c, Time__c, Speaker__c, Web_Description__c, Display_Speaker__c, Name, 
                    Display_Time__c, Display_Location__c, Confirmation_Text__c, Web_Page_Public__c, Encrypted_Key__c, Submit_Button_Label__c,
                    Display_Date__c, Display_Event_Details_Header__c, Do_Not_Use_VU_Web_Wrapper__c, Event_Venue__r.Name, Event_Venue__r.URL__c
                    
                    from Campaign where Encrypted_Key__c =: strKey];
                
                if (c.Date__c != null){
                	strDate = c.Date__c.format();
                }
                
            }
        }
    }
    
    public extRegistration(ApexPages.StandardController ctrl) {
        //this.c = (Campaign)ctrl.getRecord();
        strKey = Apexpages.currentpage().getParameters().get('event');
        String strContact = Apexpages.currentpage().getParameters().get('person');
        InitCampaign();
        strTable = '<table>';
        strEndTable = '</table>';
                
        strRegLink = 'http://nyuadi.force.com/Events/EventRegistration?event=' +c.Encrypted_Key__c +'.';
        
        strUserType = UserInfo.getUserType();
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
        
        
        
        if (strContact != null &&strContact != ''){
        	
            //Get all of the Contact fields and types
            Map<String, Schema.SObjectField> FieldMap = Schema.SObjectType.Contact.fields.getMap();
            Set<String> setFields = FieldMap.keySet();
            Map<String, Schema.DisplayType> LeadFieldMap = new Map<String, Schema.DisplayType>();
            SObjectField f;
            Schema.DescribeFieldResult d;
    
            String strSoQL = '';
            for (String fname : setFields) {
                if (strSoQL <> ''){
                    strSoQL += ', ';
                }
                strSoQL += fname;
            }
            strSoQL = 'Select ' +strSoQL +', Account.Name from Contact where Encrypted_Key__c = \'' +strContact +'\'';
            List<Contact> lstCon = Database.query(strSoQL);
            
            if (lstCon.size() > 0){
                con = lstCon[0];
            }
            
            //If Contact not found, try Lead
        	if (con == null){
	            //Get all of the Contact fields and types
	            FieldMap = Schema.SObjectType.Lead.fields.getMap();
	            setFields = FieldMap.keySet();
	            LeadFieldMap = new Map<String, Schema.DisplayType>();
	    
	            strSoQL = '';
	            for (String fname : setFields) {
	                if (strSoQL <> ''){
	                    strSoQL += ', ';
	                }
	                strSoQL += fname;
	            }
	            strSoQL = 'Select ' +strSoQL +' from Lead where Encrypted_Key__c = \'' +strContact +'\'';
	            List<Lead> lstLead = Database.query(strSoQL);
	            
	            if (lstLead.size() > 0){
	                le = lstLead[0];
	            }
        	}
        }
        
        //InitParticipants();
        //InitCM();
        
        
    }//end extRegistration
    /*
    public PageReference InitParticipants(){
    	lstCM = [Select Id, ContactId, Contact.Name, Contact.Title, Status, Display_on_Registration_Page__c
    			from CampaignMember where CampaignId =: c.Id and 
    			(Status = 'Participant' or Status = 'Speaker' or Status = 'Panel Member'
    			or Status = 'Moderator' or Status = 'Convener')
    	];
    	
    	return null;
    }
    */
    public List<SelectOption> getPartStats() {
    	List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('Speaker','Speaker'));
        options.add(new SelectOption('Participant','Participant'));
        options.add(new SelectOption('Panel Member','Panel Member'));
        options.add(new SelectOption('Moderator','Moderator'));
        options.add(new SelectOption('Convener','Convener'));
        
        return options;
    }
    /*
    public PageReference InitCM(){
    	System.debug('In InitCM now');
    	cm = new CampaignMember();
    	cm.CampaignId = c.Id;
    	cm.Display_on_Registration_Page__c = true;
    	return null;
    }
    
   
    
    public PageReference SaveCM(){
    	strCMErr = null;
    	System.debug('In SaveCM and cm.Contact = ' +cm.Contact);
    	if (cm.Contact == null){
    		strCMErr = 'Please select a Contact to add as a Principle.';
    	} else {
    		try {
	    		insert cm;
	    	} catch (Exception e) {
	            strCMErr = e.getMessage();
	        }
    	}
    	
        
        if (strCMErr == null){
        	InitParticipants();
        	InitCM();
        }
    	return null;
    }
    */
    
	
    public List<SelectOption> getVenues() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        List<Venue__c> lstVenues = [Select Id, Name from Venue__c order by Name];
        
        options.add(new SelectOption('','--- None ---'));
        for (Venue__c v : lstVenues){
            options.add(new SelectOption(v.Id,v.Name));
        }
        
        return options; 
    }
    
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
        if (le != null){
        	l = le;
        }
        ApexPages.Message m;
        Boolean FoundCompany = false;
        Confirm = false;
        Wait = false;
        Boolean IsError = false;
        List<Attachment> lstAttach = new List<Attachment>();
        Map<String, Blob> mapBlob = new Map<String, Blob>();
        strError = null;
        PageReference p = Page.EventRegistration;
        p.getParameters().put('event', strKey);
        transient Savepoint sp = Database.setSavepoint();
        
        if (le == null && con == null){
	        for (LeadField lf : lstDisplayFields){
	            if (lf.field == 'lastname'){
	            	l.LastName = lf.value;
	            }
	            if (lf.field == 'firstname'){
	            	l.FirstName = lf.value;
	            }
	            if (lf.field == 'email'){
	            	l.Email = lf.value;
	            }
	        }
	        
	        List<Lead> lstLeads = [Select Id from Lead where FirstName =: l.FirstName and LastName =: l.LastName and Email =: l.Email];
	        if (lstLeads.size() > 0){
	        	l = lstLeads[0];
	        }
        }
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
            	||(lf.required &&lf.datatype == 'BOOLEAN' &&(lf.bool == false))
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
            
            //Now, let's make sure this person doesn't already exist as a contact
            /*Contact con;
            if (Apexpages.currentpage().getParameters().get('contact') != null &&Apexpages.currentpage().getParameters().get('contact') != ''){
                List<Contact> lstCon = [Select Id from Contact where Encrypted_Key__c =: Apexpages.currentpage().getParameters().get('contact')];
                if (lstCon.size() > 0){
                	con = lstCon[0];
                }
                System.debug('Contacts found = ' +lstCon.size());
            } else {*/
            if (con == null &&le == null){
                //If they weren't out right passed in, check by name and email
                List<Contact> lstCon = [Select Id from Contact where FirstName =: l.FirstName and LastName =: l.LastName and Email =: l.Email];
                if (lstCon.size() > 0){
                    con = lstCon[0]; 
                }
            }
            
            //If Contact was found, move data from Lead to Contact
            if (con != null){
                Map<String, String> mapFields = clsFields.CommonLeadContactFields(UserInfo.getUserType());
                for (String fname : mapFields.keySet()){
                    //Don't overwrite fields with null
                    if (l.get(fname) != null &&fname != 'id'){
                    	if (fname == 'company' || fname == 'user_specified_company__c'){
                    		con.put('user_specified_company__c', l.get(fname));
                    	} else {
                    		if (fname == 'street' || fname == 'city' || fname == 'postalcode'
                    			|| fname == 'state' || fname == 'country'
                    		){
                    			con.put('mailing' +fname, l.get(fname));
                    		} else {
                    			if (fname == 'rating'){
                    				con.put('rating__c', l.get(fname));
                    			} else {
                        			con.put(fname, l.get(fname));
                    			}
                    		}
                    	}
                    	
                    }
                }
                 try {
                    update con;
                } catch (System.DmlException e) {
	            	for (Integer i = 0; i < e.getNumDml(); i++) {
				        // Process exception here  
				    	m = new ApexPages.Message(
	                        ApexPages.severity.ERROR,
	                        e.getDmlMessage(i)
	                    );
	                    ApexPages.addMessage(m);
				        System.debug(e.getDmlMessage(i)); 
				        
				        strError = (strError == null? e.getDmlMessage(i) :strError+'<br/>' +e.getDmlMessage(i));
				    }
                 }
            //Otherwise, insert as a lead
            } else {
                try {
                    upsert l;
                } catch (System.DmlException e) {
                	for (Integer i = 0; i < e.getNumDml(); i++) {
				        // Process exception here  
				    	m = new ApexPages.Message(
	                        ApexPages.severity.ERROR,
	                        e.getDmlMessage(i)
	                    );
	                    ApexPages.addMessage(m);
				        System.debug(e.getDmlMessage(i)); 
				        
				        strError = (strError == null? e.getDmlMessage(i) :strError+'<br/>' +e.getDmlMessage(i));
				    }
                	
                    
                    IsError = true; 
                }
            }
            if (!IsError){
            	CampaignMember cm;
            	List<CampaignMember> lstTemp = new List<CampaignMember>();
            	if (l != null){
            		lstTemp = [Select Id, Status, CampaignId from CampaignMember where LeadId =: l.Id and CampaignId =: c.Id];
            	} //else {
            	if (con != null){
            		System.debug('Looking for CM with con.Id' +con.Id);
            		lstTemp = [Select Id, Status, CampaignId from CampaignMember where ContactId =: con.Id and CampaignId =: c.Id];
            	}
            	//}
            	//if no existing Campaign member found, create a new one
            	if (lstTemp.size() == 0){
            		cm = new CampaignMember();
            		cm.CampaignId = c.Id;
            		if (con != null){
	                    cm.contactId = con.Id;
	                } else {
	                    cm.LeadId = l.Id;
	                }
            	} else {
            		cm = lstTemp[0];
            	}
            	System.debug('Current cm is ' +cm.Status);
                cm.Status = 'Registered';
                
                if (Apexpages.currentpage().getParameters().get('decline') == 'true'){
                	cm.Status = 'Declined';
                	Decline = true;
                }
                
                try {
                    upsert cm;
                } catch (System.DmlException e) {
                	for (Integer i = 0; i < e.getNumDml(); i++) {
				        // Process exception here  
				    	m = new ApexPages.Message(
	                        ApexPages.severity.ERROR,
	                        e.getDmlMessage(i)
	                    );
	                    ApexPages.addMessage(m);
				        System.debug(e.getDmlMessage(i)); 
				        
	                    String str = e.getDmlMessage(i);
	                    str = (str.contains('does not fall into any') ? 'Registration to this event is restricted and you are not eligible to attend.' : str);
	                    str = (str.contains('no more room') ? 'We apologize, but there is no more room on the wait list for this event.  If you have any questions, feel free to contact us at <a href="mailto:nyuad.institute@nyu.edu">nyuad.institute@nyu.edu</a>.' : str);
	                    
				        strError = (strError == null? str :strError+'<br/>' +str);
				    }
                	
                    
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
                    } catch (System.DmlException e) {
	                	for (Integer i = 0; i < e.getNumDml(); i++) {
					        // Process exception here  
					    	m = new ApexPages.Message(
		                        ApexPages.severity.ERROR,
		                        e.getDmlMessage(i)
		                    );
		                    ApexPages.addMessage(m);
					        System.debug(e.getDmlMessage(i)); 
					        
					        strError = (strError == null? e.getDmlMessage(i) :strError+'<br/>' +e.getDmlMessage(i));
					    }
	                	
	                    
	                    IsError = true; 
	                }
                }
                
                if (!IsError){
                	if ([Select Id, Status from CampaignMember where Id =: cm.Id][0].Status == 'Wait List'){
                		Wait = true;
                	}
                    Confirm = true;
                    p.getParameters().put('confirmed', 'true');
                } 
            }
        }

        if (IsError){
            Database.rollback(sp);
            strName = '' +System.now().formatLong();
            Apexpages.currentpage().getParameters().put('temp', strName);
            p.getParameters().put('temp', strName);
            p.getParameters().put('person',Apexpages.currentpage().getParameters().get('person'));
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
        } catch (System.DmlException e) {
        	for (Integer i = 0; i < e.getNumDml(); i++) {
		        // Process exception here  
		    	m = new ApexPages.Message(
                    ApexPages.severity.ERROR,
                    e.getDmlMessage(i)
                );
                ApexPages.addMessage(m);
		        System.debug(e.getDmlMessage(i)); 
		        
		        strError = (strError == null? e.getDmlMessage(i) :strError+'<br/>' +e.getDmlMessage(i));
		    }
        	
        }

        if (m == null){
            //Get existing display fields
            lstCFFs = [Select Id, Name, Order__c, Required__c, Text__c from Campaign_Form_Item__c where Campaign__c =: c.Id];
            
            try{
                delete lstCFFs;
            } catch (System.DmlException e) {
            	for (Integer i = 0; i < e.getNumDml(); i++) {
			        // Process exception here  
			    	m = new ApexPages.Message(
                        ApexPages.severity.ERROR,
                        e.getDmlMessage(i)
                    );
                    ApexPages.addMessage(m);
			        System.debug(e.getDmlMessage(i)); 
			        
			        strError = (strError == null? e.getDmlMessage(i) :strError+'<br/>' +e.getDmlMessage(i));
			    }
            	
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
            }catch (System.DmlException e) {
            	for (Integer x = 0; x < e.getNumDml(); x++) {
			        // Process exception here  
			    	m = new ApexPages.Message(
                        ApexPages.severity.ERROR,
                        e.getDmlMessage(x)
                    );
                    ApexPages.addMessage(m);
			        System.debug(e.getDmlMessage(x)); 
			        
			        strError = (strError == null? e.getDmlMessage(x) :strError+'<br/>' +e.getDmlMessage(x));
			    }
            	
            }
        }
        /*
        if (m == null){
        	try {
        		upsert lstCM;
        	} catch (Exception e) {
               	m = new ApexPages.Message(
                    ApexPages.severity.ERROR,
                    e.getMessage()
                );
                ApexPages.addMessage(m);
            }
        }
        */
        if (m != null){
            Database.rollback(sp);

        } else {
            InitCampaign();
            AllLeadConFields();
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
    
    public PageReference AllLeadConFields(){
        lstFields = new List<LeadField>();
        Map<String, Campaign_Form_Item__c> mapDFields = new Map<String, Campaign_Form_Item__c>();
        List<Campaign_Form_Item__c> lstCFFs = new List<Campaign_Form_Item__c>();
        lstDisplayFields.clear();
        lstFields.clear();
        List<Temp_Lead_Data__c> lstTemp = new List<Temp_Lead_Data__c>();
        List<Contact> lstCons = new List<Contact>();
        List<Attachment> lstAtts = new List<Attachment>();
        ApexPages.Message m;
                    
        //To clear out warning messages about the HTML format
        ApexPages.getMessages().clear();
        if (c != null &&c.Id != null){
            //Get existing display fields
            lstCFFs = [Select Id, Name, Order__c, Required__c, Type__c, Label__c, Text__c from Campaign_Form_Item__c where Campaign__c =: c.Id order by Order__c];
            //Always include First and Last Name fields
            if (lstCFFs.size() == 0){
                lstCFFs.add(new Campaign_Form_Item__c(Campaign__c = c.Id, Name = 'firstname', Label__c = 'First Name', Order__c = 1, Required__c = true));
                lstCFFs.add(new Campaign_Form_Item__c(Campaign__c = c.Id, Name = 'lastname', Label__c = 'Last Name', Order__c = 2, Required__c = true));
                lstCFFs.add(new Campaign_Form_Item__c(Campaign__c = c.Id, Name = 'email', Label__c = 'Email', Order__c = 3, Required__c = true));
                //lstCFFs.add(new Campaign_Form_Item__c(Campaign__c = c.Id, Name =  'user_specified_company__c', Label__c = 'Organization', Order__c = 4, Required__c = true));
                insert lstCFFs;
            }
            
            
            strTemp = 'Temp: ' +Apexpages.currentpage().getParameters().get('temp')  +' ';
            System.debug('strTemp is ' +strTemp);
            if (Apexpages.currentpage().getParameters().get('temp') != null){
                lstTemp = [Select Id, Field__c, Value__c from Temp_Lead_Data__c
                    where Name =: Apexpages.currentpage().getParameters().get('temp')
                    and Campaign__c =: c.Id];
                Set<Id> setIds = new Set<Id>();
                for (Temp_Lead_Data__c tld : lstTemp){
                    setIds.add(tld.Id);
                    strTemp += ' Field = ' +tld.Field__c +' value = ' +tld.Value__c;
                }
                lstAtts = [Select Id, Body, Name, ParentId from Attachment where Id IN: setIds];
            }
            System.debug('strTemp is ' +strTemp); 
            
            Map<String, String> mapFields = clsFields.CommonLeadContactFields(strUserType);
            /*else {
            
                //To pre-populate forms
                if (Apexpages.currentpage().getParameters().get('person') != null){
                    String strSoQL = 'Select ';
                    String fields = '';
                    if (strUserType != 'Guest'){
                    	fields += 'Id';
                    }
                    for (String fname : mapFields.keySet()) {
                    	if (fields != ''){
                    		fields += ', ';
                    	}
                        fields += fname;
                    }
                    strSoQL += fields +', Account.Name from Contact where Encrypted_Key__c = \'' +Apexpages.currentpage().getParameters().get('contact') +'\'';
                    lstCons = Database.query(strSoQL);
                }
            }*/
            
            //Get all of the Lead fields and types
            Map<String, Schema.SObjectField> FieldMap = Schema.SObjectType.Lead.fields.getMap();
            //Set<String> setFields = FieldMap.keySet();
            
            Map<String, Schema.DisplayType> LeadFieldMap = new Map<String, Schema.DisplayType>();
            SObjectField f;
            Schema.DescribeFieldResult d;
            for (Campaign_Form_Item__c cff : lstCFFs){
                mapDFields.put(cff.Name, cff); 
            }
            System.debug('I got ' +mapFields.keySet() +' Lead fields');
            for (String fname : mapFields.keySet()) {

                //FOR LEAD FIELDS
                f = FieldMap.get(fname);
                d = f.getDescribe();
                //Only want fields that can be updated, skipping reference fields
                if (((d.isUpdateable() &&strUserType != 'Guest') || strUserType == 'Guest')
                    &&(''+d.getType()).replace('Schema.DisplayType.','') != 'Reference'
                ){
                    if (mapDFields.get(fname) != null){
                    	String strLab = mapDFields.get(fname).Label__c;
           				strLab = (strLab == 'User-Specified Organization' ? 'Organization' : strLab);
                        lstDisplayFields.add(new LeadField(fname,strLab,(''+d.getType()).replace('Schema.DisplayType.',''),
                                mapDFields.get(fname).Order__c.intvalue(), true, mapDFields.get(fname).Required__c,null, false,null));
                        System.debug('Adding field ' +mapDFields.get(fname) +', Required = ' +mapDFields.get(fname).Required__c);
                        
                    } else {
                        lstFields.add(new LeadField(fname,d.getLabel(),(''+d.getType()).replace('Schema.DisplayType.',''),
                                null,  false, false,null, false,null));
                    }
                    mapDFields.remove(fname);
                }
                
            }//end setFields loop
            
            
            
            //Pre-populate with Contact data
            //for (Contact c : lstCons){
            if (con != null){
                for (LeadField lf : lstDisplayFields){
                	String fname = lf.field;
                	if (fname == 'street' || fname == 'city' || fname == 'postalcode'
            			|| fname == 'state' || fname == 'country'
            		){
            			fname = 'mailing' +fname;
            		}
            		if (fname == 'rating'){
            			fname = 'rating__c';
            		}
                    lf.value = String.valueOf(con.get(fname)); 
                    if (lf.field == 'user_specified_company__c' &&String.valueOf(con.get(fname)) == null 
                    	&&con.Account.Name != 'Individuals'
                	){
                    	lf.value = con.Account.Name;
                    }  
                    if (String.valueOf(con.get(fname)) == 'true'){
                        lf.bool = true;
                    } else {
                        lf.bool = false;
                    }
                    
                }
            }
            
            //Pre-populate with Lead data
            if (le != null){
                for (LeadField lf : lstDisplayFields){
                    lf.value = String.valueOf(le.get(lf.field)); 
                    if (lf.field == 'user_specified_company__c' &&String.valueOf(le.get(lf.field)) == null 
                    	
                	){
                    	lf.value = le.Company;
                    }  
                    if (String.valueOf(le.get(lf.field)) == 'true'){
                        lf.bool = true;
                    } else {
                        lf.bool = false;
                    }
                    
                }
            }
            
            //Add in attachment items
            for (Campaign_Form_Item__c cff : lstCFFs){
                if (cff.Type__c == 'ATTACHMENT' || cff.Type__c == 'Line' || cff.Type__c == 'Heading' || cff.Type__c == 'Descrip'){
                	
                    lstDisplayFields.add(new LeadField(mapDFields.get(cff.Name).Name,mapDFields.get(cff.Name).Label__c, mapDFields.get(cff.Name).Type__c,
                            mapDFields.get(cff.Name).Order__c.intvalue(), true, mapDFields.get(cff.Name).Required__c,null,false,mapDFields.get(cff.Name).Text__c));
                    System.debug('Adding element ' +mapDFields.get(cff.Name) +', Required = ' +mapDFields.get(cff.Name).Required__c);
                    mapDFields.remove(cff.Name);
                }
            }
            
            //Add objects to the fields
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
        
        //This is the contructor method
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
    
    static testMethod void testPageMethods3() {
        Id idRT = [Select Id from RecordType where SObjectType = 'Campaign' 
        and DeveloperName = 'Event' limit 10000][0].Id ;
        
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true,
            RecordTypeId = idRT, 
            Display_Date__c = true,
            Date__c = System.today()
        );
        
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        Id idIndiv = [Select Id from Account limit 1000][0].id;
        Contact con = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = idIndiv
        );
        insert con;
        con = [Select Id, Encrypted_Key__c from Contact where Id =: con.Id];
        
        Campaign grp = [Select Id from Campaign where Event__c =: c.Id and Short_Name__c = 'All'];
        grp.Registration_Limit__c = 1;
        grp.Wait_List_Limit__c = 1;
        update grp;
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        System.currentPagereference().getParameters().put('person',con.Encrypted_Key__c);
        extRegistration ext = new extRegistration(stdCon);
        
        ext.AllLeadConFields();
        
        Test.startTest();
        ext.getAvailFields();
        ext.getvenues();
        
         
        for (LeadField lf : ext.lstDisplayFields){
            if (lf.field == 'FirstName'){
                lf.value = 'FirstNameTest';
            }
            if (lf.field == 'LastName'){
                lf.value = 'LastNameTest';
            }
            if (lf.field == 'email'){
                lf.value = 'Email@test.com';
            }
			if (lf.field == 'user_specified_company__c'){
                lf.value = 'OrgTest';
            }
            
        }
        
        ext.Register();
        System.debug('Error hit: ' +ext.strError);
        System.assert(ext.strError == null);
        
        System.currentPagereference().getParameters().put('person','');
        for (LeadField lf : ext.lstDisplayFields){
            if (lf.field == 'LastName'){
                lf.value = 'LastNameTest';
            }
            
        }
        ext.Register();
        
        /*
        for (LeadField lf : ext.lstDisplayFields){
            if (lf.field == 'LastName'){
                lf.value = 'LastNameTest2';
            }
            
        }
        ext.Register();
        System.debug('!!!!!!!!!!!!!!!!!!!!!!Error: ' +ext.strError);
        System.assert(ext.strError != null);
        */
        CampaignMember cm = [Select Id from CampaignMember where CampaignId =: c.Id and ContactId =: con.Id];
        cm.Status = 'Declined';
        update cm;
        //ext.InitCM();
        Test.stopTest();
    }
    
    static testMethod void testPageMethods2() {
        Id idRT = [Select Id from RecordType where SObjectType = 'Campaign' and DeveloperName = 'Event'][0].Id;
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true,
            RecordTypeId = idRT, 
            Display_Date__c = true,
            Date__c = System.today()
        );
        
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        extRegistration ext = new extRegistration(stdCon);
        
        ext.AllLeadConFields();
        
        Test.startTest();
        ext.getAvailFields();
        ext.getvenues();
        
        ext.strAddField = 'Birthdate';
        ext.AddField();
        ext.SaveC();
        
        //Populate some fields, but intentionally leave out Last Name (required) 
        for (LeadField lf : ext.lstDisplayFields){
            if (lf.field == 'FirstName'){
                lf.value = 'FirstNameTest';
            }
            if (lf.field == 'email'){
                lf.value = 'Email@test.com';
            }
			if (lf.field == 'user_specified_company__c'){
                lf.value = 'OrgTest';
            }
            if (lf.field == 'Birthdate'){
                lf.value = 'Email@test.com';
            }
        }
        ext.Register();
        
        //Set the parameter so the data is retrieved
        System.currentPagereference().getParameters().put('temp',ext.strName);
        ext.AllLeadConFields();
        
        //Now fix the data
        for (LeadField lf : ext.lstDisplayFields){
            if (lf.field == 'LastName'){
                lf.value = 'LastNameTest';
            }
            if (lf.field == 'Birthdate'){
                lf.value = '' +System.today();
            }
        }
        ext.Register();
        System.debug('Error hit: ' +ext.strError);
        System.assert([Select count() from Lead where FirstName = 'FirstNameTest' and LastName = 'LastNameTest'] > 0);
        Test.stopTest();
    }
    
    static testMethod void testPageMethods() {
        Id idRT = [Select Id from RecordType where SObjectType = 'Campaign' and DeveloperName = 'Event'][0].Id;
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true,
            RecordTypeId = idRT, 
            Display_Date__c = true,
            Date__c = System.today()
        );
        
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        Id idIndiv = [Select Id from Account limit 1][0].id;
        Contact cont = new Contact(
            FirstName = 'Test',
            LastName = 'Person',
            AccountId = idIndiv,
            Email = 'email@email.com'
        );
        insert cont;
        CampaignMember cm = new CampaignMember(
        	CampaignId = c.Id,
        	Status = 'Speaker',
        	ContactId = cont.Id
    	);
        insert cm;
       
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        extRegistration ext = new extRegistration(stdCon);
        
        ext.AllLeadConFields();
        
        
        Test.startTest();
        ext.getAvailFields();
        ext.getPartStats();
        ext.EditToggle();
        //Add the Annual Revenue field to the form add (to test currency and number fields)
        ext.strAddField = 'annualrevenue';
        ext.AddField();
        System.currentPagereference().getParameters().put('field','annualrevenue');
        //Move it up and down
        ext.MoveUp();
        ext.MoveDown();
        
        //Add City
        ext.strAddField = 'city';
        ext.AddField();
        ext.SaveC();
        
        //Remove City
        System.currentPagereference().getParameters().put('rem_field','city');
        ext.RemoveField();
        ext.SaveC();
        Test.stopTest();
        
    }
    
    
}