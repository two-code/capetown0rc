function c0rc_gen_uuid() {
    print "$(head -c 16 /dev/urandom | xxd -l 16 -p -c 16)"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}

function c0rc_gen_hex32bit() {
    print "$(head -c 4 /dev/urandom | xxd -l 4 -p -c 4)"
    if [ $? -ne 0 ]; then
        return 1
    fi

    return 0
}
