// CRON Format: Seconds Minutes Hours Day_of_month Month Day_of_week optional_year
// Run job every Monday at 4:00 AM: 0 0 4 ? * MON
//
// To schedule this jub, use:
////VEM_VolumeMonitor vm = new VEM_VolumeMonitor();
//VEM_VolumeMonitor vm = new VEM_VolumeMonitor(7500);
//System.schedule('VEM Volume Monitor', '0 0 4 ? * MON', vm);
//
// To test this code, use:
//VEM_VolumeMonitor vm = new VEM_VolumeMonitor();
//vm.isTest = true;
//SchedulableContext sc;
//vm.execute(sc);
//
global class VEM_VolumeMonitor implements Schedulable
{

	private Integer m_volumeThreshold = 5000;
	global VEM_VolumeMonitor(Integer volumeThreshold)
	{
		m_volumeThreshold = volumeThreshold;
	}

	private Boolean m_isTest = false;
	global Boolean isTest
	{
		get { return m_isTest; }
		set { m_isTest = value; }
	}

	global void execute(SchedulableContext SC)
	{
		checkForHighVolume();
	}

	private void checkForHighVolume()
	{
		// Look for days with expected volumes greater than the threshold
		List<AggregateResult> resultList = [   SELECT Start_Date__c StartDate, sum(Expected_Volume__c) ExpectedVolume
												 FROM VEM_Event__c
												WHERE Start_Date__c > TODAY
											 GROUP BY Start_Date__c
											   HAVING SUM(Expected_Volume__c) > :m_volumeThreshold ];

		// Was at least one day found
		if (resultList.size() > 0)
		{
			// Construct email message header
			String msg = '';
			msg += '<p>\n';
			msg += 'The following dates have high expected volumes (> ' + format(m_volumeThreshold) + ').<br />\n';
			msg += 'There may be too many events scheduled on these dates:\n';
			msg += '</p>\n';
			msg += '<table>\n';
			msg += '<tr><td><u>Date</u></td><td width="10">&nbsp;</td><td align="right"><u>Expected Volume</u></td></tr>\n';

			// Construct email message body
			DateTime startDate;
			Double expectedVolume;
			for (AggregateResult result : resultList)
			{
				startDate = (Date)result.get('StartDate');
				expectedVolume = (Double)result.get('ExpectedVolume');
				msg += '<tr><td>' + startDate.format('MM/dd/yyyy') + '</td><td>&nbsp;</td><td align="right">' + format(expectedVolume) + '</td></tr>\n';
			}
			msg += '</table>\n';

			// Send email to users
			notifyUsers(msg);
		}
	}

	private String format(Double dbl)
	{
		return Decimal.valueOf(dbl).setScale(0).format();
	}

	private void notifyUsers(String msg)
	{
		List<String> volumeMonitors = getVolumeMonitors();
		if (volumeMonitors.size() > 0)
		{
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			email.setToAddresses(volumeMonitors);
			email.setSenderDisplayName('VEM - Expected Volume Threshold Warning(s)');
			email.setSaveAsActivity(false);
			email.setHtmlBody(msg);
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		}
	}

	private List<String> getVolumeMonitors()
	{
		List<String> volumeMonitors = new List<String>();

		// Get group members (these must be users, not roles or other groups)
		Group volumeMonitorGroup = [ SELECT Id FROM Group WHERE Name = 'VEM Volume Monitors' LIMIT 1 ];
		List<GroupMember> volumeMonitorMemberList = [ SELECT UserOrGroupId FROM GroupMember WHERE GroupId = :volumeMonitorGroup.Id ];

		// Get users
		Set<Id> userIdSet = new Set<Id>();
		for (GroupMember member : volumeMonitorMemberList)
		{
			userIdSet.add(member.UserOrGroupId);
		}

		// Get email addresses
		List<User> userList = [ SELECT Id, Name, Email FROM USER WHERE Id in :userIdSet ];
		for (User usr : userList)
		{
			volumeMonitors.add(usr.Email);
		}

		if (isTest)
		{
			volumeMonitors.clear();
			volumeMonitors.add('krensc01@villanova.edu');
			volumeMonitors.add('arben.dodbiba@villanova.edu');
		}

		return volumeMonitors;
	}

}