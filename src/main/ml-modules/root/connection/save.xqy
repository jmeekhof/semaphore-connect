xquery version '1.0-ml';
import module namespace eput = "http://marklogic.com/rest-api/lib/endpoint-util" at "/MarkLogic/rest-api/lib/endpoint-util.xqy";
import module namespace c = 'pipeline:connection' at "connection.xqy";
declare namespace s = "smartlogic:classification:settings";
declare option xdmp:mapping "false";

let $headers := eput:get-request-headers()
let $method := eput:get-request-method($headers)

let $form-post := c:init-form-vars()
let $doc-uri := c:save-configuration($form-post)
return
  $doc-uri
