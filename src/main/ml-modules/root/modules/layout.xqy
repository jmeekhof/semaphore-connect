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
