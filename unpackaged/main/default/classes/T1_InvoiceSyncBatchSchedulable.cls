global class T1_InvoiceSyncBatchSchedulable implements Schedulable {
    global void execute(SchedulableContext ctx) {
       Database.executeBatch(new T1_InvoiceSyncBatch());
    }
}