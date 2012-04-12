public class DocumentUtil {
    public static DocumentUtil instance = null;
    public Id orgID{get; set;}
    public Document doc;
    public static Document doc = null; 
    
    public DocumentUtil() {
        orgID = [SELECT Id FROM Organization].Id;
    }
    
    
    public String getURL() {
        return getURL(doc);
    }
    
    public String getURL(Document d) {
        // Rewrite as a relative path.
        String URL;
        String did = String.valueOf(d.id).substring(0,15);
        if (clsConstants.isProduction){
        	if (SiteImageBrowser.isImage){
            	URL = 'https://na6.salesforce.com/servlet/servlet.ImageServer?id=' + did + '&oid=' + orgID;
        	} else {
        		URL = 'https://na6.salesforce.com/servlet/servlet.FileDownload?file=' + did + '&oid=' + orgID; //
        	}
        } else { 
        	if (SiteImageBrowser.isImage){
            	URL = 'https://cs1.salesforce.com/servlet/servlet.ImageServer?id=' + did + '&oid=' + orgID;
        	} else {
            	URL = 'https://cs1.salesforce.com/servlet/servlet.FileDownload?file=' + did + '&oid=' + orgID; // 
        	}
        }
        return URL;
    }
    
    public static DocumentUtil getInstance() {
        if (doc == null) {
            doc = new Document();
        }
        return getInstance(doc);
    }
    
    public static DocumentUtil getInstance(Document d) {
        if (instance == null) {
            instance = new DocumentUtil();
        }
        instance.doc = d;
        return instance;
    }
}