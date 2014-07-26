@isTest
global class MockWhoAtWebAPIRequestIntro implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        // Optionally, only send a mock response for a specific endpoint
        // and method.
        System.assert(req.getEndpoint().startsWith('https://whoat.net/api/v1'));
        System.assertEquals('POST', req.getMethod());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('');
        res.setStatusCode(200);

		//return test value based on incoming url
        if (req.getEndpoint().contains('joe')) {
            res.setBody('{"message": "success"}');
        }
                
        return res;
    }
    
    
}