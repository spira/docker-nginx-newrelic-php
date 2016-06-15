#!/bin/bash

if [ $XDEBUG_ENABLED = 'true' && $NEWRELIC_ENABLED -ne 'true' ]; then
    echo "XDebug enabled.."
    cat /opt/etc/xdebug.ini >> /usr/local/etc/php/conf.d/xdebug.ini
else
    # turn off xdebug extension altogether - if we have it disabled, let's disable
    echo "Disabling XDebug.."
    mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.disabled

fi


if [ $NEWRELIC_ENABLED = 'true' ]; then
    echo "Enabling New Relic.."
    cat /opt/etc/newrelic.ini > /usr/local/etc/php/conf.d/newrelic.ini
    sed -i -- 's/REPLACE_WITH_REAL_KEY/'${NEWRELIC_KEY}'/g' /usr/local/etc/php/conf.d/newrelic.ini
    sed -i -- 's/REPLACE APPLICATION NAME/'${NEWRELIC_APPNAME}'/g' /usr/local/etc/php/conf.d/newrelic.ini
    sed -i -- 's/;newrelic.enabled/newrelic.enabled/g' /usr/local/etc/php/conf.d/newrelic.ini
    sed -ie -- 's/;newrelic\.framework.*/newrelic.framework='${NEWRELIC_FRAMEWORK}'/g' /usr/local/etc/php/conf.d/newrelic.ini
    # can't have both xdebug and new relic enabled
    if [ -e /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini ]; then
        mv /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini.disabled
    fi
    echo ".. with configuration file:"
    cat /usr/local/etc/php/conf.d/newrelic.ini | grep -e "^newrelic\."
fi

exec php-fpm
