global class BatchUpdateContactSummary {
    Public static void BatchUpdateContactSummary() {
        ID batchprocessid;
        BatchExecUpdateContactSummary reassign;

        reassign = new BatchExecUpdateContactSummary('Select ID from Contact');//  where ID=\'003M0000001jjUr\'');
        batchprocessid = Database.executeBatch(reassign,200);

    }
    
}