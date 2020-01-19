%global provider_dir %{_libdir}/cmpi

Name:           sblim-cmpi-nfsv4
Summary:        SBLIM nfsv4 instrumentation
Version:        1.1.0
Release:        8%{?dist}
License:        EPL
Group:          Applications/System
URL:            http://sourceforge.net/projects/sblim/
Source0:        http://downloads.sourceforge.net/project/sblim/providers/%{name}/%{version}/%{name}-%{version}.tar.bz2

# Patch0: use Pegasus root/interop instead of root/PG_Interop
Patch0:         sblim-cmpi-nfsv4-1.1.0-pegasus-interop.patch

BuildRequires:  sblim-cmpi-base-devel sblim-cmpi-devel
Requires:       sblim-cmpi-base cim-server cim-schema
Requires:       /etc/ld.so.conf.d
Requires(post): /sbin/ldconfig
Requires(postun): /sbin/ldconfig

%description
Standards Based Linux Instrumentation Nfsv4 Providers

%package devel
# ^- currently a placeholder - no devel files shipped
Summary:        SBLIM Nfsv4 Instrumentation Header Development Files
Group:          Development/Libraries
Requires:       %{name} = %{version}-%{release}

%description devel
SBLIM Base Nfsv4 Development Package

%package test
Summary:        SBLIM Nfsv4 Instrumentation Testcases
Group:          Applications/System
Requires:       %{name} = %{version}-%{release}
Requires:       sblim-testsuite

%description test
SBLIM Base Fsvol Testcase Files for SBLIM Testsuite

%prep
%setup -q
%patch0 -p1 -b .pegasus-interop

%build
%ifarch s390 s390x ppc ppc64
export CFLAGS="$RPM_OPT_FLAGS -fsigned-char"
%else
export CFLAGS="$RPM_OPT_FLAGS" 
%endif
%configure \
        --disable-static \
        TESTSUITEDIR=%{_datadir}/sblim-testsuite \
        PROVIDERDIR=%{provider_dir}
sed -i 's|^hardcode_libdir_flag_spec=.*|hardcode_libdir_flag_spec=""|g' libtool
sed -i 's|^runpath_var=LD_RUN_PATH|runpath_var=DIE_RPATH_DIE|g' libtool
make

%install
make install DESTDIR=$RPM_BUILD_ROOT
# remove unused libtool files
rm -f $RPM_BUILD_ROOT/%{_libdir}/*.la
rm -f $RPM_BUILD_ROOT/%{provider_dir}/*.la
# shared libraries
mkdir -p $RPM_BUILD_ROOT/%{_sysconfdir}/ld.so.conf.d
echo "%{_libdir}/cmpi" > $RPM_BUILD_ROOT/%{_sysconfdir}/ld.so.conf.d/%{name}-%{_arch}.conf
mv $RPM_BUILD_ROOT/%{_libdir}/libLinux_NFSv4SystemConfigurationUtil.so $RPM_BUILD_ROOT/%{provider_dir}

%files
%dir %{provider_dir}
%{provider_dir}/*.so
%{_datadir}/%{name}
%docdir %{_datadir}/doc/%{name}-%{version}
%{_datadir}/doc/%{name}-%{version}
%config(noreplace) %{_sysconfdir}/ld.so.conf.d/%{name}-%{_arch}.conf

%files test
%{_datadir}/sblim-testsuite

%global PEGASUS_MOF CIM_SystemSetting,CIM_NFS,CIM_SystemConfiguration,CIM_SystemSettingContext

%pre
# If upgrading, deregister old version
if [ $1 -gt 1 ]; then
  %{_datadir}/%{name}/provider-register.sh -d \
    -r %{_datadir}/%{name}/*.registration \
    -m %{_datadir}/%{name}/*.mof \
    > /dev/null 2>&1 || :;
fi

%post
/sbin/ldconfig
# tog-pegasus needs some schemes registered first  
if [ -x /usr/bin/peg-loadmof.sh ]; then
   peg-loadmof.sh -n root/cimv2 /usr/share/mof/cim-current/*/{%{PEGASUS_MOF}}.mof > /dev/null 2>&1 || :;
   /sbin/service tog-pegasus try-restart > /dev/null 2>&1 || :;
fi
if [ $1 -ge 1 ]; then
# Register Schema and Provider - this is higly provider specific
  %{_datadir}/%{name}/provider-register.sh \
    -r %{_datadir}/%{name}/*.registration \
    -m %{_datadir}/%{name}/*.mof \
    > /dev/null 2>&1 || :;
fi;

%preun
# Deregister only if not upgrading 
if [ $1 -eq 0 ]; then
  %{_datadir}/%{name}/provider-register.sh -d \
    -r %{_datadir}/%{name}/*.registration \
    -m %{_datadir}/%{name}/*.mof \
    > /dev/null 2>&1 || :;
fi

%postun -p /sbin/ldconfig

%changelog
* Wed Aug 14 2013 Vitezslav Crhonek <vcrhonek@redhat.com> - 1.1.0-8
- Use Pegasus root/interop instead of root/PG_Interop

* Thu Feb 14 2013 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.0-7
- Rebuilt for https://fedoraproject.org/wiki/Fedora_19_Mass_Rebuild

* Wed Nov 07 2012 Vitezslav Crhonek <vcrhonek@redhat.com> - 1.1.0-6
- Fix Source0 URL

* Wed Sep 05 2012 Vitezslav Crhonek <vcrhonek@redhat.com> - 1.1.0-5
- Fix issues found by fedora-review utility in the spec file

* Sat Jul 21 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.0-4
- Rebuilt for https://fedoraproject.org/wiki/Fedora_18_Mass_Rebuild

* Sat Jan 14 2012 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.0-3
- Rebuilt for https://fedoraproject.org/wiki/Fedora_17_Mass_Rebuild

* Wed Feb 09 2011 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 1.1.0-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_15_Mass_Rebuild

* Wed Oct  6 2010 Vitezslav Crhonek <vcrhonek@redhat.com> - 1.1.0-1
- Update to sblim-cmpi-nfsv4-1.1.0
- Remove CIMOM dependencies

* Wed Oct 14 2009 Vitezslav Crhonek <vcrhonek@redhat.com> - 1.0.12-1
- Initial support
