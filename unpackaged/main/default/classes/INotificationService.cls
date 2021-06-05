public interface INotificationService {
    NotificationResponse notify(NotificationRequest req);
    void notifyF(String req);
}