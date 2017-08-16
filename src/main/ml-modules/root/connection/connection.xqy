xquery version '1.0-ml';

module namespace c = 'pipeline:connection';
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";
import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace e = "xdmp:eval";

declare namespace s = "smartlogic:classification:settings";
declare variable $c:collection-name as xs:string := 'classification-rules';
declare variable $c:trigger-options as element(e:options) := <e:options><e:database>{xdmp:triggers-database()}</e:database></e:options>;

declare option xdmp:mapping 'false';

declare function c:init-form-vars() as map:map {
  (:~ Initialize form vars with some reasonable defaults
   :
   :)
  map:new( (
    map:entry('connection-name', xdmp:get-request-field('connection-name' ,'Default_SCS-1')),
    map:entry('classification-server-url', xdmp:get-request-field('classification-server-url' ,'http://localhost:5058')),
    map:entry('classification-description', xdmp:get-request-field( 'classification-description','')),
    map:entry('article-type', xdmp:get-request-field('article-type' ,'SA')),
    map:entry('root-element', xdmp:get-request-field( 'root-element','.')),
    map:entry('response-element', xdmp:get-request-field( 'response-element','meta')),
    map:entry('response-namespace', xdmp:get-request-field('response-namespace' ,'urn:namespace:here')),
    map:entry('classification-timeout', xdmp:get-request-field( 'classification-timeout' ,'300')),
    map:entry('title',xdmp:get-request-field( 'title' ,'title/text()')),
    map:entry('body', xdmp:get-request-field('body' ,'/')),
    map:entry('body-type', xdmp:get-request-field('body-type' ,'HTML')),
    map:entry('clustering-type', xdmp:get-request-field( 'clustering-type' ,'default')),
    map:entry('clustering-threshold',xdmp:get-request-field('clustering-threshold' ,'20')),
    map:entry('threshold', xdmp:get-request-field('threshold' ,'48')),
    map:entry('language', xdmp:get-request-field('language' ,'')),
    map:entry('rulebases', (xdmp:get-request-field('rulebase'))),
    map:entry('uri', xdmp:get-request-field("uri"))
  ) )
};

declare function c:read-config($uri as xs:string) as map:map {
  let $doc := fn:doc($uri)/s:classification-settings
  let $r-val := map:new( (
    map:entry('connection-name', $doc/s:connection-name),
    map:entry('classification-server-url', $doc/s:classification-server-url),
    map:entry('classification-description', xdmp:get-request-field( 'classification-description','')),
    map:entry('article-type', $doc/s:article-type),
    map:entry('root-element', xdmp:get-request-field( 'root-element','.')),
    map:entry('response-element', xdmp:get-request-field( 'response-element','meta')),
    map:entry('response-namespace', $doc/s:response-namespace),
    map:entry('classification-timeout', xdmp:get-request-field( 'classification-timeout' ,'300')),
    map:entry('title',xdmp:get-request-field( 'title' ,'title/text()')),
    map:entry('body', $doc/s:body),
    map:entry('body-type', $doc/s:body-type),
    map:entry('clustering-type', xdmp:get-request-field( 'clustering-type' ,'default')),
    map:entry('clustering-threshold',$doc/s:clustering-threshold),
    map:entry('threshold', $doc/s:threshold),
    map:entry('language', $doc/s:language),
    map:entry('rulebases', ($doc/s:rulebases/*) ),
    map:entry('uri', $uri)

  ) )
  return $r-val
};

declare function c:new-connection-form() as element() {
  c:connection-form(c:init-form-vars())
};

declare function c:edit-connection-form($uri as xs:string) as element() {
  c:connection-form(c:read-config($uri))
};

declare function
c:connection-form($defaults as map:map) as element() {
  <form class="form" action="/connection/save.xqy?uri={map:get($defaults, 'uri')}"
    method="POST" enctype="multipart/form-data">
    <input type="hidden" id="useGK" name="useGK" value="false"/>
    <div class="panel">
      <div class="panel-heading bg-gradient">
        <h4 class="m-t-xs m-b-xs">Connector Details</h4>
      </div>
      <table class="table table-striped">
        <tr>
          <td>
            <label>Connection Name</label>
          </td>
          <td>
            <input type="text" class="form-control input-sm" id="connection-name" name="connection-name" size="25" value="{map:get($defaults, 'connection-name')}"/>
          </td>
          <td>
            <label>Classification Server URL</label>
          </td>
          <td>
            <input type="text" class="form-control input-sm" id="classification-server-url" name="classification-server-url" size="35" value="{map:get($defaults, 'classification-server-url')}"/>
          </td>
        </tr>
        <tr>
          <td>
            <label>Description</label>
          </td>
          <td>
            <input type="text" class="form-control input-sm" id="classification-description" name="classification-description" size="25" value="{map:get($defaults, "classification-description")}"/>
          </td>

          <td>
            <label>Article Type</label>
          </td>
          <td>
          {
          element input {
            attribute type { "radio"},
            attribute name { "article-type"},
            attribute id { "article-sa" },
            (
              if ( map:get( $defaults, 'article-type') = 'SA' ) then
                attribute checked { "checked" }
              else
                ()
            ),
            attribute value {"SA"}
          }
          }
            &nbsp;<label for="article-sa">Single</label> /
          {
          element input {
            attribute type { "radio"},
            attribute name { "article-type"},
            attribute id { "article-ma" },
            (
              if ( map:get( $defaults, 'article-type') = 'MA' ) then
                attribute checked { "checked" }
              else
                ()
            ),
            attribute value {"MA"}
          }
          }
            &nbsp;<label for="article-ma">Multiple</label>
          </td>
        </tr>
        <tr>
          <td>
            <label>Root Element</label>
          </td>
          <td>
            <input type="text" class="form-control input-sm" id="root-element" name="root-element" size="25" value="{map:get($defaults, 'root-element')}"/>
          </td>

          <td>
            <label>CS Request Timeout</label>
          </td>
          <td>
            <input type="text" class="form-control input-sm" id="classification-timeout" name="classification-timeout" size="10" value="{map:get($defaults, 'classification-timeout')}"/>
          </td>
        </tr>

        <tr>
          <td>
          <label>CS Response Namespace</label>
          </td>
          <td>
            <input type="text" class="form-control input-sm" size="20" name="response-namespace" id="response-namespace" value="{map:get($defaults, 'response-namespace')}"/>
          </td>
          <td>
            <label>CS Response Property</label>
          </td>
          <td>
            <input type="text" class="form-control input-sm" size="20" name="response-element" id="response-element" value="{map:get($defaults, 'response-element')}"/>
          </td>
        </tr>
      </table>
    </div>
    <div class="panel">
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Setting</th>
            <th>Default Value</th>
            <th>Configured</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>Title</td>
            <td>title/text()</td>
            <td>
              <input type="text" class="form-control input-sm" size="30" id="title" name="title" value="{map:get($defaults, 'title')}"/>
            </td>
          </tr>
          <tr>
            <td>Body</td>
            <td> / </td>
            <td>
              <input type="text" class="form-control input-sm" size="30" id="body" name="body" value="{map:get($defaults, 'body')}"/>
            </td>
          </tr>
          <tr>
            <td>Body Type</td>
            <td>HTML</td>
            <td>
              <input type="text" class="form-control input-sm" size="30" id="body-type" name="body-type" value="HTML"/>
            </td>
          </tr>
          <tr>
            <td>Clustering Type</td>
            <td>default</td>
            <td>
              <input type="text" class="form-control input-sm" size="30" id="clustering-type" value="{map:get($defaults, 'clustering-type')}" name="clustering-type"/>
            </td>
          </tr>
          <tr>
            <td>Clustering Threshold</td>
            <td>20</td>
            <td>
              <input type="text" class="form-control input-sm" size="30" id="clustering-threshold" value="{map:get($defaults, 'clustering-threshold')}" name="clustering-threshold"/>
            </td>
          </tr>
          <tr>
            <td>Threshold</td>
            <td>48</td>
            <td>
              <input type="text" class="form-control input-sm" size="30" id="threshold" name="threshold" value="{map:get($defaults, 'threshold')}"/>
            </td>
          </tr>
          <tr>
            <td>Language</td>
            <td>(blank - use auto detect)</td>
            <td>
              <input type="text" class="form-control input-sm" size="30" id="language" name="language" value="{map:get($defaults, 'language')}"/>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div class="panel col">
      <div class="panel-heading bg-gradient text-left">
        <h5 class="m-t-xs m-b-xs">Rulebase class name</h5>
      </div>
      <table class="table table-striped" id="myTable" name="myTable">
        <tbody>
        {

        map:get($defaults, 'rulebases') !
        element tr {
          element td {
            element input {
              attribute name { 'rulebase' },
              attribute value { . },
              attribute type {"text"},
              attribute class {"form-control input-sm"},
              attribute size {"30"}
            }
          }
        }

        }
        </tbody>
      </table>
      <div class="panel-footer">
        <input type="button" class="btn btn-sm btn-primary m-r-xs" onclick="createRuleBase()" value="Add Rulebase"/>
        <input class="btn btn-sm btn-danger" type="button" onclick="deleteRuleBase()" value="Delete Rulebase"/>
      </div>
    </div>
    <div class="text-center m-t-lg m-b-lg">
      <input type="submit" class="btn btn-lg btn-default" formaction="/" value="Cancel"/>
      <input type="submit" class="btn btn-lg btn-success" value="Update"/>
    </div>
  </form>

};

declare function c:save-configuration($form-post as map:map) as xs:string {
  let $doc :=
    <s:classification-settings>
      <s:connection-name>{map:get($form-post, 'connection-name')}</s:connection-name>
      <s:classification-server-url>{map:get($form-post, 'classification-server-url')}</s:classification-server-url>
      <s:classification-description>{map:get($form-post, 'classification-description')}</s:classification-description>
      <s:article-type>{map:get($form-post, 'article-type')}</s:article-type>
      <s:root-element>{map:get($form-post, 'root-element')}</s:root-element>
      <s:response-element>{map:get($form-post, 'response-element')}</s:response-element>
      <s:response-namespace>{map:get($form-post, 'response-namespace')}</s:response-namespace>
      <s:classification-timeout>{map:get($form-post, 'classification-timeout')}</s:classification-timeout>
      <s:title>{map:get($form-post, 'title')}</s:title>
      <s:body>{map:get($form-post, 'body')}</s:body>
      <s:body-type>{map:get($form-post, 'body-type')}</s:body-type>
      <s:clustering-type>{map:get($form-post, 'clustering-type')}</s:clustering-type>
      <s:clustering-threshold>{map:get($form-post, 'clustering-threshold')}</s:clustering-threshold>
      <s:threshold>{map:get($form-post, 'threshold')}</s:threshold>
      <s:language>{map:get($form-post, 'language')}</s:language>
      {
      let $rulebases := map:get($form-post, 'rulebases')
      return
        if ( fn:exists($rulebases) ) then
          element s:rulebases {
            $rulebases ! element s:rulebase { . }
          }
        else
          ()
      }
    </s:classification-settings>
  let $uri :=
    if ( map:contains($form-post, 'uri' ) ) then
      map:get($form-post, 'uri')
    else
      "/classification-settings/" || sem:uuid-string() || ".xml"
  let $_ :=  xdmp:document-insert($uri, $doc, (),($c:collection-name))
  return $uri
};

declare function c:list-connections() as map:map* {

  cts:search(fn:collection($c:collection-name),
    cts:element-query(xs:QName("s:connection-name"), cts:true-query()),
    cts:index-order(cts:element-reference(xs:QName("s:connection-name")))
    )/s:classification-settings
    !
    map:new((
      map:entry('connection-name', ./s:connection-name/text() ),
      map:entry('classification-description',./s:classification-description/text()),
      map:entry('domains', c:get-domains(./s:connection-name/text()) ),
      map:entry('uri', xdmp:node-uri(.))
    ))
};

declare function c:delete-connection($uri as xs:string) as empty-sequence() {
  xdmp:document-delete($uri)
};

declare function c:get-domains($pipeline-name as xs:string) as element(dom:domain)* {
  let $eval :=
    'xquery version "1.0-ml"; ' ||
    'import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy"; ' ||
    'import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy"; ' ||
    'declare variable $pipe-line as xs:string external; ' ||
    'dom:domains()[p:get-by-id(./dom:pipeline)[p:pipeline-name = $pipe-line]] '

  let $vars := map:new ((
    map:entry(xdmp:key-from-QName(fn:QName('','pipe-line')), $pipeline-name)
  ))

  return
    xdmp:eval($eval, $vars, $c:trigger-options)
};

declare function c:get-databases() as element(option)* {
  let $current-db := xdmp:database()

  return xdmp:databases() !
    element option {
        attribute value { . },
        (
        if ( $current-db = . ) then
          attribute selected { 'selected' }
        else
          ()
        ),
        xdmp:database-name(.)
    }
};

declare function c:get-domains() as element(option)* {
  let $eval :=
  "xquery version '1.0-ml'; " ||
  'import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy"; ' ||
  "  dom:domains() ! "||
  "  element option { "||
  "    attribute value { ./dom:domain-id/text() }, "||
  "  ./dom:domain-name/text() "||
  "  } "

  return xdmp:eval($eval, (), $c:trigger-options)
};

declare function c:pipeline-exists($pipeline-name as xs:string) as xs:boolean {
  let  $eval :=
  'xquery version "1.0-ml"; '||
  'import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy"; '||
  'declare variable $pipeline-name as xs:string external; '||
  'declare option xdmp:mapping "false"; '||
  'fn:exists( p:pipelines()[p:pipeline-name = $pipeline-name] )'

  let $vars := map:new( (
    map:entry( xdmp:key-from-QName(fn:QName('','pipeline-name')), $pipeline-name)
  ) )

  return xdmp:eval($eval, $vars, $c:trigger-options)
};

declare function c:add-pipeline($cfg as map:map) as xs:unsignedLong {
  let $eval :=
    "  xquery version '1.0-ml'; " ||
    "  import module namespace p = 'http://marklogic.com/cpf/pipelines' at '/MarkLogic/cpf/pipelines.xqy'; " ||
    "  declare variable $cfg-doc as node() external; " ||
    "  declare variable $cfg as map:map external; " ||
    "  declare option xdmp:mapping 'false'; " ||
    " " ||
    "  let $action := p:action('/classify.xqy', " ||
    "    'This classifies our document against the classification server', " ||
    "    <options><config>{$cfg-doc}</config></options> " ||
    "  ) " ||
    " " ||
    "  return  " ||
    "    p:create( " ||
    "      map:get($cfg, 'connection-name'), " ||
    "      map:get($cfg, 'classification-description'), " ||
    "      (), " ||
    "      (), " ||
    "      ( " ||
    "        p:status-transition('created','',(),(),(),$action ,()), " ||
    "        p:status-transition('updated', '',(),(),(),$action ,()), " ||
    "        p:status-transition('deleted','',(),(),(),(),()) " ||
    "      ), " ||
    "      () " ||
    "    ) "

  let $vars := map:new( (
    map:entry(xdmp:key-from-QName(fn:QName("","cfg-doc")), fn:doc(map:get($cfg,'uri'))),
    map:entry(xdmp:key-from-QName(fn:QName("","cfg")), $cfg)
  ) )

  return xdmp:eval($eval, $vars, $c:trigger-options)
};
