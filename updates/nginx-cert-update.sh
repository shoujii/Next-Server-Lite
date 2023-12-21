update_nginx_cert() {

source /root/NeXt-Server-Lite/configs/sources.cfg

systemctl -q stop nginx.service

#cleanup old cert / key, maybe backup until success?
rm -R /root/.acme.sh/${MYDOMAIN}_ecc/
rm /etc/nginx/ssl/${MYDOMAIN}-ecc.cer
rm /etc/nginx/ssl/${MYDOMAIN}-ecc.key

#delete old keys
sed -i 's/HPKP1="'${HPKP1}'"/HPKP1="1"/' /root/NeXt-Server-Lite/configs/userconfig.cfg
sed -i 's/HPKP2="'${HPKP2}'"/HPKP2="2"/' /root/NeXt-Server-Lite/configs/userconfig.cfg
sed -i "s/"${HPKP1}"/HPKP1/g" /etc/nginx/security.conf
sed -i "s/"${HPKP2}"/HPKP2/g" /etc/nginx/security.conf

cd /root/NeXt-Server-Lite/sources/acme.sh/
bash acme.sh --set-default-ca --server letsencrypt 
bash acme.sh --issue --standalone --debug 2 --log -d ${MYDOMAIN} -d www.${MYDOMAIN} --keylength ec-384 

ln -s /root/.acme.sh/${MYDOMAIN}_ecc/fullchain.cer /etc/nginx/ssl/${MYDOMAIN}-ecc.cer 
ln -s /root/.acme.sh/${MYDOMAIN}_ecc/${MYDOMAIN}.key /etc/nginx/ssl/${MYDOMAIN}-ecc.key 

HPKP1=$(openssl x509 -pubkey < /etc/nginx/ssl/${MYDOMAIN}-ecc.cer | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64) 
HPKP2=$(openssl rand -base64 32) 

#SED doesn't work when the HPKP contains "/", so we escape it
HPKP1=$(echo "$HPKP1" | sed 's/\//\\\//g')
HPKP2=$(echo "$HPKP2" | sed 's/\//\\\//g')

sed_replace_word "HPKP1" "${HPKP1}" "/etc/nginx/security.conf"
sed_replace_word "HPKP2" "${HPKP2}" "/etc/nginx/security.conf"

sed -i 's/HPKP1="1"/HPKP1="'${HPKP1}'"/' /root/NeXt-Server-Lite/configs/userconfig.cfg
sed -i 's/HPKP2="2"/HPKP2="'${HPKP2}'"/' /root/NeXt-Server-Lite/configs/userconfig.cfg

systemctl -q start nginx.service
}