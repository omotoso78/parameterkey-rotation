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
    
    keyName =json.loads(event['body']['keyName']) #added to define variable 
    
    #Using put method, as it can update existing key values before it is returned, and input new keyname and genrate key_values
    if ['httpMethod'] == "PUT": 
        response =client.put_parameter(
                Name= keyName,
                #Description='keys',
                Value= key_gen,
                Type='String',
                Overwrite=True
           )
    

    pass

    print(response) # to be formated 




'''
import json
import boto3
import string
import random


source = string.ascii_letters + string.digits
key_gen = ''.join((random.choice(source) for i in range(50)))

AWS_REGION = "eu-west-3"

def lambda_handler(event, context):
    
 
    client = boto3.client("ssm", region_name = AWS_REGION)
   
    response = client.put_parameter(
            Name= "ParameterName",
            #Description='keys',
            Value= str(key_gen),
            Type='String',
            Overwrite=True
           )
    

      
    response = {'statusCode': 200, 'body': json.dumps("success") } # to format with variable key name and value
    return response'''
