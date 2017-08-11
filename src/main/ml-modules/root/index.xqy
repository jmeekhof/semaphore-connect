xquery version '1.0-ml';

import module namespace l = 'pipeline:layout:html' at '/modules/layout.xqy';

declare option xdmp:mapping "false";
declare option xdmp:output "method=html";

let $title := xdmp:database-name(xdmp:database())

let $content := (
    <section class="animated fadeIn w-f">
      <section class="hbox stretch">
        <header class="bg-white">
          <div class="row b-b m-l-none m-r-none">
            <div class="col-lg-12">
              <h3 class="m-t m-b-none">
                <p class="block">Semaphore Connector</p>
              </h3>
              <p class="block">Home</p>
            </div>
          </div>
        </header>
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
                <form class="form m-b-none" action="/connections/update.html" method="POST" enctype="multipart/form-data">
                  <table class="table table-hover m-b-none">
                    <tbody>
                      <!-- list existing connectors here -->
                    </tbody>
                  </table>
                </form>
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
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </section>
    </section>
)

return
  l:assemble-page-default( $title, $content)
