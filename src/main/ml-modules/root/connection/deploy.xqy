xquery version '1.0-ml';
import module namespace c = 'pipeline:connection' at '/connection/connection.xqy';
import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";
import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";
import module namespace mem = "http://xqdev.com/in-mem-update" at "/MarkLogic/appservices/utils/in-mem-update.xqy";
declare namespace error="http://marklogic.com/xdmp/error";
declare option xdmp:mapping 'false';
(:~
 : Create a pipeline.
 :
 : Pipelines need to be created in the triggers database, so an eval will need
 : to be used.
 :
 : Pipeline names need to be unique, so check prior to creating
 :)
let $uri :=xdmp:get-request-field("uri")
let $domain-name := xdmp:get-request-field("domain-name","")
let $cfg := c:read-config($uri)

(:This needs to be eval'd, otherwise pipeline won't be added on time for
 : dom:add-pipeline
 :)
let $pipeline-id :=
  xdmp:eval(
  '
  xquery version "1.0-ml";
  import module namespace c = "pipeline:connection" at "/connection/connection.xqy";
  declare variable $cfg as map:map external;
  c:add-pipeline($cfg)
  ',
  map:new((map:entry(xdmp:key-from-QName(fn:QName('','cfg')), $cfg))),
  <options xmlns="xdmp:eval"><isolation>different-transaction</isolation></options>)
let $_ := dom:add-pipeline($domain-name, $pipeline-id)

return
  xdmp:redirect-response("/index.xqy")
