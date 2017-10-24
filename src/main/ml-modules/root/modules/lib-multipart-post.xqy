xquery version "1.0-ml" encoding "utf-8";

(:
 : lib-multipart-post.xqy
 :)

(:~
 : Mark Logic multi-part POST Library
 : Assembles a multi-part POST and performs an xdmp:post() sending the data to a webservice URI.
 :
 : The document can be read from the database or the filesystem.  First the database is checked -
 : if the information provided does not resolve a document in the database, it will fall back to
 : trying to get the document from the filesystem
 :
 : @version 1.1
 : @author <a href="mailto:ableasdale@marklogic.com">Alex Bleasdale</a>
 : @requires MarkLogic Server 4.2.x or greater
 :
 : @version 1.2
 : @updatedby <a href="mailto:cmontero@marklogic.com">Carlos Montero</a>
 : @testedOn MarkLogic Server 8.0.2
 :
 :)


module namespace lib-multipart-post = "http://marklogic.com/ps/lib-multipart-post";

declare namespace http = "xdmp:http";

declare default function namespace "http://www.w3.org/2005/xpath-functions";

(: Public functions :)

(:~
: Takes 3 parameters and formats and performs a multi-part http POST
: to a given URI
:
: @param $uri as xs:string
:           - the URI for the webservice
: @param $boundary as xs:string
:           - a string denoting the boundary string value for demarcating
:             break-points between message parts
: @param $data as node()+
:           -
: @return
:           - the XML response from the Web Service.
:
: Example usage:
:
: local:multipart-post(
:                    "http://webservice.com/",
:                    "------------12345xyz",
:   (<data name="file" filename="blah.pdf" type="application/pdf">document-uri OR filesystem/path/to/test-doc.pdf</data>,
:    <data name="api_key">1234xyz</data>,
:    <data name="method">docs.upload</data>) )
:
:)
declare function lib-multipart-post:multipart-post(
                                        $uri as xs:string,
                                        $boundary as xs:string,
                                        $data as element(data)+
) as item()+
{
  let $multipart-encode := lib-multipart-post:multipart-encode($data, $boundary)
  let $boundary-str-len := concat(substring($boundary, string-length($boundary) - 4, 5),fn:codepoints-to-string((13,10)))
  let $length := string-length(string(data($multipart-encode))) idiv 2
  let $patched-multipart-encode := if(xdmp:subbinary($multipart-encode, $length - 6, $length) eq xdmp:unquote($boundary-str-len, (), "format-binary"))
    then (
      xdmp:log("lib-multipart-post :: Bug is present - patching", "debug"),
      binary { xs:hexBinary(concat(string(data(xdmp:subbinary($multipart-encode, 1, $length - 2))), "2D2D"))}
    )
    else (
      xdmp:log("lib-multipart-post :: Bug is not present", "debug"),
      $multipart-encode
    )
  return
  (
  xdmp:http-post(
    $uri,
    <options xmlns="xdmp:http">
      <headers>
        <Content-Type>multipart/form-data; boundary={$boundary}</Content-Type>
      </headers>
    </options>,
    $patched-multipart-encode
  )
  )
};



(: Private Functions :)

declare private function lib-multipart-post:create-parts($data as element(data)+) as node()+ {
    (
    for $data-item in $data
      return lib-multipart-post:create-part($data-item)
    )
};

declare private function lib-multipart-post:create-part($data as element(data)) as node() {

    if (exists($data/@*[local-name(.) eq "type"]))
    then (
        if (exists($data/@fulltext))
        then (
          xdmp:log(concat("lib-multipart-post :: Document: ", $data/text(), " is a valid URI in the database"), "debug"),
          document{$data/*}
        )
        else  ( )
    )
    else (
      if(empty(xdmp:unquote($data/text(), (), "format-binary")))
        then(text{""})
        else(xdmp:unquote($data/text(), (), "format-binary"))
      )
};

declare private function lib-multipart-post:prepare-meta($data as element(data)) as element()+ {
    (
      lib-multipart-post:process-content-disposition($data),
      lib-multipart-post:process-content-type($data)
    )
};

declare private function lib-multipart-post:multipart-encode($data as element(data)+, $boundary as xs:string) {
    let $parts := lib-multipart-post:create-parts($data)
    return
    xdmp:multipart-encode (
    $boundary,
    <manifest xmlns="xdmp:multipart">
    {
    for $part at $pos in $parts
        return element part {
            element http:headers {
               lib-multipart-post:prepare-meta($data[$pos])
            }
        }
    }
    </manifest>, $parts)
};

declare private function lib-multipart-post:process-content-disposition($data as element(data)) as element(Content-Disposition) {
    (
    let $partial-string := concat("form-data; ", lib-multipart-post:extract-data-from-attribute($data, "name"))
    let $string := if (empty( lib-multipart-post:extract-data-from-attribute($data, "filename") ))
    then ($partial-string)
    else (concat($partial-string,"; ", lib-multipart-post:extract-data-from-attribute($data, "filename")))
    return
        element Content-Disposition {$string}
    )
};

declare private function lib-multipart-post:process-content-type($data as element(data)) as element(Content-Type)? {
    if (exists($data/@*[local-name(.) eq "type"]))
    then (element Content-Type {string($data/@*[local-name(.) eq "type"])})
    else ()
};

      (: for $attr in $data/@*
              return xdmp:log(text{"local name: ",local-name($attr), "value: ",string($attr)}), :)

declare private function lib-multipart-post:extract-data-from-attribute($data as element(data), $attr as xs:string) as xs:string? {
    if (exists($data/@*[local-name(.) eq $attr]))
    then (fn:concat($attr,'="', string($data/@*[local-name(.) eq $attr]),'"'))
    else ()
};
