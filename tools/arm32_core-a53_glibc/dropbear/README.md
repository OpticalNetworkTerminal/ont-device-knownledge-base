# 安装说明

## 创建文件夹

```bash
mkdir -p /usr/bin /usr/sbin
```

## 安装真实二进制

```bash
mv dropbearmulti /usr/bin/dropbearmulti
chmod +x /usr/bin/dropbearmulti
```

# SSH 服务端命令

```bash
cd /usr/bin
ln -sfn dropbearmulti /usr/sbin/dropbear
```

# SSH 客户端及工具

```bash
ln -sfn dropbearmulti /usr/bin/dbclient
ln -sfn dropbearmulti /usr/bin/dropbearkey
ln -sfn dropbearmulti /usr/bin/dropbearconvert
ln -sfn dropbearmulti /usr/bin/scp
```

# 可选兼容命令

```bash
ln -sfn dropbearmulti /usr/bin/ssh
ln -sfn dropbearmulti /usr/bin/ssh-keygen
```

# sftp-server

```bash
```