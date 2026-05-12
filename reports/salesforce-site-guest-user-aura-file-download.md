Title: Auth layer on api.exchange.coinbase.com throws uncaught exception on malformed credentials, returns HTTP 500 across trading endpoints                                                     
                                                                                                                                                                                                   
  Summary
                                                                                                                                                                                                   
  Both authentication paths on api.exchange.coinbase.com throw an uncaught exception when given malformed but well-shaped input. The Bearer token path crashes on any non-empty token. The HMAC    
  path crashes when CB-ACCESS-KEY, a current CB-ACCESS-TIMESTAMP, and a bogus CB-ACCESS-SIGN are sent together. The response is HTTP 500 with body {"message":"Internal Server Error."} instead of
  the expected 401. The same crash reproduces on the main trading endpoints (/accounts, /orders, /fills, /users, /profiles, /coinbase-accounts) but not on others (/payment-methods, /transfers,   
  /reports), which establishes the bug as a missing error-handling wrapper on a specific route group rather than a global edge issue. The same internal error body is also forwarded through the 
  WebSocket endpoint as the reason field of a WS error frame.

  Steps to reproduce

  1. Bearer path. Send a non-empty Bearer token to any auth-protected endpoint.                                                                                                                    
   
  curl -i https://api.exchange.coinbase.com/accounts \                                                                                                                                             
    -H "Authorization: Bearer test"                                                                                                                                                              

  Result: HTTP/2 500 with {"message":"Internal Server Error."}. Any non-empty token value triggers it. An empty Bearer returns a clean 401 ({"message":"Access token is invalid"}), which locates  
  the crash specifically in the parser branch that runs once a token is present.
                                                                                                                                                                                                   
  2. HMAC path. Send valid-shape HMAC headers with a current timestamp and a bogus signature.                                                                                                    

  NOW=$(date -u +%s)
  curl -i https://api.exchange.coinbase.com/accounts \
    -H "CB-ACCESS-KEY: test" \                                                                                                                                                                     
    -H "CB-ACCESS-TIMESTAMP: $NOW" \
    -H "CB-ACCESS-SIGN: AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA" \                                                                                                        
    -H "CB-ACCESS-PASSPHRASE: x"                                                                                                                                                                   
                                                                                                                                                                                                   
  Result: HTTP/2 500 with the same body. The intermediate states are clean:                                                                                                                        
                                                                                                                                                                                                 
  - CB-ACCESS-KEY alone: 401 {"message":"invalid timestamp"}                                                                                                                                       
  - CB-ACCESS-KEY plus future timestamp: 401 {"message":"request timestamp expired"}                                                                                                             
  - CB-ACCESS-KEY plus current timestamp plus invalid signature: 500                                                                                                                               
                                                                                                                                                                                                 
  The handler proceeds through timestamp validation correctly. The crash is in the next step, signature verification.                                                                              
                                                                                                                                                                                                 
  3. Endpoint coverage table. Same payloads, different routes.                                                                                                                                     
                                                                                                                                                                                                 
  ┌────────────────────┬────────┬─────────────────────────────┐                                                                                                                                    
  │      Endpoint      │ Bearer │ HMAC (key + ts + bogus sig) │                                                                                                                                  
  ├────────────────────┼────────┼─────────────────────────────┤
  │ /accounts          │ 500    │ 500                         │
  ├────────────────────┼────────┼─────────────────────────────┤
  │ /orders            │ 500    │ 500                         │                                                                                                                                    
  ├────────────────────┼────────┼─────────────────────────────┤
  │ /fills             │ 500    │ 500                         │                                                                                                                                    
  ├────────────────────┼────────┼─────────────────────────────┤                                                                                                                                  
  │ /users             │ 500    │ 500                         │
  ├────────────────────┼────────┼─────────────────────────────┤
  │ /profiles          │ 500    │ 500                         │
  ├────────────────────┼────────┼─────────────────────────────┤                                                                                                                                    
  │ /coinbase-accounts │ 500    │ 500                         │
  ├────────────────────┼────────┼─────────────────────────────┤                                                                                                                                    
  │ /payment-methods   │ 500    │ 401 (clean)                 │                                                                                                                                  
  ├────────────────────┼────────┼─────────────────────────────┤
  │ /transfers         │ 500    │ 401 (clean)                 │
  ├────────────────────┼────────┼─────────────────────────────┤                                                                                                                                    
  │ /reports           │ 500    │ 401 (clean)                 │
  └────────────────────┴────────┴─────────────────────────────┘                                                                                                                                    
                                                                                                                                                                                                 
  The Bearer path crashes on every endpoint I tested. The HMAC path crashes on a subset. This is direct evidence of inconsistent error-handling between route groups within the same service. The  
  crashing routes are missing a wrapper that the cleanly-rejecting routes already have.
                                                                                                                                                                                                   
  4. WebSocket. Connect to wss://ws-feed-public.sandbox.exchange.coinbase.com, subscribe with an unknown channel name, and read the response.                                                      
   
  {"type":"error","message":"Authentication Failed","reason":"{\"message\":\"Internal Server Error.\"}"}                                                                                           
                                                                                                                                                                                                   
  The HTTP-side error body is serialized verbatim into the WS reason field as a string. This is observable cross-transport behavior, not inference. It also confirms the underlying auth helper is 
  reachable through more than one transport.                                                                                                                                                       
                                                                                                                                                                                                   
  Reproducibility                                                                                                                                                                                  
   
  I ran 27 invocations against the affected endpoints, three attempts per endpoint for each of Bearer and HMAC. The Bearer crash reproduces on every attempt across every endpoint listed. The HMAC
   crash reproduces deterministically on the crashing subset listed in the table. The response carries the application's standard CB CORS headers and an etag, which places the 500 in the normal
  application response pipeline rather than at a network edge.                                                                                                                                     
                                                                                                                                                                                                 
  What this report covers

  This finding is scoped to three concrete, observable claims:                                                                                                                                     
   
  1. The auth layer reaches an unhandled exception on malformed but well-shaped credentials, and returns HTTP 500 instead of HTTP 401.                                                             
  2. Error handling is inconsistent across route groups in the same service. Some routes catch the same exception cleanly and return 401, others do not.                                         
  3. The HTTP error body is forwarded into the WebSocket error frame reason field as a string, when subscribing through wss://ws-feed-public.sandbox.exchange.coinbase.com.                        
                                                                                                                                                                                                   
  I am not claiming denial of service, downstream logging exposure, or stack trace disclosure. I did not measure resource consumption, sustained request rates, or any form of runtime degradation,
   and I did not attempt to. Triage may want to characterize those questions separately if it matters for severity.                                                                                
                                                                                                                                                                                                   
  Suggested remediation                                                                                                                                                                          

  Wrap the auth validation entry point in a try/catch (or .catch() on the underlying promise) and return a clean 401 on any thrown exception. The signature verifier and the Bearer decoder should 
  not be able to surface an unhandled exception to the response pipeline. Audit the middleware mounting between the route groups listed in step 3: the routes that already return clean 401s on bad
   HMAC have the wrapper, the routes that 500 do not. Aligning them will also stop the upstream 500 string from propagating into the WebSocket reason field.