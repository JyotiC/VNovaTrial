public with sharing class VEMEmailController {
    
   public static PageReference sendReport(string pageString,string[] toAddresses ) {
    //PageReference pref = Page.VEM_Connelly_Operations_Report;
   //string pageString = 'VEM_Connelly_Today';
    PageReference pref = new PageReference(pageString);
    //String[] toAddresses = new String[] {'arben.dodbiba@villanova.edu','arben.dodbiba@villanova.edu'};
    //String[] toAddresses = new String[] {toAddr};
    Blob body;
    try { 
      body = pref.getContent(); 
   
    } catch (VisualforceException e) {
      //body = Blob.valueOf('Today in the Connelly Center Report is attached. Salesforce');
      body = Blob.valueOf('Report is attached. Villanova Event Manager');
    }
  
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    attach.setContentType('application/pdf');
    //attach.setFileName('VEM_Connelly_Operation_Report.pdf');
    attach.setFileName(pageString + '.pdf');
    attach.setInline(false);
    attach.Body = body;
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setUseSignature(false);
    mail.setToAddresses(toAddresses);
    mail.setSubject('scheduled Report from '+ Pagestring);
    mail.setHtmlBody('Connelly Operation Report Report is attached. Salesforce ');
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    return null;
 
  }
 
}