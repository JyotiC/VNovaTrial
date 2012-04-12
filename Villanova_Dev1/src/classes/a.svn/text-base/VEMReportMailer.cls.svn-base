global class VEMReportMailer implements Schedulable{ 
	string name;
	string page;
	string[] cCAdd;
	global VEMReportMailer (string a,string b, string[] c) {
	page = a;
	name = b; 
	cCAdd = c;
	} 
   
  global void execute(SchedulableContext SC) {
     //VEM_MailerUtils M = new VEM_MailerUtils(); 
     //VEM_MailerUtils.sendMail('This is my email message from VEMscheduledReportMailer1');
    sendReportPDF(page,name,cCAdd);
   
 }
 public static void sendReportPDF(string pageS, string nameS, string[] cC ) {
  
   Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
   User recipient = [SELECT id FROM User WHERE lastName = :nameS LIMIT 1];
   EmailTemplate et = [SELECT id FROM EmailTemplate WHERE developerName = :pageS];
   //mail.setCcAddresses( new String[] {'arben.dodbiba@villanova.edu','subash.karra@villanova.edu'});
   mail.setCcAddresses(cC);
   mail.setSenderDisplayName('Your daily salesforce report');
   mail.setTargetObjectId(recipient.id); 
   mail.setTemplateId(et.id);
   mail.setSaveAsActivity(false);
   Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
 }
}