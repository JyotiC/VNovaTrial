public with sharing class VEM_EventController
{

    ////////////////////////////////////////////////////////////////////
    // Dates Formatted in Eastern Standard Time (not the default GST) //
    ////////////////////////////////////////////////////////////////////

    public String todayString      { get { return todayPlus(0); } }
    public String todayPlus0String { get { return todayPlus(0); } }
    public String todayPlus1String { get { return todayPlus(1); } }
    public String todayPlus2String { get { return todayPlus(2); } }
    public String todayPlus3String { get { return todayPlus(3); } }
    public String todayPlus4String { get { return todayPlus(4); } }
    public String todayPlus5String { get { return todayPlus(5); } }
    public String todayPlus6String { get { return todayPlus(6); } }

    private String todayPlus(Integer days)
    {
        //return System.now().format('EEEE - MMMM d, yyyy h:mm a (z)');
        //return System.now().format('EEEE - MMMM d, yyyy h:mm a (z)', 'EDT');
        //return System.now().format('EEEE - MMMM d, yyyy h:mm a (z)', 'EST');
        return System.now().addDays(days).format('EEEE, MMMM d, yyyy');
    }

    ////////////////////////////////////
    // Today's Connelly Center Events //
    ////////////////////////////////////

    private static final String CONNELLY_CENTER = 'Connelly Center';
         
    public List<VEM_Event__c> eventsInConnellyToday
    {
        get
        {
            //ToDo: Look for better way to find all locations with Connelly Center as parent, grandparent, etc.
            return  [  SELECT Id, Name, Start_Time__c, End_Time__c, Event_Location__r.Name, Event_Type__c, Event_Sponsor__c
                         FROM VEM_Event__c
                        WHERE Start_Date__c = TODAY
                          AND Event_Status__c = 'Approved'
                          AND (Event_Location__r.Name = :CONNELLY_CENTER
                           OR  Event_Location__r.Parent_Location__r.Name = :CONNELLY_CENTER
                           OR  Event_Location__r.Parent_Location__r.Parent_Location__r.Name = :CONNELLY_CENTER)
                     ORDER BY Start_Date_Time__c, End_Date_Time__c, Name];
        }
    }

    public List<VEM_Event__c> getEventsInConnellyToday()
    {
        return eventsInConnellyToday;
    }

    /////////////////////////////
    // Today's Athletic Events //
    /////////////////////////////

	private final Profile athleticsApproverProfile = [ SELECT Id, Name FROM Profile WHERE Name = 'VEM Athletics User' LIMIT 1];

    private List<VEM_Event__c> m_eventsInAthleticsToday;
    public List<VEM_Event__c> eventsInAthleticsToday
    {
        get
        {
            if (m_eventsInAthleticsToday == null)
            {
                m_eventsInAthleticsToday =
                        [  SELECT Id, Name, Start_Time__c, End_Time__c, Event_Location__r.Name, Event_Type__c, Event_Sponsor__c
                                 FROM VEM_Event__c
                                WHERE Start_Date__c = TODAY
                                  AND Event_Status__c = 'Approved'
                                  AND Location_Approver__r.Profile.Id = :athleticsApproverProfile.Id
                         ORDER BY Start_Date_Time__c, End_Date_Time__c, Name];
            }
            return m_eventsInAthleticsToday;
        }
    }

    public List<VEM_Event__c> getEventsInAthleticsToday()
    {
        return eventsInAthleticsToday;
    }

    public void ClearCacheOfEventsInAthleticsToday()
    {
        m_eventsInAthleticsToday = null;
    }

    /////////////////////////////////
    // This Week's Athletic Events //
    /////////////////////////////////

    private List<VEM_Event__c> m_eventsInAthleticsThisWeek;
    public List<VEM_Event__c> eventsInAthleticsThisWeek
    {
        get
        {
            if (m_eventsInAthleticsThisWeek == null)
            {
                m_eventsInAthleticsThisWeek =
                        [  SELECT Id, Name, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Event_Location__r.Name, Event_Type__c, Event_Sponsor__c
                                 FROM VEM_Event__c
                                WHERE (Start_Date__c >= TODAY
                                  AND  Start_Date__c <= NEXT_N_DAYS:6)
                                  AND Event_Status__c = 'Approved'
                                  AND Location_Approver__r.Profile.Id = :athleticsApproverProfile.Id
                         ORDER BY Start_Date_Time__c, End_Date_Time__c, Name];
            }
            return m_eventsInAthleticsThisWeek;
        }
    }

    public List<VEM_Event__c> getEventsInAthleticsThisWeek()
    {
        return eventsInAthleticsThisWeek;
    }

    public List<VEM_Event__c> eventsInAthleticsTodayPlus0 { get { return getEventsInAthleticsTodayPlus(0); } }
    public List<VEM_Event__c> eventsInAthleticsTodayPlus1 { get { return getEventsInAthleticsTodayPlus(1); } }
    public List<VEM_Event__c> eventsInAthleticsTodayPlus2 { get { return getEventsInAthleticsTodayPlus(2); } }
    public List<VEM_Event__c> eventsInAthleticsTodayPlus3 { get { return getEventsInAthleticsTodayPlus(3); } }
    public List<VEM_Event__c> eventsInAthleticsTodayPlus4 { get { return getEventsInAthleticsTodayPlus(4); } }
    public List<VEM_Event__c> eventsInAthleticsTodayPlus5 { get { return getEventsInAthleticsTodayPlus(5); } }
    public List<VEM_Event__c> eventsInAthleticsTodayPlus6 { get { return getEventsInAthleticsTodayPlus(6); } }

	private List<VEM_Event__c> getEventsInAthleticsTodayPlus(Integer days)
	{
		Date dateFilter = Date.today().addDays(days);
		List<VEM_Event__c> filteredList = new List<VEM_Event__c>();

		for (VEM_Event__c event : eventsInAthleticsThisWeek)
		{
			if (event.Start_Date__c == dateFilter)
			{
				filteredList.add(event);
			}
		} 

		return filteredList;
	}

    public void ClearCacheOfEventsInAthleticsThisWeek()
    {
        m_eventsInAthleticsThisWeek = null;
    }

    /////////////////////////////////
    // Connelly Operations Reports //
    /////////////////////////////////

	private final Profile connellyCenterApproverProfile = [ SELECT Id, Name FROM Profile WHERE Name = 'VEM Connelly Center User' LIMIT 1];

	private Date m_connellyOperationsReportDate = defaultOperationsReportDate();
	public Date connellyOperationsReportDate
	{
		get { return m_connellyOperationsReportDate; }
		set { m_connellyOperationsReportDate = value; }
	}

	private Date m_connellyProjectionStartDate = defaultProjectionStartDate();
	public Date connellyProjectionStartDate
	{
		get { return m_connellyProjectionStartDate; }
		set { m_connellyProjectionStartDate = value; }
	}

	private Date m_connellyProjectionEndDate = defaultProjectionEndDate();
	public Date connellyProjectionEndDate
	{
		get { return m_connellyProjectionEndDate; }
		set { m_connellyProjectionEndDate = value; }
	}

	private Date defaultOperationsReportDate()
	{
		Date reportDate = Date.today();

		//try
		//{
			//Check URL parameter first (format: yyyy-mm-dd)
			String reportDateStr = ApexPages.currentPage().getParameters().get('date');
			if (reportDateStr != null)
			{
				reportDate = Date.valueOf(reportDateStr);
			}
		//}
		//catch (Exception ex)
		//{
		//	//Ignore error
		//}

		return reportDate;
	}

    private Date defaultProjectionStartDate()
    {
    	Date startDate = Date.today();

		//Check URL parameters first (format: yyyy-mm-dd)
		String startDateStr = ApexPages.currentPage().getParameters().get('start');
		if (startDateStr != null)
		{
			startDate = Date.valueOf(startDateStr);
		}

        return startDate;
    }

    private Date defaultProjectionEndDate()
    {
        //Date endDate =  connellyProjectionStartDate.addDays(14).toStartOfWeek().addDays(-1);
        Date endDate = connellyProjectionStartDate.addDays(13);

		//Check URL parameters first (format: yyyy-mm-dd)
		String endDateStr = ApexPages.currentPage().getParameters().get('end');
		if (endDateStr != null)
		{
			Date tempEndDate = Date.valueOf(endDateStr);
			if (tempEndDate >= connellyProjectionStartDate)
			{
				endDate = tempEndDate;
			}
		}

        return endDate;
    }

    public String operationsReportDateString
    {
        get
        {
            return Datetime.newInstance(connellyOperationsReportDate.year(), connellyOperationsReportDate.month(), connellyOperationsReportDate.day()).format('EEEE, MMMM d, yyyy');
        }
    }

    public String projectionDateRangeString
    {
        get
        {
            //format('MMM d, yyyy');
            return connellyProjectionStartDate.format() + ' - ' + connellyProjectionEndDate.format();
        }
    }

    private List<VEM_Event__c> m_connellyOperationsReportEvents;
    public List<VEM_Event__c> connellyOperationsReportEvents
    {
        get
        {
            if (m_connellyOperationsReportEvents == null)
            {
                m_connellyOperationsReportEvents = getConnellyOperationsEvents(connellyOperationsReportDate, connellyOperationsReportDate);
            }
            return m_connellyOperationsReportEvents;
        }
    }

    private List<VEM_Event__c> m_connellyOperationsProjectionEvents;
    public List<VEM_Event__c> connellyOperationsProjectionEvents
    {
        get
        {
            if (m_connellyOperationsProjectionEvents == null)
            {
                m_connellyOperationsProjectionEvents = getConnellyOperationsEvents(connellyProjectionStartDate, connellyProjectionEndDate);
            }
            return m_connellyOperationsProjectionEvents;
        }
    }

    private List<VEM_Event__c> getConnellyOperationsEvents(Date startDate, Date endDate)
    {
        return [  SELECT Id, Name, Event_Type__c, Event_Location__r.Name,
                         Ready_By_Time__c,
                         Start_Date__c, Start_Time__c, Start_Date_Time__c,
                         End_Date__c, End_Time__c, End_Date_Time__c,
                         Event_Sponsor__c, Sponsor_Account__c, Sponsor_Phone__c, Sponsor_Email__c,
                         Expected_Volume__c, Event_Description__c, Event_Notes__c, Recurrence_Type__c
                    FROM VEM_Event__c
                   WHERE Start_Date__c >= :startDate
                     AND End_Date__c <= :endDate
                     AND Event_Status__c = 'Approved'
                     AND Location_Approver__r.Profile.Id = :connellyCenterApproverProfile.Id
                ORDER BY Start_Date_Time__c, End_Date_Time__c, Name ];
    }

}