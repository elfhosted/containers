# /bin/bash
# shellcheck shell=bash

cryptography=openssl
pythonver=python3
python=python3
tag=" static with c++14 march=native"
libtorrent_branch=RC_1_2
pythonmajor=$(apt-cache madison python3 | grep -m1 "python3" | awk '{print $3}' | cut -d- -f 1 | cut -d+ -f 1 | cut -d. -f1-2)
export BOOST_VERSION=1_75_0
export BOOST_ROOT=/opt/boost_${BOOST_VERSION} 
export BOOST_INCLUDEDIR=${BOOST_ROOT}
export BOOST_BUILD_PATH=${BOOST_ROOT}

function _build() {
    cd ${BOOST_ROOT}
    /opt/boost_${BOOST_VERSION}/bootstrap.sh --with-libraries=system

    echo 'using gcc : : : <cflags>"-march=native -std=c++14" <cxxflags>"-march=native -std=c++14" ;' > /root/user-config.jam
    echo "using python : ${pythonmajor} : /usr/bin/${pythonver} : /usr/include/python${pythonmajor} : /usr/lib/python${pythonmajor} ;" >> /root/user-config.jam
    apt-get install -y ${pythonver}-dev libssl-dev
    git clone -b ${libtorrent_branch} https://github.com/arvidn/libtorrent /tmp/libtorrent 
    cd /tmp/libtorrent
    VERSION=$(grep AC_INIT configure.ac | grep -oP '\d+\.\d+\.\d+')
    
    if [[ $1 -ne "" ]]; then
        curl -sL "${1}" -o /libtorrent-${libtorrent_branch}.patch
        patch -p1 < /libtorrent-${libtorrent_branch}.patch
    fi

    sed -i 's|, (arg("seconds") = 0, arg("tracker_idx") = -1, arg("flags") = reannounce_flags_t{}))|, (arg("seconds") = 0, arg("tracker_idx") = -1, arg("flags") = 1))|g' bindings/python/src/torrent_handle.cpp
    cd /tmp/libtorrent/bindings/python || exit 1
    /opt/boost_${BOOST_VERSION}/b2 -j$(nproc) python="${pythonmajor}" crypto="${cryptography}" variant=release libtorrent-link=static boost-link=static install_module python-install-path=/tmp/dist/libtorrent-python/usr/local/lib/python${pythonmajor}/dist-packages
    tag=" static with c++14 march=native"
    mkdir -p /root/dist
    fpm -f -C /tmp/dist/libtorrent-python -p "/root/dist/${python}-libtorrent_${VERSION}.deb" -s dir -t deb -n "${python}-libtorrent" --version "${VERSION}" --description "Libtorrent rasterbar python binding compiled by swizzin$tag"
    cd /tmp || (echo "failed to cd into /tmp" && exit 1)
    dpkg -r python-libtorrent 
    dpkg -r python3-libtorrent 
    dpkg -i "/root/dist/${python}-libtorrent_${VERSION}.deb"
}
