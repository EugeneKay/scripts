<!--
# nagios-static/README.md
# EugeneKay/scripts
-->
Nagios Static
-------------

Generate static HTML & PNG resources from dynamic Nagios CGI documents, suitable for serving to the internet without authentication. [Example site](https://status.kashpureff.org/)


Installation
------------

  * checkout repo somewhere web-servable
  * symlink nagios' image/ and stylesheets/ from htdocs into assets/
  * Create a dynamic/ folder which can be written into
  * Modify dynamic.sh' USER variable to suit. Must exist in nagios with CGI read permissions
  * Invoke dynamic.sh via cron. Every 5-15 minutes is suggested
