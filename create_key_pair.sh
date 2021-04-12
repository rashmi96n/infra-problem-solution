#!/bin/bash
############################
# Generates the new ssh key pair 
############################



command -v ssh-keygen
if [ $? -ne 0 ]; then
    echo "ssh-keygen not available!"
    exit 1
fi
command -v curl
if [ $? -ne 0 ]; then
    echo "curl not available!"
    exit 1
fi


SSH_UTIL_TMP_DIR=/tmp/ssh_util/
mkdir -p $SSH_UTIL_TMP_DIR || (echo "Unable to create temp dir." && exit 1)

PRIVATE_KEY_FD=$SSH_UTIL_TMP_DIR/keypair.key
PUBLIC_KEY_FD="${PRIVATE_KEY_FD}.pub"

KEY_BITS=8096
KEY_PASSPHRASE=""
KEY_ALGORITHM="rsa"

    echo "=======Creating new ssh key pairs ========"
    rm -vf $PRIVATE_KEY_FD
    ssh-keygen -t $KEY_ALGORITHM -N "$KEY_PASSPHRASE" -b $KEY_BITS -f $PRIVATE_KEY_FD
    retval=$?
    if [ $retval -ne 0 ]; then
        echo "Generating keypair using ssh-keygen failed with code: [$retval] !"
        exit 1
    fi


    if [ ! -s "$PRIVATE_KEY_FD" ]; then
        echo "$PRIVATE_KEY_FD file is non-existing or empty"
        exit 1
    fi

    if [ ! -s "${PRIVATE_KEY_FD}.pub" ]; then
        echo "${PRIVATE_KEY_FD}.pub file is non-existing or empty"
        exit 1
    fi


    if [ ! -s "$PUBLIC_KEY_FD" ]; then
         "Could not parse public key. Task failed."
        exit 1
    fi

export TF_VAR_ssh_public_key=$(base64 -w 0 $PUBLIC_KEY_FD)
#echo "New Encoded Public Key: $TF_VAR_ssh_public_key"
#echo "New Decoded Public Key: "$(echo "$TF_VAR_ssh_public_key" | base64 -d)
