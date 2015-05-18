# Generated from rtasklib-0.2.1.gem by gem2rpm -*- rpm-spec -*-
%define rbname rtasklib
%define version 0.2.1
%define release 1

Summary: A Ruby wrapper around the TaskWarrior CLI
Name: ruby-gems-%{rbname}

Version: %{version}
Release: %{release}
Group: Development/Ruby
License: MIT
URL: http://github.com/dropofwill/rtasklib
Source0: %{rbname}-%{version}.gem
# Make sure the spec template is included in the SRPM
Source1: ruby-gems-%{rbname}.spec.in
BuildRoot: %{_tmppath}/%{name}-%{version}-root
Requires: ruby >= 2
Requires: ruby-gems >= 2
Requires: ruby-gems-virtus 
Requires: ruby-gems-activesupport 
Requires: ruby-gems-activemodel 
Requires: ruby-gems-active_model_serializers 
Requires: ruby-gems-oj 
Requires: ruby-gems-multi_json 
Requires: ruby-gems-iso8601 
Requires: ruby-gems-bundler => 1.8
Requires: ruby-gems-bundler < 2
Requires: ruby-gems-rake => 10.0
Requires: ruby-gems-rake < 11
Requires: ruby-gems-coveralls 
Requires: ruby-gems-rspec 
Requires: ruby-gems-rspec-nc 
Requires: ruby-gems-guard 
Requires: ruby-gems-guard-rspec 
Requires: ruby-gems-yard 
BuildRequires: ruby >= 2
BuildRequires: ruby-gems >= 2
BuildArch: noarch
Provides: ruby(Rtasklib) = %{version}

%define gemdir /usr/share/gems
%define gembuilddir %{buildroot}%{gemdir}

%description
A Ruby wrapper around the TaskWarrior CLI. Requires a TaskWarrior install
version 2.4.0 of greater.


%prep
%setup -T -c

%build

%install
%{__rm} -rf %{buildroot}
mkdir -p %{gembuilddir}
gem install --local --install-dir %{gembuilddir} --force %{SOURCE0}

%clean
%{__rm} -rf %{buildroot}

%files
%defattr(-, root, root)
%{gemdir}/gems/rtasklib-0.2.1/

%doc %{gemdir}/doc/rtasklib-0.2.1
%{gemdir}/cache/rtasklib-0.2.1.gem
%{gemdir}/specifications/rtasklib-0.2.1.gemspec

%changelog
