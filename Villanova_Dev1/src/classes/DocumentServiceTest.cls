public class DocumentServiceTest {
 
    static integer debug=3;
    static final string sessionAuthToken = 'CJ3pqczuBBDk2N0S';
    
    // DocumentServiceTest.tup();  
    public static  testmethod void tup() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        service.debug = 0; 
        
        string doctitle = 'upload sample.csv';
        string csvBody = 'name,city,state' + '\n';
                csvBody += 'bill,new york, new york';
        GoogleData sheet = service.uploadDocument(
                            csvBody,
                            doctitle,
                            'text/csv'); 
        sheet.dump(); 
        
        /*
        To put a document in the trash, send an HTTP DELETE request 
        to the edit link. The edit link will have a document id and a 
        version token represented by id and version respectively in the 
        example below:
        DELETE /feeds/documents/private/full/spreadsheet%3Aid/version
        */
        service.debug = 0; 
        return;
        // my new spreadsheet does non appear in the all docs return..      
//      GoogleData allDocs = service.getDocuments();        

        GoogleData allDocs = service.getSpreadsheets(); 
//      for( xmldom.element e: allDocs.entries) { e.dumpAll();  }
        
        GoogleData titleMatches = service.getSpreadsheets( doctitle );
    
        //titleMatches.dump(); 
        xmldom.element one = titleMatches.entries.remove(0);
        one.dump(); 
        //for( xmldom.element e: titleMatches.entries) { e.dumpAll();  }
         // get the edit link for this doc
        system.debug( GoogleData.getRelLink( one, 'edit') ) ;   
        
    //  TODO delete the document is not YET WORKING
    //  GoogleData sf = service.getFeed( sheet.id ) ;
    //  sf.dump();
    //  system.debug( GoogleData.getKey(sheet.feed) );
   //     service.trashDocument( GoogleData.getRelLink( one, 'edit') ); 
                
    } 
    
    // Get a list of documents
    public static  testmethod void t1() {
    
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
        GoogleData documents = service.getDocuments(); // list all documents
        documents.dump();
        system.assert( documents.title.startswith( 'Available Documents - sforcedemos') );
        
        /*string res = myDump(documents.feed);
        System.assert(false, res);
        myDump(documents.feed);*/
        
    }
    public static  testmethod void t2() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        system.assert ( service.documentsFeed == 'http://docs.google.com/feeds/documents/private/full/-/document');
        service.getDocumentsFolder('foobar');
    }
    public static  testmethod void t3() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        service.getDocumentsAuthor('foobar');
    }
    public static  testmethod void t4() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        service.getDocumentsTextSearch('foobar');
    }   

    public static  testmethod void t5() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        service.getDocumentsStarred();
    }

    public static  testmethod void t6() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        service.getDocumentsTitleAndTextSearch('foobar','gack',true);
    }

    public static  testmethod void t7() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        service.getDocumentsTitle('foobar');
    }
    public static  testmethod void t8() {
        DocumentService service = DocumentServicetest.getTestDocService(); 
        service.getDocumentsTitleExact('foobar');
    }   
    public static DocumentService getTestDocService() {
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
        return service;
    }

    /* returns 404?
    public static  testmethod void t9() {
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
        string doctitle = 'upload sample.csv';
        GoogleData documents = service.getSpreadsheets(doctitle);
        documents.dump(); 
        xmldom.element one = documents.entries.remove(0);
        one.dumpAll();
        service.trashDocument( GoogleData.getRelLink( one, 'edit')  );  
    }*/

    //    Retrieving all word processor documents
    public static  testmethod void t9() {
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
        GoogleData documents = service.getFeed ( DocumentService.feedUrl + '-/document' ); 
        documents.dump(); 
    }
    
    // Retrieving all starred presentations
    public static  testmethod void t10() {
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
        GoogleData documents = service.getFeed ( 
            DocumentService.feedUrl + '-/presentation/starred' ); 
        documents.dump(); 
    } 
    
    // Retrieving all documents in a named folder
    public static  testmethod void t11() {
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
        GoogleData documents = service.getFeed ( 
            DocumentService.feedUrl + 
            '-/{http:%2F%2Fschemas.google.com%2Fdocs%2F2007%2Ffolders%2Femail}starred'); 
        documents.dump(); 
    }
    
    // Performing a text query
    public static  testmethod void t12() {
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
        GoogleData documents = service.getFeed ( 
            DocumentService.feedUrl + '?q=example+query'); 
        documents.dump(); 
    }
    
    // DocumentServiceTest.hello_world();  
   public static  testmethod void hello_world() {
        DocumentService service = new DocumentService();
        service.setAuthSubToken(sessionAuthToken);
      
        string doctitle = 'Hello World sample.csv';
        string csvBody = 'Hello,World';
        GoogleData sheet = service.uploadDocument(
                            csvBody,
                            doctitle,
                            'text/csv'); 
        sheet.dump(); 
   }
}