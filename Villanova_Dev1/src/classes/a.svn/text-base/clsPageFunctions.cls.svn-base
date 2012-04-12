public class clsPageFunctions {
	//Returns a list of records that is a subset of a greater list based on pagination criteria
	public static void MakePageList(List<SObject> lstSO, Integer intPage, Integer intPerPage){
		System.debug('MakePageList entered with lstSO size ' +lstSO.size() +', intPage = ' +intPage +', intPerPage = ' +intPerPage);
		List<cObject> lstPage = new List<cObject>();
		Integer intStart = 0;
		Integer intEnd = 0;
		
		intPage = (intPage <= 0 ? 1 : intPage);
		intStart = (intPerPage * intPage) - intPerPage;
		intEnd = intStart + intPerPage;
		
		for(Integer i = intStart; i < intEnd && i < lstSO.size(); i++){
			System.debug('Making page list, i = ' +i +', intStart = ' +intStart +', intEnd = ' +intEnd);
			lstPage.add(new cObject(lstSO.get(i)));	
	    }
	    
		lstSO.clear();
		for (cObject c : lstPage){
			lstSO.add(c.obj);
		}
	}
	
	//Returns the total number of pages that can be created for a list based on # per page
	public static Integer ReturnTotalPages(List<SObject> lstSO, Integer intPerPage){
		Integer intTotalPages;
		
		if (lstSO != null &&lstSO.size() > 0 &&intPerPage > 0){
			intTotalPages = Decimal.valueOf(lstSO.size().format()).divide(intPerPage,0,System.Roundingmode.CEILING).intValue();
		} else {
			intTotalPages = 0;
		}
		System.debug('Total pages is: ' +intTotalPages);
		
		return intTotalPages;
	}
	
	public class cObject{
	    sObject obj {get; set;}
	       
	    public cObject(sObject obj){
	     	this.obj = obj;	
	    }
	}
}