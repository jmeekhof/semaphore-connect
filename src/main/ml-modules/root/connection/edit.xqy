xquery version '1.0-ml';

import module namespace l = 'pipeline:layout:html' at '/modules/layout.xqy';
import module namespace c = 'pipeline:connection' at '/connection/connection.xqy';
declare namespace html = "http://www.w3.org/1999/xhtml";

declare option xdmp:mapping "false";
declare option xdmp:output "method=xhtml";

let $uri := xdmp:get-request-field("uri")
return
if ( fn:not(fn:exists($uri))  ) then
  xdmp:redirect-response("/index.xqy")
else

let $title := "Semaphore Connector &mdash; Edit Connection"

let $content := (
  <div class="wrapper">
    <div class="row">
      <div class="connections main col-lg-8">
      { c:edit-connection-form($uri) }
      </div>
      <div class="col-lg-4">
        <div class="panel">
          <div class="panel-heading bg-gradient">
            <h5 class="m-t-xs m-b-xs">
              <label> <input name="UGK" id="UGK" type="checkbox" onchange="()"/> Use Generated Keys</label>
              <br/>
              <label> <input id="toggleForm" type="checkbox" onchange="activeXSLOnChange()"/> Classification Server feedback </label>
            </h5>
          </div>
        </div>
      </div>
    </div>
  </div>
)

return l:assemble-page-default($title, $content)
