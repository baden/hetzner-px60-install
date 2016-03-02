### Создание сертификата на сервере.

Я пока плохо понимаю принцип работы сертификатов. Буду тыкать пока не заработает.

Есть [официальная инструкция](https://docs.docker.com/engine/security/https/), буду шпарить по ней.

```
mkdir -p /etc/docker/certs
cd /etc/docker/certs
```

#### Генерируем CA приватный и публичные ключи.

```
openssl genrsa -aes256 -out ca-key.pem 4096
```

Вводим пароль (дважды). На время экспериментов это **docker**.

```
openssl req -new -x509 -days 365 -key ca-key.pem -sha256 -out ca.pem
```

Заполняем поля:

* Country Name (2 letter code) [AU]:**UA**
* State or Province Name (full name) [Some-State]:**UA**
* Locality Name (eg, city) []:**Dnieprodzerzhinsk**
* Organization Name (eg, company) [Internet Widgits Pty Ltd]:**BadenWork**
* Organizational Unit Name (eg, section) []:**Navicc**
* Common Name (e.g. server FQDN or YOUR name) []:**my.baden.work**
* Email Address []:**baden.i.ua@gmail.com**

Можно посмотреть (перепроверить) содержимое файла сертификата:

```
openssl x509 -in ca.pem -inform pem -noout -text
```


Теперь, когда у нас есть CA, мы создадим ""запрос на сервер ключей и сертификат подписи" (CSR). Важно! чтобы "Common Name" (FQDN) совпадало с именем хоста, который будет использоваться для подключения к докеру:

```
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=my.baden.work" -sha256 -new -key server-key.pem -out server.csr
```

Примечание! Тут возможно при CN=* можно было бы обеспечить доступ по любому имени FQDN, может поиграюсь позже.

Теперь подпишем публичный ключ нашим CA.
Если нужен доступ через IP-адрес, то можно прописать явно:

```
echo subjectAltName = IP:10.10.10.20,IP:127.0.0.1 > extfile.cnf
```

Подписываем:

```
openssl x509 -req -days 365 -sha256 -in server.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out server-cert.pem -extfile extfile.cnf
```

Вводим пароль для нашего CA-файла (**docker**)

Вроде все. Теперь создаем ключ для клиента и запрос для подписи.
```
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=client' -new -key key.pem -out client.csr
```

Для того, чтобы ключ подходил для проверки подлинности клиента, нужно создать конфигурационный файл расширений:

```
echo extendedKeyUsage = clientAuth > extfile.cnf
```

Подписываем публичный ключ:

```
openssl x509 -req -days 365 -sha256 -in client.csr -CA ca.pem -CAkey ca-key.pem \
  -CAcreateserial -out cert.pem -extfile extfile.cnf
```

Вводим пароль от CA-файла (**docker**)

После создания cert.pem и server-cert.pem, можно удалить файлы запросов подписи:

```
rm -v client.csr server.csr
```

Защитим файлы ключей от чтения:

```
chmod -v 0400 ca-key.pem key.pem server-key.pem
```

Файлы сертификатов должны быть доступны для чтения, но недоступны для (случайной) записи:

```
chmod -v 0444 ca.pem server-cert.pem cert.pem
```

Теперь подправим файл /etc/default/docker, довавим

DOCKER_OPTS="$DOCKER_OPTS -D -H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock --tlsverify --tlscacert=/etc/docker/certs/ca.pem --tlscert=/etc/docker/certs/server-cert.pem --tlskey=/etc/docker/certs/server-key.pem --label provider=hetzner"


На стороне клиента, нужно скопировать файлы ca.pem, cert.pem, key.pem в папку ~/.docker/


```
mkdir -p ~/.docker
cd ~/.docker
scp baden@my.baden.work:~/.docker/* .
```

И проверить работу

```
docker --tlsverify -H=my.baden.work:2375 version
```

Чтобы не указывать постоянно дополнительные ключи, можно задать переменные:

DOCKER_HOST=my.baden.work:2375
DOCKER_TLS_VERIFY=1

Предварительно проверить работу можно:

```
DOCKER_HOST=my.baden.work:2375 DOCKER_TLS_VERIFY=1 docker info
```

Чтобы задать альтернативный путь к файлам сертификата: DOCKER_CERT_PATH=
