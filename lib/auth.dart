part of authServer;

@app.Group('/auth')
class AuthService
{
	@app.Route('/login', methods: const[app.POST])
    Future<Map> loginUser(@app.Body(app.JSON) Map parameters) async
    {
		Random rand = new Random();

    	//TODO: this must be changed to not allow the client to dictate what the audience is
    	//according to the persona docs. However, for testing purposes, this is a necessary evil.
    	String audience = 'http://play.childrenofur.com:80';
    	if(parameters['testing'] != null)
    		audience = 'http://localhost:8080';
    	if(parameters['audience'] != null)
    		audience = parameters['audience'];

    	Map body = {'assertion':parameters['assertion'],
    				'audience':audience};

    	http.Response response = await http.post('https://verifier.login.persona.org/verify',body:body);
		Map responseMap = JSON.decode(response.body);

		if(responseMap['status'] == 'okay')
		{
			try
			{
				String sessionKey = await createSession(responseMap['email']);
				String query = "SELECT * FROM metabolics AS m JOIN users AS u ON m.user_id = u.id WHERE u.username = @username";
				List<Metabolics> m = await dbConn.query(query, Metabolics, {'username':SESSIONS[sessionKey].username});
				Metabolics playerMetabolics = new Metabolics();
				if(m.length > 0)
					playerMetabolics = m[0];
				Map response =  {'ok':'yes',
						'slack-team':slackTeam,
						'slack-token':bugToken,
						'sc-token':scToken,
						'sessionToken':sessionKey,
						'playerName':SESSIONS[sessionKey].username,
						'playerEmail':responseMap['email'],
						'playerStreet':playerMetabolics.current_street,
						'metabolics':JSON.encode(encode(playerMetabolics))};

				return response;
			}
			catch(e){print(e);return {'ok':'no'};}
		}
		else
			return {'ok':'no'};
    }

	@app.Route('/logout', methods: const[app.POST])
    Map logoutUser(@app.Body(app.JSON) Map parameters)
    {
		//should remove any session key associated with parameters['sessionToken']
		SESSIONS.remove([parameters['sessionToken']]);
		return {'ok':'yes'};
    }

	@app.Route('/setusername', methods: const[app.POST])
	Future<Map> setUsername(@app.Body(app.JSON) Map parameters) async
	{
		try
		{
			String query = "INSERT INTO users (username,email,bio) VALUES(@username,@email,@bio)";
            Map params = {
                          'username':parameters['username'],
                          'email':SESSIONS[parameters['token']].email,
                          'bio':''
                         };
			int userId = await dbConn.execute(query,params);

			if(userId != 0)
				return {'ok':'yes'};
			else
				return {'ok':'no'};
		}
		catch(e){return {'ok':'no'};}
	}

	PostgreSql get dbConn => app.request.attributes.dbConn;

	//creates an entry in the SESSIONS map and returns the username associated with the session
	Future<String> createSession(String email) async
	{
		String query = "SELECT * FROM users WHERE email = @email";
		Map params = {'email':email};

		String sessionKey = uuid.v1();

		List<User> users = await dbConn.query(query, User, params);
		Session session;

		if(users.length > 0)
			session = new Session(sessionKey, users[0].username, email);
		else
			session = new Session(sessionKey, '', email);

		SESSIONS[sessionKey] = session;
		return sessionKey;
	}
}