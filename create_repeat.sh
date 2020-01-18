#!/bin/bash

function help(){
echo "-d|--domain \"set your domain\" "
echo "-n|--number \"set number of account you want to create\" "
echo "example"
echo "$./create_repeat.sh -d imsdomain.com -n 1000"
}

if [ $# -ne 4 ]
then
help
exit 1
fi

while [ $# -ne 0 ]
do
	case $1 in
	  -d)
	  DOMAIN=$2
	  shift
	  ;;
	  --domain)
	  DOMAIN=$2
	  shift
	  ;;
	  -n)
	  NUMBER=$2
	  shift
	  ;;
	  --number)
	  NUMBER=$2
	  shift
	  ;;
	  -h)
	  help
	  exit 1
	  ;;
	  --help)
	  help
	  exit 1
	  ;;
	  *)
	  help
	  exit 1
	  ;;
	esac
	shift
done



rm clients.csv create.sql

echo "SEQUENTIAL" >> ./clients.csv
echo "use hss_db;" >> ./create.sql
echo "delete from imsu where name like 'test%';" >> ./create.sql
echo "DELETE FROM impi WHERE id_imsu not in (select id from imsu);" >> ./create.sql
echo "DELETE FROM impi_impu WHERE id_impi not in (select id from impi);" >> ./create.sql
echo "DELETE FROM impi_impu WHERE id_impu not in (select id from impu);" >> ./create.sql
echo "DELETE FROM impu WHERE id not in (select id_impu from impi_impu);" >> ./create.sql
echo "DELETE FROM impu_visited_network WHERE id_impu not in (select id from impu);" >> ./create.sql
echo "SET autocommit=0;" >> ./create.sql




i=1

while [ $NUMBER -ge $i ]
do
echo "Creating $i / $NUMBER accounts"
echo "test$i;$DOMAIN;[authentication username=test$i password=test$i];test;orig;scscf-1.imsdomain.com:6060" >> ./clients.csv
echo "START TRANSACTION;" >> ./create.sql
echo "insert into imsu (name, id_capabilities_set, id_preferred_scscf_set, scscf_name, diameter_name) values ('test$i', 1, 1, 'sip:scscf-1.$DOMAIN:6060', 'scscf-1.$DOMAIN.lo');" >> ./create.sql
echo "set @imsu_id=last_insert_id();" >> ./create.sql
echo "INSERT INTO impi (id_imsu, identity, k, auth_scheme, default_auth_scheme, amf, op, sqn, ip, line_identifier, zh_uicc_type, zh_key_life_time, zh_default_auth_scheme) VALUES (@imsu_id, 'test$i@$DOMAIN', 'test$i' , 255, 4, '', '', '000000000000', '', '', 0, 3600, 1);" >>  create.sql
echo "set @impi1_id=last_insert_id();" >>  create.sql
echo "INSERT INTO impu (identity, type, barring, user_state, id_sp, id_implicit_set, id_charging_info, wildcard_psi, display_name, psi_activation, can_register) VALUES('sip:test$i@$DOMAIN', 0, 0, 1, 1, 0, 1, '', '', 0, 1);" >>  create.sql
echo "set @impu1_id=last_insert_id();" >>  create.sql
echo "INSERT INTO impu_visited_network (id_impu, id_visited_network) SELECT @impu1_id, id FROM visited_network;" >>  create.sql
echo "update impu set id_implicit_set=@impu1_id where id=@impu1_id;" >>  create.sql
echo "INSERT INTO impi_impu (id_impi, id_impu) VALUES(@impi1_id, @impu1_id);" >>  create.sql
echo "COMMIT;" >>  create.sql
i=`expr $i + 1`
done
