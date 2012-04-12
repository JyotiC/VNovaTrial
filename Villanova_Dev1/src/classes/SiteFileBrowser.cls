public with sharing class SiteFileBrowser {
	public String myFolder {get; set;}
	public List<SelectOption> myItems {get; set;}
	
	public list<ImageFile> files {get; set;}
	public String inFolderId {get; set;}

	public SiteFileBrowser() {
		if (System.currentPageReference().getParameters().get('folder') != NULL ) {
			inFolderId = System.currentPageReference().getParameters().get('folder');
		}
		else {
			inFolderId = '0';
		}
		SiteImageBrowser.isImage = false;
		myItems = new List<SelectOption>();
		MAP<String, String> fmap = new MAP<String, String>();
		for (Folder f : [SELECT id, Name FROM Folder WHERE Name != '*' AND Name != NULL]) {
			fmap.put(f.id, f.name);
		}
		myItems.add(new SelectOption('0', 'All Documents'));
		myItems.add(new SelectOption(String.valueOf(UserInfo.getUserId()), 'Personal Documents'));
		for (String s : fmap.keySet()) {
			if ('' + fmap.get(s) != 'null') {
				myItems.add(new SelectOption(s, '' + fmap.get(s)));
			}
		}
		
		
		files = new List<ImageFile>();
		List<Document> images = new List<Document>();
		if (inFolderId != '0') {
			images = [SELECT Id, Url, Name, IsPublic, BodyLength, ContentType FROM Document WHERE IsPublic = true AND FolderId = :inFolderId];
		}
		else {
			images = [SELECT Id, Url, Name, IsPublic, BodyLength, ContentType FROM Document WHERE IsPublic = true];
		}
		for (Document loopDoc : images) {
			//if (loopDoc.ContentType == null || loopDoc.ContentType == 'image/png' || loopDoc.ContentType == 'image/jpg' || loopDoc.ContentType == 'image/jpeg' || loopDoc.ContentType == 'image/gif' ) {
				files.add(new ImageFile(loopDoc,DocumentUtil.getInstance().getURL(loopDoc)));
			//}
		}
	}
	
	static testmethod void testSiteFileBrowser() {
		// Create a Doc.
		Document doc1 = new Document();
		doc1.ContentType = 'image/png';
		doc1.Name = 'testdoc1.png';
		doc1.IsPublic = true;
		doc1.Url = 'testURL';
		doc1.FolderId = System.Userinfo.getUserId();
		
		insert doc1;
		
		// Instantiate the SFB, and look for the image that we just pushed in...
		SiteFileBrowser sfb = new SiteFileBrowser();
		List<ImageFile> imageList = sfb.files;
		
		for (ImageFile loopImage : imageList) {
			if (loopImage.doc.Name == doc1.Name) {
				System.assert(true);
			}
		}
	}
	

}