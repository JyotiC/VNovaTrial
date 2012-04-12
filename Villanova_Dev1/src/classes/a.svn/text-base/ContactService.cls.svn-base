public class ContactService {
    
    GoogleService service = new GoogleService('Contact');
    
    public void setAuthSubToken(string t) { service.AuthSubToken = t;   }

    public GoogleData getFeed(string url) {  
        return service.getFeed(url); 
    } 
    
    public void  makePutRequest( string url, string body) {
        service.makePutRequest(  url,  body) ;
    }
    
    /* The feed URL is in one of the following forms:
     * http://www.google.com/m8/feeds/contacts/userEmail/full
     * http://www.google.com/m8/feeds/contacts/default/full
     */
    public static final string defaultFeed = 'https://www.google.com/m8/feeds/contacts/default/full';
     
       // Retrieving a photo for a contact
    public static testMethod  void getOnePhotoContact() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
 
        GoogleData feed = service.getFeed( ContactService.defaultFeed ); 
        
        for( xmldom.element e: feed.entries) { 
            string photoUrl = GoogleData.getRelLink( e, 
                'http://schemas.google.com/contacts/2008/rel#photo'); 
            if ( photoUrl != null ) {
                system.debug( GoogleData.getTitle(e) + 'has a photo ');
                string photo = service.getPhotoBody(photoUrl ); 
                system.debug(photo); // binary data for photo
                return;
            }   
        } 
    }  
     
    public void insertContact( GoogleData addressbook, Contact con ) { 
        // take data from the contact , create a contact record, insert it
        xmldom.element entry =new xmldom.element('entry');
        GoogleData.addNameSpace(entry); 
        
        xmldom.element cat = new xmldom.element('category');    
        cat.attributes.put('scheme','http://schemas.google.com/g/2005#kind');
        cat.attributes.put('term','http://schemas.google.com/g/2005#contact');
        entry.appendChild(cat);
        entry.appendChild( GoogleData.createTextNode ( 'title', con.firstname + ' ' + con.lastname) );
        entry.appendChild( GoogleData.createTextNode ( 'content', con.description) );
        /*
        // TODO add more fields from contact record to the entry 
        // 
         <gd:email rel='http://schemas.google.com/g/2005#work'
            address='liz@gmail.com' />
          <gd:email rel='http://schemas.google.com/g/2005#home'
            address='liz@example.org' />
          <gd:phoneNumber rel='http://schemas.google.com/g/2005#work'
            primary='true'>
            (206)555-1212
          </gd:phoneNumber>
          <gd:phoneNumber rel='http://schemas.google.com/g/2005#home'>
            (206)555-1213
          </gd:phoneNumber>
          <gd:im address='liz@gmail.com'
            protocol='http://schemas.google.com/g/2005#GOOGLE_TALK'
            rel='http://schemas.google.com/g/2005#home' />
          <gd:postalAddress rel='http://schemas.google.com/g/2005#work'
            primary='true'>
            1600 Amphitheatre Pkwy Mountain View
          </gd:postalAddress>
        */
        if ( con.email != null ) { 
            xmldom.element email = new xmldom.element('gd:email');
            email.attributes.put( 'rel','http://schemas.google.com/g/2005#work');
            email.attributes.put( 'address', con.email ); 
            entry.appendChild(email);   
        }   
        // add more here
        
        string body = entry.toXmlString(); 
        system.debug (body) ; 
        string postUrl = GoogleData.getRelLink(addressbook.feed,'http://schemas.google.com/g/2005#post');
        service.makePostRequest( postUrl, body );
    }
        
    public GoogleData getContactsByTitle(string match) {
        xmldom f = new xmldom('<feed></feed>'); 
        xmldom.element feed = f.getElementByTagName('feed');
        
        for (xmldom.element con : service.getFeed( ContactService.defaultFeed ).entries) { 
            system.debug ( GoogleData.getTitle( con) + ' ' + match); 
            if ( GoogleData.getTitle( con).contains(match) ) { 
                feed.appendChild(con); 
            }   
        } 
        
        return new GoogleData(f) ;
    }
    
    // Updating contacts
    public void updateContact( xmldom.element con) { 
        
        xmldom.element node = con.getElementByTagName('entry');
        GoogleData.addNameSpace(node); 
        
        string body = con.toXmlString();
        system.debug( body); 
    
        service.makePutRequest( 
            GoogleData.getRelLink( con, 'edit'), 
            con.toXmlString() );    
    }
    
     public void removeContact( xmldom.element ev ) {
        string editUrl  = GoogleData.getRelLink(ev,'edit');
        if ( editUrl == null ) { system.debug( 'ERROR missing edit url'); return ; }
        service.makeDeleteRequest( editUrl );
    }
   
    public string getPhotoBody( string photoUrl ) { 
        service.getFeedMethod('GET', photoUrl,null,GoogleService.CONTENT_TYPE_URL );
        return service.response.getBody();  
    } 
    
    // TODO write and test batch contact insert , update and delete
      
    /* more features to consider 
    
    Support for contact groups
    Have you ever wanted to group your contacts? Ever wanted to get your Google contact groups? 
    Now you can create, read, edit and delete contact groups.
    
    Support for extended properties
    Have you ever wanted to add new properties to a contact? 
    Thought that the contact element does not have enough fields? 
    Extended property allow you to store client-specific properties.
    
    Support for batch processing
    Google Contacts API now allows you to collect multiple insert, update, 
    delete and query operations in one request. Please see http://code.google.com/apis/gdata/batch.html 
    for more information. Please also note that the maximum number of operations per request is 100.

    */
     
    /* *********************************
     * Test methods below here 
     * 
     */          
    static integer debug=3;
    static final string sessionAuthToken = 'CJ3pqczuBBCk0tSrBQ';
        
    // ContactService.listContacts(); 
    public static testMethod  void listContacts() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
        
        GoogleData feed = service.getFeed( ContactService.defaultFeed ); 
        feed.dump(); 
        system.debug( feed.id );
    } 
    
    // add a Contact 
    // ContactService.addOneContact();
    public static testMethod  void addOneContact() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
                
        Contact newContact = new Contact( 
            firstname='B', lastname='Spears', description='Sings for money',
            email='go@for.broke' ); 

        GoogleData feed = service.getFeed( ContactService.defaultFeed );
        
        service.insertContact( feed, newContact );
        
    }
    
    // 
    // ContactService.deleteOneContact();
    public static testMethod  void deleteOneContact() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
      
        GoogleData brits = service.getContactsByTitle( 'Spears' );
        service.removeContact( brits.entries[0] );
    }
 
    
    // ContactService.updateOneContact();
    public static testMethod  void updateOneContact() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
        
        GoogleData brits = service.getContactsByTitle( 'Spears' );
        
        for (xmldom.element con : brits.entries) { 
            con.dumpAll(); 
            con.getElementByTagName('title').nodeValue = 'New Spears';
            con.getElementByTagName('content').nodeValue = 'Writes Songs';
            
            service.updatecontact( con);
            
            return;
        } 
            
    }
    static string tmpstr = '<?xml version=\'1.0\' encoding=\'UTF-8\'?><entry xmlns=\'http://www.w3.org/2005/Atom\' xmlns:gContact=\'http://schemas.google.com/contact/2008\' xmlns:batch=\'http://schemas.google.com/gdata/batch\' xmlns:gd=\'http://schemas.google.com/g/2005\'><id>http://www.google.com/m8/feeds/contacts/sforcedemos%40gmail.com/base/7656a03108ee72bc</id><updated>2008-06-14T20:24:40.624Z</updated><category scheme=\'http://schemas.google.com/g/2005#kind\' term=\'http://schemas.google.com/contact/2008#contact\'/><title type=\'text\'>B Spears</title><content type=\'text\'>Sings for money</content><link rel=\'http://schemas.google.com/contacts/2008/rel#edit-photo\' type=\'image/*\' href=\'http://www.google.com/m8/feeds/photos/media/sforcedemos%40gmail.com/7656a03108ee72bc/1B2M2Y8AsgTpgAmY7PhCfg\'/><link rel=\'self\' type=\'application/atom+xml\' href=\'http://www.google.com/m8/feeds/contacts/sforcedemos%40gmail.com/full/7656a03108ee72bc\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://www.google.com/m8/feeds/contacts/sforcedemos%40gmail.com/full/7656a03108ee72bc/1213475080624000\'/><gd:email rel=\'http://schemas.google.com/g/2005#work\' address=\'go@for.broke\'/><gContact:groupMembershipInfo deleted=\'false\' href=\'http://www.google.com/m8/feeds/groups/sforcedemos%40gmail.com/base/284ae66c0fa3829a\'/></entry>';
    
    // Retrieving a single contact
    public static testMethod  void getOneContact() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
        
        // to get a single contact you must have stored the self 
        // link for that contact 
        GoogleData oneCon = service.getFeed( 
           'https://www.google.com/m8/feeds/contacts/sforcedemos%40gmail.com/full/7656a03108ee72bc');
        oneCon.dump(); 
    } 
    
    public static testMethod  void test3() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
        service.makePutRequest('sdffd','sdfsdf');
    } 
    public static testMethod  void test4() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
        xmldom tmp = new xmldom(tmpstr);
        try {       
        service.insertContact( new GoogleData(tmp), new Contact( 
            firstname='B', lastname='Spears', description='Sings for money',
            email='go@for.broke' ));
            
        } catch ( exception e) {} 
    } 
    public static testMethod  void test5() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
        xmldom tmp = new xmldom(tmpstr);
        try {       
        service.updateContact( tmp.root );
        } catch ( exception e) {} 
    } 
    public static testMethod  void test6() {
        ContactService service = new ContactService();  
        service.setAuthSubToken(sessionAuthToken); 
        xmldom tmp = new xmldom(tmpstr);
        try {       
        service.removeContact( tmp.root );
        } catch ( exception e) {} 
    }               
    
}