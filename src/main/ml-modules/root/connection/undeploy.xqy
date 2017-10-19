xquery version "1.0-ml";

import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";
import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";

declare option xdmp:mapping "false";

let $pipeline-id := xdmp:get-request-field("pipeline-id")
let $domain-id := xdmp:get-request-field("domain-id")

return
  (
    if ( fn:exists($pipeline-id) and fn:exists($domain-id) ) then
      dom:remove-pipeline(
        dom:domains()[dom:domain-id = xs:unsignedLong($domain-id)]/dom:domain-name,
        xs:unsignedLong($pipeline-id)
      )
    else
      ()
    ,
    xdmp:redirect-response("/")
  )
