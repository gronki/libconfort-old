Name:           libminiconf
Version:        604.27
Release:        1%{?dist}
Summary:        Mini Config

License:        GPL v2
URL:            https://github.com/gronki/libminiconf
Source0:        https://github.com/gronki/libminiconf/archive/master.tar.gz

BuildRequires:  gcc gcc-gfortran
Requires:       gcc gcc-gfortran

%description
Minimalistic config utility with Fortran bindings.

%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.


%prep
%autosetup -n libminiconf-master


%build
make %{?_smp_mflags} prefix="/usr" bindir="%{_bindir}"  libdir="%{_libdir}"  includedir="%{_includedir}"


%install
rm -rf $RPM_BUILD_ROOT
%make_install prefix="/usr" bindir="%{_bindir}"  libdir="%{_libdir}"  includedir="%{_includedir}"
find $RPM_BUILD_ROOT -name '*.la' -exec rm -f {} ';'

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%files
%{_libdir}/*.so.*

%files devel
%{_includedir}/*
%{_libdir}/*.so.*
%{_libdir}/*.a
%{_libdir}/pkgconfig/*.pc


%changelog
* Tue Apr 26 2016 Dominik Gronkiewicz
- created RPM package
