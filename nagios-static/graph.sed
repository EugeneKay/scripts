# vim: ft=sed 
# nagios-static/graph.sed
# EugeneKay/scripts
#
# Sed replacements for nagiosgraph showhost.cgi
#

# Remove unused scripting
#/script/d
/menudata/d
/js_disabled/d
/js_version/d
/script/d
/\]\]$/d
/\];/d

# Remove graph box
/<div class="controls">/,/<h1>Nagiosgraph/d

# Repoint assets
s/\/nagiosgraph\///g

# Remove host link
s/<a href="\/nagios\/cgi-bin\/extinfo.cgi.*">\(.*\)<\/a>/\1/g

# Remove period controls
#s/<button.*<\/button>//g
s/<span class="period_controls.*/<\/span><\/div>/g

# Remove service links
s/<p class="graph_title"><a href=".*">\(.*\)<\/a><\/p>/<p class="graph_title">\1<\/p>/g

# Repoint graphs
s/src=".*host=\(.*\)&service=\([a-zA-Z0-9\-]*\)&db=.*snow-\(.*\)%20-enow-0"/src="graph-\1-\2-\3.png"/g

# Remove footer
/footer/d


