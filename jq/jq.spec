Name: jq
Version: 1.5
Release: 1.xyz%{?dist}
Summary:        Command-line JSON processor

License:        MIT and ASL 2.0 and CC-BY and GPLv3
Group: Development/Tools
BuildRoot: %{_tmppath}/%{name}-%{version}-root
URL:            http://stedolan.github.io/jq/
Source0:        https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64
Source1:        https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux32

%description
lightweight and flexible command-line JSON processor

 jq is like sed for JSON data â€“ you can use it to slice
 and filter and map and transform structured data with
 the same ease that sed, awk, grep and friends let you
 play with text.

 It is written in portable C, and it has zero runtime
 dependencies.

 jq can mangle the data format that you have into the
 one that you want with very little effort, and the
 program to do so is often shorter and simpler than
 you'd expect.


%prep
%ifarch x86_64
cp %{_topdir}/SOURCES/%{name}-linux64 .
%endif

%ifarch %{ix86}
cp %{_topdir}/SOURCES/%{name}-linux32 .
%endif

%build
ls -l

%install
rm -rf $RPM_BUILD_ROOT
install -m 0755 -d $RPM_BUILD_ROOT/usr/local/bin
%ifarch x86_64
cp %{name}-linux64 $RPM_BUILD_ROOT/usr/local/bin/jq
%endif

%ifarch %{ix86}
cp %{name}-linux32 $RPM_BUILD_ROOT/usr/local/bin/jq
%endif

%files
%defattr(755,root,root)
/usr/local/bin/%{name}

%changelog
* Wed Apr 27 2016 Dan Tian <dantian@gmail.com> - 1.5
- Skip compile
- Download the executable and release it to /usr/local/bin/jq

* Sun Jun 08 2014 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.3-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_21_Mass_Rebuild

* Thu Oct 24 2013 Flavio Percoco <flavio@redhat.com> - 1.3-2
- Added check, manpage

* Fri Oct 18 2013 Flavio Percoco <flavio@redhat.com> - 1.3-1
- Initial package release.


