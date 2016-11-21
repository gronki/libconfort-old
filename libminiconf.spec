Name:           libminiconf
Version:        %{_version}
Release:        1%{?dist}
Summary:        Mini Config

License:        MIT
URL:            http://github.com/gronki/libminiconf
Source:         libminiconf-%{version}.tar.xz

BuildRequires:  gcc gcc-gfortran
Requires:       gcc gcc-gfortran

%description
A minimalistic utility for reading configuration files. Easy to use Fortran 2008 bindings are included. Compatible with GCC and Intel compilers. (This packages is built for GCC.)

%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%prep
%autosetup -n libminiconf

%build
make DESTDIR=$RPM_BUILD_ROOT \
        prefix="/usr" \
        bindir="%{_bindir}"  \
        libdir="%{_libdir}"  \
        includedir="%{_includedir}"

%install
rm -rf $RPM_BUILD_ROOT
make install DESTDIR=$RPM_BUILD_ROOT \
        prefix="/usr" \
        bindir="%{_bindir}"  \
        libdir="%{_libdir}"  \
        includedir="%{_includedir}"
find $RPM_BUILD_ROOT -name '*.la' -exec rm -f {} ';'

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%files
%{_libdir}/*.so

%files devel
%{_includedir}/miniconf/*
#%{_libdir}/*.so
%{_libdir}/*.a
%{_libdir}/pkgconfig/*.pc
