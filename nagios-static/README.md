<!--
# nagios-static/README.md
# EugeneKay/scripts
-->
Nagios Static
-------------

Generate static HTML & PNG resources from dynamic Nagios CGI documents, suitable for serving to the internet without authentication.


Installation
------------

  * Put index.html somewhere web-servable
  * Create a dynamic/ folder which can be written into
  * Modify dynamic.sh' USER variable to suit. Must exist in nagios with CGI read permissions
  * Invoke dynamic.sh via cron. Every 5-15 minutes is suggested.
