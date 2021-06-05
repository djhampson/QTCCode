global class schedbatchUpdateAccServProd implements Schedulable {
   global void execute(SchedulableContext sc) {
      batchUpdateAccServProd c = new batchUpdateAccServProd();
      database.executebatch(c);
   }
}