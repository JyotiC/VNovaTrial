public with sharing class PDFEmailController {

   
  //public String email {get;set;}
 
 
  public static PageReference sendPdf() {
 
    PageReference pdf = Page.VEM_Connelly_Today;
     
    Blob body;
 
    try {
 
      body = pdf.getContent();
     
    } catch (VisualforceException e) {
      body = Blob.valueOf('Some Text');
    }
 
    Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
    attach.setContentType('application/pdf');
    attach.setFileName('testPdf.pdf');
    attach.setInline(false);
    attach.Body = body;
 
    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    mail.setUseSignature(false);
    mail.setToAddresses(new String[] { 'arben.dodbiba@villanova.edu','krensc01@villanova.edu' });
    mail.setSubject('Today in the Connelly Center Report');
    mail.setHtmlBody('Kevin, Today in the Connelly Center Report is attached. Thanks Salesforce ');
    mail.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
 
    // Send the email
    Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
 
   
  
    return null;
 
  }
 
}