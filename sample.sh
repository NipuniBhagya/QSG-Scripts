#!/bin/sh

# ----------------------------------------------------------------------------
#  Copyright 2017 WSO2, Inc. http://www.wso2.org
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

configure_sso_saml2 () {
# Get the WSO2-IS Home directory path
echo "Please Enter the path for your WSO2-IS home directory"
read WSO2_HOME

 if [ ! -d "$WSO2_HOME" ]
  then
    echo "$WSO2_HOME Directory does not exists. Please download and install the latest pack."
    return -1
  fi

deploy_apps agent apps https://github.com/madumalt/identity-agent-sso.git https://github.com/madumalt/quick-start-guide.git
add_user admin admin 2
 
echo "Please select a user."
echo "Enter 1 - Cameron(Manager)"
echo "Enter 2 - Alex(Employee)"
 
read user
 if [ $user -eq "1" ]
  then 
   add_service_provider dispatch 2 urn:createApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz
   add_service_provider swift 2 urn:createApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz
   
   configure_saml dispatch 2 urn:addRPServiceProvider https://localhost:9443/services/IdentitySAMLSSOConfigService.IdentitySAMLSSOConfigServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz
   configure_saml swift 2 urn:addRPServiceProvider https://localhost:9443/services/IdentitySAMLSSOConfigService.IdentitySAMLSSOConfigServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz

   create_updateapp_xml dispatch Y2FtZXJvbjpjYW1lcm9uMTIz
   create_updateapp_xml swift Y2FtZXJvbjpjYW1lcm9uMTIz	
	
   update_application dispatch 2 urn:updateApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz
   update_application swift 2 urn:updateApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ Y2FtZXJvbjpjYW1lcm9uMTIz

   echo "To clean up the process please enter 0"
   read clean

   if [ $clean -eq "0" ]
     then
     delete_sp dispatch 2 urn:deleteApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/
     delete_sp swift 2 urn:deleteApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/
     delete_user	
     return 0;
   fi

 else
  add_service_provider dispatch 2 urn:createApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ YWRtaW46YWRtaW4=
  add_service_provider swift 2 urn:createApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ YWRtaW46YWRtaW4=
   
  configure_saml dispatch 2 urn:addRPServiceProvider https://localhost:9443/services/IdentitySAMLSSOConfigService.IdentitySAMLSSOConfigServiceHttpsSoap11Endpoint/ YWRtaW46YWRtaW4=
  configure_saml swift 2 urn:addRPServiceProvider https://localhost:9443/services/IdentitySAMLSSOConfigService.IdentitySAMLSSOConfigServiceHttpsSoap11Endpoint/ YWRtaW46YWRtaW4=
		
  update_application dispatch 2 urn:updateApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ YWRtaW46YWRtaW4=
  update_application swift 2 urn:updateApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ YWRtaW46YWRtaW4=

   echo "To clean up the process please enter 0"
   read clean

   if [ $clean -eq "0" ]
     then
     delete_sp dispatch 2 urn:deleteApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/
     delete_sp swift 2 urn:deleteApplication https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/

     return 0;
   fi
 fi
 return 0;

}

add_user(){

cd ~/Quick-Start-Guide
IS_name=$1
IS_pass=$2
scenario=$3
request_data="${scenario}/add-role.xml"

# The following command can be used to create a user.
curl -v -k --user ${IS_name}:${IS_pass} --data '{"schemas":[],"name":{"familyName":"Smith","givenName":"Cameron"},"userName":"cameron","password":"cameron123","emails":"cameron@gmail.com","addresses":{"country":"Canada"}}' --header "Content-Type:application/json" https://localhost:9443/wso2/scim/Users

# The following command can be used to create a user.
curl -v -k --user ${IS_name}:${IS_pass} --data '{"schemas":[],"name":{"familyName":"Miller","givenName":"Alex"},"userName":"alex","password":"alex123","emails":"alex@gmail.com","addresses":{"country":"Canada"}}' --header "Content-Type:application/json" https://localhost:9443/wso2/scim/Users

#The following command will add a role to the user.
curl -k -d @$request_data -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:addRole" https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/

}

add_service_provider() {

sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
auth=$5
request_data="${scenario}/create-sp-${sp_name}.xml"
  
 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi

echo "Creating Service Provider $sp_name..."
  
# Send the SOAP request to create the new SP.
curl -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" $endpoint	

echo "Service Provider $sp_name successfully created."
return 0;

}

delete_user() {

request_data1="2/delete-cameron.xml"
request_data2="2/delete-alex.xml"
request_data3="2/delete-role.xml"

# Send the SOAP request to delete the user.
curl -k -d @$request_data1 -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:deleteUser" https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/

# Send the SOAP request to delete the user.
curl -k -d @$request_data2 -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:deleteUser" https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/

# Send the SOAP request to delete the role.
curl -k -d @2/delete-role.xml -H "Authorization: Basic YWRtaW46YWRtaW4=" -H "Content-Type: text/xml" -H "SOAPAction: urn:deleteRole" https://localhost:9443/services/RemoteUserStoreManagerService.RemoteUserStoreManagerServiceHttpsSoap11Endpoint/

}

delete_sp() {

sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
request_data="${scenario}/delete-sp-${sp_name}.xml"
  
 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi

echo "Deleting Service Provider $sp_name..."

# Send the SOAP request to delete a SP.
curl -k -d @$request_data -H "Authorization: Basic Y2FtZXJvbjpjYW1lcm9uMTIz" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" $endpoint

echo "Service Provider $sp_name successfully deleted."
return 0;

}

configure_saml() {

sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
auth=$5
request_data="${scenario}/sso-config-${sp_name}.xml"

 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory does not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi

echo "Configuring SAML2 web SSO for $sp_name..."

# Send the SOAP request for Confuring SAML2 web SSO.
curl -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" $endpoint  

echo "Successfully configured SAML"
return 0;

}

create_updateapp_xml() {

sp_name=$1
request_data="get-app-${sp_name}.xml"
auth=$2

cd ~/Quick-Start-Guide/2
 
 if [ ! -f "$request_data" ]
  then
    echo "$request_data File does not exists."
    return -1
  fi

 if [ -f "response_unformatted.xml" ] 
  then
   rm -r response_unformatted.xml
 fi
 
 if [ -f "response_formatted.xml" ]
  then
   rm -r response_formatted.xml  
 fi

touch response_unformatted.xml
touch response_formatted.xml

curl -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: urn:getApplication" https://localhost:9443/services/IdentityApplicationManagementService.IdentityApplicationManagementServiceHttpsSoap11Endpoint/ > response_unformatted.xml

xmllint --format response_unformatted.xml > response_formatted.xml
app_id=$(grep '<ax2140:applicationID' response_formatted.xml | cut -f2 -d">"|cut -f1 -d"<")

echo "${app_id}"

 if [ -f "update-app-${sp_name}.xml" ]
  then 
   rm -r update-app-${sp_name}.xml
 fi
   
touch update-app-${sp_name}.xml

echo "<soapenv:Envelope xmlns:soapenv="\"http://schemas.xmlsoap.org/soap/envelope/"\" xmlns:xsd="\"http://org.apache.axis2/xsd"\" xmlns:xsd1="\"http://model.common.application.identity.carbon.wso2.org/xsd"\">
    <soapenv:Header/>
    <soapenv:Body>
        <xsd:updateApplication>
            <!--Optional:-->
            <xsd:serviceProvider>
                <!--Optional:-->
                <xsd1:applicationID>${app_id}</xsd1:applicationID>
                <!--Optional:-->
                <xsd1:applicationName>${sp_name}</xsd1:applicationName>
                <!--Optional:-->
                <xsd1:claimConfig>
                    <!--Optional:-->
                    <xsd1:alwaysSendMappedLocalSubjectId>false</xsd1:alwaysSendMappedLocalSubjectId>
                    <!--Optional:-->
                    <xsd1:localClaimDialect>true</xsd1:localClaimDialect>
                </xsd1:claimConfig>
                <!--Optional:-->
                <xsd1:description>sample service provider</xsd1:description>
                <!--Optional:-->
                <xsd1:inboundAuthenticationConfig>
                    <!--Zero or more repetitions:-->
                    <xsd1:inboundAuthenticationRequestConfigs>
                        <!--Optional:-->
                        <xsd1:inboundAuthKey>saml2-web-app-dispatch.com</xsd1:inboundAuthKey>
                        <!--Optional:-->
                        <xsd1:inboundAuthType>samlsso</xsd1:inboundAuthType>
                        <!--Zero or more repetitions:-->
                        <xsd1:properties>
                            <!--Optional:-->
                            <xsd1:name>attrConsumServiceIndex</xsd1:name>
                            <!--Optional:-->
                            <xsd1:value>1223160755</xsd1:value>
                        </xsd1:properties>
                    </xsd1:inboundAuthenticationRequestConfigs>
                </xsd1:inboundAuthenticationConfig>
                <!--Optional:-->
                <xsd1:inboundProvisioningConfig>
                    <!--Optional:-->
                    <xsd1:provisioningEnabled>false</xsd1:provisioningEnabled>
                    <!--Optional:-->
                    <xsd1:provisioningUserStore>PRIMARY</xsd1:provisioningUserStore>
                </xsd1:inboundProvisioningConfig>
                <!--Optional:-->
                <xsd1:localAndOutBoundAuthenticationConfig>
                    <!--Optional:-->
                    <xsd1:alwaysSendBackAuthenticatedListOfIdPs>false</xsd1:alwaysSendBackAuthenticatedListOfIdPs>
                    <!--Optional:-->
                    <xsd1:authenticationStepForAttributes></xsd1:authenticationStepForAttributes>
                    <!--Optional:-->
                    <xsd1:authenticationStepForSubject></xsd1:authenticationStepForSubject>
                    <xsd1:authenticationType>default</xsd1:authenticationType>
                    <!--Optional:-->
                    <xsd1:subjectClaimUri>http://wso2.org/claims/fullname</xsd1:subjectClaimUri>
                </xsd1:localAndOutBoundAuthenticationConfig>
                <!--Optional:-->
                <xsd1:outboundProvisioningConfig>
                    <!--Zero or more repetitions:-->
                    <xsd1:provisionByRoleList></xsd1:provisionByRoleList>
                </xsd1:outboundProvisioningConfig>
                <!--Optional:-->
                <xsd1:permissionAndRoleConfig></xsd1:permissionAndRoleConfig>
                <!--Optional:-->
                <xsd1:saasApp>false</xsd1:saasApp>
            </xsd:serviceProvider>
        </xsd:updateApplication>
    </soapenv:Body>
</soapenv:Envelope>" >> update-app-${sp_name}.xml 

}


update_application() {

sp_name=$1
scenario=$2
soap_action=$3
endpoint=$4
auth=$5
request_data="${scenario}/update-app-${sp_name}.xml"

cd ~/Quick-Start-Guide

 if [ ! -d "$scenario" ]
  then
    echo "$scenario Directory does not exists."
    return -1
  fi

  if [ ! -f "$request_data" ]
   then
    echo "$request_data File does not exists."
    return -1
  fi

echo "Updating application..."

# Send the SOAP request to Update the Application. 
curl -k -d @$request_data -H "Authorization: Basic ${auth}" -H "Content-Type: text/xml" -H "SOAPAction: ${soap_action}" $endpoint 

echo "Successfully updated the application"
return 0;

}

deploy_apps() {

echo "Please enter the path to your QSG directory"
read qsg

# Get the TOMCAT Home
echo "Please Enter the path for your Tomcat home directory"
read TOMCAT_HOME

 if [ ! -d "$TOMCAT_HOME" ]
   then
     echo "$TOMCAT_HOME Directory does not exists. Please download and install the latest tomcat version."
    return -1
 fi

 if [ -f "${TOMCAT_HOME}/webapps/saml2-web-app-dispatch.com.war" ]
   then
    echo "The Dispatch app is already deployed."
   return -1
 fi

 if [ -f "${TOMCAT_HOME}/webapps/saml2-web-app-swift.com.war" ]
   then
    echo "The Dispatch app is already deployed."
   return -1
 fi
 
agent_repo_name=$1
app_repo_name=$2
agent_git_repo=$3
app_git_repo=$4

mkdir $agent_repo_name
echo "Creating new directory ${agent_repo_name}..."
  
 if [ ! -d "$agent_repo_name" ]
  then
    echo "$repo_name Directory does not exists."
    return -1
  fi

cd $agent_repo_name
git clone $agent_git_repo
echo "Cloning the github repository identity-agent-sso..."
cd identity-agent-sso
git checkout SSOAgentGeneralization
mvn clean install

cd ~/Quick-Start-Guide
mkdir $app_repo_name
echo "Creating new directory ${app_repo_name}..." 

 if [ ! -d "$app_repo_name" ]
  then
    echo "$repo_name Directory does not exists."
    return -1
  fi

cd $app_repo_name
git clone $app_git_repo
echo "Cloning the github repository quick-start-guide..."
cd quick-start-guide/components/SAML2/saml2-web-app-dispatch
mvn clean install
cd ..
cd saml2-web-app-swift
mvn clean install

cd target
cp saml2-web-app-swift.com.war $TOMCAT_HOME/webapps
cd ..
cd ..
cd saml2-web-app-dispatch/target
cp saml2-web-app-dispatch.com.war $TOMCAT_HOME/webapps 

 if [ "$?" -ne "0" ]; 
  then
   echo "Sorry, we had a problem there!"
 fi

}

echo "Please pick a scenario from the following."
echo "-----------------------------------------------------------------------------"
echo "|  Scenario 1 - Getting Started with WSO2 IS                                |"
echo "|  Scenario 2 - Configuring Single-Sign-On with SAML2                       |"
echo "|  Scenario 3 - Configuring Single-Sign-On with OIDC                        |"
echo "|  Scenario 4 - Configuring Multi-Factor Authentication                     |"
echo "|  Scenario 5 - Configuring Google as a Federated Authenticator             |"
echo "|  Scenario 6 - Setting up Self-Signup                                      |"
echo "|  Scenario 7 - Creating a workflow                                         |"  
echo "-----------------------------------------------------------------------------"
echo "Enter the scenario number you selected."

	read scenario
	case $scenario in
		1)
		echo "Getting Started with WSO2 IS"		
		;;
		
		2)

		configure_sso_saml2

		if [ "$?" -ne "0" ]; then
  		  echo "Sorry, we had a problem there!"
		 fi

		break ;;

		3)
		
		echo "Configuring Single-Sign-On with OIDC"
		break ;;
		
		4)
		echo "Configuring Multi-Factor Authentication"
		break ;;

		5)
		echo "Configuring Google as a Federated Authenticator"
		break ;;

		6)
		echo "Setting up Self-Signup"
		break ;;
		
		7)
		echo "Creating a workflow"
		break ;;

		*)
		echo "Sorry, that's not an option."
		;;
	esac	
echo



































