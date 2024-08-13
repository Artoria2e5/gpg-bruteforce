#!/usr/bin/env bash

GPG_KEY=${1+"--default-key $1"}

if gpg $GPG_KEY -n --passphrase NobodyCouldPossiblyHaveThisAsAPassphrase --pinentry-mode loopback --clearsign /dev/null >&/dev/null; then
	echo "$0: No passphrase required, or passphrase is already registered in the gpg-agent."
 	exit -1
fi

while IFS= read -r pass; do
	if [[ $pass ]]; then
		gpg_test=$(gpg "$GPG_KEY" -n --passphrase "$pass" --pinentry-mode loopback --clearsign /dev/null 2>&1)
		ret=$?
		if ((!ret)); then
  			printf "Found ! Passphrase: %q\\n" "$pass"
     			break
		fi
		if [[ ! $gpg_test =~ "Bad passphrase" ]]; then
  			printf %s\\n "$gpg_test"
     			exit $ret
		fi
	fi
done

if ((ret)); then
	echo "Not found :("
 	exit -2
fi
