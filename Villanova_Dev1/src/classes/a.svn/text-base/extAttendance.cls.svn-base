public with sharing class extAttendance {
    public Campaign camp {get;set;}
    public List<Attendee> lstPageAttendees {get;set;}
    public List<CampaignMember> lstMembers {get;set;}
    public Map<Id, CampaignMember> mapMembers {get;set;}
    public String strAttPerPage {get;set;}
    public Integer intAttPerPage {get;set;}
    public Integer intAttTotalPages {get;set;}
    public Integer intAttCurrPage {get;set;}
    public Contact con {get;set;}
    //public Lead l {get;set;}
    public CampaignMember cm {get;set;}
    public String strAddType {get;set;}
    public Boolean isAdd {get;set;}
    public Boolean isFullScreen {get;set;}
    public Boolean SelectAll {get;set;}
    public CampaignMember DummyMember {get;set;}
    public String strStatFilter {get;set;}
    public String strFirstFilter {get;set;}
    public String strLastFilter {get;set;}
    public String strSaveMsg {get;set;}
    
    public extAttendance(ApexPages.StandardController ctrl) {
        this.camp = (Campaign)ctrl.getRecord();
        this.intAttPerPage = 10;
        strAttPerPage = '10';
        this.intAttCurrPage = 0;
        this.intAttTotalPages = 0;
        DummyMember = new CampaignMember();
        DummyMember.Status = 'Attended';
        
        String strFull = Apexpages.currentpage().getParameters().get('full');
        
        isFullScreen = (strFull == 'true' ? true : false);

        isAdd = false;
        strAddType = 'New';
        
        Init();
    }
    
    public void Init(){
        cm = new CampaignMember();
        cm.CampaignId = camp.Id;

        con = new Contact();
        //l = new Lead();
        //con.AccountId = idIndiv;
        
        Attendees();
        
        camp = [Select Id, Name, Date__c from Campaign where Id =: camp.Id];
        
        
    }//end Init
    
    public PageReference Attendees(){
        
        String strSoQL = 'Select Id, LeadId, Lead.FirstName, Lead.LastName, Display_on_Registration_Page__c, ';
        strSoQL += 'Lead.Phone, Lead.Email, ContactId, Contact.FirstName, Contact.LastName, ';
        strSoQL += 'Contact.Phone, Contact.Email, Status, Attendee_Group__c, Attendee_Group__r.Name ';
        strSoQL += 'from CampaignMember where CampaignId =\'' +camp.Id + '\'';
        
        if (strStatFilter != null &&strStatFilter != ''){
            strSoQL += ' and Status = \'' +strStatFilter +'\'';
        }
        
        if (strFirstFilter != null &strFirstFilter != ''){
            strSoQL += ' and (Lead.FirstName like \'%' +strFirstFilter +'%\'';
            strSoQL += ' or Contact.FirstName like \'%' +strFirstFilter +'%\')';
        }
        
        if (strLastFilter != null &&strLastFilter != ''){
            strSoQL += ' and (Lead.LastName like \'%' +strLastFilter +'%\'';
            strSoQL += ' or Contact.LastName like \'%' +strLastFilter +'%\')';
        }
        
        strSoQL += ' Order by Last_Name__c, First_Name__c';
        System.debug('In Attendees and strSoQL = ' + strSoQL);
        lstMembers = Database.query(strSoQL);
        
        //Put them in a map for later
        mapMembers = new Map<Id, CampaignMember>();
        for (CampaignMember cm : lstMembers){
        	mapMembers.put(cm.Id, cm.clone());
        }
        
        if (lstMembers.size() > 0 &&intAttCurrPage == 0){
            intAttCurrPage = 1;
        }
        if (lstMembers.size() == 0){
            intAttCurrPage = 0;
        }
        ChangeAttPage();
        //}
        
        return null;
    }
    
    public PageReference DelMember(){
        
        if (System.currentPageReference().getParameters().get('member') != null){
            List<CampaignMember> lstDel = [Select Id from CampaignMember where Id =: System.currentPageReference().getParameters().get('member')]   ;
            delete lstDel;
        }
        Attendees();
        return null; 
    }
    
    public PageReference RegPageDisplayMember(){
        
        if (System.currentPageReference().getParameters().get('member') != null){
            CampaignMember cmUpdate = [Select Id, Display_on_Registration_Page__c from CampaignMember where Id =: System.currentPageReference().getParameters().get('member')][0];
            cmUpdate.Display_on_Registration_Page__c = cmUpdate.Display_on_Registration_Page__c?false:true;
            update cmUpdate;
        }
        Attendees();
        return null;
    }
    
    public PageReference Clear(){
        strLastFilter = null;
        strFirstFilter = null;
        strStatFilter = null;
        
        Attendees();
        return null;
    }
    
    public List<SelectOption> getStatuses() {
        List<SelectOption> options = new List<SelectOption>(); 
        
        options.add(new SelectOption('','---None----'));
        options.add(new SelectOption('Attended','Attended'));
        
        options.add(new SelectOption('New (not invited yet)','New (not invited yet)'));
        options.add(new SelectOption('Registered','Registered'));
        
        options.add(new SelectOption('Wait List','Wait List'));
        
        return options;
    }
    
    public List<SelectOption> getGroups() {
        List<SelectOption> options = new List<SelectOption>(); 
        List<Campaign> lstGroups = [Select Id, Short_Name__c 
            from Campaign where Event__c =: camp.Id Order By Short_Name__c
        ];
        
        for (Campaign g : lstGroups){
            options.add(new SelectOption(g.Id,g.Short_Name__c));
        }
        
        return options;
    }
    
    public PageReference UpdateContact(){
        if (cm.ContactId != null){
            con = [Select Id, FirstName, LastName, Phone, Email, AccountId, Account.Name 
            	from Contact where Id =: cm.ContactId]; 
        }
        return null;
    }
    
    public PageReference SaveAtt(){
        List<CampaignMember> lstCM = new List<CampaignMember>();
        ApexPages.Message mssErr;
        Boolean isError = false;
        strSaveMsg = null;
        Set<Id> setSaved = new Set<Id>();
        
        for (Attendee att : lstPageAttendees){
        	if (att.Member.Status != mapMembers.get(att.Member.Id).Status ||
        		att.Member.Attendee_Group__c != mapMembers.get(att.Member.Id).Attendee_Group__c
        	){
            	lstCM.add(att.Member);
            	setSaved.add(att.MemberId);
        	} 
        }
        
        if (lstCM.size() > 0){
        	
            try{
                update lstCM;
            } catch (Exception e) {
                strSaveMsg = 'Error saving Attendees, changes not saved: <br/>' +e.getMessage(); // new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
                isError = true;
                
            }
            
            if (!isError){
                strSaveMsg = 'Attendance Saved Succesfully';
                Attendees();
                for (Attendee att : lstPageAttendees){
                	if (setSaved.contains(att.MemberId)){
        				att.Saved = true;
                	}
        		}
            }
        }
        
        System.debug('Just updated and strSaveMsg = ' +strSaveMsg);
        return null;
    }//end SaveAtt
    
    public List<SelectOption> getNumberPerPage() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('5','5'));
        options.add(new SelectOption('10','10'));
        options.add(new SelectOption('25','25'));
        options.add(new SelectOption('50','50'));
        options.add(new SelectOption('All','All'));
        
        return options;
    }
    
    public List<SelectOption> getAddTypes() {
        List<SelectOption> options = new List<SelectOption>();
        
        options.add(new SelectOption('New','New Lead'));
        options.add(new SelectOption('Existing','Existing Lead'));
        
        return options;
    }
    
    
    
    public PageReference SetisAdd(){
        if (isAdd){
            isAdd = false;
        } else {
            isAdd = true;
        }
        
        return null;
    }
    
    public PageReference SetAttPage(){
        
        if (System.currentPageReference().getParameters().get('intAttPageChange') != null){
            intAttCurrPage = Integer.valueOf(System.currentPageReference().getParameters().get('intAttPageChange'));
            ChangeAttPage();
        }
        
        return null;
    }
    
    public PageReference ChangeAttPage(){
        List<CampaignMember> lstPageMembers = new List<CampaignMember>();
        lstPageAttendees = new List<Attendee>();
        
        if (!lstMembers.isEmpty()){
            if (strAttPerPage == 'All'){
                this.intAttPerPage = 1000;
            } else {
                this.intAttPerPage = Integer.valueOf(strAttPerPage);
            }
            
            SelectAll = false;
            this.intAttTotalPages = clsPageFunctions.ReturnTotalPages(lstMembers, this.intAttPerPage);
            
            if (this.intAttCurrPage > this.intAttTotalPages){
                this.intAttCurrPage = this.intAttTotalPages;
            }
            lstPageMembers = lstMembers.clone();
            clsPageFunctions.MakePageList(lstPageMembers, this.intAttCurrPage, this.intAttPerPage); 
            
            //add booleans for check boxes
            for (CampaignMember cm : lstPageMembers){
                lstPageAttendees.add(new Attendee(cm));
            }
        }
        return null;
    }
    
    public PageReference SelectAllAttendees(){
        strSaveMsg = null;
        for (Attendee a : lstPageAttendees){
            a.Checked = SelectAll;
        }
        return null;
    }
    
    public PageReference MassStatus(){
        strSaveMsg = null;
        for (Attendee a : lstPageAttendees){
            if (a.Checked){
                a.Member.Status = DummyMember.Status;
            }
        }
        PageReference pr = SaveAtt();
        return null;
    }
    /*
    public PageReference SavePage(){
        List<CampaignMember> lstCMs = new List<CampaignMember>();
        ApexPages.Message mssErr;
        
        for (Attendee a : lstPageAttendees){
            lstCMs.add(a.Member);
        }
        
        try{
            update lstCMs;
        } catch (Exception e) {
            mssErr = new ApexPages.Message(ApexPages.severity.ERROR,e.getMessage());
            ApexPages.addMessage(mssErr);
        }
        
        return null;
    }*/
    
    public PageReference SaveNewAtt(){
        ApexPages.Message mssErr;
        strSaveMsg = null;
        //set a savepoint for rollback if any errors occurs
        transient Savepoint sp = Database.setSavepoint();
        
        
        try{
            upsert con;
        } Catch (Exception e){
            mssErr = new ApexPages.Message(ApexPages.severity.ERROR, 'Error creating Lead: ' +e.getMessage());
        }
        
        if (mssErr == null){
            cm.ContactId = con.Id;
            try{
                upsert cm;
            } Catch (Exception e){
                mssErr = new ApexPages.Message(ApexPages.severity.ERROR, 'Error creating Event Registration: ' +e.getMessage());
            }
        }
        
        if (mssErr != null){
            Contact temp = new Contact();
            temp.FirstName = con.FirstName;
            temp.LastName = con.LastName;
            temp.AccountId = con.AccountId;
            temp.Phone = con.Phone;
            temp.Email = con.Email;
            con = temp;
            Database.rollback(sp);
            ApexPages.addMessage(mssErr);
            System.debug('Error hit was: ' +mssErr.getDetail());
        } else {
            Init();
            mssErr = new ApexPages.Message(ApexPages.severity.INFO, 'Save Successful');
            ApexPages.addMessage(mssErr);
            
        }
        return null;
    }
    
    public PageReference FullScreen(){
        PageReference pr = new PageReference('/apex/attendance');//Page.Attendance;
        
        pr.setRedirect(true);
        pr.getParameters().put('full', 'true');
        pr.getParameters().put('id', camp.Id);
        pr.getParameters().remove('inline');
        System.debug('In FullScreen now');
        return pr;
    }
    
    public class Attendee{
        public Boolean Checked {get;set;}
        public String MemberId {get;set;}
        public String FirstName {get;set;}
        public String LastName {get;set;}
        public String Email {get;set;}
        public String Phone {get;set;}
        public CampaignMember Member {get;set;}
        public Boolean Saved {get;set;}
        
        public Attendee(CampaignMember cm){
            Member = cm;
            if (cm.ContactId != null){
                MemberId = cm.ContactId;
                FirstName = cm.Contact.FirstName;
                LastName = cm.Contact.LastName;
                Email = cm.Contact.Email;
                Phone = cm.Contact.Phone;
            } else {
                MemberId = cm.LeadId;
                FirstName = cm.Lead.FirstName;
                LastName = cm.Lead.LastName;
                Email = cm.Lead.Email;
                Phone = cm.Lead.Phone;
            }
            Saved = false;
        }
    }//end Attendee
   static testMethod void testPageMethods() {
        Id idRT = [Select Id from RecordType where SOBjectTYpe = 'Campaign' and DeveloperName = 'Event'][0].id;
        Campaign c = new Campaign(
            Name = 'Test Campaign',
            IsActive = true, Date__c=system.today(),
            RecordTypeId = idRT
        );
        insert c;
        c = [Select Id, Encrypted_Key__c from Campaign where Id =: c.Id];
        
        ApexPages.StandardController stdCon = new ApexPages.StandardController(c);
        System.currentPagereference().getParameters().put('event',c.Encrypted_Key__c);
        extattendance ext = new extattendance(stdCon);
        
        
        ext.strstatfilter = 'bah';
        ext.strfirstfilter = 'blah';
        ext.strlastfilter = 'pfft';
        ext.getstatuses();    
        ext.attendees();
        ext.getgroups();
        ext.updatecontact();
        ext.getnumberperpage();
        ext.getaddtypes();
        ext.setisadd();
        ext.changeattpage();
        ext.setattpage();
        
        ext.massstatus();
 //       ext.savepage();
        ext.con.FirstName = 'Jessie';
        ext.con.LastName = 'Grenfell';
        ext.con.Email = 'email@email.com';
        ext.cm.Status = 'Registered';
        ext.savenewatt();
        ext.saveatt();
        ext.selectallattendees();
        Id idMemb;
        for (Attendee a : ext.lstPageAttendees){
            idMemb = a.Member.Id;
        }
        System.currentPageReference().getParameters().put('member',idMemb);
        ext.delmember();
        ext.fullscreen();
        ext.clear();
    }
}