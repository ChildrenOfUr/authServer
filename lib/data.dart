part of authServer;

@app.Group('/data')
class DataService
{
	@app.Route('/street', methods: const[app.POST])
    Future<Map> requestStreet(@app.Body(app.JSON) Map parameters)
    {
		Completer c = new Completer();

		if(!SESSIONS.containsKey(parameters['sessionToken']))
			c.complete({'ok':'no','error':'not logged in'});
		else
		{
			String tsid = parameters['street'];
    		if(tsid.startsWith('L'))
    			tsid = tsid.replaceFirst('L', 'G');
    		String url = "http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$tsid.json";
    		http.get(url).then((response)
    		{
    			try
    			{
    				Map street = JSON.decode(response.body);
    				Map r = {'ok':'yes','streetJSON':street};
                    c.complete(r);
    			}
    			catch(err)
    			{
    				Map r = {'ok':'no', 'error':err};
    				c.complete(r);
    			}
    		});
		}

		return c.future;
    }
}