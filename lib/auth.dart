part of authServer;

@app.Group('/auth')
class AuthService
{
	@app.Route('/login', methods: const[app.POST])
    Future<Map> loginUser(@app.Body(app.JSON) Map parameters)
    {
		Random rand = new Random();
    	Completer c = new Completer();

    	//TODO: this must be changed to not allow the client to dictate what the audience is
    	//according to the persona docs. However, for testing purposes,
    	//this is a necessary evil.
    	String audience = 'http://play.childrenofur.com:80';
    	if(parameters['testing'] != null)
    		audience = 'http://localhost:8080';
    	if(parameters['audience'] != null)
    		audience = parameters['audience'];

    	Map body = {'assertion':parameters['assertion'],
    				'audience':audience};

    	http.post('https://verifier.login.persona.org/verify',body:body).then((response)
		{
			Map responseMap = JSON.decode(response.body);
			if(responseMap['status'] == 'okay')
			{
				createSession(responseMap['email']).then((String sessionKey)
				{
				  //TODO remove default player street
					c.complete({'ok':'yes',
    							'slack-team':slackTeam,
    							'slack-token':bugToken,
    							'sc-token':scToken,
    							'sessionToken':sessionKey,
    							'playerName':SESSIONS[sessionKey].username,
    							'playerEmail':responseMap['email'],
    							'playerStreet':'LA58KK7B9O522PC'});
				},
				onError:((_) => c.complete({'ok':'no'})));
			}
			else
				c.complete({'ok':'no'});
		});

    	return c.future;
    }

	@app.Route('/logout', methods: const[app.POST])
    Map logoutUser(@app.Body(app.JSON) Map parameters)
    {
		//should remove any session key associated with parameters['sessionToken']
		SESSIONS.remove([parameters['sessionToken']]);
		return {'ok':'yes'};
    }

	@app.Route('/setusername', methods: const[app.POST])
	Future<Map> setUsername(@app.Body(app.FORM) Map parameters)
	{
		Completer c = new Completer();

		try
		{
			String query = "INSERT INTO users (username,email,bio) VALUES(@username,@email,@bio)";
            Map params = {
                          'username':parameters['username'],
                          'email':SESSIONS[parameters['token']].email,
                          'bio':''
                         };
			dbConn.execute(query,params).then((int userId)
			{
				if(userId != 0)
				{
					c.complete({'ok':'yes'});
				}
				else
					c.complete({'ok':'no'});
			});
		}
		catch(e){c.completeError({'ok':'no'});}

		return c.future;
	}

	PostgreSql get dbConn => app.request.attributes.dbConn;

	//creates an entry in the SESSIONS map and returns the username associated with the session
	Future<String> createSession(String email)
	{
		Completer c = new Completer();
		String query = "SELECT * FROM users WHERE email = @email";
		Map params = {'email':email};

		dbConn.query(query, User, params).then((List<User> users)
		{
			if(users.length > 0)
			{
    			String sessionKey = uuid.v1();
    			Session session = new Session(sessionKey, users[0].username, email);

    			SESSIONS[sessionKey] = session;
    			c.complete(sessionKey);
			}
			else
				c.complete('');
		});

		return c.future;
	}
}