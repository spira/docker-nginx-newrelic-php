#!/bin/bash

which supervisord
supervisord -v

echo "Supervisord conf /etc/supervisor/supervisord.conf: "
cat /etc/supervisor/supervisord.conf

supervisord -c /etc/supervisor/supervisord.conf