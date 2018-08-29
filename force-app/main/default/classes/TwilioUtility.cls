global class TwilioUtility implements TwilioUtilityInterface {
    global void SendCall(String phNumber){
    }
    global string SendSMS(List<String>PhNumberList,String body){
        return 'Twilio Package not installed';
    }
    global void SendSMS2(List<String>PhNumberList,String body){
    }
    
}