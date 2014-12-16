Name: dnetc
Version: 2.9111.520
Release: 1%{?dist}
Summary: distributed.net project client
BuildArch: x86_64
Group:	
License: Distributed.net License
URL: http://distributed.net
Source: http://http.distributed.net/pub/dcti/current-client/dnetc-linux-amd64.tar.gz

%description

distributed.net project client

%prep
%setup -q


%build


%install
install -m 0755 -d $RPM_BUILD_ROOT/etc/init.d
install -m 0755 init/dnetc $RPM_BUILD_ROOT/etc/init.d/dnetc
install -m 0755 -d $RPM_BUILD_ROOT/opt/dnetc
install -m 0755 dnetc $RPM_BUILD_ROOT/opt/dnetc/dnetc
install -m 0755 dnetc.1 $RPM_BUILD_ROOT/opt/dnetc/dnetc.1


%clean
rm -rf $RPM_BUILD_ROOT


%files
/etc/init.d/dnetc
%dir /opt/dnetc
/opt/dnetc/dnetc
/opt/dnetc/dnetc.1


%changelog
* Sat Nov 14 2014 Eugene E. Kashpureff Jr <eugene@kashpureff.org>
- First RPM package for EL7
