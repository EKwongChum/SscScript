# 生成自签名证书脚本

## Run

执行 ***ssc_gen.sh*** 文件即可：

   ```bash
   bash ssc_gen.sh
   ```

## 说明

### 文件

执行脚本后，会生成以下文件

```bash
-rw-r--r--  1 ekwong  staff   1.9K  1 24 14:21 ca.crt
-rw-r--r--  1 ekwong  staff   3.2K  1 24 14:21 ca.key
-rw-r--r--  1 ekwong  staff    17B  1 24 14:21 ca.srl
-rw-r--r--  1 ekwong  staff   2.2K  1 24 14:21 example.com.crt
-rw-r--r--  1 ekwong  staff   1.7K  1 24 14:21 example.com.csr
-rw-r--r--  1 ekwong  staff   3.2K  1 24 14:21 example.com.key
-rw-r--r--  1 ekwong  staff   267B  1 24 14:21 v3.ext
```

这里着重关注四个文件：

```bash
# 证书颁布机构的证书
ca.crt
# 证书颁布机构的私钥
ca.key

# 服务器证书
example.com.crt
# 服务器证书私钥
example.com.key
```

### 使用方法

以 nginx 配置作为 web 服务器，Windows 机器作为 client 为例。

#### server

请把 ***example.com.crt*** 和 ***example.com.key*** 上传到服务器，并配置修改 nginx.conf ：

```nginx
http{
  ...
    server{
        listen    443 ssl;
        ssl_certificate  /home/ca/example.com.crt;
        ssl_certificate_key /home/ca/example.com.key;
        ...
  }
  ...
}
```

请重启 nginx 服务：

```bash
nginx -s reload
```

#### client

请把 ***ca.crt*** 放到 Windows 机器上，并添加为受信任的证书。


## 自定义

若需自定义证书颁布机构域名、服务器域名、过期时间等信息，请修改 ***custom.cf*** 文件，请把 ***custom.cf*** 文件和 ***ssc_gen.sh*** 文件放在同一目录下。

```bash
ca_numbits=4096
ca_c=CN
ca_st=Beijing
ca_l=Beijing
ca_o=Ca
ca_ou=Personal
ca_cn=self.ca.org
ca_days=3650

svr_numbits=4096
svr_domain=example.com
svr_c=CN
svr_st=Beijing
svr_l=Beijing
svr_o=Example
svr_ou=Personal
svr_days=3650
svr_host=localhost.domain

```

