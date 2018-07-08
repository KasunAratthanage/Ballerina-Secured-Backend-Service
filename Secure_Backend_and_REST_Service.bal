//Scenario - Bank Account Management System (Access Information)

//Import Ballerina http library packages
//Package contains fuctions annotaions and connectores

import ballerina/http;
import ballerina/runtime;



//This service is accessible at port no 9091

//Ballerina client can be used to connect to the created HTTPS listener.
//The client needs to provide values for 'trustStoreFile' and 'trustStorePassword'
endpoint http:SecureListener ep {
    port: 9097,

    secureSocket: {
        keyStore: {
            path: "${ballerina.home}/bre/security/ballerinaKeystore.p12",
            password: "ballerina"
        },
        trustStore: {
            path: "${ballerina.home}/bre/security/ballerinaTruststore.p12",
            password: "ballerina"
        }
    }
};

map<json> bankDetails;

//authConfiguration comprise Authentication and Authorization
//Authentication can set as 'enable' 
//Authorization based on scpoe
@http:ServiceConfig {
    basePath: "/banktest",
    authConfig: {
        authentication: { enabled: true },
        scopes: ["scope1"]
    }
}



service<http:Service> accountMgt bind ep {

//------------POST-----------------------------------------------------------------

@http:ResourceConfig {
        methods: ["POST"],
        path: "/account",
	authConfig: {
        scopes: ["scope2"]
        }
    }
    
	
    //Create Account 

    hello(endpoint client, http:Request req) {
	
	
        json accountReq = check req.getJsonPayload();
        json Bank_Account_No = accountReq.Account_Details.Bank_Account_No;
        
	// Check the Bank_Account_No is null or not entered 	
	if(Bank_Account_No == null || Bank_Account_No.toString().length() == 0)	{
	json payload = { status: " Please Enter Your Bank Account Number "};
        http:Response response;
        response.setJsonPayload(payload);

    	// Set 204 "No content" response code in the response message.
		response.statusCode = 204;
		_ = client->respond(response);
	}

	else {

        string accountId = Bank_Account_No.toString();
        bankDetails[accountId] = accountReq;
	  
        // Create response message.
        json payload = { status: " Account has been created sucessfully ", Bank_Account_No: accountId};
        http:Response response;
	
	// Set 201 "Created new account" response code in the response message.
        response.statusCode = 201;        
	response.setJsonPayload(payload);

        

        
        // Send response to the client.
        _ = client->respond(response);
	}

		

    }

	// curl command for POST method
	// curl -v -X POST -d '{ "Account_Details": { "Bank_Account_No": "12345", "Name": "Kasun","Account_type":"Savings","Branch":"Colombo"}}'
	// "http://localhost:9091/accountmgt/account" -H "Content-Type:application/json"


//------------------------------------GET---------------------------------------------------------------

@http:ResourceConfig {
        methods: ["GET"],
        path: "/account/{accountId}",
	authConfig: {
        scopes: ["scope2","scope1"]
        }
    }
    

retriveBankAccountDetails(endpoint client, http:Request req, string accountId) {
        // Find the requested accountId from the map and retrieve it in JSON format.

        //json? payload = bankDetails[accountId];
	//runtime:sleep(10000);
        http:Response response;
       	// Find the accountId is exists or not
	if (bankDetails.hasKey(accountId)) {
	json? payload = bankDetails[accountId];

	// Set the JSON payload to outgoing response message.
        response.setJsonPayload(payload);
        
        // Send response to the client.
        _ = client->respond(response);
	
	}

	else{

		json payload = "accountId : " + accountId + " This account is cannot be found.";
		response.setJsonPayload(payload);
                
        	// Send response to the client.
        	_ = client->respond(response);

	    }
   }


//--------------------------------------PUT---------------------------------------------------------------------

//Implemet HTTP PUT request for update inserted Account Deatils
   	//Can access '/account/<accountId> path	

	@http:ResourceConfig {
        methods: ["PUT"],
        path: "/account/{accountId}",
	authConfig: {
        scopes: ["scope2"]
        }
    	}
	
	
	//update Account Details
    	updateAccountDetails(endpoint client, http:Request req, string accountId) {
        json updatedAccount = check req.getJsonPayload();

        // Find the Account Details using AccountId
        json existingAccount = bankDetails[accountId];

        // Updating inserted Account Details
        if (existingAccount != null) {
	    
	    existingAccount.Account_Details.Bank_Account_No = updatedAccount.Account_Details.Bank_Account_No;
            existingAccount.Account_Details.Name = updatedAccount.Account_Details.Name;
	    existingAccount.Account_Details.Account_type = updatedAccount.Account_Details.Account_type;
            existingAccount.Account_Details.Branch = updatedAccount.Account_Details.Branch;
            bankDetails[accountId] = existingAccount;
        } 
        else {

            existingAccount = "Account : " + accountId + " is invalid. Plese create a account.";
        }

            http:Response response;
            // Set the JSON payload to outgoing response message.
            response.setJsonPayload(existingAccount);
	
            // Send response to the client.
            _ = client->respond(response);
        
            
          
   
	 }


//------------------------------------DELETE---------------------------------------------------------

@http:ResourceConfig {
        methods: ["DELETE"],
        path: "/account/{accountId}",
	authConfig: {
        scopes: ["scope2"]
        }
    }

    deleteAccount(endpoint client, http:Request req, string accountId) {
                    
       
	http:Response response;
    
        //Find the accountId is exists or not 
	if(bankDetails.hasKey(accountId)){
	
        // Remove the requested order from the map.
        _ = bankDetails.remove(accountId);

        json payload = "Account_Details : " + accountId + " Deleted.";
        // Set a generated payload with order status.
        response.setJsonPayload(payload);

        // Send response to the client.
        _ = client->respond(response);
	}
	
	else{
	 json payload = "Account : " + accountId + " not found.";
        // Set a generated payload with order status.
        response.setJsonPayload(payload);

        // Send response to the client.
        _ = client->respond(response);

	}
    	
	}


}

