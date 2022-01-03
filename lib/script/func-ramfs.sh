function c0rc_gen_ramfs_mnt_point() {
    local uuid=$(c0rc_gen_uuid)
    if [ $? -ne 0 ]; then
        return 1
    fi

    print "/mnt/ramfs_$uuid"

    return 0
}
