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
 : Produces a <data> for the mpost library
 :)
let $f := function ($key, $val, $opts, $doc) {
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
let $b := function ($key, $val, $opts, $doc) {
  (:~
   : body function. Produces a value to be posted with a name of $key. This
   : function produces an xpath statement into the document.
   :)
  let $xp := $f($key, $val,$opts,$doc)

  return
    element data {
      attribute name { $key },
      xdmp:quote($doc/xdmp:value($xp))
    }
}

(:~
 : Produces a <data> for the mpost library
 :)
let $at := function($key, $val, $opts, $doc) {
  (:~
   : Post value function. Specifically designed to handle a mutually exclusive
   : option. Multi-article vs single-article.
   :)
  switch($f($key, $val, $opts, $doc))
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
      map:entry("data-function", $at)
    ))
  ),
  map:entry("title",
    map:new((
      map:entry("config-path", "s:title"),
      map:entry("data-function", $b)
    ))
  ),
  map:entry("body",
    map:new((
      map:entry("config-path", "s:body"),
      map:entry("data-function", $b)
    ))
  ),
  map:entry("type",
    map:new((
      map:entry("config-path", "s:body-type"),
      map:entry("data-function", $f)
    ))
  ),
  map:entry("clustering_type",
    map:new((
      map:entry("config-path", "s:clustering-type"),
      map:entry("data-function", $f)
    ))
  ),
  map:entry("threshold",
    map:new((
      map:entry("config-path", "s:threshold"),
      map:entry("data-function", $f)
    ))
  ),
  map:entry("clustering_threshold",
    map:new((
      map:entry("config-path", "s:clustering-threshold"),
      map:entry("data-function", $f)
    ))
  ),
  map:entry("language",
    map:new((
      map:entry("config-path", "s:language"),
      map:entry("data-function", $f)
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
      $w-qname := fn:QName($ns, $cs-wrap),
      $m-qname := fn:QName($ns, $cs-elem),

      $_ := xdmp:log($w-qname, "info"),
      $_ := xdmp:log($m-qname, "info"),

      $cs-meta :=fn:map(
      function($x){
        element {$m-qname} {
          $x/@* !
          (
          element {fn:QName($ns,fn:local-name(.))} { fn:data(.) }
          ),
          element {fn:QName($ns, "nameValueScore")} { fn:string-join( ($x/@name, $x/@value, $x/@score), "^") },
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
       : Remove previous rulebases if they exists, otherwise proceed as normal
       :)
      if ( fn:exists($doc//element()[fn:node-name(.) = $w-qname]) ) then
        (
        xdmp:log("meta exists", "info"),

        $doc//element()[fn:node-name(.) = $w-qname] !
        xdmp:node-delete(.)
        )
      else
        xdmp:log("meta doesn't exist", "info")
      ,
      (:~
       : This is proceding as normal
       :)
      xdmp:node-insert-child($doc/child::element(),
        element { $w-qname } {
          attribute classification-dateTime { fn:current-dateTime() },
          $cs-meta
        }
      ),
      cpf:success( $cpf:document-uri, $cpf:transition, ())
      )
  }
  catch($e) {
    cpf:failure( $cpf:document-uri, $cpf:transition, $e, () )
  }
else
  ()
