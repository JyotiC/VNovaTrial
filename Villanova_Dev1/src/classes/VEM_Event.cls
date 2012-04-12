/// This class contains properties and methods for Villanova University events.
///
public with sharing class VEM_Event
{
	//////////////////////
	// Event Validation //
	//////////////////////

	private static Map<Id,VEM_BlackoutDate__c> blackoutDateMap
	{
		get
		{
			if (blackoutDateMap == null)
			{
				// Get list of blackout dates
				blackoutDateMap = new Map<Id,VEM_BlackoutDate__c>
					([SELECT Start_Date__c, End_Date__c
						FROM VEM_BlackoutDate__c
					   WHERE End_Date__c >= LAST_N_DAYS:365]);
			}
			return blackoutDateMap;
		}
	}

	//Set to false to allow events in the past to be inserted or updated via DataLoader or script
	private static Boolean m_allowFutureEventsOnly = true;
	public static Boolean allowFutureEventsOnly
	{
		get { return m_allowFutureEventsOnly; }
		set { m_allowFutureEventsOnly = value; }
	}

	//Set to false to allow events to be inserted or updated via DataLoader or script
	private static Boolean m_isValidationRequired = true;
	public static Boolean isValidationRequired
	{
		get { return m_isValidationRequired; }
		set { m_isValidationRequired = value; }
	}

	public static Boolean validateEvents(List<VEM_Event__c> eventList)
	{
		Boolean isValid = true;

		if (isValidationRequired)
		{
	   		for (VEM_Event__c event : eventList)
			{
				if (!validateEventDateTimes(event) ||
				    !validateEventForBlackoutDates(event) ||
				    !validateEventLocationAvailability(event))
				{
					isValid = false;
				}
		    }
		}

	    return isValid;
	}

	public static Boolean validateEventDateTimes(VEM_Event__c event)
	{
		Boolean isValid = true;

		if (isValidationRequired)
		{
			Boolean isAllDayEvent = isAllDay(event);
			Datetime startDateTime = toDatetime(event.Start_Date__c, event.Start_Time__c, false);
			Datetime endDateTime = toDatetime(event.End_Date__c, event.End_Time__c, isAllDayEvent);
	
			if (event.End_Date__c < event.Start_Date__c)
			{
				event.End_Date__c.addError('End date cannot be earlier than the start date');
				isValid = false;
			}
			else if (event.Start_Date__c < Date.today() && allowFutureEventsOnly)
			{
				event.Start_Date__c.addError('Start date must be today or later');
				isValid = false;
			}
			else if (isAllDayEvent)
			{
				if (event.Start_Time__c != null && event.Start_Time__c != '' && event.Start_Time__c != '12:00 AM')
				{
					event.Start_Time__c.addError('Start time must be set to "None" for All-Day events');
					isValid = false;
				}
				else if (event.End_Time__c != null && event.End_Time__c != '' && event.End_Time__c != '12:00 AM')
				{
					event.End_Time__c.addError('End time must be set to "None" for All-Day events');
					isValid = false;
				}
			}
			else  // Not an all-day event
			{
				if (event.Start_Time__c == null || event.Start_Time__c == '')
				{
					event.Start_Time__c.addError('Start time is required');
					isValid = false;
				}
				else if (event.End_Time__c == null || event.End_Time__c == '')
				{
					event.End_Time__c.addError('End time is required');
					isValid = false;
				}
				else if (startDateTime <= Datetime.now() && allowFutureEventsOnly)
				{
					event.Start_Time__c.addError('Start time must be later than now');
					isValid = false;
				}
				else if (event.End_Date__c == event.Start_Date__c)
				{
					if (endDateTime <= startDateTime)
					{
						event.End_Time__c.addError('End time must be later than the start time');
						isValid = false;
					}
				}
			}
		}

		return isValid;
	}

	public static Boolean validateEventForBlackoutDates(VEM_Event__c event)
	{
		Boolean isValid = true;

		if (isValidationRequired && !event.Override_Blackout_Date__c)
		{
			for (VEM_BlackoutDate__c blackout : blackoutDateMap.values())
			{
				if (event.Start_Date__c >= blackout.Start_Date__c && event.Start_Date__c <= blackout.End_Date__c)
				{
					event.Start_Date__c.addError(getBlackoutDateMessage(blackout));
					isValid = false;
					break;
				}
				else if (event.End_Date__c >= blackout.Start_Date__c && event.End_Date__c <= blackout.End_Date__c)
				{
					event.End_Date__c.addError(getBlackoutDateMessage(blackout));
					isValid = false;
					break;
				}
			}
		}

		return isValid;
	}

	public static Boolean validateEventLocationAvailability(VEM_Event__c event)
	{
		Boolean isValid = true;

		if (isValidationRequired)
		{
			Datetime startDateTime = toDatetime(event.Start_Date__c, event.Start_Time__c, false);
			Datetime endDateTime = toDatetime(event.End_Date__c, event.End_Time__c, isAllDay(event));
	
			// List of locations for which to check availability
			Set<Id> locationIds = new Set<Id>();
	
			// Add requested location to search list
			locationIds.add(event.Event_Location__c);
	
			// Add parent location(s) to search list
			Id locationId = event.Event_Location__c;
			while (locationId != null)
			{
				// Get parent of current location
				locationId = parentIdOf(locationId);

				if (locationId != null)
				{
					// Add id to search list
					locationIds.add(locationId);
				}
			} 

			// Add child location(s) to search list
			Set<Id> parentLocationIds = new Set<Id>();
			parentLocationIds.add(event.Event_Location__c);
			Set<Id> childLocationIds;
			while (!parentLocationIds.isEmpty())
			{
				// Get children
				childLocationIds = VEM_Event.childIdsOf(parentLocationIds);

				// Clear old parent Ids
				parentLocationIds.clear();

				for (Id childLocationId : childLocationIds)
				{
					// Add id to search list
					locationIds.add(childLocationId);
	
					// Prepare for next search
					parentLocationIds.add(childLocationId);
				} 
			}

			// Add location groups to search list
			for (VEM_Location_Group__c locationGroup : locationGroupMap.values())
			{
				if (event.Event_Location__c == locationGroup.Group__c)
				{
					locationIds.add(locationGroup.Location__c);
				}
				if (event.Event_Location__c == locationGroup.Location__c)
				{
					locationIds.add(locationGroup.Group__c);
				}
			}

			// Check location availability
			Map<Id,VEM_Event__c> eventMap = new Map<Id,VEM_Event__c>
				([SELECT Name, Start_Date__c, Start_Time__c, Start_Date_Time__c, End_Date__c, End_Time__c, End_Date_Time__c
					FROM VEM_Event__c
				   WHERE Event_Location__c IN :locationIds
					 AND Id != :event.Id
					 AND ( (Start_Date_Time__c <= :startDateTime AND End_Date_Time__c > :startDateTime)
					  OR   (Start_Date_Time__c < :endDateTime AND End_Date_Time__c >= :endDateTime)
					  OR   (Start_Date_Time__c >= :startDateTime AND End_Date_Time__c <= :endDateTime) )]);
	
			// Report location conflicts to user
			for (VEM_Event__c foundEvent : eventMap.values())
			{
				if (foundEvent.Start_Date__c == foundEvent.End_Date__c)
				{
					event.Event_Location__c.addError('This location is already in use on ' + foundEvent.Start_Date__c.format() + ' from ' + foundEvent.Start_Time__c + ' to ' + foundEvent.End_Time__c);
					isValid = false;
				}
				else
				{
					event.Event_Location__c.addError('This location is already in use from ' + foundEvent.Start_Date_Time__c.format() + ' to ' + foundEvent.End_Date_Time__c.format());
					isValid = false;
				}
			}
		}

		return isValid;
	}

	private static String getBlackoutDateMessage(VEM_BlackoutDate__c blackout)
	{
		if (blackout.Start_Date__c == blackout.End_Date__c)
		{
			return 'Event cannot be scheduled during blackout date on ' + blackout.Start_Date__c.format();
		}
		else
		{
			return 'Event cannot be scheduled during blackout dates from ' + blackout.Start_Date__c.format() + ' to ' + blackout.End_Date__c.format();
		}
	}

	private static Map<Id,VEM_Location__c> locationMap
	{
		get
		{
			if (locationMap == null)
			{
				locationMap = new Map<Id,VEM_Location__c>
					([SELECT Id, Name, Parent_Location__c, Approver__c
						FROM VEM_Location__c]);
			}
			return locationMap;
		}
	}

	private static Id parentIdOf(Id locationId)
	{
		Id parentId = null;

		VEM_Location__c parentLocation = locationMap.get(locationId);
		if (parentLocation != null)
		{
			parentId = parentLocation.Parent_Location__c;
		}

		return parentId;
	}

	private static Set<Id> childIdsOf(Set<Id> parentIds)
	{
		Set<Id> childIds = new Set<Id>();

		for (Id parentId : parentIds)
		{
			for (VEM_Location__c parentLocation : locationMap.values())
			{
				if (parentId == parentLocation.Parent_Location__c)
				{
					childIds.add(parentLocation.Id);
				}
			}
		}

		return childIds;
	}

	private static Map<Id,VEM_Location_Group__c> locationGroupMap
	{
		get
		{
			if (locationGroupMap == null)
			{
				locationGroupMap = new Map<Id,VEM_Location_Group__c>
					([SELECT Group__c, Location__c
						FROM VEM_Location_Group__c]);
			}
			return locationGroupMap;
		}
	}

	///////////////////////////
	// Event Synchronization //
	///////////////////////////

	public static void syncEventDateTime_OnInsert(List<VEM_Event__c> eventList)
	{
		// Construct start/end date/time fields from separate date and time fields
		for (VEM_Event__c newEvent : eventList)
		{
			newEvent.Start_Date_Time__c = toDatetime(newEvent.Start_Date__c, newEvent.Start_Time__c, false);
			newEvent.End_Date_Time__c = toDatetime(newEvent.End_Date__c, newEvent.End_Time__c, isAllDay(newEvent));

			newEvent.Ready_By_Time__c = newEvent.Start_Date_Time__c.addMinutes(-15).format('h:mm a');
		}
	}

	public static void syncEventDateTime_OnUpdate(List<VEM_Event__c> oldEventList, List<VEM_Event__c> newEventList)
	{
        VEM_Event__c oldEvent;
        VEM_Event__c newEvent;
		Integer eventCount = oldEventList.size();

		// Update event(s)
        for (Integer i = 0; i < eventCount; i++)
        {
        	oldEvent = oldEventList[i];
            newEvent = newEventList[i];

			// Check to see if we need to sync start date/time to start date and start time
        	if (oldEvent.Start_Date__c == newEvent.Start_Date__c &&
        	    oldEvent.Start_Time__c == newEvent.Start_Time__c &&
        	    oldEvent.Start_Date_Time__c != newEvent.Start_Date_Time__c)
        	{
        		// Copy the date/time into the separate date and time fields
        	    newEvent.Start_Date__c = newEvent.Start_Date_Time__c.date();
        	    newEvent.Start_Time__c = newEvent.Start_Date_Time__c.format('hh:mm aa');
        	}

			// Check to see if we need to sync end date/time to end date and end time
        	if (oldEvent.End_Date__c == newEvent.End_Date__c &&
        	    oldEvent.End_Time__c == newEvent.End_Time__c &&
        	    oldEvent.End_Date_Time__c != newEvent.End_Date_Time__c)
        	{
        		// Copy the date/time into the separate date and time fields
        	    newEvent.End_Date__c = newEvent.End_Date_Time__c.date();
        	    newEvent.End_Time__c = newEvent.End_Date_Time__c.format('hh:mm aa');
        	}
        }

		// Sync for insert too
        syncEventDateTime_OnInsert(newEventList);
	}

	public static Datetime toDatetime(Date inDate, String inTimeString, Boolean isAllDayEndDate)
	{
		Date outDate;
		String outTimeString;

		if (inTimeString == null || inTimeString.trim() == '')
		{
			Integer daysToAdd;
			if (isAllDayEndDate)
			{
				daysToAdd = 1;
			}
			else
			{
				daysToAdd = 0;
			}
			outDate = inDate.addDays(daysToAdd);
			outTimeString = '12:00 AM';
		}
		else
		{
			outDate = inDate;
			outTimeString = inTimeString;
		}

		return Datetime.parse(outDate.format() + ' ' + outTimeString);
	}

	public static Boolean isAllDay(VEM_Event__c event)
	{
		return event.Time_Interval__c == null || event.Time_Interval__c == '';
	}

	////////////////////////////
	// Sync Location Approver //
	////////////////////////////

	public static void syncLocationApprover(List<VEM_Event__c> eventList)
	{
		//Note: Can't use this because relationships aren't setup at this point
		//for (VEM_Event__c newEvent : eventList)
		//{
		//	newEvent.Location_Approver__c = newEvent.Event_Location__r.Approver__c;
		//}

		for (VEM_Event__c newEvent : eventList)
		{
			newEvent.Location_Approver__c = locationMap.get(newEvent.Event_Location__c).Approver__c;
		}
	}

	///////////////////////
	// Default Resources //
	///////////////////////

	private static Map<Id,VEM_Location_Resource__c> locationResourceMap
	{
		get
		{
			if (locationResourceMap == null)
			{
				locationResourceMap = new Map<Id,VEM_Location_Resource__c>
					([SELECT Location__c, Resource__c, Quantity__c
						FROM VEM_Location_Resource__c]);
			}
			return locationResourceMap;
		}
	}

	public static void addDefaultResourcesByLocation(List<VEM_Event__c> oldEventList, List<VEM_Event__c> newEventList)
	{
		Boolean defaultResources;
		VEM_Event__c oldEvent;
		VEM_Event__c newEvent;
		VEM_Event_Resource__c eventResource; 

		// Add the default resources for the selected location to each event
		for (Integer i = 0; i < newEventList.size(); i++)
        {
        	newEvent = newEventList[i];

			// Only default resources for inserts and updates when the location changed
        	defaultResources = true;
        	if (oldEventList != null)
        	{
        		// It's an update
        		oldEvent = oldEventList[i];
        		if (oldEvent.Event_Location__c == newEvent.Event_Location__c)
        		{
        			// The location did not change
        			defaultResources = false;
        		}
        	}

			if (defaultResources)
			{
	        	for (VEM_Location_Resource__c locationResource : locationResourceMap.values())
	        	{
	        		if (newEvent.Event_Location__c == locationResource.Location__c)
	        		{
	        			eventResource = new VEM_Event_Resource__c();
	        			eventResource.Events__c = newEvent.Id;
	        			eventResource.Resource__c = locationResource.Resource__c;
	        			eventResource.Quantity__c = locationResource.Quantity__c;
	        			insert eventResource;
	        		}
	        	}
			}
        }
	}

	//////////////////////
	// Event Recurrence //
	//////////////////////

	public static Boolean validateEventRecurrence(List<VEM_Event__c> eventList)
	{
		Boolean isValid = true;

		for (VEM_Event__c event : eventList)
		{
			if (event.Recurrence_Type__c == 'Daily')
			{
				if (event.Recurrence_Daily_Type__c == null || event.Recurrence_Daily_Type__c == '')
				{
					event.Recurrence_Daily_Type__c.addError('Please select an option for the daily recurrence');
					isValid = false;
				}
				else if (event.Recurrence_Daily_Type__c == 'Every X day(s)')
				{
					if (event.Recurrence_Days__c == null)
					{
						event.Recurrence_Days__c.addError('Please enter the number of days for the recurrence');
						isValid = false;
					}
					else if (event.Recurrence_Days__c < 1 || event.Recurrence_Days__c > 365)
					{
						event.Recurrence_Days__c.addError('Please enter a number between 1 and 365');
						isValid = false;
					}
				}
			}
			else if (event.Recurrence_Type__c == 'Weekly')
			{
				if (event.Recurrence_Weeks__c == null)
				{
					event.Recurrence_Weeks__c.addError('Please enter the number of weeks for the recurrence');
					isValid = false;
				}
				else if (event.Recurrence_Weeks__c < 1 || event.Recurrence_Weeks__c > 52)
				{
					event.Recurrence_Weeks__c.addError('Please enter a number between 1 and 52');
					isValid = false;
				}

				if (!event.Recurrence_Sunday__c && !event.Recurrence_Monday__c && !event.Recurrence_Tuesday__c &&
					!event.Recurrence_Wednesday__c && !event.Recurrence_Thursday__c && !event.Recurrence_Friday__c &&
					!event.Recurrence_Saturday__c)
				{
					event.Recurrence_Saturday__c.addError('Please select at least one day of the week');
					isValid = false;
				}
			}
			else if (event.Recurrence_Type__c == 'Monthly')
			{
				if (event.Recurrence_Monthly_Type__c == null || event.Recurrence_Monthly_Type__c == '')
				{
					event.Recurrence_Monthly_Type__c.addError('Please select an option for the recurrence');
					isValid = false;
				}
				else if (event.Recurrence_Monthly_Type__c == 'Day X of every Y month(s)')
				{
					if (event.Recurrence_Day_Of_Month__c == null)
					{
						event.Recurrence_Day_Of_Month__c.addError('Please enter the day of the month for the recurrence');
						isValid = false;
					}
					else if (event.Recurrence_Day_Of_Month__c < 1 || event.Recurrence_Day_Of_Month__c > 31)
					{
						event.Recurrence_Day_Of_Month__c.addError('Please enter a number between 1 and 31');
						isValid = false;
					}

					if (event.Recurrence_Months1__c == null)
					{
						event.Recurrence_Months1__c.addError('Please enter the number of months for the recurrence');
						isValid = false;
					}
					else if (event.Recurrence_Months1__c < 1 || event.Recurrence_Months1__c > 12)
					{
						event.Recurrence_Months1__c.addError('Please enter a number between 1 and 12');
						isValid = false;
					}
				}
				else if (event.Recurrence_Monthly_Type__c == 'The X Y of every Z month(s)')
				{
					if (event.Recurrence_Monthly_Day_List1__c == null || event.Recurrence_Monthly_Day_List1__c == '')
					{
						event.Recurrence_Monthly_Day_List1__c.addError('Please select day of the month for the recurrence');
						isValid = false;
					}

					if (event.Recurrence_Monthly_Day_List2__c == null || event.Recurrence_Monthly_Day_List2__c == '')
					{
						event.Recurrence_Monthly_Day_List2__c.addError('Please select day of the month for the recurrence');
						isValid = false;
					}

					if (event.Recurrence_Months2__c == null)
					{
						event.Recurrence_Months2__c.addError('Please enter the number of months for the recurrence');
						isValid = false;
					}
					else if (event.Recurrence_Months2__c < 1 || event.Recurrence_Months2__c > 12)
					{
						event.Recurrence_Months2__c.addError('Please enter a number between 1 and 12');
						isValid = false;
					}
				}
			}
			else if (event.Recurrence_Type__c == 'Yearly')
			{
				if (event.Recurrence_Yearly_Type__c == null || event.Recurrence_Yearly_Type__c == '')
				{
					event.Recurrence_Yearly_Type__c.addError('Please select an option for the recurrence');
					isValid = false;
				}
				else if (event.Recurrence_Yearly_Type__c == 'Every X Y')
				{
					if (event.Recurrence_Yearly_Month_List1__c == null || event.Recurrence_Yearly_Month_List1__c == '')
					{
						event.Recurrence_Yearly_Month_List1__c.addError('Please select the month for the recurrence');
						isValid = false;
					}

					if (event.Recurrence_Yearly_Day__c == null)
					{
						event.Recurrence_Yearly_Day__c.addError('Please enter the day of the month for the recurrence');
						isValid = false;
					}
					else if (event.Recurrence_Yearly_Day__c < 1 || event.Recurrence_Yearly_Day__c > 31)
					{
						event.Recurrence_Yearly_Day__c.addError('Please enter a number between 1 and 31');
						isValid = false;
					}
				}
				else if (event.Recurrence_Yearly_Type__c == 'The X Y of Z')
				{
					if (event.Recurrence_Yearly_Day_List1__c == null || event.Recurrence_Yearly_Day_List1__c == '')
					{
						event.Recurrence_Yearly_Day_List1__c.addError('Please select day of the month for the recurrence');
						isValid = false;
					}

					if (event.Recurrence_Yearly_Day_List2__c == null || event.Recurrence_Yearly_Day_List2__c == '')
					{
						event.Recurrence_Yearly_Day_List2__c.addError('Please select day of the month for the recurrence');
						isValid = false;
					}

					if (event.Recurrence_Yearly_Month_List2__c == null || event.Recurrence_Yearly_Month_List2__c == '')
					{
						event.Recurrence_Yearly_Month_List2__c.addError('Please select the month for the recurrence');
						isValid = false;
					}
				}
			}

			// Ensure that the recurrence start/end date is >= the event start/end date
			if (event.Recurrence_Type__c != null && event.Recurrence_Type__c != '')
			{
				if (event.Recurrence_Start_Date__c < event.Start_Date__c)
				{
					event.Recurrence_Start_Date__c.addError('Recurrence start date cannot be before the event start date of ' + event.Start_Date__c.format());
					isValid = false;
				}
				if (event.Recurrence_End_Date__c < event.Recurrence_Start_Date__c)
				{
					event.Recurrence_End_Date__c.addError('Recurrence end date cannot be before the recurrence start date');
					isValid = false;
				}
			}
		}

		return isValid;
	}

	public static void clearUnselectedRecurrenceOptions(VEM_Event__c event)
	{
		if (event.Recurrence_Type__c != 'Daily')
		{
			event.Recurrence_Daily_Type__c = null;
		}
		if ((event.Recurrence_Type__c != 'Daily') ||
			(event.Recurrence_Type__c == 'Daily' && event.Recurrence_Daily_Type__c != 'Every X day(s)'))
		{
			event.Recurrence_Days__c = null;
		}

		if (event.Recurrence_Type__c != 'Weekly')
		{
			event.Recurrence_Weeks__c = null;
			event.Recurrence_Sunday__c = false;
			event.Recurrence_Monday__c = false;
			event.Recurrence_Tuesday__c = false;
			event.Recurrence_Wednesday__c = false;
			event.Recurrence_Thursday__c = false;
			event.Recurrence_Friday__c = false;
			event.Recurrence_Saturday__c = false;
		}

		if (event.Recurrence_Type__c != 'Monthly')
		{
			event.Recurrence_Monthly_Type__c = null;
		}
		if ((event.Recurrence_Type__c != 'Monthly') ||
			(event.Recurrence_Type__c == 'Monthly' && event.Recurrence_Monthly_Type__c != 'Day X of every Y month(s)'))
		{
			event.Recurrence_Day_Of_Month__c = null;
			event.Recurrence_Months1__c = null;
		}
		if ((event.Recurrence_Type__c != 'Monthly') ||
			(event.Recurrence_Type__c == 'Monthly' && event.Recurrence_Monthly_Type__c != 'The X Y of every Z month(s)'))
		{
			event.Recurrence_Monthly_Day_List1__c = null;
			event.Recurrence_Monthly_Day_List2__c = null;
			event.Recurrence_Months2__c = null;
		}

		if (event.Recurrence_Type__c != 'Yearly')
		{
			event.Recurrence_Yearly_Type__c = null;
		}
		if ((event.Recurrence_Type__c != 'Yearly') ||
			(event.Recurrence_Type__c == 'Yearly' && event.Recurrence_Yearly_Type__c != 'Every X Y'))
		{
			event.Recurrence_Yearly_Month_List1__c = null;
			event.Recurrence_Yearly_Day__c = null;
		}
		if ((event.Recurrence_Type__c != 'Yearly') ||
			(event.Recurrence_Type__c == 'Yearly' && event.Recurrence_Yearly_Type__c != 'The X Y of Z'))
		{
			event.Recurrence_Yearly_Day_List1__c = null;
			event.Recurrence_Yearly_Day_List2__c = null;
			event.Recurrence_Yearly_Month_List2__c = null;
		}
	}

	public static void clearUnselectedRecurrenceOptions(List<VEM_Event__c> eventList)
	{
		for (VEM_Event__c event : eventList)
		{
			clearUnselectedRecurrenceOptions(event);
		}
	}

	public static void addRecurringEvents(List<VEM_Event__c> eventList)
	{
		for (VEM_Event__c event : eventList)
		{
			List<Date> recurrenceDateList = new List<Date>();

			if (event.Recurrence_Type__c == 'Daily')
			{
				for (Date dt = event.Recurrence_Start_Date__c; dt <= event.Recurrence_End_Date__c; dt = dt.addDays(1))
				{
					if ((event.Recurrence_Daily_Type__c == 'Every X day(s)') ||
					    (event.Recurrence_Daily_Type__c == 'Every weekday' && isWeekday(dt)))
					{
						recurrenceDateList.add(dt);
					}
				}
			}
			else if (event.Recurrence_Type__c == 'Weekly')
			{
				Integer dayIncrement = 7 * event.Recurrence_Weeks__c.intValue();
				for (Date dt = event.Recurrence_Start_Date__c.toStartOfWeek(); dt <= event.Recurrence_End_Date__c.toStartOfWeek(); dt = dt.addDays(dayIncrement))
				{
					if (event.Recurrence_Sunday__c) { recurrenceDateList.add(dt); }
					if (event.Recurrence_Monday__c) { recurrenceDateList.add(dt.addDays(1)); }
					if (event.Recurrence_Tuesday__c) { recurrenceDateList.add(dt.addDays(2)); }
					if (event.Recurrence_Wednesday__c) { recurrenceDateList.add(dt.addDays(3)); }
					if (event.Recurrence_Thursday__c) { recurrenceDateList.add(dt.addDays(4)); }
					if (event.Recurrence_Friday__c) { recurrenceDateList.add(dt.addDays(5)); }
					if (event.Recurrence_Saturday__c) { recurrenceDateList.add(dt.addDays(6)); }
				}
			}
			else if (event.Recurrence_Type__c == 'Monthly')
			{
				if (event.Recurrence_Monthly_Type__c == 'Day X of every Y month(s)')
				{
					Date startDate = Date.newInstance(event.Recurrence_Start_Date__c.year(), event.Recurrence_Start_Date__c.month(), event.Recurrence_Day_Of_Month__c.intValue());
					for (Date dt = startDate; dt <= event.Recurrence_End_Date__c; dt = dt.addMonths(event.Recurrence_Months1__c.IntValue()))
					{
						recurrenceDateList.add(dt);
					}
				}
				else if (event.Recurrence_Monthly_Type__c == 'The X Y of every Z month(s)')
				{
					Date startDate = event.Recurrence_Start_Date__c.toStartOfMonth();
					for (Date dt = startDate; dt <= event.Recurrence_End_Date__c; dt = dt.addMonths(event.Recurrence_Months2__c.IntValue()))
					{
						recurrenceDateList.add(selectedDate(event.Recurrence_Monthly_Day_List1__c, event.Recurrence_Monthly_Day_List2__c, dt));
					}
				}
			}
			else if (event.Recurrence_Type__c == 'Yearly')
			{
				if (event.Recurrence_Yearly_Type__c == 'Every X Y')
				{
					Date startDate = Date.newInstance(event.Recurrence_Start_Date__c.year(), monthValueOf(event.Recurrence_Yearly_Month_List1__c), event.Recurrence_Yearly_Day__c.intValue());
					for (Date dt = startDate; dt <= event.Recurrence_End_Date__c; dt = dt.addYears(1))
					{
						recurrenceDateList.add(dt);
					}
				}
				else if (event.Recurrence_Yearly_Type__c == 'The X Y of Z')
				{
					Date startDate = Date.newInstance(event.Recurrence_Start_Date__c.year(), monthValueOf(event.Recurrence_Yearly_Month_List2__c), 1);
					for (Date dt = startDate; dt <= event.Recurrence_End_Date__c; dt = dt.addYears(1))
					{
						recurrenceDateList.add(selectedDate(event.Recurrence_Yearly_Day_List1__c, event.Recurrence_Yearly_Day_List2__c, dt));
					}
				}
			}

			// Create the recurring events
			createRecurringEvents(event, recurrenceDateList);
		}
	}

	public static void removeRecurringEvents(List<VEM_Event__c> eventList)
	{
		for (VEM_Event__c event : eventList)
		{
			if (event.Recurrence_Type__c != null && event.Recurrence_Type__c != '')
			{
				List<VEM_Event__c> deleteEventList = [SELECT Id FROM VEM_Event__c WHERE Recurrence_Parent_Event__c = :event.Id];
				for (VEM_Event__c deleteEvent : deleteEventList)
				{
					delete deleteEvent;
				}
			}
		}
	}

	public static Boolean isWeekday(Date inDate)
	{
		if (inDate == inDate.toStartOfWeek() || inDate.addDays(-6) == inDate.toStartOfWeek()) 
		{
			return false;
		}
		return true;
	}

	public static Boolean isWeekday(Datetime inDate)
	{
		if (inDate.format('E') == 'Sun' || inDate.format('E') == 'Sat') 
		{
			return false;
		}
		return true;
	}

	private static void createRecurringEvents(VEM_Event__c event, List<Date> dateList)
	{
		// Compute the event length in days
		Integer eventLength = event.Start_Date__c.daysBetween(event.End_Date__c);

		// Loop through the list of dates
		for (Date dt : dateList)
		{
			// Ensure the parent is the first event in the recurrence
			if (dt > event.Start_Date__c && dt >= event.Recurrence_Start_Date__c)
			{
				// Create a recurring event
				VEM_Event__c newEvent = event.clone(false);
				newEvent.Recurrence_Type__c = null;
				clearUnselectedRecurrenceOptions(newEvent);
				newEvent.Start_Date__c = dt;
				newEvent.End_Date__c = dt.addDays(eventLength);
				newEvent.Recurrence_Parent_Event__c = event.Id;
				insert newEvent;
			}
		}
	}

	public static Date selectedDate(String daySequence, String dayOfWeek, Date sourceDate)
	{
		Date targetDate = null;

		Date firstDayOfMonth = sourceDate.toStartOfMonth();
		if (dayOfWeek == 'Day')
		{
			// Locate target day
			if (daySequence == 'First') { targetDate = firstDayOfMonth; }
			else if (daySequence == 'Second') { targetDate = firstDayOfMonth.addDays(1); }
			else if (daySequence == 'Third') { targetDate = firstDayOfMonth.addDays(2); }
			else if (daySequence == 'Fourth') { targetDate = firstDayOfMonth.addDays(3); }
			else if (daySequence == 'Last') { targetDate = lastDayOfMonth(sourceDate); }				
		}
		else
		{
			// Set target counter
			Integer targetCount = 0;
			if (daySequence == 'First') { targetCount = 1; }
			else if (daySequence == 'Second') { targetCount = 2; }
			else if (daySequence == 'Third') { targetCount = 3; }
			else if (daySequence == 'Fourth') { targetCount = 4; }
			else if (daySequence == 'Last') { targetCount = 5; }

			// Locate target day in the first week
			Date dt;
			Integer currentCount = 0;
			Date lastDayOfFirstWeek = firstDayOfMonth.addDays(6);
			for (dt = firstDayOfMonth; dt <= lastDayOfFirstWeek; dt = dt.addDays(1))
			{
				DateTime dtm = Datetime.newInstance(dt.year(), dt.month(), dt.day());
				if (dtm.format('EEEE') == dayOfWeek)
				{
					currentCount++;
					break;
				}
			}

			// Locate target day in the target week
			Date nextDate;
			while (currentCount < targetCount)
			{
				nextDate = dt.addDays(7);
				if (nextDate.month() == dt.month())
				{
					dt = nextDate;
				}
				currentCount++;
			}

			targetDate = dt;
		}

		return targetDate;
	}

	public static Date lastDayOfMonth(Date dt)
	{
		return dt.toStartOfMonth().addMonths(1).addDays(-1);
	}

	public static Integer monthValueOf(String monthName)
	{
		Integer monthValue = null;

		String month = monthName.toUpperCase();
		if (month.startsWith('JAN')) { monthValue = 1; }
		else if (month.startsWith('FEB')) { monthValue = 2; }
		else if (month.startsWith('MAR')) { monthValue = 3; }
		else if (month.startsWith('APR')) { monthValue = 4; }
		else if (month.startsWith('MAY')) { monthValue = 5; }
		else if (month.startsWith('JUN')) { monthValue = 6; }
		else if (month.startsWith('JUL')) { monthValue = 7; }
		else if (month.startsWith('AUG')) { monthValue = 8; }
		else if (month.startsWith('SEP')) { monthValue = 9; }
		else if (month.startsWith('OCT')) { monthValue = 10; }
		else if (month.startsWith('NOV')) { monthValue = 11; }
		else if (month.startsWith('DEC')) { monthValue = 12; }

		return monthValue;
	}

}