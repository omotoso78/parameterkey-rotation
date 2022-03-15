import json
import boto3
import string
import random

print("loading function")

def lambda_handler(event, context):
    AWS_REGION = "eu-west-3"
    source = string.ascii_letters + string.digits
    key_gen = ''.join((random.choice(source) for i in range(50)))
    
    client = boto3.client("ssm", region_name = AWS_REGION)
    
    print('event:', json.dumps(event))
    
   # keyName = json.loads(event['body']['keyName'])
    
    body = json.loads(event['body'])
    keyName = body['keyName']#added to define variable keyName
    #keyName = event['queryStringParameters']['keyName']
    
    
    try:
        key_value = body['value']
    except:
        key_value = str(key_gen)
   
   #Using put method, to update existing key values, and input new keyname and generate key_values
    parameter_detail =client.put_parameter(
                Name= keyName,
                Value= key_value,
                Type='String',
                Overwrite=True
           )
    #using get method to return key details
    parameter_return = client.get_parameter(Name=keyName)
    
    value_body = {
        "Name": keyName,
        "Value": key_value
    }
    return{
        "statusCode": 200,
        "body":json.dumps(value_body)
    }    
