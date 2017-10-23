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


(:
<opt:options xmlns:p="http://marklogic.com/cpf/pipelines" xmlns:opt="/classify.xqy">
<s:classification-settings xmlns:s="smartlogic:classification:settings">
<s:connection-name>Classify email</s:connection-name>
<s:classification-server-url>http://apsrd8076:5058/</s:classification-server-url>
<s:classification-description/>
<s:article-type>SA</s:article-type>
<s:root-element>.</s:root-element>
<s:response-element>meta</s:response-element>
<s:response-namespace>urn:namespace:here</s:response-namespace>
<s:classification-timeout>300</s:classification-timeout>
<s:title>title/text()</s:title>
<s:body>/</s:body>
<s:body-type>HTML</s:body-type>
<s:clustering-type>default</s:clustering-type>
<s:clustering-threshold>20</s:clustering-threshold>
<s:threshold>48</s:threshold>
<s:language>en</s:language>
</s:classification-settings>
</opt:options>
 :)
let $_ := xdmp:log(">>>>>>>>>>>>>>>HERE")

let $opt-map := map:new((
  map:entry("title","s:title"),
  map:entry("body", "s:body"),
  map:entry("type", "s:body-type"),
  map:entry("clustering_type", "s:clustering-type"),
  map:entry("clustering_threshold", "s:clustering-threshold"),
  map:entry("language", "s:language"),
  ()
))

(:let $options := function($map as map:map, $options as
 :
 : element(s:classification-settings)) as element(data)* {:)
let $options := function($map, $options) {
  fn:map(
    function($key) {
      let $xp := map:get($map, $key)
      return
        element data {
          attribute name { $key },
          $options/xdmp:value($xp)/fn:string()
        }
      (:
      return
        element data {
          attribute name {$key},
          xdmp:unpath($options || "/" || $xp)
        }
      :)
    },
    map:keys($map)
  )
}

let $data := $options($opt-map, $cpf:options/s:classification-settings)
let $_ := xdmp:log($data)
return
if (cpf:check-transition($cpf:document-uri, $cpf:transition)) then
  try {
    let $cs := $cpf:options/s:classification-settings/s:classification-server-url/fn:string()
    let $doc := fn:doc($cpf:document-uri)
    (:
    let $m-part :=
      mpost:multipart-post($cs,"--deadbeef00--",
      (<data name="UploadFile" filename="{$cpf:document-uri}" type="application/xml">{$cpf:document-uri}</data>)
    )
    :)
    let $m-part := mpost:multipart-post($cs,"--deadbeef00--",(
      <data name="body">{xdmp:url-encode($doc)}</data>,
      <data name="path" />,
      <data name="title">This is a test</data>,
      <data name="type">XML</data>,
      <data name="operation">CLASSIFY</data>
    ))
    let $_ := xdmp:log($m-part)
    let $resp := xdmp:http-post($cs, (), $m-part)
    let $_ := xdmp:log($resp)

    return
    (
    xdmp:log($cs),
    xdmp:log($cpf:options)
    )
  }
  catch($e) {
    cpf:failure( $cpf:document-uri, $cpf:transition, $e, () )
  }
else
  ()
(:
if (cpf:check-transition($cpf:document-uri, $cpf:transition)) then
  try {
    let $aMsg := xdmp:set-request-time-limit(300)
    let $doc := fn:doc( $cpf:document-uri )
    let $doc-without-dpath := element {node-name($doc/*)} {
      $doc/*/@*,
      $doc/*/*[not(name(.)="meta")]
    }

    let $doc-name := $cpf:document-uri
    let $payload := mpost:multipart-post(
    $cpf:remote-url,
    "------------12345xyz",
    (
      <data name="UploadFile" filename="{$doc-name}" type="text/plain" fulltext="yes">{$doc-without-dpath}</data>,
      <data name="XML_INPUT" filename="/csreq-26567061.xml" type="text/xml">/csreq-26567061.xml</data>,
      <data name="method">docs.upload</data>
    ) )

    let $meta :=  <meta>{for $x in $payload/response/STRUCTUREDDOCUMENT/META where  $x[@name="Business Segment"]
 or  $x[@name="Product Family"]
 or  $x[@name="Product Line"]
 or  $x[@name="Product"]  return $x}</meta>
        let $a := $doc/*/meta
        return (
          if (exists($a))
          then xdmp:node-delete($doc/*/meta)
          else (),

          xdmp:node-insert-child($doc/child::element(), $meta),
          xdmp:log( "Add classification metadata ran OK" ),
          cpf:success( $cpf:document-uri, $cpf:transition, () )
         )
  }
  catch ($e) {
    cpf:failure( $cpf:document-uri, $cpf:transition, $e, () )
  }
else
  ()
  :)
