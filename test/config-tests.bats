#!/usr/bin/env bats

if [ "${PATH#*/usr/local/david/bin*}" = "$PATH" ]; then
    . /etc/profile.d/david.sh
fi

load 'test_helper/bats-support/load'
load 'test_helper/bats-assert/load'
load 'test_helper/bats-file/load'

function random() {
head /dev/urandom | tr -dc 0-9 | head -c$1
}

function setup() {
    # echo "# Setup_file" > &3
    if [ $BATS_TEST_NUMBER = 1 ]; then
        echo 'user=test-5285' > /tmp/david-test-env.sh
        echo 'user2=test-5286' >> /tmp/david-test-env.sh
        echo 'userbk=testbk-5285' >> /tmp/david-test-env.sh
        echo 'userpass1=test-5285' >> /tmp/david-test-env.sh
        echo 'userpass2=t3st-p4ssw0rd' >> /tmp/david-test-env.sh
        echo 'DAVID=/usr/local/david' >> /tmp/david-test-env.sh
        echo 'domain=test-5285.davidk.online' >> /tmp/david-test-env.sh
        echo 'domainuk=test-5285.davidk.online.uk' >> /tmp/david-test-env.sh
        echo 'rootdomain=testdavidk.online' >> /tmp/david-test-env.sh
        echo 'subdomain=cdn.testdavidk.online' >> /tmp/david-test-env.sh
        echo 'database=test-5285_database' >> /tmp/david-test-env.sh
        echo 'dbuser=test-5285_dbuser' >> /tmp/david-test-env.sh
    fi

    source /tmp/david-test-env.sh
    source $DAVID/func/main.sh
    source $DAVID/conf/david.conf
    source $DAVID/func/ip.sh
}

@test "Setup Test domain" {
    run v-add-user $user $user $user@davidk.online default "Super Test"
    assert_success
    refute_output

    run v-add-web-domain $user 'testdavidk.online'
    assert_success
    refute_output

    ssl=$(v-generate-ssl-cert "testdavidk.online" "info@testdavidk.online" US CA "Orange County" davidcp IT "mail.$domain" | tail -n1 | awk '{print $2}')
    mv $ssl/testdavidk.online.crt /tmp/testdavidk.online.crt
    mv $ssl/testdavidk.online.key /tmp/testdavidk.online.key

    # Use self signed certificates during last test
    run v-add-web-domain-ssl $user testdavidk.online /tmp
    assert_success
    refute_output
}

@test "Web Config test" {
    for template in $(v-list-web-templates plain); do
        run v-change-web-domain-tpl $user testdavidk.online $template
        assert_success
        refute_output
    done
}

@test "Proxy Config test" {
    if [ "$PROXY_SYSTEM" = "nginx" ]; then
        for template in $(v-list-proxy-templates plain); do
            run v-change-web-domain-proxy-tpl $user testdavidk.online $template
            assert_success
            refute_output
        done
    else
        skip "Proxy not installed"
    fi
}

@test "Clean up" {
    run v-delete-user $user
    assert_success
    refute_output
}
