xquery version '1.0-ml';

import module namespace c = 'pipeline:connection' at '/connection/connection.xqy';

let $form-post := c:init-form-vars()
let $doc-uri := c:save-configuration($form-post)
return xdmp:redirect-response('/connection/edit.xqy?uri=' || $doc-uri)
