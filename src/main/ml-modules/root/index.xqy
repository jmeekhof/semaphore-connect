xquery version '1.0-ml';

import module namespace l = 'pipeline:layout:html' at '/modules/layout.xqy';

declare option xdmp:mapping "false";
declare option xdmp:output "method=html";

let $title := xdmp:database-name(xdmp:database())
let $headers := (
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>,
  <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"/>,
  <link rel="stylesheet" href="/resources/css/app.css" />,
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"/>,
  <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"/>
)

let $content := (
<div>
  <section xmlns="" class="vbox">
    <header id="nav-bar-main" class="header bg-primary nav-bar">
      <div class="navbar-header">
        <a class="navbar-brand animated pulse no-padder m-r" href="/">
          <img class="m-t" alt="Smartlogic" width="80px" src="/resources/images/smartlogic-logo.png"/>
        </a>
      </div>
    </header>
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
                  <form action="/connections/main.html" method="POST" enctype="multipart/form-data">
                    <input formaction="/connections/addDefault.html" type="submit" value="Add Connection" name="myAction2" id="myAction2" data-toggle="tooltip" data-placement="top" title="Add a default connection" class="btn m-b-xs btn-success"/>
                  </form>
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
      <footer class="footer bg-white text-right">
        <p>
          <img style="height: 20px" src="resources/images/ml-logo.gif"/>
        </p>
        <br/>
        <p style="font-size:75%;">Semaphore Connector v<!-- version here, eventually --></p>
      </footer>
    </section>
  </section>
</div>
)

return
l:assemble-page(
	$title,
	$content,
	$headers
)
