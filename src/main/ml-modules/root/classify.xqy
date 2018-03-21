xquery version "1.0-ml";

import module namespace mpost = "http://marklogic.com/ps/lib-multipart-post" at "/modules/lib-multipart-post.xqy";
import module namespace cpf = "http://marklogic.com/cpf"  at "/MarkLogic/cpf/cpf.xqy";
import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";
declare namespace opt = "/classify.xqy";
declare namespace s = "smartlogic:classification:settings";

declare variable $cpf:document-uri as xs:string external;
declare variable $cpf:transition as element() external;
declare variable $cpf:options as element() external;

declare option xdmp:mapping "false";

(:~
 : These functions all need an arity of 4.
 : $key, $val, $opts, & $doc
 :
 : Each is a basic variation of create this $key and either take the $val from
 : the $opts structure or the $doc.
 :)
(:~
 : Produces a <data> for the mpost library
 :)
let $config-value-func := function (
  $key as xs:string,
  $val as xs:string,
  $opts as element()*,
  $doc as document-node()* )
{
  (:~
   : This produces a value to be posted. Taken from the options document
   :)
  element data {
    attribute name { $key },
    $opts/xdmp:value($val)/fn:string()
  }
}

(:~
 : Produces a <data> for the mpost library
 :)
let $doc-value-func := function (
  $key as xs:string,
  $val as xs:string,
  $opts as element()*,
  $doc as document-node()* )
{
  (:~
   : body function. Produces a value to be posted with a name of $key. This
   : function produces an xpath statement into the document.
   :)
  let $xp := $config-value-func($key, $val,$opts,$doc)

  return
    element data {
      attribute name { $key },
      xdmp:quote($doc/xdmp:value($xp))
    }
}

(:~
 : Produces a <data> for the mpost library
 :)
let $article-type-func := function (
  $key as xs:string,
  $val as xs:string,
  $opts as element()*,
  $doc as document-node()* )
{
  (:~
   : Post value function. Specifically designed to handle a mutually exclusive
   : option. Multi-article vs single-article.
   :)
  switch($config-value-func($key, $val, $opts, $doc))
    case "MA" return element data { attribute name { "multiarticle" } }
    default return element data { attribute name { "singlearticle" } }
}

(:~
 : This is a map of options ($cpf:options) to the <data> for mpost. Basically
 : a map from the element to the function to transform that element to what we
 : want for our mpost
 :)
let $opt-map := map:new((
  map:entry("articletype",
    map:new((
      map:entry("config-path", "s:article-type"),
      map:entry("data-function", $article-type-func)
    ))
  ),
  map:entry("title",
    map:new((
      map:entry("config-path", "s:title"),
      map:entry("data-function", $doc-value-func)
    ))
  ),
  map:entry("body",
    map:new((
      map:entry("config-path", "s:body"),
      map:entry("data-function", $doc-value-func)
    ))
  ),
  map:entry("type",
    map:new((
      map:entry("config-path", "s:body-type"),
      map:entry("data-function", $config-value-func)
    ))
  ),
  map:entry("clustering_type",
    map:new((
      map:entry("config-path", "s:clustering-type"),
      map:entry("data-function", $config-value-func)
    ))
  ),
  map:entry("threshold",
    map:new((
      map:entry("config-path", "s:threshold"),
      map:entry("data-function", $config-value-func)
    ))
  ),
  map:entry("clustering_threshold",
    map:new((
      map:entry("config-path", "s:clustering-threshold"),
      map:entry("data-function", $config-value-func)
    ))
  ),
  map:entry("language",
    map:new((
      map:entry("config-path", "s:language"),
      map:entry("data-function", $config-value-func)
    ))
  ),
  ()
))

(:~
 : This puts it all together. This applies the map to the functions with the
 : accompanying document data
 :)
let $option-f := function($map, $options, $doc) {
  (:~
   : @param $map the map containing the values
   : @param $options map to be passed along with the data function
   : @param $doc the actual content to be passed with data function
   :
   : @return a sequence of values corresponding to the transformations
   : prescibed by the data-functions. Some data points use values from the
   : document, others use values from the config document.
   :)
  fn:map(
    function($key) {
      let $cfg-map := map:get($map, $key)
      let $xp := map:get($cfg-map, "config-path")
      let $d-f := map:get($cfg-map, "data-function")
      return
        $d-f($key, $xp, $options, $doc)
    },
    map:keys($map)
  )
}

(:~
 : Now all the setup is done. Post the data to the classification server
 :)
return
if (cpf:check-transition($cpf:document-uri, $cpf:transition)) then
  try {
    let
      $cs := $cpf:options/s:classification-settings/s:classification-server-url/fn:string(),
      $doc := fn:doc($cpf:document-uri),
      $data := $option-f($opt-map, $cpf:options/s:classification-settings, $doc),

      $_ := xdmp:log("cs:opts>>>", "info"),
      $_ := xdmp:log($cpf:options, "info"),
      $_ := xdmp:log("data>>>>", "info"),
      $_ := xdmp:log($data, "info"),

      (:~
       : This posts to the classification server. The return is the
       : classification data. The full xsd is available on
       : https://portal.smartlogic.com/docs/classification_server_-_developers_guide/appendix_-_xml_dtd
       :)
      $m-part := mpost:multipart-post($cs,"--deadbeef00--",$data),

      $_ := xdmp:log($m-part, "info"),

      $ns := $cpf:options/s:classification-settings/s:response-namespace/fn:string(),
      $cs-elem := $cpf:options/s:classification-settings/s:response-element/fn:string(),
      $cs-wrap := $cpf:options/s:classification-settings/s:response-wrapper/fn:string(),
      $wrapper-qname := fn:QName($ns, $cs-wrap),
      $m-qname := fn:QName($ns, $cs-elem),

      $_ := xdmp:log($wrapper-qname, "info"),
      $_ := xdmp:log($m-qname, "info"),

      $cs-meta :=fn:map(
      function($x){
        let $rulebase-name := $x/@name,
          $namespace := (
            $cpf:options/s:classification-settings/s:rulebases
              /s:rulebase[./fn:string() = $rulebase-name]/@namespace,
            $ns
          )[1],
          $_ := xdmp:log("rbname>>> " || $rulebase-name, "info"),
          $_ := xdmp:log($namespace, "info")

        return
        element {$m-qname} {
          $x/@* !
          (
          element {fn:QName($namespace,fn:local-name(.))} { fn:data(.) }
          ),
          element {fn:QName($namespace, "nameValueScore")} { fn:string-join( ($x/@name, $x/@value, $x/@score), "^") },
          $x/fn:data()
        }
      },
        (:~
         : Filter the meta nodes IF rulebases are specified. Otherwise, return
         : them all
         :)
        if ( fn:exists($cpf:options/s:classification-settings/s:rulebases)) then
          fn:filter(
            function($z) {
              fn:exists($z[@name = $cpf:options/s:classification-settings/s:rulebases/s:rulebase])
            },
            $m-part/response/STRUCTUREDDOCUMENT/META)
        else
          $m-part/response/STRUCTUREDDOCUMENT/META
      )
    return
      (
      (:~
       : Replace previous rulebases if they exists, otherwise add
       :)
      let
        $existing-node := $doc/child::element()/element()
          [fn:node-name(.) = $wrapper-qname],
        $cs-element :=
          element { $wrapper-qname } {
            attribute classification-dateTime { fn:current-dateTime() },
            $cs-meta
          }
      return
        if ( fn:exists($existing-node) ) then
          (
          xdmp:log("meta exists", "info"),
          xdmp:node-replace($existing-node, $cs-element)
          )
        else
          (
          xdmp:log("meta doesn't exist", "info"),
          xdmp:node-insert-child($doc/child::element(), $cs-element)
          ),
      cpf:success( $cpf:document-uri, $cpf:transition, ())
      )
  }
  catch($e) {
    cpf:failure( $cpf:document-uri, $cpf:transition, $e, () )
  }
else
  ()
