Public class VEMCallEMSWS  
    {  
      static  public void invokeExternalWs()  
      {  
      	Http http = new Http();  
      	HTTPResponse res = null;
        HttpRequest req = new HttpRequest();  
        String UserName= 'emsapiuser';
        String Password='salesforce';
        System.debug('hello1:'); 
       
        //String content = 'UserName='+UserName+'&Password='+Password+'&BuildingID='+'1';
        String content = '<GetAllRooms xmlns="http://DEA.EMS.API.Web.Service/"> ' +
      						'<UserName>emsapiuser</UserName> ' +
                            '<Password>salesforce</Password> ' +
                            '<BuildingID>1</BuildingID> ' +
                         '</GetAllRooms>';
        //String content = 'accountType=HOSTED_OR_GOOGLE&Email='+username+'&Passwd='+passwd+'&service='+service;
        //req.setEndpoint('http://vuemspro.villanova.edu/EMSAPI/Service.asmx?op=GetAllRooms');
        req.setEndpoint('http://vuemspro.villanova.edu/EMSAPI/Service.asmx');
        //req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Host', 'vuemspro');
        req.setHeader('Content-Type', 'text/xml; charset=utf-8');
        req.setHeader('Content-Length', String.valueOf(content.length()));
        req.setHeader('SOAPAction', 'http://DEA.EMS.API.Web.Service/GetAllRooms');
        req.setMethod('POST');
        req.setBody(content);

        System.debug('hello2'); 
        System.debug('hello2.1 - ' + req.getBody());
        //req.setCompressed(true);
         
        //Put this in a method that updates VEM_Event, location and etc
        try {  
          //call the external web service here
          req.setTimeout(30000);       
          res = http.send(req);  
           System.debug('hello3:');
          //Check the status for debugging  
          System.debug(res.toString());  
          System.debug('STATUS:'+res.getStatus());  
          System.debug('STATUS_CODE:'+res.getStatusCode());   
           System.debug('hello4:');
          if (res.getStatusCode() == 200)// check the satus on this
          {
           VEM_Event	ev =  new VEM_Event();
           String aa= res.getBody();
           //ETL the data or PARSE THE RESPONSE XML USING XmlStreamReader  CLASS
          }              
       } catch(System.CalloutException e) {  
            System.debug('Callout failed:' + e);//Exception handling .  
     }         
 }     
}