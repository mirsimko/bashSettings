#/bin/bash

pushd ~ >> /dev/null
curl http://beyondgrep.com/ack-2.14-single-file > ~/bin/ack && chmod 0755 !#:3
popd >> /dev/null
