xquery version '1.0-ml';

module namespace c = 'pipeline:connection';
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";
import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";
import module namespace p = "http://marklogic.com/cpf/pipelines" at "/MarkLogic/cpf/pipelines.xqy";
declare namespace html = "http://www.w3.org/1999/xhtml";
declare namespace e = "xdmp:eval";
declare namespace error="http://marklogic.com/xdmp/error";

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
    map:entry('response-wrapper', xdmp:get-request-field('redirect-response', 'classification-data')),
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
    map:entry('response-wrapper', $doc/s:response-wrapper),
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
        <tr>
          <td><label>CS Response Wrapper</label></td>
          <td>
            <input type="text" class="form-control input-sm" size="20" name="response-wrapper" id="response-wrapper" value="{map:get($defaults, 'response-wrapper')}"/>
          </td>
          <td>&nbsp;</td>
          <td>&nbsp;</td>
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
              <select class="form-control input-sm" id="body-type" name="body-type">
              {
              ("HTML","TEXT") !
              (
                element option {
                  attribute value {.},
                  if ( map:get($defaults, "body-type") = . ) then
                    attribute selected {"selected"}
                  else
                    ()
                  ,
                  .
                }
              )
              }
              </select>
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
      <s:response-wrapper>{map:get($form-post, 'response-wrapper')}</s:response-wrapper>
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
      map:entry('pipeline-id', c:get-pipeline-by-name(./s:connection-name/fn:string())/p:pipeline-id),
      map:entry('classification-description',./s:classification-description/text()),
      map:entry('domains', c:get-domains-by-pipeline(./s:connection-name/text()) ),
      map:entry('uri', xdmp:node-uri(.))
   ))

};


declare function c:delete-connection($uri as xs:string) as empty-sequence() {
  (:~
   : Delete the config file for a connection. Look to see if this config has
   : been used to deploy a pipeline. Remove the pipeline from the domains it's
   : associated with then remove the pipeline.
   :)
  let $cfg := c:read-config($uri)
  let $pipeline := c:get-pipeline($cfg)
  let $_ := xdmp:log($pipeline)
  return
    (
      if ( fn:exists($pipeline) ) then
        let $domains := c:get-domains-by-pipeline($pipeline/p:pipeline-name)
        return
        (
          $domains ! dom:remove-pipeline(./dom:domain-name, $pipeline/p:pipeline-id),
          p:remove($pipeline/p:pipeline-name)
        )
      else
        ()
      ,
      xdmp:document-delete($uri)
    )
};

declare function c:get-domains-by-pipeline($pipeline-name as xs:string) as element(dom:domain)* {
  (:dom:domains()[p:get-by-id(./dom:pipeline)[p:pipeline-name =
   : $pipeline-name]]:)
  fn:map(function($d) {
  let $pipelines := $d/dom:pipeline ! p:get-by-id(.)
  return
  if (fn:exists($pipelines[p:pipeline-name = $pipeline-name]) ) then
    $d
  else
    ()
  }, dom:domains())
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
  dom:domains() !
  element option {
    attribute value { ./dom:domain-name/text() },
  ./dom:domain-name/text()
  }
};

declare function c:pipeline-exists($pipeline-name as xs:string) as xs:boolean {
  fn:exists( p:pipelines()[p:pipeline-name = $pipeline-name] )
};

declare function c:pipeline($cfg as map:map) as element(p:pipeline) {
  let $action := p:action('/classify.xqy',
    'This classifies our document against the classification server',
    <options><config>{fn:doc(map:get($cfg,'uri'))}</config></options>
  )
  return
  element p:pipeline {
    element p:pipeline-name { map:get($cfg, 'connection-name')/fn:string()},
    element p:pipeline-description { map:get($cfg, 'connection-description')/fn:string()},
    element p:success-action {
      p:action(
        '/MarkLogic/cpf/actions/success-action.xqy',
        (),
        <opt:options xmlns:opt="/MarkLogic/cpf/actions/success-action.xqy"/>
      )/element()
    },
    element p:failure-action {
      p:action(
      '/MarkLogic/cpf/actions/failure-action.xqy',
      (),
      <opt:options xmlns:opt="/MarkLogic/cpf/actions/failure-action.xqy"/>
      )/element()
    },
    p:status-transition('created','',(),(),(),() ,()),
    p:status-transition('updated', '',(),(),(),() ,()),
    p:status-transition('deleted','',(),(),(),(),())
    ()
  }
};

declare function c:add-pipeline($cfg as map:map) as xs:unsignedLong {
  let $action := p:action('/classify.xqy',
    'This classifies our document against the classification server',
    <options><config>{fn:doc(map:get($cfg,'uri'))}</config></options>
  )

  let $pipeline :=
    <p:pipeline xml:lang="zxx" xmlns:p="http://marklogic.com/cpf/pipelines">
      <p:pipeline-name>{map:get($cfg, 'connection-name')/fn:string()}</p:pipeline-name>
      <p:pipeline-description>{map:get($cfg, 'classification-description')} </p:pipeline-description>
      <p:success-action>
        <p:annotation/>
        <p:module>/MarkLogic/cpf/actions/success-action.xqy</p:module>
        <opt:options xmlns:opt="/MarkLogic/cpf/actions/success-action.xqy"> </opt:options>
      </p:success-action>
      <p:failure-action>
        <p:annotation/>
        <p:module>/MarkLogic/cpf/actions/failure-action.xqy</p:module>
        <opt:options xmlns:opt="/MarkLogic/cpf/actions/failure-action.xqy">
        </opt:options>
      </p:failure-action>
      <p:status-transition>
        <p:annotation/>
        <p:status>created</p:status>
        <p:default-action>
          <p:annotation>This classifies our document against the classification server</p:annotation>
          <p:module>/classify.xqy</p:module>
          <opt:options xmlns:opt="/classify.xqy">
            {fn:doc(map:get($cfg, 'uri'))}
          </opt:options>
        </p:default-action>
      </p:status-transition>
      <p:status-transition>
        <p:annotation/>
        <p:status>updated</p:status>
        <p:default-action>
          <p:annotation>This classifies our document against the classification server</p:annotation>
          <p:module>/classify.xqy</p:module>
          <opt:options xmlns:opt="/classify.xqy">
            {fn:doc(map:get($cfg, 'uri'))}
          </opt:options>
        </p:default-action>
      </p:status-transition>
      <p:status-transition>
        <p:annotation/>
        <p:status>deleted</p:status>
      </p:status-transition>
    </p:pipeline>

  return
    p:insert($pipeline)
};

declare function c:remove-pipeline($cfg as map:map) as empty-sequence() {
  p:remove(map:get($cfg, 'connection-name'))
};

declare function c:get-pipeline($cfg as map:map) as element(p:pipeline)? {
  (:~
   : Safe get pipeline. Won't throw an error if the pipeline doesn't exist.
   :)
    try {
      p:get(map:get($cfg, 'connection-name'))
    }
    catch($e) {
      if ( $e/error:code = "CPF-PIPELINENOTFOUND" ) then
        ()
      else
        xdmp:rethrow()
    }
};

declare function c:get-pipeline-by-name($name as xs:string) as element(p:pipeline)? {
  c:get-pipeline(map:new(( map:entry("connection-name", $name) )) )
};

declare function c:add-pipeline-to-domain($domain as xs:string, $pipeline-id as xs:unsignedLong) as empty-sequence() {
  dom:add-pipeline($domain, $pipeline-id)
};

declare function c:remove-pipeline-from-domain($domain as xs:string, $pipeline-id as xs:unsignedLong) as empty-sequence() {
  dom:remove-pipeline($domain, $pipeline-id)
};
