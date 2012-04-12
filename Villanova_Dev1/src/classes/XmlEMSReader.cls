public with sharing class XmlEMSReader {

	/*******************************
	*** Call EMS API GetBookings ***
	********************************/

    public static Integer callEmsApi(String user, String passwd, Datetime startDate, Datetime endDate, Integer batchStart, Integer batchEnd)
    {
        Integer bookingsLoaded = 0;

    	Integer[] batchStartEndArray = new Integer[] {batchStart, batchEnd};
    	VEMCallEMSWebService.ArrayOfInt batchStartEnd = new VEMCallEMSWebService.ArrayOfInt();
    	batchStartEnd.int_x = batchStartEndArray;

        String result;
        VEMCallEMSWebService.ServiceSoap s = new VEMCallEMSWebService.ServiceSoap();
        s.timeout_x = 30000;  // Increase the timeout value from the default of 10,000 milliseconds
        try
        {
            result = s.GetBookings(user, passwd, startDate, endDate, null, null, null, batchStartEnd, false);
        }
        catch (CalloutException ex)
        {
            // Try a second time; this usually avoids the timeout error...
            result = s.GetBookings(user, passwd, startDate, endDate, null, null, null, batchStartEnd, false);
        }
        //System.debug(LoggingLevel.INFO, 'res length: ' + result.length());

        bookingsLoaded = getEMSData(result);

        return bookingsLoaded;
    }//end class callEmsApi	

    /***********************************************************************
    *** Process the response from EMS by using the EMS WSDL and Apex XML ***
    ************************************************************************/
    public static Integer getEMSData(String res)
    {
      	//XmlDom doc = new XmlDom(String.escapeSingleQuotes(res));
      	XmlDom doc = new XmlDom(res);
        //System.debug(LoggingLevel.INFO, res);

        //get EMS data by Element named 'Data'
        XmlDom.Element[] elements = doc.getElementsByTagName('Data');
        //System.debug(LoggingLevel.INFO, '   Element size: ' + elements.size()); return 0;

        //get the sforce id for location insert into sforce 
        VEM_Location__c parentLoc = [SELECT Id,Approver__c FROM VEM_Location__c WHERE Name = 'Villanova Athletics' LIMIT 1];

        VEM_Location__c loc;
        Set<String> locEMSSet = new Set<String>();
        List<VEM_Location__c> locsList = new List<VEM_Location__c>();

        //get all locations used per day in a list and respective names in a set 
        //Integer counter1 = 0;
        for (XmlDom.Element element : elements)
        {
            loc = new VEM_Location__c();
            loc.Name = element.getValue('Room').trim();
            loc.Location_Type__c = '';
            loc.Zone__c = '';
            loc.Parent_Location__c = parentLoc.Id;
            loc.Approver__c = parentLoc.Approver__c;
            //loc.Capacity__c = null;

            //ToDo: Add EMS Room Id to VEM?
            ///loc.EMS_Room_ID__c = Integer.valueOf(element.getValue('RoomID'));

            locsList.add(loc);
            locEMSset.add(loc.Name);
            //System.debug(LoggingLevel.INFO, 'Location[' + counter1 + ']: ' + element.getValue('Room'));
            //counter1++;
        }

        //List<VEM_Location__c> locInSFList = [SELECT Id,Name FROM VEM_Location__c WHERE Name IN :locEMSset AND Approver__c = :parentLoc.Approver__c];
        List<VEM_Location__c> locInSFList = [SELECT Id,Name FROM VEM_Location__c WHERE Name IN :locEMSset];
        Set<String> locSFSet = new Set<String>();

        //get sf locations
		for (VEM_Location__c locSF : locInSFList)
		{
		    locSFSet.add(locSF.Name.toUpperCase());
		}

		//remove the ones that exist in SF (loop in reverse since items may be deleted)
		//for (VEM_Location__c  u : locsList)
		//System.debug(LoggingLevel.INFO, 'loclist size: ' + locsList.size());
        for (Integer i = locsList.size()-1; i >= 0; i--)
        {
            if (locSFSet.contains(locsList[i].Name.toUpperCase()))
            {
                locsList.remove(i);
            }
        }

        VEM_Event__c evt;
        String locationName;
        Datetime startDateTime;
        Datetime endDateTime;
        Integer statusTypeId;

        List<VEM_Event__c> eventsToUpsert = new List<VEM_Event__c>();
        List<VEM_Event__c> eventsToDelete = new List<VEM_Event__c>();

		//Integer counter2 = 0;
        for (XmlDom.Element element : elements)
        {
            evt = new VEM_Event__c();

            evt.Name = element.getValue('EventName').trim();
            evt.Event_Type__c = element.getValue('EventTypeDescription').trim();

            locationName = element.getValue('Room').trim();
            for (VEM_Location__c sfLoc : locInSFList)
		    {
		       if (sfLoc.name == locationName)
                   evt.Event_Location__c = sfLoc.Id;
		    }

            //ToDo: Load EMS buildings into VEM or continue to use "Villanova Athletics" as the parent for new buildings?
            //evt.Event_Location__c = element.getValue('Building').trim(); why we need this
            
            startDateTime = toDateTime(element.getValue('TimeEventStart'));
            evt.Start_Date__c = startDateTime.date();
            evt.Start_Time__c = startDateTime.format('h:mm aa');

            endDateTime = toDateTime(element.getValue('TimeEventEnd'));
            evt.End_Date__c = endDateTime.date();
            evt.End_Time__c = endDateTime.format('h:mm aa');
            
            //System.debug(LoggingLevel.INFO, 'startDateTime.date()[' + i + ']: ' + startDateTime.date());
            //System.debug(LoggingLevel.INFO, 'startDateTime.format[' + i + ']: ' + startDateTime.format('h:mm aa'));
            //System.debug(LoggingLevel.INFO, 'endDateTime.date()[' + i + ']: ' + endDateTime.date());
            //System.debug(LoggingLevel.INFO, 'endDateTime.format[' + i + ']: ' + endDateTime.format('h:mm aa'));

            evt.Event_Sponsor__c = element.getValue('GroupName').trim() + '->' + element.getValue('Contact').trim();

			evt.Expected_Volume__c = Integer.valueOf(element.getValue('SetupCount'));
            if ( evt.Expected_Volume__c < 1)
            	evt.Expected_Volume__c = 1;

            evt.EMS_Booking_ID__c = Integer.valueOf(element.getValue('BookingID'));

            //Determine event status from EMS status type ID (-14=Confirmed; -12=Cancelled)
            statusTypeId = Integer.valueOf(element.getValue('StatusTypeID'));
            if (statusTypeId == -14)
            {
            	evt.Event_Status__c = 'Approved';

                // This event is new or modified; add it to the list of events to be inserted into VEM
                eventsToUpsert.add(evt);
            }
            else if (statusTypeId == -12)
            {
                evt.Event_Status__c = 'Cancelled';

                // This event was cancelled in EMS; add it to the list of events to be deleted from VEM
                eventsToDelete.add(evt);
            }
            else
            {            	
                evt.Event_Status__c = 'Saved';

                // This event is tentative in EMS; add it to the list of events to be inserted into VEM
                eventsToUpsert.add(evt);
            }

            //counter2++;
            //System.debug(LoggingLevel.INFO, 'EventName[' + counter2 + ']: ' + element.getValue('EventName'));
        }

        insertLocationsIntoSF(locsList);
        insertEventsIntoSF(eventsToUpsert);
        deleteCancelledEventsFromSF(eventsToDelete);

		//ToDo: Need to keep track of the number of bookings retrieved from EMS; we can't use the count of events
		//      in SF with EMS_Booking_ID != null because that doesn't count the deleted events; this will cause
		//      us to process some bookings multiple times

        return elements.size();

    }//end of getEMSData method

    /***************************************
    *** insert locations into salesforce ***
    ****************************************/ 
    public static void insertLocationsIntoSF(List<VEM_Location__c> locList)
    {
        // Insert the new EMS locations
        if (locList.size() > 0)
        {
        	//ToDo: Use EMS Room Id and do an upsert?
            insert locList;
            //System.debug(LoggingLevel.INFO, 'Inserted: ' + locList.size() + ' location(s)');
        }
    }

    /************************************
    *** insert events into salesforce ***
    *************************************/ 
    public static void insertEventsIntoSF(List<VEM_Event__c> evtList)
    {
        // Upsert the new/updated EMS events
        if (evtList.size() > 0)
        {
            // Allow events to be inserted/updated without validation
            VEM_Event.isValidationRequired = false;

            upsert evtList EMS_Booking_ID__c;
            //System.debug(LoggingLevel.INFO, 'Upserted: ' + evtList.size() + ' event(s)');
        }
    }

    /**********************************************
    *** delete cancelled events from salesforce ***
    ***********************************************/ 
    public static void deleteCancelledEventsFromSF(List<VEM_Event__c> evtList)
    {
        // Delete cancelled EMS events
        if (evtList.size() > 0)
        {
            // Allow events to be inserted/updated without validation
            VEM_Event.isValidationRequired = false;

			// Put EMS_Booking_IDs into a set
			Set<Integer> bookingIds = new Set<Integer>();
			for (VEM_Event__c evt : evtList)
			{
				bookingIds.add(Integer.valueOf(evt.EMS_Booking_ID__c));
				//System.debug(LoggingLevel.INFO, '   Booking ID to Delete: ' + evt.EMS_Booking_ID__c);
			}

			// Delete events with EMS_Booking_ID that match the ones in the set
			List<VEM_Event__c> deleteList = [SELECT Id FROM VEM_Event__c WHERE EMS_Booking_ID__c IN :bookingIds];
			if (deleteList.size() > 0)
			{
				delete deleteList;
				//System.debug(LoggingLevel.INFO, 'Deleted: ' + deleteList.size() + ' event(s)');
			}
        }
    }

    /****************************************************
    *** Convert retrieved EMS times to Apex dateTime  ***
    *****************************************************/
    public static dateTime toDateTime(string s)
    {
        // EMS returns this format: 2008-06-14T10:00:00-05:00, but the values are not GMT
        // Don't use the GMT version (ignore the "T" and the "-05:00"); use the date/time as is

    	//String date = DateTime.valueOfGmt(s.substring(0,19).replace('T',' '));
        //String time = s.substring(11,19);
        //return Datetime.parse(date + ' ' + time);
        return dateTime.valueOf(s.replace('T', ' '));
    }

}//end XmlEMSReader class