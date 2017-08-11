xquery version '1.0-ml';

import module namespace l = 'pipeline:layout:html' at '/modules/layout.xqy';

declare option xdmp:mapping "false";
declare option xdmp:output "method=html";


let $title := "Semaphore Connector &mdash; Add Connection"

let $content := (
  <div class="wrapper">
    <div class="row">

      <div class="connections main col-lg-8">
        <form class="form" action="/connections/replace.html" method="POST" enctype="multipart/form-data" onsubmit="x = document.getElementById('myTable').rows.length; document.getElementById('filterCount').value = x; var xslt = document.getElementById('xslt').value; document.getElementById('filenameXSL').value = xslt; var checked = document.getElementById('toggleForm').checked; document.getElementById('useXSL').value = checked;  var checked = document.getElementById('UGK').checked; document.getElementById('useGK').value = checked">
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
                  <input type="text" class="form-control input-sm" id="cname" name="cname" size="25" value="Default_SCS-1"/>
                </td>
                <td>
                  <label>Classification Server URL</label>
                </td>
                <td>
                  <input type="text" class="form-control input-sm" id="sserv" name="sserv" size="35" value="http://localhost:5058"/>
                </td>
              </tr>
              <tr>
                <td>
                  <label>Description</label>
                </td>
                <td>
                  <input type="text" class="form-control input-sm" id="desc" name="desc" size="25" value="Enhances Metadata (ID: 26-18-30-63-75)"/>
                </td>
                <td>
                  <label> Single Article</label>
                </td>
                <td>
                  <input type="radio" id="radiosa" checked="checked" name="radioac" value="SA"/>
                </td>
              </tr>
              <tr>
                <td>
                  <label>Root Element</label>
                </td>
                <td>
                  <input type="text" class="form-control input-sm" id="relem" name="relem" size="25" value="."/>
                </td>
                <td>
                  <label> Multi-Article</label>
                </td>
                <td>
                  <input type="radio" id="radioma" name="radioac" value="MA"/>
                </td>
              </tr>
              <tr>
                <td>
                  <label>CS Response Property</label>
                </td>
                <td>
                  <input type="text" class="form-control input-sm" size="20" name="dpath" id="dpath" value="meta"/>
                </td>
                <td>
                  <label>CS Request Timeout</label>
                </td>
                <td>
                  <input type="text" class="form-control input-sm" id="timeout" name="timeout" size="10" value="300"/>
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
                  <td>Tittle</td>
                  <td>title/text()</td>
                  <td>
                    <input type="text" class="form-control input-sm" size="30" id="tittle" name="tittle" value="tittle/text()"/>
                  </td>
                </tr>
                <tr>
                  <td>Body</td>
                  <td> / </td>
                  <td>
                    <input type="text" class="form-control input-sm" size="30" id="body" name="body" value="/"/>
                  </td>
                </tr>
                <tr>
                  <td>Body Type</td>
                  <td>HTML</td>
                  <td>
                    <input type="text" class="form-control input-sm" size="30" id="bodyType" name="bodyType" value="HTML"/>
                  </td>
                </tr>
                <tr>
                  <td>Clustering Type</td>
                  <td>default</td>
                  <td>
                    <input type="text" class="form-control input-sm" size="30" id="clusType" value="default" name="clusType"/>
                  </td>
                </tr>
                <tr>
                  <td>Clustering Threshold</td>
                  <td>20</td>
                  <td>
                    <input type="text" class="form-control input-sm" size="30" id="clusThres" value="20" name="clusThres"/>
                  </td>
                </tr>
                <tr>
                  <td>Threshold</td>
                  <td>48</td>
                  <td>
                    <input type="text" class="form-control input-sm" size="30" id="threshold" name="threshold" value="48"/>
                  </td>
                </tr>
                <tr>
                  <td>Language</td>
                  <td>(blank - use auto detect)</td>
                  <td>
                    <input type="text" class="form-control input-sm" size="30" id="language" name="language" value=""/>
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
              <input type="button" class="btn btn-sm btn-primary m-r-xs" onclick="myCreateFunction()" value="Add Rulebase"/>
              <input class="btn btn-sm btn-danger" type="button" onclick="myDeleteFunction()" value="Delete Rulebase"/>
            </div>
          </div>
          <div class="text-center m-t-lg m-b-lg">
            <input type="submit" class="btn btn-lg btn-default" formaction="/" value="Cancel"/>
            <input type="submit" class="btn btn-lg btn-success" value="Update"/>
          </div>
        </form>
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
