part of authServer;

@app.Group('/data')
class DataService {
    @app.Route('/street', methods: const[app.POST])
    Future<Map> requestStreet(@app.Body(app.JSON) Map parameters) async
    {
        if (!SESSIONS.containsKey(parameters['sessionToken']))
            return {'ok':'no', 'error':'not logged in'};
        else {
            String tsid = parameters['street'];
            if (tsid.startsWith('L'))
                tsid = tsid.replaceFirst('L', 'G');
            String url = "http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$tsid.json";
            http.Response response = await http.get(url);

            try {
                Map street = JSON.decode(response.body);
                return {'ok':'yes', 'streetJSON':street};
            }
            catch (err) {
                return {'ok':'no', 'error':err};
            }
        }
    }
}