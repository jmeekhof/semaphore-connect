xquery version '1.0-ml';

import module namespace l = 'pipeline:layout:html' at '/modules/layout.xqy';
import module namespace c = 'pipeline:connection' at '/connection/connection.xqy';
import module namespace dom = "http://marklogic.com/cpf/domains" at "/MarkLogic/cpf/domains.xqy";
declare namespace html = "http://www.w3.org/1999/xhtml";

declare option xdmp:mapping "false";
declare option xdmp:output "method=xhtml";

let $title := xdmp:database-name(xdmp:database())

let $connectors := c:list-connections()

let $database-names := c:get-databases()

let $content := (
    <section class="animated fadeIn w-f">
      <section class="hbox stretch">
        <div class="wrapper">
          <div class="row">
            <div class="col-md-3">
              <div class="panel">
                <div class="panel-heading bg-gradient">
                  <h4 class="m-t-xs m-b-xs text-center">Connectors</h4>
                </div>
                <div class="panel-body text-center">
                  <a href="/connection/add.xqy" class="btn m-b-xs btn-success">Add Connection</a>
                </div>
                  <table class="table table-hover m-b-none">
                    <tbody>
                      <!-- list existing connectors here -->
                      {
                      $connectors !
                      element tr {
                        element td { map:get(.,'connection-name')},
                        element td {
                          attribute width { '150px'},
                          attribute class {'text-right'},
                          element a {
                            attribute class {"btn btn-sm btn-primary"},
                            attribute href { "/connection/edit.xqy?uri="||map:get(.,'uri') },
                            "Edit"
                          },
                          element a {
                            attribute class {"btn btn-sm btn-danger"},
                            attribute href { "/connection/delete.xqy?uri="||map:get(.,'uri')},
                            "Delete"
                          }
                        }
                      }
                      }
                    </tbody>
                  </table>
              </div>
            </div>
            <div xmlns="" class="results col-md-9">
              <div class="panel">
                <div class="panel-heading bg-gradient">
                  <h4 class="m-t-xs m-b-xs">Connector Status</h4>
                </div>
                <table class="table table-striped">
                  <thead>
                    <tr>
                      <th>Connection</th>
                      <th width="40%">Description</th>
                      <th>Domains</th>
                      <th>Deploy</th>
                      <th>Undeploy</th>
                    </tr>
                  </thead>
                  <tbody>
                    <!-- list connector status here -->
                    {
                    $connectors !
                    element tr {
                      element td { map:get(.,'connection-name') },
                      element td { map:get(.,'classification-description') },
                      element td {
                        if (map:contains(.,'domains')) then
                          (
                          let $d := map:get(.,'domains')
                          return
                            (
                              attribute class {'text-success font-bold'},
                              element input {
                                attribute type {"hidden"},
                                attribute name {map:get(.,'connection-name')},
                                attribute values { 1 }
                              },
                              $d/dom:domain-name !  element p { ./text() }
                            )
                          )
                        else
                          (
                           attribute class {'text-danger font-bold'},
                           element input {
                             attribute type {"hidden"},
                             attribute name {map:get(.,'connection-name')},
                             attribute values { 0 }
                           },
                           'Ready To Deploy'
                          )
                      },
                      (:
                       : <a
                       : class="btn btn-sm btn-success"
                       : data-toggle="modal"
                       : href="#deploy"
                       : onClick="document.getElementById('fdeploy').action =
                       : '/deploy/dodeploy.html?
                       : myuri={fn:string($r//*[fn:local-name()="u"])}';
                       : document.getElementById('dLabel').innerHTML =
                       : '&lt;p&gt;Please select the Database and Domain where pipeline &lt;
                       : strong&gt;
                       : {fn:string($r//*[fn:local-name()='pipeline-name'])}&lt;
                       : /strong&gt; will be deployed.&lt;/p&gt;'">Deploy</a>
                       :)
                      element td {
                        element a {
                          attribute class {"btn btn-sm btn-success"},
                          attribute data-toggle {"modal"},
                          attribute href {"#deploy"},
                          "Deploy"
                        }
                      },(:deploy:)
                      (:<a class="btn btn-sm btn-default" data-toggle="modal"
                       : href="#undeploy"
                       : onClick="document.getElementById('fundeploy').action
                       : =
                       : '/undeploy/doundeploy.html?myuri={fn:string($r//*[fn:local-name()="u"])}';document.getElementById('PNAME').value
                       : =
                       : '{fn:string($r//*[fn:local-name()='pipeline-name'])}';document.getElementById('udomlist').innerHTML
                       : = '{$options_str}';
                       : document.getElementById('PID').value =
                       : '{fn:string($id)}';document.getElementById('uLabel').innerHTML
                       : = '&lt;p&gt;Pipeline
                       : &lt;strong&gt;{fn:string($r//*[fn:local-name()='pipeline-name'])}&lt;/strong&gt;
                       : with ID {$id} is currently deployed in the following
                       : domains:&lt;/p&gt;'">Undeploy</a>:)
                      element td {
                        element a {
                          attribute class {"btn btn-sm btn-default"},
                          attribute data-toggle {"modal"},
                          attribute href {"#undeploy"},
                          "Undeploy"
                        }
                      } (:undeploy:)
                    }
                    }
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </section>
    </section>,
    <div class="modal fade" id="deploy" tabindex="-1" role="dialog" aria-labelledby="newModel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h5 class="modal-title">Deploy</h5>
          </div>
          <div class="modal-body">
            <label id="dLabel">.</label>
              <div xmlns="http://www.w3.org/1999/xhtml" class="deploy main">
                <form id="fdeploy" action="/deploy/dodeploy.html?myuri=" method="POST" enctype="multipart/form-data">
                  <div class="form-group">
                    <select class="form-control input-sm" value="dblist" name="dblist" id="dblist">
                      {$database-names}
                    </select>
                  </div>
                </form>
              </div>
          </div>

        </div>
      </div>
    </div>
)



return
  l:assemble-page-default( $title, $content)
