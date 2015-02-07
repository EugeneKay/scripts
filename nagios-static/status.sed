# vim: ft=sed 
# nagios-static/status.sed
# EugeneKay/scripts
#
# Sed replacements for nagios status.cgi
#

# Remove nagios comments
s/<!--.*-->//g

# Change path of JS/CSS
s/\/nagios\//\/dynamic\//g

# De-link host/service totals
s/<a class='.*Totals' href='.*'>\(.*\)<\/a>/\1/g

# Remove some infobox stuff
s/^Updated every.*//g
s/^Nagios&reg; Core&trade;.*//g
s/^Logged in as.*//g

# Remove linkbox links
s/<a href='history\.cgi.*//g
s/<a href='notifications.cgi.*//g
s/<br \/><a href='status.cgi.*//g

# Remove Limit box
s/.*limit.*//g
s/^<option.*//g
s/^<\/select><\/div>//g
s/^<div id='top_page_numbers'><\/div>//g

# Remove sort links
s/th><th/th>\n<th/g

# Remove info links
s/<a href='extinfo.cgi?.*'>\(.*\)<\/a>/\1/g

# Convert graph links
s/<a href='\/nagiosgraph\/cgi-bin\/showhost\.cgi?host=\(.*\)' TARGET='main'>/<a href='graph-\1.html'>/g

# Remove count
s/.*itemTotalsTitle.*//g
