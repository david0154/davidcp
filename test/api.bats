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
    source /tmp/david-api-env.sh
    source $DAVID/func/main.sh
    source $DAVID/conf/david.conf
    source $DAVID/func/ip.sh
}

@test "[Success][ Admin/password ] List users" {
    run curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "user=admin&password=$password&returncode=no&cmd=v-list-users&arg1=plain" "https://$server:$port/api/index.php"
    assert_success
    assert_output --partial "admin"
}

@test "[Success][ Hash ] List users" {
    run curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "hash=$apikey&returncode=no&cmd=v-list-users&arg1=plain" "https://$server:$port/api/index.php"
    assert_success
    assert_output --partial "admin"
}

@test "[Fail][ APIV2 ] Create new user" {
    run curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "hash=$accesskey&returncode=yes&cmd=v-add-user&arg1=davidtest&arg2=strongpassword&arg3=info@davidk.online" "https://$server:$port/api/index.php"
    assert_success
    assert_output --partial "don't have permission to run the command v-add-user"
}

@test "[Success][ Hash ] Create tmp file" {
    run curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "hash=$apikey&cmd=v-make-tmp-file&arg1=strongpassword&arg2=clusterpassword" "https://$server:$port/api/index.php"
    assert_success
    assert_output --partial "OK"
}

@test "[Success][ Hash ] Create new user" {
    run curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "hash=$apikey&cmd=v-add-user&arg1=davidtest&arg2=/tmp/clusterpassword&arg3=info@davidk.online&arg4=default" "https://$server:$port/api/index.php"
    assert_success
    assert_output --partial "OK"
}

@test "[Success][ Hash ] Check password" {
    run curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "hash=$apikey&cmd=v-check-user-password&arg1=davidtest&arg2=strongpassword" "https://$server:$port/api/index.php"
    assert_success
    assert_output --partial "OK"
}


@test "[Success][ Local ] Add user" {
    run v-add-user davidtest 1234BCD info@davidk.online
    assert_success
}

@test "[Success][ Local ] Add DNS domain" {
    run v-add-dns-domain davidtest ilovedavidk.online 127.0.0.1
    assert_success
}

@test "[Success][ APIV2 ] Add remote DNS host" {
    run v-add-remote-dns-host $server $port "$accesskey" '' api 'davidtest'
    assert_success
}

@test "[Success][ APIV2 ] Sync DNS cluster 1" {
    run v-sync-dns-cluster
    assert_success
}

@test "[Success][ Local ] nslookup ilovedavidk.online" {
    run nslookup ilovedavidk.online $server
    assert_success
    assert_output --partial "127.0.0.1"
}

@test "[Success][ Local ] Add DNS domain 2" {
    run v-add-dns-domain davidtest ilovedavidcp.org 127.0.0.1
    assert_success
}

@test "[Success][ Local ] Add DNS record" {
    run v-add-dns-record davidtest ilovedavidcp.org test A 127.0.0.1 yes 20
    assert_success
}

@test "[Success][ Local ] nslookup test.ilovedavidcp.org" {
    run nslookup test.ilovedavidcp.org $server
    assert_failure 1
    assert_output --partial "REFUSED"

    run nslookup test.ilovedavidcp.org localhost
    assert_success
    assert_output --partial "127.0.0.1"
}

@test "[Success][ APIV2 ] Sync DNS cluster 2" {
    run v-sync-dns-cluster
    assert_success

    run nslookup test.ilovedavidcp.org $server
    assert_success
    assert_output --partial "127.0.0.1"
}

@test "[Success][ Local ] Delete DNS record" {
    run v-delete-dns-record davidtest ilovedavidcp.org 20
    assert_success
}

@test "[Success][ Local ] nslookup test.ilovedavidcp.org 2" {
    run nslookup test.ilovedavidcp.org $server
    assert_success
    assert_output --partial "127.0.0.1"

    run nslookup test.ilovedavidcp.org localhost
    assert_failure
}

@test "[Success][ APIV2 ] Sync DNS cluster 3" {
    run v-sync-dns-cluster
    assert_success

    run nslookup test.ilovedavidcp.org $server
    assert_failure
}


@test "[Success][ APIV2 ] Delete remote DNS host" {
    run v-delete-remote-dns-host $server
    assert_success
}


@test "[Success][ Local ] Delete user" {
    run v-delete-user davidtest
    assert_success
}

@test "[Success][ Hash ] Delete user" {
    run curl -k -s -X POST -H "Content-Type: application/x-www-form-urlencoded" -d "hash=$apikey&cmd=v-delete-user&arg1=davidtest" "https://$server:$port/api/index.php"
}
