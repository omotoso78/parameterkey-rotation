import boto3
import string
import random
import json

print("loading function")

def lambda_handler(event, contest):
    AWS_REGION = "eu-west-3"
    source = string.ascii_letters + string.digits
    key_gen = ''.join((random.choice(source) for i in range(50)))
    
    client = boto3.client("ssm", region_name = AWS_REGION)
    
    print('event:', json.dumps(event))
    
    #using queryStringParamters to enable variable event input with GET method
    keyName = event['queryStringParameters']['keyName']
    
    #Python logic to update or generate key
    try:
        key_value = body['value']
    except:
        key_value = key_gen
   
   #Using put method, to update existing key values, and input new keyname and generate key_values
    parameter_detail =client.put_parameter(
                Name= keyName,
                Value= key_value,
                Type='String',
                Overwrite=True
           )
   
#Isolate required key details
    value_body = {
        "Name": keyName,
        "Value": key_value
    }
    #Code Json response
    return{
        "statusCode": 200,
        "body":json.dumps(value_body)
    }
