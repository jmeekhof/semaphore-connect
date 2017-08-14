xquery version '1.0-ml';

import module namespace c = 'pipeline:connection' at '/connection/connection.xqy';

declare option xdmp:mapping "false";


let $uri := xdmp:get-request-field('uri')

let $_ :=
  if ( fn:exists($uri) ) then
    c:delete-connection($uri)
  else
    ()

return
  xdmp:redirect-response('/index.xqy')
