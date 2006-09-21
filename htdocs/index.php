<?php
require_once("always.php");
require_once("RSCDSSession.php");
$session->LoginRequired();

require_once("interactive-page.php");
include("page-header.php");

  echo <<<EOBODY
<h1>These are the admin pages...</h1>
<p>You appear to be logged on as $session->username ($session->fullname)</p>
<p>Useful links:
<ul>
<li><a href="/help.php">Help on configuring CalDAV clients with RSCDS</a></li>
</ul>
</p>
EOBODY;

include("page-footer.php");
?>