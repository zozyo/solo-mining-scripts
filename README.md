## Readme

EN | [中文](./README.cn.md)

#### Get to Ready

-   #### BIOS Setting

    -   Disabled Secure Boot
    -   Boot Mode must be **UEFI**
    -   SGX Setting，must be **Enabled** or **Software Controlled**

-   Run the **egx_enable** if your SGX setting in BIOS is  **Software Controlled**

```bash
sudo chmod +x sgx_enable
sudo ./sgx_enable
sudo reboot
```

#### Install the Phala Scripts

Go to the **Phala** folder

```bash
chmod +x install.sh
sudo ./install.sh
```

#### How to use

##### Install

```bash
sudo phala install
```
Enter information as prompted.

##### Start minner
```bash
sudo phala start
```

##### Stop minner
```bash
sudo phala stop all
```
##### Stop docker separately
```bash
sudo phala stop node
sudo phala stop pruntime
sudo phala stop pherry
```

##### Update Phala Dockers

###### Update Phala dockers without clean data

```bash
sudo phala update
```

###### Update Phala dockers with clean data

```bash
sudo phala update clean
```

###### Now you can auto update the script

```bash
sudo phala update script
```

##### Check the docker status

```bash
sudo phala status
```

##### Get Logs

```bash
sudo phala logs node
sudo phala logs pruntime
sudo phala logs pherry
```

##### Check the config of minner


```bash
sudo phala config show
```
##### Setup the config of minner

```bash
sudo phala config set
```

##### Check the board support
- Use `sudo phala install` command to install all dependencies witout configuration

```bash
sudo phala sgx-test
```
