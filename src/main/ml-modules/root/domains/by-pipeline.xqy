xquery version "1.0-ml";

import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";
import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";

declare option xdmp:mapping "false";

let $pipeline-name := xdmp:get-request-field("pipeline-name","")

return
xdmp:to-json(
  json:to-array(
    fn:map(
      function($domain) {
        let $pipelines := $domain/dom:pipeline ! p:get-by-id(.)/p:pipeline-name[. = $pipeline-name]
        return
          if ( fn:exists($pipelines) ) then
            let $dom := json:object()
            let $_ :=
            (
              map:put($dom, "domain-name", $domain/dom:domain-name/fn:string()),
              map:put($dom, "domain-id", $domain/dom:domain-id/fn:string())
            )
            return $dom
          else
            ()
      }, dom:domains()
    )
  )
)
