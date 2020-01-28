{
  "AWSTemplateFormatVersion": "2010-09-09",
  "Resources": {
    "EmailSNSTopic": {
      "Type": "AWS::SNS::Topic",
      "Properties": {
        "DisplayName": "${display_name}",
        "Subscription": [
          {
            "Endpoint": "${subscription}",
            "Protocol": "email"
          }
        ]
      }
    }
  },
  "Outputs": {
    "ARN": {
      "Description": "Email SNS Topic ARN",
      "Value": {
        "Ref": "EmailSNSTopic"
      }
    }
  }
}
