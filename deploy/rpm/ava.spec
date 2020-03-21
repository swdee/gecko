Summary: AVALabs Gecko a Golang implementation of an AVA Node
Name: avalabs-gecko 
Version: 0.1
Release: 1
URL: https://github.com/ava-labs/gecko/
Source0: ava
Source1: xputtest
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-buildroot
License: BSD 3-Clause License

%description
AVALabs Gecko a Golang implementation of an AVA Node

%install
%{__mkdir_p} %{buildroot}/usr/bin/
%{__install} -Dp -m0755 %{SOURCE0} %{buildroot}/usr/bin/ava
%{__install} -Dp -m0755 %{SOURCE1} %{buildroot}/usr/bin/xputtest

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root, 0755)
/usr/bin/ava
/usr/bin/xputtest
