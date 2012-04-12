global class VEMEMSAPI implements Schedulable {

	global static void execute(SchedulableContext SC)
	{
		try
		{
			// Asynchronously load EMS bookings
			loadEmsBookingsAsync();

			// Remove scheduled jobs that have completed
			removeCompletedScheduledJobs();
		}
		catch (Exception ex)
        {
        	sendEmail('arben.dodbiba@villanova.edu', 'krensc01@villanova.edu', 'VEMEMSAPI Error (000)', 'VEMEMSAPI Error (000): ' + ex.getMessage());
			System.debug('VEMEMSAPI Error (000): ' + ex.getMessage());
        }
	}

	@future (callout=true)
	private static void loadEmsBookingsAsync()
	{
		// Load EMS bookings
		loadEmsBookings();
	}

	public static void loadEmsBookings()
	{
		try
		{
			// Compute date range of bookings to retrieve
			DateRange bookingDateRange = computeBookingDateRange();

			// Compute batch record range
			RecordRange batchRecordRange = computeBatchRecordRange();

			// Load EMS batch
			// Note: All callouts must be executed before any DML statements (insert/update/delete)
			Integer bookingsLoaded = XmlEMSReader.callEmsApi('emsapiuser', 'salesforce',
															 bookingDateRange.startDate, bookingDateRange.endDate,
															 batchRecordRange.firstRecord, batchRecordRange.lastRecord);
			//System.debug(LoggingLevel.INFO, 'Loaded: ' + bookingsLoaded + ' EMS Booking(s)');

			// Schedule additional job (if needed)
			scheduleNextJob(bookingsLoaded);
		}
		catch (loadEmsBookingsException ex)
		{
        	sendEmail('arben.dodbiba@villanova.edu', 'krensc01@villanova.edu', 'VEMEMSAPI Error (001)', 'VEMEMSAPI Error (001): ' + ex.getMessage());
			System.debug('VEMEMSAPI Error (001): ' + ex.getMessage());
		}
        catch (CalloutException ex)
        {
        	sendEmail('arben.dodbiba@villanova.edu', 'krensc01@villanova.edu', 'VEMEMSAPI Error calling API (002)', 'VEMEMSAPI Error calling API (002): ' + ex.getMessage());
			System.debug('VEMEMSAPI Error calling API (002): ' + ex.getMessage());
        }
		catch (Exception ex)
        {
        	sendEmail('arben.dodbiba@villanova.edu', 'krensc01@villanova.edu', 'VEMEMSAPI Error (003)', 'VEMEMSAPI Error (003): ' + ex.getMessage());
			System.debug('VEMEMSAPI Error (003): ' + ex.getMessage());
        }
	}

	private class DateRange
	{
		Datetime startDate;
		Datetime endDate;
	}

	private class RecordRange
	{
		Integer firstRecord;
		Integer lastRecord;
	}

	// The number of records in a batch
	private static Integer m_batchSize = null;
	public static Integer batchSize
	{
		get
		{
			if (m_batchSize == null)
			{
				m_batchSize = 50;
				try
				{
					Map<String,VemEmsSyncJobSetting__c> settingMap = VemEmsSyncJobSetting__c.getAll();
					VemEmsSyncJobSetting__c setting = settingMap.get('BatchSize');
					Integer integerValue = Integer.valueOf(setting.Value__c);
					if (integerValue > 0)
					{
						m_batchSize = integerValue;
					}
				}
				catch (Exception ex)
				{
					// Use default value...
				}
			}
			return m_batchSize;
		}
	}

	// The minimum number of minutes to wait before submitting another batch
	private static Integer m_batchDelayInMinutes = null;
	public static Integer batchDelayInMinutes
	{
		get
		{
			if (m_batchDelayInMinutes == null)
			{
				m_batchDelayInMinutes = 10;
				try
				{
					Map<String,VemEmsSyncJobSetting__c> settingMap = VemEmsSyncJobSetting__c.getAll();
					VemEmsSyncJobSetting__c setting = settingMap.get('BatchDelayInMinutes');
					Integer integerValue = Integer.valueOf(setting.Value__c);
					if (integerValue > 0)
					{
						m_batchDelayInMinutes = integerValue;
					}
				}
				catch (Exception ex)
				{
					// Use default value...
				}
			}
			return m_batchDelayInMinutes;
		}
	}

	private static final Date YESTERDAY = Date.today().addDays(-1);

	// The start date of the range of bookings to retrieve
	private static Date m_bookingStartDate = null;
	public static Date bookingStartDate
	{
		get
		{
			if (m_bookingStartDate == null)
			{
				m_bookingStartDate = YESTERDAY;
				try
				{
					Map<String,VemEmsSyncJobSetting__c> settingMap = VemEmsSyncJobSetting__c.getAll();
					VemEmsSyncJobSetting__c setting = settingMap.get('StartDateOverride');
					m_bookingStartDate = Date.parse(setting.Value__c);
				}
				catch (Exception ex)
				{
					// Use default value...
				}
			}
			return m_bookingStartDate;
		}
	}

	// The start date of the range of bookings to retrieve
	private static Date m_bookingEndDate = null;
	public static Date bookingEndDate
	{
		get
		{
			if (m_bookingEndDate == null)
			{
				m_bookingEndDate = YESTERDAY;
				try
				{
					Map<String,VemEmsSyncJobSetting__c> settingMap = VemEmsSyncJobSetting__c.getAll();
					VemEmsSyncJobSetting__c setting = settingMap.get('EndDateOverride');
					m_bookingEndDate = Date.parse(setting.Value__c);
				}
				catch (Exception ex)
				{
					// Use default value...
				}
			}
			return m_bookingEndDate;
		}
	}

	public class loadEmsBookingsException extends Exception	{}

	private static DateRange computeBookingDateRange()
	{
		DateRange bookingDateRange = new DateRange();

		// Validate start/end dates
		Date startDate = bookingStartDate;
		Date endDate = bookingEndDate;
		if (startDate == null || endDate == null || bookingStartDate > bookingEndDate)
		{
			//startDate = YESTERDAY;
			//endDate = YESTERDAY;
			throw new loadEmsBookingsException('computeBookingDateRange Start/End Date Error: Start or end date is null or start date is after the end date');
		}

		// Convert start/end dates to date/times
		bookingDateRange.startDate = Datetime.newInstance(startDate.year(), startDate.month(), startDate.day());
		bookingDateRange.endDate = Datetime.newInstance(endDate.year(), endDate.month(), endDate.day());
		//System.debug(LoggingLevel.INFO, '   Booking Start/End Dates: ' + bookingDateRange.startDate.format() + '/' + bookingDateRange.endDate.format());

		return bookingDateRange;
	}

	private static RecordRange computeBatchRecordRange()
	{
		RecordRange batchRecordRange = new RecordRange();

		// Get count of EMS records already processed
		//List<AggregateResult> results =
		//   [  SELECT count(Id) RecordsProcessed
		//		FROM VEM_Event__c
		//	   WHERE EMS_Booking_ID__c != null
		//		 AND LastModifiedDate = TODAY
		//	GROUP BY DAY_ONLY(LastModifiedDate)];

		// Determine number of records processed
		//Integer alreadyProcessed = 0;
		//if (results != null && results.size() > 0)
		//{
		//	alreadyProcessed = Integer.valueOf(results[0].get('RecordsProcessed'));
		//}

		// Determine number of records processed
		Integer alreadyProcessed = bookingsProcessed;

		// Set record range
		batchRecordRange.firstRecord = alreadyProcessed + 1;
		batchRecordRange.lastRecord = alreadyProcessed + batchSize;

		return batchRecordRange;
	}

	private static Integer bookingsProcessed
	{
		get
		{
			Integer processed = 0;
			try
			{
				Map<String,VemEmsSyncJobSetting__c> settingMap = VemEmsSyncJobSetting__c.getAll();
				VemEmsSyncJobSetting__c setting = settingMap.get('BookingsProcessed');
				if (setting != null)
				{
					processed = Integer.valueOf(setting.Value__c);
				}
			}
			catch (Exception ex)
			{
				// Use default value...
			}
			return processed;
		}
		set
		{
			Map<String,VemEmsSyncJobSetting__c> settingMap = VemEmsSyncJobSetting__c.getAll();
			VemEmsSyncJobSetting__c setting = settingMap.get('BookingsProcessed');
			if (setting == null)
			{
				setting = new VemEmsSyncJobSetting__c();
			}
			setting.Name = 'BookingsProcessed';
			setting.Value__c = String.valueOf(value);
			setting.Description__c = 'Used to track number of records processed';
			upsert setting;
		}
	}

	public static void scheduleNextJob(Integer bookingsLoaded)
	{
		//Update and save processed count
		bookingsProcessed += bookingsLoaded;

		if (bookingsLoaded < batchSize)
		{
			//Send success email
			sendEmail('arben.dodbiba@villanova.edu', 'krensc01@villanova.edu', 'VEMEMSAPI Success',
								   'Processed ' + bookingsProcessed + ' records for ' + bookingStartDate.format() + '-' + bookingEndDate.format());

			//Clear processed count
			bookingsProcessed = 0;
		}
		else  // Is an additional job needed?
		{
			Id cronJobId;
			String cronJobName;
			String cronJobBaseName = 'VEM EMS Sync - Batch ';
			String cronJobRunTime = Datetime.now().addMinutes(batchDelayInMinutes).format('s m H d MMM ? yyyy');

			for (Integer i = 1; i <= 9; i++)
			{
				try
				{
					// Schedule cron job
					cronJobName = cronJobBaseName + i;
					cronJobId = System.schedule(cronJobName, cronJobRunTime, new VEMEMSAPI());

					// Add cron job id and name to the list of running jobs
					VemEmsSyncJobSetting__c emsJob = new VemEmsSyncJobSetting__c();
					emsJob.Name = cronJobName;
					emsJob.JobId__c = cronJobId;
					insert emsJob;

					// Success so no need to try again; break out of loop
					break;
				}
				catch (Exception ex)
				{
					// Try again...
				}
			}
		}
	}

	private static void removeCompletedScheduledJobs()
	{
		// Get list of scheduled EMS jobs
		Map<String,VemEmsSyncJobSetting__c> emsJobMap = VemEmsSyncJobSetting__c.getAll();

		// Get the current status of the scheduled EMS jobs
		Set<Id> emsJobIds = new Set<Id>();
		List<VemEmsSyncJobSetting__c> emsJobs = new List<VemEmsSyncJobSetting__c>();
		for (VemEmsSyncJobSetting__c emsJob : emsJobMap.values())
		{
			if (emsJob.JobId__c != null)
			{
				emsJobs.add(emsJob);
				emsJobIds.add(emsJob.JobId__c);
			}
		}
		Map<Id,CronTrigger> cronJobMap = new Map<Id,CronTrigger>
			([SELECT Id, State, CronExpression, TimesTriggered, NextFireTime
				FROM CronTrigger
			   WHERE Id IN :emsJobIds]);

		// Delete scheduled jobs that have completed
		CronTrigger cronJob;
		for (VemEmsSyncJobSetting__c emsJob : emsJobs)
		{
			cronJob = cronJobMap.get(emsJob.JobId__c);
			if (cronJob == null || cronJob.State == 'DELETED')
			{
				if (cronJob != null)
				{
					// Delete cron job
					System.abortJob(cronJob.Id);
				}

				// Remove job from list of EMS jobs
				delete emsJob;
			}
		}
	}

	public static void sendEmail(String to, String cc, String subject, String body)
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		String[] toAddresses = new String[] {to};
		String[] ccAddresses = new String[] {cc};
		mail.setToAddresses(toAddresses);
		mail.setCcAddresses(ccAddresses);
		mail.setSenderDisplayName('Salesforce VU Support');
		mail.setSubject(subject);
		mail.setUseSignature(false);
		mail.setPlainTextBody(body);
		mail.setSaveAsActivity(false);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}

}