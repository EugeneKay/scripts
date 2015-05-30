# vim: ft=sed 
# nagios-static/status.sed
# EugeneKay/scripts
#
# Sed replacements for nagios status.cgi
#

# Remove nagios comments
s/<!--.*-->//g

# Remove javascript
/script/d
/function()/d

# Change assets path
s/\/nagios\//\/assets\//g

# Center headertable
/headertable/ s/>$/style="margin: 0 auto;">/g

# De-link host/service totals
s/<a class='.*Totals' href='.*'>\(.*\)<\/a>/\1/g

# Remove some infobox stuff
/Updated every/d
/Nagios&reg; Core&trade;/d
/^Logged in as.*/d

# Remove linkbox links
/<a href='history\.cgi.*/d
/<a href='notifications.cgi.*/d
/<br \/><a href='status.cgi.*/d

# Replace title with map
s/Service Status Details For All Hosts/<img src="dynamic\/map.png" alt="Host status map">/g

# Remove Limit box
/limit'/d
/<option.*/d
/<\/select><\/div>/d
/<div id='top_page_numbers'><\/div>/d

# Split table header
s/th><th/th>\n<th/g

# Convert graph links
s/<a href='\/nagiosgraph\/cgi-bin\/showhost\.cgi?host=\(.*\)' TARGET='main'><IMG/<a href='dynamic\/graph-\1.html'><img/g
s/Perform Extra Host Actions/View Host Graphs/g

# Remove host links
s/<a href='extinfo\.cgi.*<IMG.*<a href='dynamic/<a href='dynamic/g
s/<a href='extinfo\.cgi.*<IMG SRC='\(.*\)'.*<\/a>/<img src='\1'>/g
s/<a href='extinfo\.cgi.*'>\(.*\)<\/a>/\1/g

# Remove count
s/.*itemTotalsTitle.*//g

# Insert footer link
/<\/body>/ s/^/<div id="footer" style="text-align:center">Produced by <a href="https:\/\/madeitwor.se\/scripts\/tree\/master\/nagios-static">nagios-static<\/a>\n/g

#Insert meta-refresh
s/<head>/<head>\n<meta http-equiv="refresh" content="300">/g
