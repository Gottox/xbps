#! /usr/bin/env atf-sh

atf_test_case install_existent

install_existent_head() {
	atf_set "descr" "xbps-install(8): install multiple existent pkgs (issue #53)"
}

install_existent_body() {
	mkdir -p some_repo pkg_A pkg_B
	touch pkg_A/file00
	touch pkg_B/file00
	cd some_repo
	xbps-create -A noarch -n A-1.0_1 -s "A pkg" ../pkg_A
	atf_check_equal $? 0
	xbps-rindex -d -a $PWD/*.xbps
	atf_check_equal $? 0
	xbps-create -A noarch -n B-1.1_1 -s "B pkg" ../pkg_B
	atf_check_equal $? 0
	xbps-rindex -d -a $PWD/*.xbps
	atf_check_equal $? 0
	cd ..
	xbps-install -r root -C empty.conf --repository=$PWD/some_repo -y A
	atf_check_equal $? 0
	xbps-install -r root -C empty.conf --repository=$PWD/some_repo -y A B
	atf_check_equal $? 0

	rm -r root
	xbps-install -r root -C empty.conf --repository=$PWD/some_repo -y A
	atf_check_equal $? 0
	xbps-install -r root -C empty.conf --repository=$PWD/some_repo -y B A
	atf_check_equal $? 0
}

atf_test_case update_pkg_on_hold

update_pkg_on_hold_head() {
	atf_set "descr" "xbps-install(8): update packages on hold (issue #143)"
}

update_pkg_on_hold_body() {
	atf_expect_death "Known bug: see https://github.com/voidlinux/xbps/issues/143"
	mkdir -p some_repo pkginst pkgheld pkgdep-21_1 pkgdep-22_1
	touch pkginst/pi00
	touch pkgheld/ph00
	touch pkgdep-21_1/pd21
	touch pkgdep-22_1/pd22

	cd some_repo

	xbps-create \
		-A noarch \
		-n "pkgdep-21_1" \
		-s "pkgdep" \
		../pkgdep-21_1

	atf_check_equal $? 0

	xbps-create \
		-A noarch \
		-n "pkgdep-22_1" \
		-s "pkgdep" \
		../pkgdep-22_1

	atf_check_equal $? 0

	xbps-create \
		-A noarch \
		-n "pkginst-1.0_1" \
		-s "pkginst" \
		-D "pkgdep-22_1" \
		../pkginst

	atf_check_equal $? 0

	xbps-create \
		-A noarch \
		-n "pkgheld-1.17.4_2" \
		-s "pkgheld" \
		-P "pkgdep-21_1" \
		../pkgheld

	atf_check_equal $? 0

	#ls -laR ../

	xbps-rindex -d -a pkgheld*.xbps
	atf_check_equal $? 0

	xbps-install -r root -C empty.conf --repository=$PWD -y pkgheld
	atf_check_equal $? 0
	xbps-pkgdb -r root -m hold pkgheld

	xbps-rindex -d -a pkginst*.xbps
	atf_check_equal $? 0

	xbps-rindex -d -a pkgdep-22*.xbps
	atf_check_equal $? 0

	xbps-install -r root -C empty.conf --repository=$PWD -d -y pkginst >&2
	atf_check_equal $? 0
}

atf_init_test_cases() {
	atf_add_test_case install_existent
	atf_add_test_case update_pkg_on_hold
}
