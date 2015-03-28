part of authServer;

@app.Group('/auth')
class AuthService
{
	static Map<String,WebSocket> pendingVerifications = {};

	@app.Route('/verifyEmail', methods: const[app.POST])
	Future<Map> verifyEmail(@app.Body(app.JSON) Map parameters) async
	{
		if(parameters['email'] == null)
			return {'ok':'no'};

		//create a unique link to click in the email
		String token = uuid.v1();
		String link = 'https://$serverUrl:8383/auth/verifyLink?token=$token&email=${parameters['email']}';

		//store this in the database with their email so we can verify when they click the link
		String query = 'INSERT INTO email_verifications(email,token) VALUES(@email,@token)';
		int result = await dbConn.execute(query, {'email':parameters['email'],'token':token});
		if(result < 1)
			return {'result':'There was a problem saving the email/token to the database'};

		//set our email server configs
		SmtpOptions options = new SmtpOptions()
			..hostName = 'smtp.childrenofur.com'
			..port = 587
			..username = 'test@childrenofur.com'
			..password = 'we-might-be-11-Giants'
			..requiresAuthentication = true;

		SmtpTransport transport = new SmtpTransport(options);

		// Create the envelope to send.
		Envelope envelope = new Envelope()
			..from = 'noreply@childrenofur.com'
			..fromName = 'Children of Ur'
			..recipients.add(parameters['email'])
			..subject = 'Verify your email'
			..html = 'Thanks for signing up. In order to verify your email address, please click on the link below.<br><a href="$link">$link</a>';

		// Finally, send it!
		try
		{
			bool result = await transport.send(envelope);
			if(result)
				return {'result':'OK'};
			else
				return {'result':'FAIL'};
		}
		catch(err)
		{
			return {'result':err};
		}
	}

	@app.Route('/verifyLink')
	Future verifyLink(@app.QueryParam() String email, @app.QueryParam() String token) async
	{
		if(AuthService.pendingVerifications[email] != null)
		{
			String query = "SELECT * FROM email_verifications WHERE email = @email";
			List<EmailVerification> results = await dbConn.query(query, EmailVerification, {'email':email});
			if(results.length > 0)
			{
				EmailVerification result = results[0];
				if(result.token == token)
				{
					Map serverdata = getSession({'email':email});
					Map response = {'result':'success','serverdata':serverdata};
					AuthService.pendingVerifications[email].add(JSON.encode(response));

					//delete pending row from database
					query = "DELETE FROM email_verifications WHERE id = @id";
					await dbConn.execute(query,result);

					return "Email Verified. You may close this window.";
				}
			}
		}

		return "Invalid Link";
	}

	@app.Route('/getSession', methods: const[app.POST])
	Map getSession(@app.Body(app.JSON) Map parameters) async
	{
		String email = parameters['email'];
		String sessionKey = await createSession(email);
		String query = "SELECT * FROM metabolics AS m JOIN users AS u ON m.user_id = u.id WHERE u.username = @username";
		List<Metabolics> m = await dbConn.query(query, Metabolics, {'username':SESSIONS[sessionKey].username});
		Metabolics playerMetabolics = new Metabolics();
		if(m.length > 0)
			playerMetabolics = m[0];
		Map serverdata =  {'slack-team':slackTeam,
    						'slack-token':bugToken,
    						'sc-token':scToken,
    						'sessionToken':sessionKey,
    						'playerName':SESSIONS[sessionKey].username,
    						'playerEmail':email,
    						'playerStreet':playerMetabolics.current_street,
    						'metabolics':JSON.encode(encode(playerMetabolics))};
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

class EmailVerification
{
	@Field()
	int id;

	@Field()
	String email;

	@Field()
	String token;
}