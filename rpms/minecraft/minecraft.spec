#
# rpms/minecraft/minecraft.spec
# EugeneKay/scripts
#
# Minecraft spec file
#


# Disable JAR rebuilding
%define __jar_repack %{nil}

%global mc_user minecraft
%global mc_data /var/lib/minecraft

Name:		minecraft
Version:	1.8.3
Release:	1%{?dist}
Summary:	Minecraft Server Daemon
Group:		Amusements/Games

License:	Minecraft EULA
URL:		http://minecraft.net
Source0:	https://s3.amazonaws.com/Minecraft.Download/versions/%{version}/minecraft_server.%{version}.jar
Source1:	minecraft.service
Source2:	minecraftctl.sh
Source3:	minecraft.conf

BuildArch: noarch
BuildRequires: systemd-units
Requires: java-headless
Requires(post): systemd-units
Requires(post): systemd-sysv
Requires(preun): systemd-units
Requires(postun): systemd-units

%description
Minecraft is a game about breaking and placing blocks. At first, people built structures to protect against nocturnal monsters, but as the game grew players worked together to create wonderful, imaginative things.

It can also be about adventuring with friends or watching the sun rise over a blocky ocean. It's pretty. Brave players battle terrible things in The Nether, which is more scary than pretty. You can also visit a land of mushrooms if it sounds more like your cup of tea.


%install
mkdir -p %{buildroot}%{_libexecdir}/%{name}
mkdir -p %{buildroot}%{_unitdir}
mkdir -p %{buildroot}%{_sbindir}
mkdir -p %{buildroot}%{_sysconfdir}/sysconfig
mkdir -p %{buildroot}%{_localstatedir}/minecraft
install -m 0644 %{SOURCE0} %{buildroot}%{_libexecdir}/%{name}/minecraft.jar
install -m 0644 %{SOURCE1} %{buildroot}%{_unitdir}/minecraft.service
install -m 0755 %{SOURCE2} %{buildroot}%{_sbindir}/minecraftctl
install -m 0644 %{SOURCE3} %{buildroot}%{_sysconfdir}/sysconfig/minecraft

%pre
getent group %{mc_user} >/dev/null || groupadd -r %[mc_user}
getent passwd %{mc_user} >/dev/null || \
    useradd -r -g %{mc_user} -d /var/lib/minecraft -s /sbin/nologin \
    -c "Account for Minecraft to run as" %{mc_user}
mkdir -p /var/lib/minecraft
chown minecraft:minecraft /var/lib/minecraft


%post
%systemd_post minecraft.service


%postun
%systemd_postun_with_restart minecraft.service


%preun
%systemd_preun minecraft.service


%files
%config %{_sysconfdir}/sysconfig/minecraft
%{_libexecdir}/%{name}/minecraft.jar
%{_unitdir}/minecraft.service
%{_sbindir}/minecraftctl
%dir %attr(0755, %{mc_user}, %{mc_user}) %{_localstatedir}/minecraft


%changelog
* Sun Mar 15 2015 Eugene Kashpureff <eugene@kashpureff.org> - 1.8.3-1
- Initial RPM Package
