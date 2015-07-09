<!--- 
	This component provides HTTP methods for accessing Web resources secured via Windows NTLM Authentication.
	This component is dependent upon the following Apache HTTPComponents jar files:
	
			commons-codec-1.4.jar
			httpclient-4.1.2.jar
			httpcore-4.1.2.jar

	These jars should be placed in the {cfinstance}\WEB-INF\lib directory.
 --->
<cfcomponent displayname="ntlmHttpClient" output="no">

	<!--- init --->
	<cffunction name="init" access="public" returntype="ntlmHttpClient">
  	<cfargument name="username" type="string" required="yes" />
    <cfargument name="password" type="string" required="yes" />
    <cfargument name="domain" type="string" required="yes" />
    <cfscript>
			variables.inetAddress = createObject('java','java.net.InetAddress');
			variables.ntCredentials = createObject('java','org.apache.http.auth.NTCredentials');
			variables.ntCredentials.init(javaCast('string',arguments.username)
																	,javaCast('string',arguments.password)
																	,javaCast('string',variables.inetAddress.getLocalHost().getHostName())
																	,javaCast('string',arguments.domain));
			variables.authScope = createObject('java','org.apache.http.auth.AuthScope');
			variables.defaultHttpClient = createObject('java','org.apache.http.impl.client.DefaultHttpClient');
			variables.defaultHttpClient.init();
			variables.defaultHttpClient.getCredentialsProvider().setCredentials(variables.authScope.ANY,variables.ntCredentials);
			variables.entityUtils = createObject('java','org.apache.http.util.EntityUtils');
		</cfscript>
		<cfreturn this />
	</cffunction>
  
  <!--- getUrlStruct --->
  <cffunction name="getUrlStruct" access="private" returntype="struct" output="no">
  	<cfargument name="urlString" type="string" required="yes" />
    <cfscript>
			local.urlStruct = {};
			local.urlObject = createObject('java','java.net.URL');
			local.urlObject.init(arguments.urlString);
			local.urlStruct.domain = local.urlObject.getHost();
			local.urlStruct.protocol = local.urlObject.getProtocol();
			local.urlStruct.pathInfo = local.urlObject.getFile();
		</cfscript>
    
    <cfif local.urlObject.getPort() NEQ -1>
    	<cfset local.urlStruct.port = local.urlObject.getPort() />
    <cfelse>
    	<cfset local.urlStruct.port = 80 />
    </cfif>
    
    <cfreturn local.urlStruct />
  </cffunction>
			
  <!--- get --->
  <cffunction name="get" access="public" returntype="struct" output="no">
  	<cfargument name="destinationUrl" type="string" required="yes" />
    
    <cfscript>
			local.urlStruct = getUrlStruct(arguments.destinationUrl);
			local.httpHost = createObject('java','org.apache.http.HttpHost');
			local.httpHost.init(javaCast('string',local.urlStruct.domain)
												 ,javaCast('int',local.urlStruct.port)
												 ,javaCast('string',local.urlStruct.protocol));
			local.httpGet = createObject('java','org.apache.http.client.methods.HttpGet');
			local.httpGet.init(javaCast('string',local.urlStruct.pathInfo));
			local.httpResponseObject = variables.defaultHttpClient.execute(local.httpHost,local.httpGet);
			local.httpEntity = local.httpResponseObject.getEntity();
			
			local.httpResponse = {};
			local.httpResponse.statusCode = local.httpResponseObject.getStatusLine().getStatusCode();
			local.httpResponse.statusText = local.httpResponseObject.getStatusLine().getReasonPhrase();
			local.httpResponse.fileContent = variables.entityUtils.toString(local.httpEntity);
			
			variables.entityUtils.consume(local.httpEntity);
		</cfscript>
    
    <cfreturn local.httpResponse />
  </cffunction>

  <!--- post --->
  <cffunction name="post" access="public" returntype="struct" output="no">
  	<cfargument name="destinationUrl" type="string" required="yes" />
    <cfargument name="content" type="string" required="yes" />
    <cfargument name="contentType" type="string" required="no" default="text/xml" />
    <cfargument name="charSet" type="string" required="no" default="ISO-8859-1" />
    
    <cfscript>
			local.urlStruct = getUrlStruct(arguments.destinationUrl);
			local.httpHost = createObject('java','org.apache.http.HttpHost');
			local.httpHost.init(javaCast('string',local.urlStruct.domain)
												 ,javaCast('int',local.urlStruct.port)
												 ,javaCast('string',local.urlStruct.protocol));
			local.stringEntity = createObject('java','org.apache.http.entity.StringEntity');
			local.stringEntity.init(javaCast('string',arguments.content)
														 ,javaCast('string',arguments.contentType)
														 ,javaCast('string',arguments.charSet));
			local.httpPost = createObject('java','org.apache.http.client.methods.HttpPost');
			local.httpPost.init(javaCast('string',local.urlStruct.pathInfo));
			local.httpPost.setEntity(local.stringEntity);
			local.httpResponseObject = variables.defaultHttpClient.execute(local.httpHost,local.httpPost);
			local.httpEntity = local.httpResponseObject.getEntity();
			
			local.httpResponse = {};
			local.httpResponse.statusCode = local.httpResponseObject.getStatusLine().getStatusCode();
			local.httpResponse.statusText = local.httpResponseObject.getStatusLine().getReasonPhrase();
			local.httpResponse.fileContent = variables.entityUtils.toString(local.httpEntity);
			
			variables.entityUtils.consume(local.httpEntity);
		</cfscript>
    
    <cfreturn local.httpResponse />     
  </cffunction>
  
</cfcomponent>