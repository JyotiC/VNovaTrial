public class DocumentService {
    GoogleService service = new GoogleService('Documents');
    public void setAuthSubToken(string t) { service.AuthSubToken = t;   }

    public static final string feedUrl =        'https://docs.google.com/feeds/documents/private/full/';
    public static final string docsUrl = 'https://docs.google.com/feeds/documents/private/full/-/document';
    public static final string sheetsUrl =  'https://docs.google.com/feeds/documents/private/full/-/spreadsheet';

	public Boolean useClientLogin(String username, String password)
	{
		return service.authenticateWithClientLogin(username, password, 'writely');	
	}
	
    public string documentsFeed { get { return docsUrl; }}
    
    public GoogleData getFeed(string url) { // pass in your own query params here
        return service.getFeed(url);
    }
    
    public GoogleData documents { get { return getFeed( docsUrl ); } }
    
    public GoogleData getDocuments() { return documents; }
    
    public GoogleData getSpreadsheets() { 
        return getFeed( sheetsUrl );
    }
    public GoogleData getSpreadsheets(string title) { 
        return getFeed( sheetsUrl + '?title=' + title);
    }
    
    public GoogleData getDocumentsFolder(string f) {
        f = EncodingUtil.urlEncode(f, 'UTF-8');
        return getFeed( docsUrl + '/' + f);
    }
    
    // works for names or emails, e.g. 'sforcedemos' and 'sforcedemos@gmail.com'
    // will have equivalent returns
    public GoogleData getDocumentsAuthor(string a) {
        a = EncodingUtil.urlEncode(a, 'UTF-8');
        return getFeed(docsUrl + '?author=' + a);
    }
    
    public GoogleData getDocumentsTextSearch(string q) {
        q = EncodingUtil.urlEncode(q, 'UTF-8');
        return getFeed(docsUrl + '?q=' + q);
    }
    
    public GoogleData getDocumentsStarred() {
        return getFeed(docsUrl + '/starred');
    }
    
    
    public GoogleData getDocumentsTitleAndTextSearch(string query, string title, boolean exactTitle) {
        query = EncodingUtil.urlEncode(query,'UTF-8');
        title = EncodingUtil.urlEncode(title,'UTF-8');      
        return getFeed(docsUrl + '?q=' + query + '&title=' + title + '&title-exact=' + exactTitle);
    }
    
    public GoogleData getDocumentsTitle(string t) {
        t = EncodingUtil.urlEncode(t,'UTF-8');
        return getFeed(docsUrl + '?title=' + t);
    }
    
    public GoogleData getDocumentsTitleExact(string t) {
        t = EncodingUtil.urlEncode(t,'UTF-8');
        return getFeed(docsUrl + '?title=' + t + '&title-exact=true' );
    }
    
    /* 
    What kinds of files can I upload to the Documents List API? 

    The following file types can be uploaded via the Google Documents List API: 
    File extension  MIME type
    CSV text/csv
    TSV text/tab-separated-values
    TAB text/tab-separated-values
    HTML    text/html
    HTM text/html
    DOC application/msword
    ODS application/x-vnd.oasis.opendocument.spreadsheet
    ODT application/vnd.oasis.opendocument.text
    RTF application/rtf
    SXW application/vnd.sun.xml.writer
    TXT text/plain
    XLS application/vnd.ms-excel
    PPT application/vnd.ms-powerpoint
    PPS application/vnd.ms-powerpoint
    */  
    
    
    /*  How it's done
     
    POST /feeds/documents/private/full HTTP/1.1
    Content-Length: 73612
    Content-Type: multipart/related; boundary=END_OF_PART
    Slug: test.doc
    MIME-version: 1.0
    
    Media multipart posting
    --END_OF_PART
    Content-Type: application/atom+xml
    
    <?xml version='1.0' encoding='UTF-8'?>
    <atom:entry xmlns:atom="http://www.w3.org/2005/Atom">
      <atom:category scheme="http://schemas.google.com/g/2005#kind" 
          term="http://schemas.google.com/docs/2007#document" />
      <atom:title>example document</atom:title>
    </atom:entry>
    --END_OF_PART
    Content-Type: application/msword
    
    ... doc contents here ...
    
    --END_OF_PART--
    
    or the simple way, no metadata
    
    POST /feeds/documents/private/full HTTP/1.1
    Content-Length: 81047
    Content-Type: application/vnd.ms-excel
    Slug: Example Spreadsheet
    */


    /* 
        Uploading a spreadsheet without metadata
        example uploadDocument('foo,bar,gack','upload sample.csv','text/csv');
    */
    public GoogleData uploadDocument (string body, string title, string contentType) {
        
        service.slug = title;
        HttpResponse res = service.getFeedMethod('POST', feedUrl,
            body, 
            contentType);
        service.slug = null;
            
        string resbody = res.getBody();  
        system.assert( resbody != null , 'missing httpresponse');
        
        // build a response that can be used to describe / query this document
        GoogleData result = new GoogleData( new xmldom( resbody ) );
        if (debug > 1) { 
            result.dump();
        }  
        return result;
    }
  
    public integer debug { get; set { service.debug = this.debug = value; } }   
   
    /* 
    not yet working...   returns 404?
    public void trashDocument( string uri ) {
        
        service.makeDeleteRequest(uri);
        string resbody = service.response.getBody();  
        system.debug (resbody);
    }  */ 
    
}