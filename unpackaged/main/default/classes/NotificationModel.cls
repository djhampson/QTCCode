/*******************************************************************************************************
* Class Name      	: NotificationModel
* Description		    : Model for Notifications
* Author          	: Simplus - Abeer Qureshi
* Created On      	: 
* Modification Log	:
* -----------------------------------------------------------------------------------------------------
* Developer				Date			Modification ID		Description
* -----------------------------------------------------------------------------------------------------
* Abeer Qureshi         		        1000				Initial version
******************************************************************************************************/
public virtual with sharing class NotificationModel {

/*  "Notification": 
    {
        "Notif_ID": "123456",
        "Notif_Type": "Invoice",
        "Notif_Obj_ID": "0065K000002m0MqQAI",
        "Notif_Status": "Posted",
        "Notif_CreateDate": "2020-10-10 08:30:00",
        "Params": [{"Param": "p1", "Value": "v1"}]
      }
*/

public string Notif_ID {get; set;}
public string Notif_Type {get; set;}
public string Notif_Obj_ID {get; set;}
public string Notif_Status {get; set;}
public string Notif_CreateDate {get; set;}
public Param[] Params {get; set;}

public NotificationModel(){
  Notif_ID = '';
  Notif_Type = '';
  Notif_Obj_ID = '';
  Notif_Status = '';
  Notif_CreateDate = '';
  Params = new List<Param>();
}

  public class Param {
    public string Param {get; set;}
    public string Value {get; set;}
  }

}