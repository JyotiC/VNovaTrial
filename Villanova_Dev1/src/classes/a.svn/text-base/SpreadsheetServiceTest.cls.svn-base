public class SpreadsheetServiceTest {

    static integer debug=3;
    static final string sessionAuthToken = 'CJ3pqczuBBCl1K_p_P____8B';

    public static testMethod  void testtitle() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        service.getSpreadsheetsTitleExact('didtitle');     
    }
    
    // SpreadsheetServiceTest.test_worksheet_based_feed();
    public static testMethod  void test_worksheet_based_feed() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        GoogleData feed = service.getSpreadsheetsTitle('account');
        
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
 		
  		// get a new feed listing the worksheets in oneSpreadSheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );
        
        worksheetsFeed.dump(); 	// each worksheet is an entry

		for ( xmldom.element ws: worksheetsFeed.entries) { 
			system.debug ( GoogleData.getTitle( ws ) );	// title of each sheet
		}
  		
    }
    
    //  Update the metadata of a worksheet
    public static testMethod  void test_metadataofaworksheet() {
   		SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        GoogleData feed = service.getSpreadsheetsTitle('account');
        
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
 		
  		// get a new feed listing the worksheets in oneSpreadSheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );
   		
   		// pick the first one to rename
   		GoogleData.Worksheet ws = new GoogleData.Worksheet( worksheetsFeed.entries[0] );
   		ws.title = 'new sheet name';   
   		
   		service.updateWorksheet(ws);  // send the update
    }
    
    //  Get a list-based feed
    public static testMethod  void test_getListbasedfeed() {
   		SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        GoogleData feed = service.getSpreadsheetsTitle('account');
        
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
 		
  		// get a new feed listing the worksheets in oneSpreadSheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );
   		
   		// pick the first worksheet to list (quite arbitrary) 
   		GoogleData.Worksheet wrkSheet = 
   			new GoogleData.Worksheet( worksheetsFeed.entries[0] );

		GoogleData listFeed = service.getFeed( wrkSheet.listFeedUrl );
 		listFeed.dump(); 
    }
    
    // SpreadsheetServiceTest.test_addRowListFeed();
    //  Add a row
    // list feeds are tricky, be sure to use lowercase in your gsx names
   	public static testMethod  void test_addRowListFeed() {
   		SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        GoogleData feed = service.getSpreadsheetsTitle('contact');
  		// get a new feed listing the worksheets in oneSpreadSheet
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );
   		
   		// pick the first worksheet to work with 
   		GoogleData.Worksheet wrkSheet = 
   			new GoogleData.Worksheet( worksheetsFeed.entries[0] );
 		wrkSheet.dump(); 
 		
		// get the list feed meta-data 
 		GoogleData listFeed = service.getFeed( wrkSheet.listFeedUrl );
  		listFeed.dump();
 		// construct a new row 
 		/*  
 		gsx:contactid->003T0000005liEWIAY {}
		gsx:firstname->Bob {}
		gsx:lastname->Dubinina {} 
		note: the gsx names must be lowercase or we get 404 not found
		*/
 		xmldom.element newrow = new xmldom.element('entry');
		newrow.appendChild( 
			GoogleData.makeElement( 'gsx:contactid', '003T0000005liEWIAY' ));
		newrow.appendChild( 
			GoogleData.makeElement( 'gsx:firstname', 'Bob' ));
		newrow.appendChild( 
			GoogleData.makeElement( 'gsx:lastname', 'Dubinina' ));
		
  		// add the row to the worksheet
    	service.insertRow( listFeed, newrow); 
    }    
    
    //  Edit a row
    // SpreadsheetServiceTest.test_editRowListFeed();
   	public static testMethod  void test_editRowListFeed() {
   		SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        GoogleData feed = service.getSpreadsheetsTitle('contact');
  		// get a new feed listing the worksheets in oneSpreadSheet
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );

  		// pick the first worksheet to work with 
   		GoogleData.Worksheet wrkSheet = 
   			new GoogleData.Worksheet( worksheetsFeed.entries[0] );
 		//wrkSheet.dump();
 		
 		GoogleData listFeed = service.getFeed( wrkSheet.listFeedUrl );

		// pick one row (last row)
		xmldom.element onerow = listFeed.entries[listfeed.entries.size()-2];
		onerow.dumpAll();
 		// change Bob to Robert
 		onerow.getElementByTagName('gsx:firstname').nodeValue = 'Robert';
 		service.debug = 3;
 		service.updateRow( onerow ); 
   	}   
    
    // remove a row
    // service.removeRow( onerow ); 
   	public static testMethod  void test_removeRowListFeed() {
   		SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        GoogleData feed = service.getSpreadsheetsTitle('account');
  		// get a new feed listing the worksheets in oneSpreadSheet
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );

  		// pick the first worksheet to work with 
   		GoogleData.Worksheet wrkSheet = 
   			new GoogleData.Worksheet( worksheetsFeed.entries[0] );
 		//wrkSheet.dump();
 		
 		GoogleData listFeed = service.getFeed( wrkSheet.listFeedUrl );

		// pick one row (last row)
		xmldom.element onerow = listFeed.entries[listfeed.entries.size()-1];
		onerow.dumpAll();
	
 		service.removeRow( onerow ); 
   	}       
    
    
    //  Reverse-sort rows
    public static testMethod  void test_getListbasedfeedReverse() {
   		SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        GoogleData feed = service.getSpreadsheetsTitle('account');
        
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
 		
  		// get a new feed listing the worksheets in oneSpreadSheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );
   		
   		// pick the first worksheet to list (quite arbitrary) 
   		GoogleData.Worksheet wrkSheet = 
   			new GoogleData.Worksheet( worksheetsFeed.entries[0] );

		GoogleData listFeed = service.getFeed( wrkSheet.listFeedUrl + '?reverse=true' );
 		listFeed.dump(); 
    }    
    
    //  Add a worksheet
    public static testMethod  void test_addasheet() {
   		SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        
        GoogleData feed = service.getSpreadsheetsTitle('account');  
        xmldom.element oneSpreadSheet = feed.entries[0]; // expects one spreadsheet
 		
  		// construct a new worksheet object
  		// update the spreadsheet to contain it 
		/*<entry>
		  <title>Expenses</title>
		  <gs:rowCount>50</gs:rowCount> 
		  <gs:colCount>10</gs:colCount>
		</entry> */
		xmldom.element wrkSheet = new xmldom.element('entry');
		xmldom.element title = new xmldom.element('title') ;		
		title.nodeValue = 'one more wk sheet';
		wrkSheet.appendChild( title );
		xmldom.element rc = new xmldom.element('gs:rowCount');
		rc.nodeValue = '50';
		wrkSheet.appendChild( rc); 	
		xmldom.element cc = new xmldom.element('gs:colCount');
		cc.nodeValue = '10';
		wrkSheet.appendChild( cc); 	
		
		GoogleData.Worksheet addedWorkSheet = new GoogleData.Worksheet( wrkSheet);
	
		service.insertWorksheet( oneSpreadSheet , addedWorkSheet );
    }
    
    
    /* take a range of cells from the sheet
     * clear out one row, write those cells back
     */ 
	// SpreadsheetServiceTest.testUpdateCellsByBatch();
    public static testMethod  void testUpdateCellsByBatch() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        system.debug( service.spreadsheetsfeed );
        system.debug ( service.cancallout ); 
        
        // get a sheet
        xmldom.element sentry = service.getSpreadsheetsTitle('contact').entries[0];
        string workSheetFeedUrl = SpreadsheetService.getWorksheetFeedUrl(sentry);
        
        GoogleData worksheetsFeed = service.getFeed( workSheetFeedUrl );
        GoogleData.Worksheet wrkSheet = new GoogleData.Worksheet( worksheetsFeed.entries[0] );
        
        // get cells from one worksheet
        string rng = 'A2:c2';
        GoogleData feed = service.getFeedRange( wrkSheet.getCellFeedUrl() ,rng);
        feed.dump();
        system.debug( ' feed range body'+service.response.getbody()); 

        wrkSheet.cellFactory(feed.getEntries()); 
        system.debug('count the cells '+wrkSheet.cells.size() );
        
        // change some 
        wrkSheet.setCellContent( 2, 1, '123' );
        wrkSheet.setCellContent( 2, 2, 'bobo' );
        wrkSheet.setCellContent( 2, 3, 'the clown' ); 
        
        // write back
        service.updateCells ( wrkSheet );   
    }  

	// SpreadsheetServiceTest.test_clearRow();
 	public static testMethod  void test_clearRow() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
      	
      	xmldom.element sentry = service.getSpreadsheetsTitle('contact').entries[0];
        string workSheetFeedUrl = SpreadsheetService.getWorksheetFeedUrl(sentry);
    
        GoogleData worksheetsFeed = service.getFeed( workSheetFeedUrl );   
        GoogleData.Worksheet ws = new GoogleData.Worksheet( worksheetsFeed.entries[0] );
       
        // specify modest range to avoid data overflow, heap, and stmt limits
 		GoogleData feed = service.getFeedRange( 
 			ws.getCellFeedUrl() ,'A1:c3');
 		
        // build a list of cells that can be updated ( /full )
        // by calling the factory with a list of entries
        ws.cellFactory(feed.getEntries()); 
        
        system.debug('count the cells '+ws.cells.size() );
        
        // start outputing to the cells array
        ws.setCellContent( 2, 1, '' );
        ws.setCellContent( 2, 2, '' );
        ws.setCellContent( 2, 3, '' );
        
        // finaly write those cells back to google
        service.updateCells ( ws );    
        
 	}
 	
    // Cells batch update of several rows using Apex SOQL query()
    // SpreadsheetServiceTest.test_updateFromQuery(); 
    public static testMethod  void test_updateFromQuery() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
   
        string key = 'o12612000142644651407.6804866143906912412';
        string workSheetFeedUrl =   
        	'http://spreadsheets.google.com/feeds/worksheets/' +
         	key + '/private/full';
        GoogleData worksheetsFeed = service.getFeed( workSheetFeedUrl );   
        GoogleData.Worksheet ws = new GoogleData.Worksheet( worksheetsFeed.entries[0] );
       
        // specify modest range to avoid data overflow, heap, and stmt limits
 		GoogleData feed = service.getFeedRange( ws.getCellFeedUrl() ,'A1:d11');
 		
        // build a list of cells that can be updated ( /full )
        // by calling the factory with a list of entries
        ws.cellFactory(feed.getEntries()); 
        
        system.debug('count the cells '+ws.cells.size() );
        
        // start outputing to the cells array
        // first labels
        ws.setCellContent( 1, 1, 'Force.com Id' );
        ws.setCellContent( 1, 2, 'Account Name' );
        ws.setCellContent( 1, 3, 'Billing City' );
        ws.setCellContent( 1, 4, 'Billing State' );
        // then data
        integer row = 2; 
        for(account sob : [select id,name,billingcity,billingstate 
        	from account limit 10]) {

            ws.setCellContent( row, 1, sob.id);
            ws.setCellContent( row, 2, string.valueof(sob.name ) );
            ws.setCellContent( row, 3, string.valueof(sob.billingcity ) );
            ws.setCellContent( row, 4, string.valueof(sob.billingstate ) );
            row++;
        }
        
        // finaly write those cells back to google
        service.updateCells ( ws );    
        
    }

    public static testMethod  void test_getMatchingTitle() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        service.debug = 2; 
        GoogleData allSheets = service.getSpreadsheetsTitle('accoun'); // match this title
        // not reached
    }
    static string accountSheetTest = 
    '<?xml version=\'1.0\' encoding=\'UTF-8\'?><feed xmlns=\'http://www.w3.org/2005/Atom\' xmlns:openSearch=\'http://a9.com/-/spec/opensearchrss/1.0/\'><id>http://spreadsheets.google.com/feeds/spreadsheets/private/full</id><updated>2008-06-10T02:28:13.486Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#spreadsheet\'/><title type=\'text\'>Available Spreadsheets - sforcedemos@gmail.com</title><link rel=\'alternate\' type=\'text/html\' href=\'http://docs.google.com\'/><link rel=\'http://schemas.google.com/g/2005#feed\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/spreadsheets/private/full\'/><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/spreadsheets/private/full?title=accoun&amp;tfe=\'/><openSearch:totalResults>1</openSearch:totalResults><openSearch:startIndex>1</openSearch:startIndex><entry><id>http://spreadsheets.google.com/feeds/spreadsheets/private/full/o12612000142644651407.6804866143906912412</id><updated>2008-06-08T02:18:19.389Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#spreadsheet\'/><title type=\'text\'>Account Summary</title><content type=\'text\'>Account Summary</content><link rel=\'http://schemas.google.com/spreadsheets/2006#worksheetsfeed\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/worksheets/o12612000142644651407.6804866143906912412/private/full\'/><link rel=\'alternate\' type=\'text/html\' href=\'http://spreadsheets.google.com/ccc?key=o12612000142644651407.6804866143906912412\'/><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/spreadsheets/private/full/o12612000142644651407.6804866143906912412\'/><author><name>sforcedemos</name><email>sforcedemos@gmail.com</email></author></entry></feed>';
    public static testMethod  void test_getWorksheetFeedUrl() {
        GoogleData d = new GoogleData(new xmldom(accountSheetTest)) ;
        SpreadsheetService service = new SpreadsheetService();  
        system.debug( SpreadsheetService.getWorksheetFeedUrl(d.feed) );
        system.assert( 
            'http://spreadsheets.google.com/feeds/worksheets/o12612000142644651407.6804866143906912412/private/full'
            == SpreadsheetService.getWorksheetFeedUrl(d.feed) );
    }
    static string cellfeedtest = 
 	'<?xml version=\'1.0\' encoding=\'UTF-8\'?><feed xmlns=\'http://www.w3.org/2005/Atom\' xmlns:openSearch=\'http://a9.com/-/spec/opensearchrss/1.0/\' xmlns:gs=\'http://schemas.google.com/spreadsheets/2006\' xmlns:batch=\'http://schemas.google.com/gdata/batch\'><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full</id><updated>2008-06-12T01:08:21.797Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>Sheet1</title><link rel=\'alternate\' type=\'text/html\' href=\'http://spreadsheets.google.com/ccc?key=o12612000142644651407.6804866143906912412\'/><link rel=\'http://schemas.google.com/g/2005#feed\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full\'/><link rel=\'http://schemas.google.com/g/2005#post\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full\'/><link rel=\'http://schemas.google.com/g/2005#batch\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/batch\'/><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full?range=A2%3Ac2&amp;return-empty=true\'/><author><name>sforcedemos</name><email>sforcedemos@gmail.com</email></author><openSearch:totalResults>3</openSearch:totalResults><openSearch:startIndex>1</openSearch:startIndex><gs:rowCount>68</gs:rowCount><gs:colCount>20</gs:colCount><entry><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C1</id><updated>2008-06-12T01:08:21.797Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>A2</title><content type=\'text\'>003T0000005liESIAY</content><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C1\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C1/y04gv6\'/><gs:cell row=\'2\' col=\'1\' inputValue=\'003T0000005liESIAY\'>003T0000005liESIAY</gs:cell></entry><entry><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C2</id><updated>2008-06-12T01:08:21.797Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>B2</title><content type=\'text\'>Rose</content><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C2\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C2/h7ecv\'/><gs:cell row=\'2\' col=\'2\' inputValue=\'Rose\'>Rose</gs:cell></entry><entry><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C3</id><updated>2008-06-12T01:08:21.797Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>C2</title><content type=\'text\'>Freedom</content><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C3\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C3/h3riuu\'/><gs:cell row=\'2\' col=\'3\' inputValue=\'Freedom\'>Freedom</gs:cell></entry></feed>';

    static string tmpcell = 
    '<?xml version=\'1.0\' encoding=\'UTF-8\'?><feed xmlns=\'http://www.w3.org/2005/Atom\' xmlns:openSearch=\'http://a9.com/-/spec/opensearchrss/1.0/\' xmlns:gs=\'http://schemas.google.com/spreadsheets/2006\' xmlns:batch=\'http://schemas.google.com/gdata/batch\'><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full</id><updated>2008-06-10T02:30:39.590Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>Sheet1</title><link rel=\'alternate\' type=\'text/html\' href=\'http://spreadsheets.google.com/ccc?key=o12612000142644651407.6804866143906912412\'/><link rel=\'http://schemas.google.com/g/2005#feed\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full\'/><link rel=\'http://schemas.google.com/g/2005#post\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full\'/><link rel=\'http://schemas.google.com/g/2005#batch\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/batch\'/><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full?range=A1%3AB2&amp;return-empty=true\'/><author><name>sforcedemos</name><email>sforcedemos@gmail.com</email></author><openSearch:totalResults>4</openSearch:totalResults><openSearch:startIndex>1</openSearch:startIndex><gs:rowCount>68</gs:rowCount><gs:colCount>20</gs:colCount><entry><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R1C1</id><updated>2008-06-10T02:30:39.590Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>A1</title><content type=\'text\'>contact id</content><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R1C1\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R1C1/2b8qvv\'/><gs:cell row=\'1\' col=\'1\' inputValue=\'contact id\'>contact id</gs:cell></entry><entry><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R1C2</id><updated>2008-06-10T02:30:39.590Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>B1</title><content type=\'text\'>First name</content><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R1C2\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R1C2/t2drff\'/><gs:cell row=\'1\' col=\'2\' inputValue=\'First name\'>First name</gs:cell></entry><entry><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C1</id><updated>2008-06-10T02:30:39.590Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>A2</title><content type=\'text\'>003T0000005liESIAY</content><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C1\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C1/y04gv6\'/><gs:cell row=\'2\' col=\'1\' inputValue=\'003T0000005liESIAY\'>003T0000005liESIAY</gs:cell></entry><entry><id>http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C2</id><updated>2008-06-10T02:30:39.590Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#cell\'/><title type=\'text\'>B2</title><content type=\'text\'>Rose</content><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C2\'/><link rel=\'edit\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/cells/o12612000142644651407.6804866143906912412/od6/private/full/R2C2/h7ecv\'/><gs:cell row=\'2\' col=\'2\' inputValue=\'Rose\'>Rose</gs:cell></entry></feed>';
    

    public static testMethod  void test_updateCellsAgain() {
    	xmldom dd = new xmldom(cellfeedtest);
    	dd.dumpAll();
        GoogleData d = new GoogleData(dd) ;
        d.dump(); 

        list<GoogleData.Worksheet> worksheets = 
            GoogleData.WorksheetFactory(d.getEntries());
        GoogleData.Worksheet ws = worksheets[0];
        system.debug( ws.id ); 
        string cellFeedUrl = ws.getCellFeedUrl();
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        service.debug = 0;  
        service.updateCells( ws, ws.cells ); 
    }
    
    // SpreadsheetServiceTest.test_updateCel();
    public static testMethod  void test_updateCel() {
        GoogleData d = new GoogleData(new xmldom(cellfeedtest)) ;
        
        list<GoogleData.Worksheet> worksheets = 
            GoogleData.WorksheetFactory(d.getEntries());
        GoogleData.Worksheet ws = worksheets[0];
        system.debug( ws.id ); 
        string cellFeedUrl = ws.getCellFeedUrl();
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        service.debug = 0;  
        GoogleData feed = new GoogleData(new xmldom(tmpcell)) ;//service.getFeedRange( cellFeedUrl ,'A1:B2');  // specify range to avoid data overflow 
        list<GoogleData.Cell> cells = ws.cellFactory(feed.getEntries());                  
        for (GoogleData.Cell cel : cells  ) {
            cel.dump(); 
            system.debug ( cel.title + ' ' + cel.content );  
            system.debug ( cel.id + ' ' +cel.row + ' ' + cel.col + ' ' + cel.edit ); 
        }
        service.updateCell( ws, cells[0] ); 
    }
    public static testMethod  void test_updateCells() {
        GoogleData d = new GoogleData(new xmldom(cellfeedtest)) ;
        list<GoogleData.Worksheet> worksheets = 
            GoogleData.WorksheetFactory(d.getEntries());
        GoogleData.Worksheet wrkSheet = worksheets[0];
        system.debug( wrkSheet.id ); 
        string cellFeedUrl = wrkSheet.getCellFeedUrl();
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        service.debug = 0;  
        service.updateCells( wrkSheet); 
    }
    public static testMethod  void test_getFeedRange() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        service.debug = 0;  
        service.getFeedRange( 'url', 'range'); 
    }
    
    // SpreadsheetServiceTest.getCellsLatest(); 
    public static testMethod  void getCellsLatest() {
       SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
      	
      	xmldom.element sentry = service.getSpreadsheetsTitle('contact').entries[0];
        string workSheetFeedUrl = SpreadsheetService.getWorksheetFeedUrl(sentry);
    
        GoogleData worksheetsFeed = service.getFeed( workSheetFeedUrl );   
        GoogleData.Worksheet worksheet = new GoogleData.Worksheet( worksheetsFeed.entries[0] );
       
        worksheet.dump();
        
   		// create a cell without fetching it from google, the cell is empty until we set content property.
   		// you must specify the row and col when the cell is created, and content after it is created.
        googledata.cell cel = new googledata.cell( worksheet,1,1 );
        cel.content = 'force overwrite this cell';
        cel.dump();
        
        service.debug = 0; 
        service.updateCells( worksheet, new list<googledata.cell>{cel} ); 
   } 
        
    //Worksheet metafeed
    // test in execute anon window with 
    // SpreadsheetServiceTest.test_spreadsheet_worksheet_dump_with_CellUpdate(); 
    public static testMethod  void test_spreadsheet_worksheet_dump_with_CellUpdate() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        service.debug = 0;  
        GoogleData allSheets = service.getSpreadsheetsTitle('accoun'); // match this title
        if ( debug > 2) allSheets.dump();
        // here sheet is a feed with meta data about all sheets, and an entry 
        // for the individual spreadsheet returned by the title query above
        system.debug( allSheets.feed.getValue('title') ); //Available Spreadsheets - vnehess@gmail.com
        system.debug( allSheets.feed.getValue('totalResults') );
        system.debug( allSheets.feed.getValue('startIndex') );
        system.debug( allSheets.updated );
        system.debug( allSheets.errors );
        system.debug( allSheets.id ); 
        system.debug( allSheets.title );
        system.debug( allSheets.links );
        //system.debug( allSheets.entries[0] );
        
        // list meta data about one sheet returned in that feed
        xmldom.element oneSheet = allSheets.entries[0];
        oneSheet.dumpAll(); 
        system.debug( oneSheet.getValue('id') ); 
        system.debug( oneSheet.getValue('updated') );
        system.debug( oneSheet.getValue('content') );
        system.debug( oneSheet.getElementByTagName('author').getValue('name') );
        system.debug( GoogleData.getKey( oneSheet)  ); 
         
        // get a new feed listing the worksheets in oneSheet
        string workSheetFeedUrl = SpreadsheetService.getWorksheetFeedUrl(oneSheet);

        GoogleData worksheetsFeed = service.getFeed( workSheetFeedUrl );
        worksheetsFeed.dump(); 
        list<GoogleData.Worksheet> worksheets = 
            GoogleData.WorksheetFactory(worksheetsFeed.getEntries());
        GoogleData.Worksheet wrkSheet = worksheets[0];
        system.debug( wrkSheet.id ); 
        //system.debug( ws.updated );
        system.debug( wrkSheet.title );
        system.debug( wrkSheet.totalResults );
        system.debug( wrkSheet.startIndex );
        system.debug( wrkSheet.edit );
            
        // get a feed of cells from this worksheet
        /* in java
        URL cellFeedUrl = worksheetEntry.getCellFeedUrl();
        CellFeed feed = service.getFeed(celFeedUrl, CellFeed.class);
        for (CellEntry cell : feed.getEntries()) {
          System.out.println(entry.getTitle().getPlainText());
          String shortId = cell.getId().substring(cell.getId().lastIndexOf('/') + 1);
          System.out.println(" -- Cell(" + shortId + "/" + cell.getTitle().getPlainText()
              + ") formula(" + cell.getCell().getInputValue() + ") numeric("
              + cell.getCell().getNumericValue() + ") value("
              + cell.getCell().getValue() + ")");
        }
        */      
        // in APEX
        //GoogleData feed = service.getFeed( cellFeedUrl );
 		
 		// == Get a cell-based feed==
        string cellFeedUrl = wrkSheet.getCellFeedUrl();
        service.debug = 2;
        GoogleData feed = service.getFeedRange( cellFeedUrl ,'A1:B2');  // specify range to avoid data overflow
 
        list<GoogleData.Cell> cells = wrkSheet.cellFactory(feed.entries);                  
        for (GoogleData.Cell cel : cells  ) {
            cel.dump(); 
            system.debug ( cel.title + ' ' + cel.content );  
            system.debug ( cel.id + ' ' +cel.row + ' ' + cel.col + ' ' + cel.edit ); 
        }
        
        
        GoogleData.Cell existingCellEntry = cells[0];
        
        /*
        Change contents of a cell
        
        To modify the contents of an existing CellEntry that you have retrieved 
        from a feed, first change its InputValue property. Then execute the update 
        request as follows:
        JAVA
        existingCellEntry.changeInputValueLocal(formulaOrValue);
        existingCell.update();
        */  
        
        // APEX 
        existingCellEntry.content = 'formulaOrValue'; 
        service.updateCell ( wrkSheet, existingCellEntry );  
          
        // or service.updateCells( ws );  // for batch
         
    }


    // Spreadsheet-feed query parameters
    /* title    Specifies the search terms for the title of a document.     
       title-exact Specifies whether the title query should be taken as an exact string.
    */  
    public static testMethod  void test_getSheetsMatchingByTitle() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
            
        GoogleData sheets = service.getSpreadsheetsTitle('accoun'); // match this title
        if ( debug > 2) sheets.dump();
        
        sheets = service.getSpreadsheetsTitleExact('accoun'); // no match this title (asked for exact match)
        if ( debug > 2) sheets.dump();
 
    }

    public static testMethod  void test_listAllSheetsandDump() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        
        // get sheet with title 'account' 
        xmldom.element entry ; 
        GoogleData sheets = service.getSpreadsheets(); // feed of sheets
        system.assert( sheets != null , 'missing sheet data ');
        
        sheets = service.spreadsheets; // alternate way to get list of sheets
        system.assert( sheets != null , 'missing sheet data2 ');
        
        if ( debug > 2) sheets.dump(); 
        
        for (xmldom.element e : sheets.entries ) {  // loop thru sheet entries
            system.debug( e.getValue('title') );
            
            // two ways to get the title of an entry
            system.assert( GoogleData.getTitle(e)  == e.getValue('title') ); 
        
            e.dumpAll(); // dump an entry 
            
        }
        
    }   
    
    static string allSheetsTestFeed = 
 	'<?xml version=\'1.0\' encoding=\'UTF-8\'?><feed xmlns=\'http://www.w3.org/2005/Atom\' xmlns:openSearch=\'http://a9.com/-/spec/opensearchrss/1.0/\'><id>http://spreadsheets.google.com/feeds/spreadsheets/private/full</id><updated>2008-06-21T04:11:50.535Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#spreadsheet\'/><title type=\'text\'>Available Spreadsheets - sforcedemos@gmail.com</title><link rel=\'alternate\' type=\'text/html\' href=\'http://docs.google.com\'/><link rel=\'http://schemas.google.com/g/2005#feed\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/spreadsheets/private/full\'/><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/spreadsheets/private/full?tfe=\'/><openSearch:totalResults>9</openSearch:totalResults><openSearch:startIndex>1</openSearch:startIndex><entry><id>http://spreadsheets.google.com/feeds/spreadsheets/private/full/o12612000142644651407.7976840196089771957</id><updated>2008-06-09T00:54:04.756Z</updated><category scheme=\'http://schemas.google.com/spreadsheets/2006\' term=\'http://schemas.google.com/spreadsheets/2006#spreadsheet\'/><title type=\'text\'>spreadsheet in folder1</title><content type=\'text\'>spreadsheet in folder1</content><link rel=\'http://schemas.google.com/spreadsheets/2006#worksheetsfeed\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/worksheets/o12612000142644651407.7976840196089771957/private/full\'/><link rel=\'alternate\' type=\'text/html\' href=\'http://spreadsheets.google.com/ccc?key=o12612000142644651407.7976840196089771957\'/><link rel=\'self\' type=\'application/atom+xml\' href=\'http://spreadsheets.google.com/feeds/spreadsheets/private/full/o12612000142644651407.7976840196089771957\'/><author><name>sforcedemos</name><email>sforcedemos@gmail.com</email></author></entry></feed>';
    
	static GoogleData fakeresult = new GoogleData( new xmldom( allSheetsTestFeed )) ;
    
    //Get a list of spreadsheets
    public static testMethod  void test_listAllSpreadsheets() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken);
        service.debug = 3;
        GoogleData sheets = service.getSpreadsheets();  // list all sheets 
        sheets.dump(); 
    }   
    
    public static testMethod  void test_worksheet_based_feedfake() {
        SpreadsheetService service = new SpreadsheetService();  
        service.setAuthSubToken(sessionAuthToken); 
        xmldom.element oneSpreadSheet = fakeresult.entries[0]; // expects one spreadsheet
 		
  		// get a new feed listing the worksheets in oneSpreadSheet
        GoogleData worksheetsFeed = service.getWorksheets( oneSpreadSheet );
        
        worksheetsFeed.dump(); 	// each worksheet is an entry

		for ( xmldom.element ws: worksheetsFeed.entries) { 
			system.debug ( GoogleData.getTitle( ws ) );	// title of each sheet
		}
  		
    }
}