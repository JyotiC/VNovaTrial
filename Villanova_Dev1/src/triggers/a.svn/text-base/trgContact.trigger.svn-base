trigger trgContact on Contact (after delete, after insert, after undelete, 
after update, before delete, before insert, before update) {
	if (Trigger.isBefore){
		//INSERT UPDATE UNDELETE
		if (Trigger.isUpdate || Trigger.isInsert || Trigger.isUnDelete){
			for (Contact c : Trigger.new) {
				if (c.Encrypted_Key__c == null){
					DateTime now = System.now();
					String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';
					String canonical = c.id + c.Name + c.OwnerId + formattednow;
					Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));
					String token = EncodingUtil.base64Encode(bsig);
				
					if(token.length() > 255) {
						token = token.substring(0,254);
					}
					try {
						c.Encrypted_Key__c = Encodingutil.urlEncode(token, 'UTF-8').replaceAll('%','_');
					}catch (Exception e){
						system.debug('EncrytpedKey__c assignment failed:' +e);
					}
				}//end if encrypted key is null
				
				
			}//end Contact loop
		}//END UPDATE INSERT UNDELETE
	}//END BEFORE
}