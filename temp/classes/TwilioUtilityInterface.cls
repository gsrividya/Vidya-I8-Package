global interface TwilioUtilityInterface {

    string SendSMS(List<String>PhNumberList,String body);
    void SendCall(String phNumber);
    void SendSMS2(List<String>PhNumberList,String body);
}