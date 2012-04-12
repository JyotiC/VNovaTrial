trigger pdfSchedT on SchedTest__c (before insert) {

String[] toAddresses =  new String[] {'arben.dodbiba@villanova.edu','krensc01@villanova.edu'};
  String rName = 'VEM_Connelly_Operations_Report';
  //VEM_MailerUtils M = new VEM_MailerUtils(); 
  //VEM_MailerUtils.sendMail('This is my email message from VEMscheduledReportMailer1');
  VEMEmailController.sendReport(Rname,toAddresses);
 // for (SchedTest__c a : Trigger.new)
 // {
 //  VEM_MailerUtils.sendMail('This is my email message from VEMscheduledReportMailer1');
   //VEMEmailController.sendReport(Rname,toAddresses);
 // }
  }