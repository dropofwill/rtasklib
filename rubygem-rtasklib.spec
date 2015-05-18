# Generated from rtasklib-0.2.3.gem by gem2rpm -*- rpm-spec -*-
%global gem_name rtasklib

Name: rubygem-%{gem_name}
Version: 0.2.3
Release: 1%{?dist}
Summary: A Ruby wrapper around the TaskWarrior CLI
Group: Development/Languages
License: MIT
URL: http://github.com/dropofwill/rtasklib
Source0: https://rubygems.org/gems/%{gem_name}-%{version}.gem
Requires: ruby(release)
Requires: ruby(rubygems) 
Requires: task > 2.4
# Requires: rubygem(multi_json) => 1.7
# Requires: rubygem(multi_json) < 2
# Requires: rubygem(virtus) => 1.0
# Requires: rubygem(virtus) < 2
# Requires: rubygem(iso8601) => 0.8
# Requires: rubygem(iso8601) < 1
BuildRequires: ruby(release)
BuildRequires: rubygems-devel 
BuildRequires: ruby >= 2.0
# BuildRequires: rubygem(coveralls) 
# BuildRequires: rubygem(rspec) 
# BuildRequires: rubygem(rspec-nc) 
# BuildRequires: rubygem(guard) 
# BuildRequires: rubygem(guard-rspec) 
# BuildRequires: rubygem(yard) 
BuildArch: noarch
Provides: rubygem(%{gem_name}) = %{version}

%description
A Ruby wrapper around the TaskWarrior CLI. Requires a TaskWarrior install
version 2.4.0 of greater.

%pre
gem install virtus --version '>= 1.0'
gem install iso8601 --version '>= 0.8'
gem install multi_json --version '>= 1.11'

%package doc
Summary: Documentation for %{name}
Group: Documentation
Requires: %{name} = %{version}-%{release}
BuildArch: noarch

%description doc
Documentation for %{name}.

%prep
gem unpack %{SOURCE0}

%setup -q -D -T -n  %{gem_name}-%{version}

gem spec %{SOURCE0} -l --ruby > %{gem_name}.gemspec

%build
# Create the gem as gem install only works on a gem file
gem build %{gem_name}.gemspec

# %%gem_install compiles any C extensions and installs the gem into ./%%gem_dir
# by default, so that we can move it into the buildroot in %%install
%gem_install

%install
mkdir -p %{buildroot}%{gem_dir}
cp -a .%{gem_dir}/* \
        %{buildroot}%{gem_dir}/


# Run the test suite
%check
pushd .%{gem_instdir}

popd

%files
%dir %{gem_instdir}
%{gem_libdir}
%exclude %{gem_cache}
%{gem_spec}
%exclude %{gem_instdir}/.*
%exclude %{gem_instdir}/*.spec
%exclude %{gem_instdir}/*.spec.template

%files doc
%doc %{gem_docdir}
%doc %{gem_instdir}/LICENSE.txt
%doc %{gem_instdir}/*.md
%{gem_instdir}/Gemfile
%{gem_instdir}/Guardfile
%{gem_instdir}/Rakefile
%{gem_instdir}/%{gem_name}.gemspec
%{gem_instdir}/spec/
%{gem_instdir}/bin/

%changelog
* Mon May 18 2015 Will Paul - 0.2.3-1
- Initial package
