См. Инструкцию (Create_Server_Certificate.md)

### Создание сертификата на компьютере клиента.

Оригинальная инструкция [тут](https://github.com/alexec/circleci/tree/effacd30611382c33fd37379c35d35d2bc538c02/etc/certs).

```
cd ~
mkdir -p .docker
cd .docker
echo 01 > ca.srl
openssl genrsa -des3 -out ca-key.pem 2048
```

Вводим пароль для pass-фазы, например **docker** (дважды).

```
openssl req -new -x509 -days 3650 -key ca-key.pem -out ca.pem
```

Вводим пароль (**docker**), заполняем поля:

* Country Name (2 letter code) [AU]:**UA**
* State or Province Name (full name) [Some-State]:**UA**
* Locality Name (eg, city) []:**Dnieprodzerzhinsk**
* Organization Name (eg, company) [Internet Widgits Pty Ltd]:**BadenWork**
* Organizational Unit Name (eg, section) []:**Navicc**
* Common Name (e.g. server FQDN or YOUR name) []:**my.baden.work**
* Email Address []:**baden.i.ua@gmail.com**

В итоге получаем три файла: _ca-key.pem_, _ca.pem_, _ca.srl_.

Можно посмотреть содержимое файла сертификата:

```
openssl x509 -in ca.pem -inform pem -noout -text
```
