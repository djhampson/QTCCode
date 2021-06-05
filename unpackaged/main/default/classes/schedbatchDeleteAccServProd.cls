global class schedbatchDeleteAccServProd implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchDeleteAccServProd c = new batchDeleteAccServProd();
      database.executebatch(c);
   }
}