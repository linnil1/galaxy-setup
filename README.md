# Setup GALAXY server
I tested on Ubuntu 20.04.

## Configuation
I assume you hava two external space
`/data` and `/datahdd`(for large files)

Find `password` and fill your own password in below files
* `docker-compose.yml`
* `galaxy.yml`
* `proftpd.conf`(ftp)

You can change your admin account in `galaxy.yml`
Note: It's static, you cannot change the admin on the fly.
```
  admin_users: c4lab@c4lab.ntu.edu.tw, linnil1@ntu.edu.tw
```
and email setting
```
  smtp_server: smtps.ntu.edu.tw:465
  smtp_username: linnil1
  smtp_password: "password"
  smtp_ssl: true
```

Add your certification in this folder
(This certification also use in nginx, proftpd,
see `nginx.conf` and `protfpd.conf` for more detail)
```
certs/
├── fullchain.pem
└── privkey.pem
```

Change `galaxy.yml` to mention your user that they can upload files via ftp by the url
```
  ftp_upload_site: 140.112.x.x:21
```
and `proftpd.conf`
```
PassivePorts 21000 21009
MasqueradeAddress	140.112.x.x
```

I run galaxy on only one computer, change the slots number to indicate the number of cpu your machine have.
see more in  https://docs.galaxyproject.org/en/latest/admin/jobs.html.
```
    <param id="local_slots">4</param>
```

## Install
```
git clone https://github.com/linnil1/galaxy-setup.git
cd galaxy-setup
bash install.sh
```

## Run

Main program
```
cd galaxy
sh run.sh --skip-venv
cd ..
```

After main program start, you can add user
```
. galaxy/.venv/bin/activate
python3 create_galaxy_user.py -c galaxy/config/galaxy.yml --user c4lab@c4lab.ntu.edu.tw --password password
deactivate
```

Run related program
* proftpd
* postgres
* rabbitmq
* nginx
```
docker-compose up -d
```


After build it, we can start with uwsgi for quicker starting.

```
cd galaxy
uwsgi --yaml /home/ubuntu/galaxy/config/galaxy.yml --static-safe /home/ubuntu/galaxy/client/src/assets
cd ..
```

In addition, you can use systemd to handle galaxy service by providing the `.service` file.
```
ln -s galaxy.service /etc/systemd/system/
sudo systemctl enable galaxy
sudo systemctl start galaxy

# restart when needed
sudo systemctl restart galaxy
```
