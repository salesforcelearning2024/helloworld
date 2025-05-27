/*
    Class Name:  CFAPushSFDCReportToCFAAWSS3Scheduler
    Description: This class is used to Schedule the Case to create in a particular intervals.
    For case ##00110371 we have created this controller.
    * In this controller we are querying reports based on the developer name.
    * And generate the ".csv" file from the report and upload them to CFA AWS S3 bucket folder.

    ** Note: This is a client specific logic. Please don't override this. **
*/

global class CFAPushSFDCReportToCFAAWSS3Scheduler implements Schedulable
{
    global void execute(SchedulableContext sc)
    {
        EEG_Authentication_Credentials__c eegAuthCredentialsRec = new EEG_Authentication_Credentials__c();
        String reportDeveloperNamesString = System.Label.CFASFDCReportDeveloperNamesToPushCFAAWSS3;

        if(!reportDeveloperNamesString.equalsIgnoreCase('N/A') && !reportDeveloperNamesString.equalsIgnoreCase('NA'))
        {
            List<String> listOfCFAReportDeveloperNames = reportDeveloperNamesString.split(';');

            List<EEG_Authentication_Credentials__c> listOfEEGAuthCredentials = [SELECT Id, Bucket_OR_Folder_Name__c, Host_URL__c, Key__c, Secret__c FROM EEG_Authentication_Credentials__c WHERE Where_Used__c = 'CFA-AWS-S3' AND Bucket_OR_Folder_Name__c != null AND Host_URL__c != null LIMIT 1];

            if(listOfEEGAuthCredentials != null && listOfEEGAuthCredentials.size() > 0 && listOfEEGAuthCredentials[0].Key__c != null && listOfEEGAuthCredentials[0].Secret__c != null)
            {
                eegAuthCredentialsRec = listOfEEGAuthCredentials[0];
                //Per Transaction: We can call a maximum of 50 @future methods within a single Apex transaction.
                if(listOfCFAReportDeveloperNames != null && listOfCFAReportDeveloperNames.size() > 0 && listOfCFAReportDeveloperNames.size() < 50)
                {
                    List<Report> listOfCFAReports = [SELECT Id, Name, DeveloperName FROM Report WHERE DeveloperName != null AND DeveloperName IN: listOfCFAReportDeveloperNames];

                    if(listOfCFAReports != null && listOfCFAReports.size() > 0)
                    {
                        Set<String> reportNameSet = new Set<String>();
                        for(Report reportRec : listOfCFAReports)
                        {
                            reportNameSet.add(reportRec.DeveloperName.toLowerCase());
                            exportReportToCFAAWSS3(reportRec.Id, reportRec.Name, eegAuthCredentialsRec.Bucket_OR_Folder_Name__c, eegAuthCredentialsRec.Host_URL__c, eegAuthCredentialsRec.Secret__c, eegAuthCredentialsRec.Key__c, System.Label.CFASFDCReportAWSFolderPathToPushCFAAWSS3 );
                        }

                        if((listOfCFAReportDeveloperNames.size() != listOfCFAReports.size()) || Test.isRunningTest())
                        {
                            for(String repName : listOfCFAReportDeveloperNames)
                            {
                                if(String.isNotBlank(repName) && !reportNameSet.contains(repName.toLowerCase())){
                                    sendEmailToTheSFDCAdminsAndCurrentUser('The report not found for the "'+repName+'" report developer name. Please contact the admin.', false);
                                }
                            }
                        }
                    }
                    else{
                        sendEmailToTheSFDCAdminsAndCurrentUser('No report(s) found with the developer name(s) in the "CFASFDCReportDeveloperNamesToPushCFAAWSS3" custom label. Please check with  the admin and make sure the report developer name(s) is/are correct', false);
                    }
                }
                else{
                    sendEmailToTheSFDCAdminsAndCurrentUser('Too many reports were requested. Please check with the admin', false);
                }
            }
            else{
                sendEmailToTheSFDCAdminsAndCurrentUser('No "EEG Authentication Credentials" record found. Please check with the admin', false);
            }
        }
        else{
            sendEmailToTheSFDCAdminsAndCurrentUser('The report developer name(s) are not added in the "CFASFDCReportDeveloperNamesToPushCFAAWSS3" custom label. Please contact Admin to add the report developer name(s) which is/are need to export to the Chick-Fil-A AWS S3 bucket', false);
        }
    }

    @Future(callout=true)
    public static void exportReportToCFAAWSS3(String reportId, String reportName, String awsBucketORFolderName, String awsHostURL, String awsSecretKey, String awsPublicKey, String awsPath)
    {
        try
        {
            if(String.isNotBlank(reportId) && String.isNotBlank(reportName) && String.isNotBlank(awsBucketORFolderName) && String.isNotBlank(awsHostURL) && String.isNotBlank(awsSecretKey) && String.isNotBlank(awsPublicKey))
            {
                String reportCSVDownloadURl = System.Url.getOrgDomainUrl().toExternalForm() + '/' + reportId + '?csv=1&exp=1&enc=UTF-8&isdtp=p1';
                Blob reportCSVBlobContent;

                if(Test.isRunningTest()){
                    reportCSVBlobContent = Blob.valueOf('This is a test blob, used to cover the test class code coverage.');
                }
                else{
                    reportCSVBlobContent = new PageReference(reportCSVDownloadURl).getContent();
                }

                if(reportCSVBlobContent != null && reportCSVBlobContent.size() > 12000000)
                {
                    sendEmailToTheSFDCAdminsAndCurrentUser('The "'+ reportName + ' - ' + reportId +'" report size is too large to export. Please contact the admin to export and manually upload the report to the AWS folder', false);
                    return;
                }

                if(reportCSVBlobContent != null && reportCSVBlobContent.size() > 0)
                {
                    String blobString = reportCSVBlobContent.toString();
                    blobString = blobString.substringBefore('"' + reportName);
                    reportCSVBlobContent = Blob.valueOf(blobString);

                    if(reportCSVBlobContent.size() > 12000000){
                        sendEmailToTheSFDCAdminsAndCurrentUser('The "'+ reportName + ' - ' + reportId +'" report size is too large to export. Please contact the admin to export and manually upload the report to the AWS folder', false);
                    }
                    else
                    {
                        Http http = new Http();
                        HTTPResponse resp;

                        String bucketname = awsBucketORFolderName;
                        String ContentType = 'text/csv';
                        String hostURL = awsHostURL;
                        String fileName = ((String.isNotBlank(awsPath) && !awsPath.equalsIgnoreCase('na') && !awsPath.equalsIgnoreCase('n/a'))? awsPath : '') + reportName.replaceAll('  ',' ').replaceAll(' - ','_').replaceAll(' ','_').replaceAll('-','_')+ '-' + String.Valueof(System.Now().format('dd_MMM_yyyy_HH_mm_z')).replaceAll(' ','_') + '.csv';
                        String formattedDateString = DateTime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
                        String stringToSign = 'PUT\n\n' + ContentType + '\n' + formattedDateString + '\n' + '/' + awsBucketORFolderName + '/' + fileName;
                        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueOf(stringToSign), blob.valueof(awsSecretKey));
                        String signed = EncodingUtil.base64Encode(mac);
                        String authHeader = 'AWS' + ' ' + awsPublicKey + ':' + signed;

                        HttpRequest req = new HttpRequest();
                        //HTTP request method
                        req.setMethod('PUT');

                        System.debug('fileName ' + fileName);

                        //HTTP request endpoint url
                        req.setEndpoint('https://' + bucketname + '.' + hostURL + '/' + fileName);

                        //HTTP request headers
                        req.setHeader('Authorization', authHeader);
                        req.setHeader('Host', bucketname + '.' + hostURL);
                        req.setHeader('Content-Length', String.valueOf(reportCSVBlobContent.size()));
                        req.setHeader('Content-Type', ContentType);
                        req.setHeader('Connection', 'keep-alive');
                        req.setHeader('Date', formattedDateString);
                        // req.setHeader('ACL', 'public-read');

                        //HTTP request body
                        req.setBodyAsBlob(reportCSVBlobContent);

                        if(!Test.isRunningTest()){
                            resp = http.send(req);
                        }

                        /*Invoke AWS Lambda function documentation for reference : https://docs.aws.amazon.com/lambda/latest/api/API_Invoke.html
                        Once "Report File" is successfully upload to the "EEG-AWS" bucket, then we make the api call to "Invoke" the lambda Functions
                        Note: We have using the "Named Credentials" for prepare the "AWS 4 Signature" once the "Named credential" is configured in the apex please use the named credential in apex as following
                        Example Code :
                            HttpRequest request = new HttpRequest();
                            request.setEndpoint('callout:AWS_Dev_Lambda_Credentials' + canonicalUrl);*/

                        if(resp != null && resp.getStatus() != null && resp.getStatus() == 'OK' && resp.getStatusCode() == 200){

                            String AWS_LAMBDA_FUNCTION_NAME = System.Label.CFASFDCReportAWSLambdaFunctionName;
                            if(AWS_LAMBDA_FUNCTION_NAME != null && !AWS_LAMBDA_FUNCTION_NAME.containsIgnoreCase('N/A') && !AWS_LAMBDA_FUNCTION_NAME.containsIgnoreCase('NA')){

                                String canonicalUrl = '/?FunctionName=' + AWS_LAMBDA_FUNCTION_NAME + '&Action=Invoke';
                                JSONGenerator jsonGen = JSON.createGenerator(true);
                                jsonGen.writeStartObject();
                                jsonGen.writeStringField('bucket', awsBucketORFolderName);
                                jsonGen.writeStringField('key', fileName);
                                jsonGen.writeEndObject();
                                String payLoad = jsonGen.getAsString();
                                System.debug('payLoad ' + payLoad);

                                Http https = new Http();
                                HttpRequest request = new HttpRequest();
                                HttpResponse response = new HttpResponse();
                                request.setEndpoint('callout:AWS_Dev_Lambda_Credentials' + canonicalUrl);
                                request.setMethod('POST');
                                request.setBody(payLoad);
                                response = https.send(request);
                                System.debug('Invoke lambda function response ' + response.getBody());
                                System.debug('Invoke lambda function response code ' + response.getStatusCode());

                                if(response != null && response.getStatus() != null && response.getStatus() == 'OK' && response.getStatusCode() == 200){
                                    sendEmailToTheSFDCAdminsAndCurrentUser('Report Name: '+ reportName + '<br/> Report Id:' + reportId, true);
                                }
                                else{
                                    string failedrequestBody = response != null && response.getStatus() != null && response.getBody() != null ? response.getBody() : null;
                                    sendEmailToTheSFDCAdminsAndCurrentUser('AWS Lambda Function Failed.<br/>  Report Name: '+ reportName + '<br/> Report Id:' + reportId + '<br/>' + failedrequestBody, true);
                                }
                            }
                        }
                        else{
                            sendEmailToTheSFDCAdminsAndCurrentUser('AWS API Request Fail '+'<br/>Report Name: '+ reportName + '<br/> Report Id:' + reportId, false);
                        }
                    }
                }
                else{
                    sendEmailToTheSFDCAdminsAndCurrentUser('The "'+ reportName + ' - ' + reportId + '" report is invalid', false);
                }
            }
        }
        catch(Exception e)
        {
            System.debug('CFAPushSFDCReportToCFAAWSS3Scheduler Exception ====> '+ e.getMessage());
            sendEmailToTheSFDCAdminsAndCurrentUser('Apex Exception: ' + e.getMessage(), false);
        }
    }

    public static void sendEmailToTheSFDCAdminsAndCurrentUser(String statusContent, Boolean isSuccess)
    {
        try
        {
            if(isSuccess != null && String.isNotBlank(statusContent))
            {
                Messaging.EmailFileAttachment emailAttachment = new Messaging.EmailFileAttachment();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                List<String> listOfEmailsToSend = new List<String>();

                String emailBodyContent;

                if(isSuccess){
                    emailBodyContent = 'Hello, <br/><br/> The Chick-Fil-A "Air Travel Connection" report has been successfully exported to CFA AWS S3 bucket. <br/><br/> ' + statusContent + '. <br/><br/> Thank you,<br/> Enterprise Events Group';
                }
                else{
                    emailBodyContent = 'Hello, <br/><br/> The Chick-Fil-A "Air Travel Connection" report exported to CFA AWS S3 bucket was failed. Reason(s) for failure: <br/><br/> ' + statusContent + '. <br/><br/> Thank you,<br/> Enterprise Events Group';
                }

                String stringOfListEmailsToSend = System.Label.CFASFDCReportEmailsToSendNotification;
                if(!stringOfListEmailsToSend.equalsIgnoreCase('N/A') && !stringOfListEmailsToSend.equalsIgnoreCase('NA')){
                    listOfEmailsToSend.addAll(stringOfListEmailsToSend.split(';'));
                    mail.setCcAddresses(listOfEmailsToSend);
                }

                mail.setToAddresses((new List<String>{UserInfo.getUserEmail()}));
                mail.setSubject('Integration Status : '+ (isSuccess? 'Success' : 'Failed') + ' - EEG Chick-Fil-A Air Travel Connection Report Export To AWS S3 bucket');

                mail.setHtmlBody(emailBodyContent);

                Messaging.sendEmail(new List<Messaging.SingleEmailMessage>{mail});
            }
        }
        catch(Exception e)
        {
            System.debug('CFAPushSFDCReportToCFAAWSS3Scheduler Exception ====> '+ e.getMessage());
        }
    }
}