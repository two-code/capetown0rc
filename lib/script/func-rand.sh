function c0rc_gen_uuid() {
    echo "$(head -c 16 /dev/urandom | xxd -l 16 -p)"
    if [ $? -ne 0]; then
        return 1
    fi

    return 0
}
