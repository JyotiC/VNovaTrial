public with sharing class VEMEmailController2
{
    /**************************************************
     Controller for the home report page***************
     **************************************************/
  //private string textAreaStyle = '';
  //private List <ApexPage> aPageList = [Select Description,Name from ApexPage where Name Like 'VEM%Today' OR Name Like 'VEM%Week'];
  
  /**get report names*******************/
  private List <ApexPage> aPageList = [SELECT Description, Name FROM ApexPage
                                       WHERE ControllerType = '2' 
                                       AND Name LIKE 'VEM%'
                                       AND Description != NULL];
 
  /***************get USer emails*********************/
  private  List<User> uList = new List<User>
    ([SELECT Name, Email FROM User WHERE Profile.Name LIKE 'VEM%' or Name in ('Arben Dodbiba','Kevin Renschler') ORDER BY Name]);
     
  //public String email {get;set;}
  public String sReports {get;set;}
  public String sUsers {get;set;}
  public String sDate {get;set;}
  public String eDate {get;set;}
  private VEM_Event__c m_event = new VEM_Event__c();
 
  /**for the time being date picker dummy event instance****/
  public VEM_Event__c getProxyObject()
  {
      m_event.Start_Date__c = Date.today(); 
      m_event.End_Date__c = Date.today().addDays(13);
      return m_event;
  }
  public VEM_Event__c setProxyObject()
  {  
      return m_event;
  }

/** keep it just in case we use a non Visualforce date picker***/
public String formatDate1(String sDateStr)
    {
        
        datetime uDate = datetime.now();
        String fDate  ;
        //format: yyyy-mm-dd
          if (sDateStr != null)  
           {  uDate = Date.valueOf(sDateStr);
              fDate = uDate.year() + '-' + uDate.month() + '-' + uDate.day();
           }   
          else
          fDate =datetime.now().format('yyyy.MM.dd').replace('.','-');
          return fDate;
    }
 /**format the date as needed***********/   
 public String formatDate2(Datetime aDate)
    {
        
        datetime uDate = datetime.now();
        String fDate;
        
        //format: yyyy-mm-dd
          if (aDate != null)  
               fDate = integer.valueOf(aDate.year()) + '-' + integer.valueOf(aDate.month()) + '-' + integer.valueOf(aDate.day()+1);
          else
              fDate = integer.valueOf(uDate.year()) + '-' + integer.valueOf(uDate.month()) + '-' + integer.valueOf(uDate.day());
          return fDate;
    }   

/**********************************************
  public List<SelectOption> getReports()
  {
    List<SelectOption> options = new List<SelectOption>();
        
    Schema.DescribeFieldResult fieldResult = VEM_Event__c.VForceReports__c.getDescribe();
    List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
    for( Schema.PicklistEntry f : ple)
    {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
    }       
    return options;
  } 
********************************************/

 /**Implement the report names ***********/ 
  public List<SelectOption> getrName()
  {
    List<SelectOption> options = new List<SelectOption>();
    for (ApexPage option : aPageList)
    {
      //if (!option.Name.contains('Report')) 
        options.add(new SelectOption(option.Name,option.Description));
    } 
    return options;
  }

 
/**
 <apex:outputLabel value="Email to " for="email"/>
    <apex:inputText size="22" value="{!email}" id="email"/>
**/

  /**implement user emails ***/
  public List<SelectOption> getuName()
  {
    List<SelectOption> options = new List<SelectOption>();
  
    for (User option : uList)
    {
      options.add(new SelectOption(option.Email,option.Name));
    } 
    return options;
  }
 
  
  /**run the report***/
  public PageReference sendReport() {
    Blob body;
    PageReference pref;
    try {
      pref = New PageReference('/apex/' + sReports);
        
      body = pref.getContent();
   
    } catch (VisualforceException e) {
      body = Blob.valueOf('Today in the Connelly Center Report is attached. Villanova Event Manager');
    }
    
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    attach.setContentType('application/pdf');
    attach.setFileName(sReports);
    attach.setInline(false);
    attach.Body = body;
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setUseSignature(false);
    mail.setToAddresses(new String[] { sUsers });
 
    mail.setSubject(sReports);
    mail.setHtmlBody(sReports + ' Report is attached. Salesforce ');
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 

    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Report sent to ' + sUsers));
    return null;
  }
  /** validate the dates ****/
  public Boolean isValid(Date startD, Date endD)
  {
      if (endD< startD)
         return false;
      else
         return true;    
  }
  /***email the report **/ 
  public PageReference runReport() {
         PageReference pref;
         if (sReports == 'VEM_Connelly_Today' || sReports == 'VEM_Athletics_Week' || sReports == 'VEM_Athletics_Today')
         {
            pref = New PageReference('/apex/' + sReports);
         }
         else if (sReports == 'VEM_Connelly_Operations_Report')
         {
            pref = New PageReference('/apex/' + sReports+'?date='+formatDate2(m_event.Start_Date__c));
         }
         else if (sReports == 'VEM_Connelly_Operations_Projection')
         { 
            if (isValid(m_event.Start_Date__c, m_event.End_Date__c))
            {
                pref = New PageReference('/apex/' + sReports+'?start='+formatDate2(m_event.Start_Date__c)+'&end='+formatDate2(m_event.End_Date__c));
            }
            else
            {
                ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'End Date can\'t be greater than Start Date.'));
                //textAreaStyle = 'border-size:2px; border-color:red;border-style:solid;';
                return null;
            }
         }
         else
         {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, 'Report "' + sReports + '" not found.'));
            return null;
         }
         pref.setRedirect(true);
         return pref;
  }
 public PageReference test() {
            return null;
        }
}