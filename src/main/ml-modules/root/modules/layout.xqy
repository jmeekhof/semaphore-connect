xquery version '1.0-ml';

module namespace l = 'pipeline:layout:html';

declare namespace html = "http://www.w3.org/1999/xhtml";

declare option xdmp:mapping "false";

declare function l:assemble-page($title as xs:string, $content as element()*) as node()* {
  l:assemble-page($title, $content, ())
};

declare function l:assemble-page($title as xs:string, $content as element()*, $head-link as element()*) as node()* {
  xdmp:set-response-content-type("text/html"),
  <html>
    <head>
        <title>{$title}</title>
        {$head-link}
    </head>
    <body role="main">
      <div class="container-fluid">
        {$content}
      </div>
    </body>
  </html>
};

declare function l:assemble-page-default($title as xs:string, $content as element()*) as node()* {
  l:assemble-page($title, (l:header(),$content, l:footer()), l:head())
};

declare function l:head() as element()* {
  (
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous"/>,
    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" integrity="sha384-rHyoN1iRsVXV4nD0JutlnGaslCJuC7uwjduW9SVrLvRYooPp2bWYgmgJQIXwl/Sp" crossorigin="anonymous"/>,
    <link rel="stylesheet" href="/resources/css/app.css" />,
    <script src="http://ajax.googleapis.com/ajax/libs/jquery/3.1.0/jquery.min.js"/>,
    <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js" integrity="sha384-Tc5IQib027qvyjSMfHjOMaLkfuWVxZxUPnCJA7l2mCWNIpG9mGCD8wGNIcPD7Txa" crossorigin="anonymous"/>
  )
};

declare function l:header() as element()* {
  <header id="nav-bar-main" class="header bg-primary nav-bar">
    <div class="navbar-header">
      <a class="navbar-brand animated pulse no-padder m-r" href="/">
        <img class="m-t" alt="Smartlogic" width="80px" src="/resources/images/smartlogic-logo.png"/>
      </a>
    </div>
  </header>
};

declare function l:footer() as element()* {
  <footer class="footer bg-white text-right">
    <p>
      <img style="height: 20px" src="resources/images/ml-logo.gif"/>
    </p>
    <br/>
    <p style="font-size:75%;">Semaphore Connector v<!-- version here, eventually --></p>
  </footer>
};
