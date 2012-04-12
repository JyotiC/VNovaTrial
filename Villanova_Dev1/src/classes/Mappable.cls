public class Mappable{

    Static Final Double PI = 3.14159265;
    String ID = '';
    String ObjectType = ''; 
    String Phone ='';
    Double Lat =0;
    Double Lon =0; 
    String Name ='';
    String Status = ''; 
    String Street='';
    String City='';
    String State ='';
    String Tp = '';
    String Zip = '';
   
    Boolean Mappable = true; 

    public Mappable(Account A){
        Id = A.Id;
        ObjectType = 'Account';
        
        if(A.Phone == null){
            Phone = '';
        }
        else{ 
            Phone = A.Phone;
        }         
        Lat = A.Lat__c;
        Lon = A.Lon__c;
        Name = A.Name;
        Status = A.FNA_Status__c;
        Tp = A.Type;

        if(A.Which_Address__c == 'Shipping')
        {    
            Street = A.ShippingStreet;
            City = A.ShippingCity;
            State = A.ShippingState; 
            Zip = A.ShippingPostalCode; 
        }
        else if(A.Which_Address__c == 'Billing' || A.Which_Address__c != null)
        {    
            Street = A.BillingStreet;
            City = A.BillingCity;
            State = A.BillingState; 
            Zip = A.BillingPostalCode; 
        }
            
    }


    
    public String getCleanAddress(){
        String theAddress='';
        
        if(zip == null){ zip = '';}
        if(street != null && city != null && state != null){
            theAddress += street+','+city+' '+state; 
        }
        else{ 
            mappable = false; 
            Status = 'Problem with Address'; 
            theAddress='';
            return Status;
        }
        
        theAddress = theAddress.replace('#','');
        theAddress = theAddress.replace('/','');
        theAddress = theAddress.replace('&','');
        theAddress = theAddress.replace('(','');
        theAddress = theAddress.replace(')','');
        theAddress = theAddress.replace(';','');
        theAddress = theAddress.replace(':','');
        theAddress = theAddress.replace('@','');
        theAddress = theAddress.replace('!','');
        theAddress = theAddress.replace('~','');
        theAddress = theAddress.replace('`','');
        theAddress = theAddress.replace('$','');
        theAddress = theAddress.replace('%','');
        theAddress = theAddress.replace('^','');
        theAddress = theAddress.replace('*','');
        theAddress = theAddress.replace('+','');
        theAddress = theAddress.replace('=','');
        theAddress = theAddress.replace('"','');
    
        String[] brokenUp = theAddress.split(' '); 
        String makeIt='';

            for(String s:brokenUp)
            {
               makeIt+=s+'+';
            }
            
        return makeIt; 
    }
   
   /*Create request*/
   public HttpRequest buildWebServiceRequest(){
        String url = 'http://maps.google.com/maps/geo?q='+getCleanAddress()+'&output=csv&oe=utf8&sensor=false&key='+Label.GeoApiKey;
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod('GET');
        return req; 
    }
    /*make the call out*/
    public String invokeWebService(Http h, HttpRequest req){
         HttpResponse res = h.send(req);
        return  res.getBody();
    }
    
    /*Go through the respone*/ 
    public void handleWebServiceResponse(String answer){
        String[] parts; 
   
        parts = answer.split(',');

        if(parts[0] == '200')
        {
            Integer accuracy = Integer.ValueOf(parts[1]);
            
            if(accuracy < 6){
                Status = 'Problem with Address';
                mappable = false; 
            }
            else{
                Lat = Double.ValueOf(parts[2]);
                Lon = Double.ValueOf(parts[3]);
                Status = 'Located';
                mappable = true;
            }
        }
        else if(parts[0] == '500' || parts[0]== '601' ){
            Status = 'Problem with Address';
            mappable =false;
        }
        else if( parts[0] == '620'){
            Status = 'Google Exhausted';
            mappable = false; 
        }
        else if(parts[0] == '602' || parts[0] == '603'){
            Status = 'Problem with Address';
            mappable =false;
        }
        else if(parts[0] == '610'){
            Status = 'Bad Google Key';
            mappable =false;
        } 
        else{
            Status = 'Problem with Address';
            mappable= false; 
        }
    }
    public String geoTag(){
        if(mappable)
        {
            try{
                Http h = new Http();
                HttpRequest req= buildWebServiceRequest(); 
                String res = invokeWebService(h,req); 
                handleWebServiceResponse(res); 
            }catch(Exception e){
              mappable = false; 
              Status = 'Problem with Address'; 
           }
        }
        return Status; 
    }
    
    public String getStreet(){return Street;}
    public String getState(){return State;}
    public String getCity(){return City;}
    public String getZip(){return Zip;}

    public Double getLat(){return Lat;}
    public Double getLon(){return Lon;}
    
    public String getID(){return Id;}
    public String getObjType(){ return ObjectType;} 
    public String getPhone(){return phone;}
    
    public String getStatus(){ return Status;} 
    
    public String getName() {return name;}
    public String getType() {return Tp;}

    public Boolean getMappable(){
        getCleanAddress();
        return mappable;
    }
    
    public String getURLCleanAddress(){
        return getCleanAddress().replace('+',' '); 
    }
    
}