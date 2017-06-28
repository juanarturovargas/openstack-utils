#!/bin/bash

#****************************************************************************
#   Script que permite borrar la base de datos de ceilometer y
#   recrear la base de datos
#   Una ves que la base de datos es recreada, el script reinicia los
#   servicios de cinder en los controladores de openstack
#   El script es ejecutado de forma automatica por el cron del sistema desde la maquina virtual
#	donde esta instalao mongodb
#   Autor: Juan Arturo Vargas Torres
#   Fecha: 28-06-2017
#   Version 1.0
#*****************************************************************************

#Parametros:
# $1 indica el tipo de instalacion
# $2 indica si es standalone o cluster

#Ejemplo de ejecucion: ./ceilometer_db_recreate.sh --install-type standalone

#Variables Globales.
OPENSTACK_CEILOMETER_N01="192.168.92.36"
OPENSTACK_CEILOMETER_N02="192.168.92.36"
SO_USER="root"

# Validación de parametros.
OK_PARAMETERS="KO"
case $1 in
"--install-type")
	case $2 in
	standalone)
		OK_PARAMETERS="OK"
	esac
esac

if [ OK_PARAMETERS=="OK" ]
then
	echo "EL tipo de instalación es Stand Alone"
else
	echo "Los parametros de ejecución son incorrectos"
	exit 0
fi

# Borrar la base de datos de mongodb
mongo --eval "db.dropDatabase();"

#Detener el servicio de mongodb
service mongod stop

# Remover los archivos de datos de la base de mongo del disco
rm -f /var/lib/mongodb/ceilometer.*

# Iniciar el servicio de mongodb
service mongod start

# Recrear la base de ceilometer
mongo --host controller --eval '
db = db.getSiblingDB("ceilometer");
db.addUser({user: "ceilometer",
            pwd: "58344qdqo83h53",
            roles: [ "readWrite", "dbAdmin" ]})'

# Reiniciar los servicios del nodo 1 de ceilometer
ssh $SO_USER@$OPENSTACK_CEILOMETER_N01 -p 65535 'service openstack-ceilometer-api restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N01 -p 65535 'service openstack-ceilometer-notification restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N01 -p 65535 'service openstack-ceilometer-central restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N01 -p 65535 'service openstack-ceilometer-collector restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N01 -p 65535 'service openstack-ceilometer-alarm-evaluator restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N01 -p 65535 'service openstack-ceilometer-alarm-notifier restart'

# Reiniciar los servicios del nodo 2 de ceilometer
ssh $SO_USER@$OPENSTACK_CEILOMETER_N02 -p 65535 'service openstack-ceilometer-api restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N02 -p 65535 'service openstack-ceilometer-notification restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N02 -p 65535 'service openstack-ceilometer-central restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N02 -p 65535 'service openstack-ceilometer-collector restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N02 -p 65535 'service openstack-ceilometer-alarm-evaluator restart'
ssh $SO_USER@$OPENSTACK_CEILOMETER_N02 -p 65535 'service openstack-ceilometer-alarm-notifier restart'

            













