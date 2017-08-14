xquery version '1.0-ml';

module namespace c = 'pipeline:connection';
import module namespace functx = "http://www.functx.com" at "/MarkLogic/functx/functx-1.0-nodoc-2007-01.xqy";

declare namespace s = "smartlogic:classification:settings";

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
    map:entry('language', xdmp:get-request-field( 'language' ,'')),
    map:entry('rulebases', (xdmp:get-request-field('rulebase')) )
  ) )
};

declare function c:new-connection-form() {
  c:connection-form(c:init-form-vars())
};

declare function
c:connection-form($defaults as map:map) as element()* {
  <form class="form" action="/connection/save.xqy" method="POST" enctype="multipart/form-data" onsubmit="x = document.getElementById('myTable').rows.length; document.getElementById('filterCount').value = x; var xslt = document.getElementById('xslt').value; document.getElementById('filenameXSL').value = xslt; var checked = document.getElementById('toggleForm').checked; document.getElementById('useXSL').value = checked;  var checked = document.getElementById('UGK').checked; document.getElementById('useGK').value = checked">
    <input type="hidden" name="myuri" value="/pipelines/2558146824718105252.xml"/>
    <input type="hidden" name="filterCount" id="filterCount"/>
    <input type="hidden" id="filenameXSL" name="filenameXSL" value="DefaultXSL.xsl"/>
    <input type="hidden" id="useXSL" name="useXSL" value="false"/>
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
        <tbody/>
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
