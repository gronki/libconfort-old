Name:           libminiconf
Version:        170102
Release:        1%{?dist}
Summary:        Mini Config

License:        MIT
URL:            http://github.com/gronki/libminiconf
Source:         libminiconf-%{version}.tar.xz

BuildRequires:  gcc-gfortran
Requires:       glibc libgfortran libquadmath libgcc

%description
A minimalistic utility for reading configuration files. Easy to use Fortran 2008 bindings are included. Compatible with GCC and Intel compilers. (This packages is built for GCC.)

%package        devel
Summary:        Development files for %{name}
Requires:       %{name}%{?_isa} = %{version}-%{release}

%description    devel
The %{name}-devel package contains libraries and header files for
developing applications that use %{name}.

%prep
%autosetup

%build
export OPT_FLAGS="%{optflags} -ftree-vectorize -finline-functions -funroll-loops -mieee-fp"
export CFLAGS="$OPT_FLAGS"
export FFLAGS="$OPT_FLAGS"
make    DESTDIR="%{buildroot}" \
        prefix="%{_prefix}" \
        bindir="%{_bindir}" \
        libdir="%{_libdir}" \
        fmoddir="%{_fmoddir}" \
        includedir="%{_includedir}"

%install
rm -rf %{buildroot}
make install DESTDIR="%{buildroot}" \
        prefix="%{_prefix}" \
        bindir="%{_bindir}" \
        libdir="%{_libdir}" \
        fmoddir="%{_fmoddir}" \
        includedir="%{_includedir}"
find %{buildroot} -name '*.la' -exec rm -f {} ';'

%post
/sbin/ldconfig

%postun
/sbin/ldconfig

%files
%{_libdir}/*.so

%files devel
%{_includedir}/*
%{_fmoddir}/*
%{_libdir}/*.a
%{_libdir}/pkgconfig/*.pc
