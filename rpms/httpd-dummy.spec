#
# rpms/httpd-dummy.spec
# eugenekay/scripts
#
# Dummy RPM spec for httpd
#
Summary: httpd dummy package
Name: httpd-dummy
Version: 1
Release: 3
License: WTFPLv2+
Packager: Eugene E. Kashpureff Jr <eugene@kashpureff.org>
Provides: httpd
Conflicts: httpd

BuildArch: noarch

%description
This is a dummy package to prevent Apache httpd and friends from installing.

%files

%changelog
* Sun Nov 2 2014 Eugene E. Kashpureff Jr <eugene@kashpureff.org>
- Initial package


