public with sharing class VEM_MailerUtils {

    public static void sendMail(string message) {
 
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {'arben.dodbiba@villanova.edu','krensc01@villanova.edu'};
        mail.setToAddresses(toAddresses);
 
        mail.setSubject('Hello');
 
        mail.setUseSignature(false);
        mail.setHtmlBody(message);
 
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
 
    }   
    
}